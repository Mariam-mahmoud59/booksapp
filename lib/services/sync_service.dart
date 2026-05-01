import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'database_helper.dart';
import 'supabase_service.dart';
import 'connectivity_service.dart';

/// Core sync engine implementing strict offline-first rules:
///
/// 1. SQLite is absolute truth
/// 2. Locked sequential sync queue (FIFO by id)
/// 3. Push-then-Pull flow
/// 4. Soft deletes propagated
/// 5. Conditional pull: only update local if remote.updated_at > local.updated_at
///    AND local.is_synced == true (never overwrite unsynced local changes)
class SyncService {
  static final SyncService _instance = SyncService._internal();
  factory SyncService() => _instance;
  SyncService._internal();

  final DatabaseHelper _db = DatabaseHelper();
  final SupabaseService _supabase = SupabaseService();
  final ConnectivityService _connectivity = ConnectivityService();

  bool _isSyncing = false;
  bool get isSyncing => _isSyncing;

  static const int _maxRetries = 3;

  /// Tables that participate in sync (order matters: profiles first).
  static const List<String> _syncTables = [
    'profiles',
    'stories',
    'story_pages',
    'favorites',
  ];

  /// Initialize the sync service.
  /// Hooks into connectivity changes to auto-sync on reconnect.
  void initialize() {
    _connectivity.onReconnect = () {
      debugPrint('[SyncService] Network reconnected — triggering sync');
      syncAll();
    };
  }

  /// Full sync cycle: push local changes, then pull remote updates.
  Future<void> syncAll() async {
    if (_isSyncing) {
      debugPrint('[SyncService] Sync already in progress, skipping');
      return;
    }
    if (!_connectivity.isOnline) {
      debugPrint('[SyncService] Offline — skipping sync');
      return;
    }
    if (!_supabase.isAuthenticated) {
      debugPrint('[SyncService] Not authenticated — skipping sync');
      return;
    }

    _isSyncing = true;
    try {
      debugPrint('[SyncService] ═══ Starting sync cycle ═══');
      await _pushLocalChanges();
      await _pullRemoteChanges();
      await _db.clearCompletedSyncOps();
      debugPrint('[SyncService] ═══ Sync cycle complete ═══');
    } catch (e) {
      debugPrint('[SyncService] Sync cycle error: $e');
    } finally {
      _isSyncing = false;
    }
  }

  // ─────────────────── PUSH ───────────────────

  /// Process the local sync queue sequentially (one operation at a time).
  Future<void> _pushLocalChanges() async {
    while (true) {
      final op = await _db.dequeueSyncOperation();
      if (op == null) break; // Queue is empty

      final id = op['id'] as int;
      final tableName = op['table_name'] as String;
      final recordId = op['record_id'] as String;
      final operation = op['operation'] as String;
      final payload =
          jsonDecode(op['payload'] as String) as Map<String, dynamic>;
      final retryCount = op['retry_count'] as int;

      // Mark as processing
      await _db.updateSyncQueueStatus(id, 'processing');

      try {
        switch (operation) {
          case 'INSERT':
          case 'UPDATE':
            await _supabase.upsertRow(tableName, payload);
            break;
          case 'DELETE':
            // Soft delete — push the deleted_at timestamp
            final deletedAt = payload['deleted_at'] as String?;
            if (deletedAt != null) {
              await _supabase.softDeleteRow(tableName, recordId, deletedAt);
            }
            break;
        }

        // Success: mark done and update local record
        await _db.updateSyncQueueStatus(id, 'done');
        await _db.markSynced(tableName, recordId);
        debugPrint('[SyncService] Pushed $operation on $tableName/$recordId ✓');
      } catch (e) {
        debugPrint('[SyncService] Push failed for $tableName/$recordId: $e');
        if (retryCount + 1 >= _maxRetries) {
          await _db.updateSyncQueueStatus(id, 'failed',
              retryCount: retryCount + 1);
          debugPrint(
              '[SyncService] Giving up on $tableName/$recordId after $_maxRetries retries');
        } else {
          // Reset to pending with incremented retry count
          await _db.updateSyncQueueStatus(id, 'pending',
              retryCount: retryCount + 1);
        }
      }
    }
  }

  // ─────────────────── PULL ───────────────────

  /// Pull remote changes for all tables.
  /// Only overwrites local data if is_synced == true (local wins if dirty).
  Future<void> _pullRemoteChanges() async {
    final userId = _supabase.currentUserId;
    if (userId == null) return;

    for (final table in _syncTables) {
      try {
        await _pullTable(table, userId);
      } catch (e) {
        debugPrint('[SyncService] Pull failed for $table: $e');
      }
    }
  }

  Future<void> _pullTable(String table, String userId) async {
    // Get the latest updated_at from synced local records
    final latestTimestamp = await _db.getLatestSyncedTimestamp(table);
    final after =
        latestTimestamp != null ? DateTime.parse(latestTimestamp) : null;

    // Fetch remote rows newer than our latest
    List<Map<String, dynamic>> remoteRows;
    if (table == 'profiles') {
      // Profile is fetched by user id directly
      remoteRows = await _supabase.fetchRowsAfter(table, after);
      // Filter to only this user's profile
      remoteRows = remoteRows.where((r) => r['id'] == userId).toList();
    } else if (table == 'favorites') {
      remoteRows = await _supabase.fetchFavoritesAfter(userId, after);
    } else {
      remoteRows = await _supabase.fetchUserRowsAfter(table, userId, after);
    }

    if (remoteRows.isEmpty) return;

    debugPrint('[SyncService] Pulling ${remoteRows.length} rows for $table');

    final db = await _db.database;

    for (final remoteRow in remoteRows) {
      final recordId = remoteRow['id'] as String;

      // Check if local record exists
      final localRows =
          await db.query(table, where: 'id = ?', whereArgs: [recordId]);

      if (localRows.isEmpty) {
        // No local copy — insert from remote
        final insertData = Map<String, dynamic>.from(remoteRow);
        insertData['is_synced'] = 1;
        if (table != 'favorites' && table != 'profiles') {
          insertData['is_dirty'] = 0;
        }
        await db.insert(table, insertData);
        debugPrint('[SyncService] Inserted remote row $table/$recordId');
      } else {
        // Local copy exists — only update if local is_synced AND not dirty
        final localRow = localRows.first;
        final localIsSynced = (localRow['is_synced'] as int?) == 1;
        final localIsDirty = table != 'favorites' && table != 'profiles'
            ? (localRow['is_dirty'] as int?) == 1
            : false;

        if (localIsSynced && !localIsDirty) {
          // Safe to overwrite with remote data
          final updateData = Map<String, dynamic>.from(remoteRow);
          updateData['is_synced'] = 1;
          if (table != 'favorites' && table != 'profiles') {
            updateData['is_dirty'] = 0;
          }
          await db.update(table, updateData,
              where: 'id = ?', whereArgs: [recordId]);
          debugPrint(
              '[SyncService] Updated local from remote $table/$recordId');
        } else {
          // Local has unsynced changes — DO NOT overwrite (local wins)
          debugPrint(
              '[SyncService] Skipping $table/$recordId — local changes pending');
        }
      }
    }
  }
}
