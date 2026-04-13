import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import '../models/story.dart';
import '../models/profile.dart';
import '../models/favorite.dart';

/// Singleton managing all local SQLite operations.
/// SQLite is the absolute source of truth — the UI always reads from here.
class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, 'storybook.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // ---------- profiles ----------
    await db.execute('''
      CREATE TABLE profiles (
        id TEXT PRIMARY KEY,
        username TEXT,
        avatar_url TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        is_synced INTEGER NOT NULL DEFAULT 0
      )
    ''');

    // ---------- stories ----------
    await db.execute('''
      CREATE TABLE stories (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        title TEXT NOT NULL,
        description TEXT,
        cover_image_url TEXT,
        genre TEXT,
        status TEXT NOT NULL DEFAULT 'draft',
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        deleted_at TEXT,
        is_synced INTEGER NOT NULL DEFAULT 0,
        is_dirty INTEGER NOT NULL DEFAULT 1,
        FOREIGN KEY (user_id) REFERENCES profiles(id)
      )
    ''');

    // ---------- story_pages ----------
    await db.execute('''
      CREATE TABLE story_pages (
        id TEXT PRIMARY KEY,
        story_id TEXT NOT NULL,
        page_number INTEGER NOT NULL,
        title TEXT,
        content TEXT NOT NULL DEFAULT '',
        audio_url TEXT,
        background_color TEXT,
        image_url TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        deleted_at TEXT,
        is_synced INTEGER NOT NULL DEFAULT 0,
        is_dirty INTEGER NOT NULL DEFAULT 1,
        FOREIGN KEY (story_id) REFERENCES stories(id)
      )
    ''');

    // ---------- favorites ----------
    await db.execute('''
      CREATE TABLE favorites (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        story_id TEXT NOT NULL,
        created_at TEXT NOT NULL,
        deleted_at TEXT,
        is_synced INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (user_id) REFERENCES profiles(id),
        FOREIGN KEY (story_id) REFERENCES stories(id)
      )
    ''');

    // ---------- sync_queue (local only) ----------
    await db.execute('''
      CREATE TABLE sync_queue (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        table_name TEXT NOT NULL,
        record_id TEXT NOT NULL,
        operation TEXT NOT NULL,
        payload TEXT NOT NULL,
        created_at TEXT NOT NULL,
        status TEXT NOT NULL DEFAULT 'pending',
        retry_count INTEGER NOT NULL DEFAULT 0
      )
    ''');

    // Indexes for common queries
    await db.execute(
        'CREATE INDEX idx_stories_user ON stories(user_id)');
    await db.execute(
        'CREATE INDEX idx_story_pages_story ON story_pages(story_id)');
    await db.execute(
        'CREATE INDEX idx_favorites_user ON favorites(user_id)');
    await db.execute(
        'CREATE INDEX idx_favorites_story ON favorites(story_id)');
    await db.execute(
        'CREATE INDEX idx_sync_queue_status ON sync_queue(status)');
  }

  // ─────────────────────── PROFILES ───────────────────────

  Future<int> insertProfile(Profile profile) async {
    final db = await database;
    return db.insert('profiles', profile.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<Profile?> getProfile(String id) async {
    final db = await database;
    final maps = await db.query('profiles', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return Profile.fromMap(maps.first);
  }

  Future<int> updateProfile(Profile profile) async {
    final db = await database;
    return db.update('profiles', profile.toMap(),
        where: 'id = ?', whereArgs: [profile.id]);
  }

  // ─────────────────────── STORIES ───────────────────────

  Future<int> insertStory(Story story) async {
    final db = await database;
    return db.insert('stories', story.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Story>> getStories(String userId) async {
    final db = await database;
    final maps = await db.query(
      'stories',
      where: 'user_id = ? AND deleted_at IS NULL',
      whereArgs: [userId],
      orderBy: 'updated_at DESC',
    );

    final stories = <Story>[];
    for (final map in maps) {
      final storyId = map['id'] as String;
      final pageCount = await getPageCount(storyId);
      final isFav = await isFavorite(userId, storyId);
      stories.add(Story.fromMap(map, pageCount: pageCount, isFavorite: isFav));
    }
    return stories;
  }

  Future<Story?> getStory(String id, String userId) async {
    final db = await database;
    final maps = await db.query('stories', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    final pageCount = await getPageCount(id);
    final isFav = await isFavorite(userId, id);
    return Story.fromMap(maps.first, pageCount: pageCount, isFavorite: isFav);
  }

  Future<int> updateStory(Story story) async {
    final db = await database;
    return db.update('stories', story.toMap(),
        where: 'id = ?', whereArgs: [story.id]);
  }

  Future<int> softDeleteStory(String id) async {
    final db = await database;
    final now = DateTime.now().toIso8601String();
    return db.update(
      'stories',
      {'deleted_at': now, 'is_dirty': 1, 'updated_at': now},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Search stories by title.
  Future<List<Story>> searchStories(String userId, String query) async {
    final db = await database;
    final maps = await db.query(
      'stories',
      where: 'user_id = ? AND deleted_at IS NULL AND title LIKE ?',
      whereArgs: [userId, '%$query%'],
      orderBy: 'updated_at DESC',
    );

    final stories = <Story>[];
    for (final map in maps) {
      final storyId = map['id'] as String;
      final pageCount = await getPageCount(storyId);
      final isFav = await isFavorite(userId, storyId);
      stories.add(Story.fromMap(map, pageCount: pageCount, isFavorite: isFav));
    }
    return stories;
  }

  /// Count all non-deleted stories for a user.
  Future<int> getStoryCount(String userId) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM stories WHERE user_id = ? AND deleted_at IS NULL',
      [userId],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// Sum of all words across all non-deleted story pages for a user.
  Future<int> getTotalWordCount(String userId) async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT SUM(LENGTH(sp.content) - LENGTH(REPLACE(sp.content, ' ', '')) + 1) as words
      FROM story_pages sp
      INNER JOIN stories s ON sp.story_id = s.id
      WHERE s.user_id = ? AND s.deleted_at IS NULL AND sp.deleted_at IS NULL
        AND sp.content != ''
    ''', [userId]);
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // ─────────────────────── STORY PAGES ───────────────────────

  Future<int> insertStoryPage(StoryPage page) async {
    final db = await database;
    return db.insert('story_pages', page.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<StoryPage>> getStoryPages(String storyId) async {
    final db = await database;
    final maps = await db.query(
      'story_pages',
      where: 'story_id = ? AND deleted_at IS NULL',
      whereArgs: [storyId],
      orderBy: 'page_number ASC',
    );
    return maps.map((m) => StoryPage.fromMap(m)).toList();
  }

  Future<StoryPage?> getStoryPage(String id) async {
    final db = await database;
    final maps =
        await db.query('story_pages', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return StoryPage.fromMap(maps.first);
  }

  Future<int> updateStoryPage(StoryPage page) async {
    final db = await database;
    return db.update('story_pages', page.toMap(),
        where: 'id = ?', whereArgs: [page.id]);
  }

  Future<int> softDeleteStoryPage(String id) async {
    final db = await database;
    final now = DateTime.now().toIso8601String();
    return db.update(
      'story_pages',
      {'deleted_at': now, 'is_dirty': 1, 'updated_at': now},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> getPageCount(String storyId) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM story_pages WHERE story_id = ? AND deleted_at IS NULL',
      [storyId],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// Next available page number for a story.
  Future<int> getNextPageNumber(String storyId) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT MAX(page_number) as max_page FROM story_pages WHERE story_id = ? AND deleted_at IS NULL',
      [storyId],
    );
    final maxPage = Sqflite.firstIntValue(result) ?? 0;
    return maxPage + 1;
  }

  // ─────────────────────── FAVORITES ───────────────────────

  Future<int> insertFavorite(Favorite favorite) async {
    final db = await database;
    return db.insert('favorites', favorite.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<bool> isFavorite(String userId, String storyId) async {
    final db = await database;
    final result = await db.query(
      'favorites',
      where: 'user_id = ? AND story_id = ? AND deleted_at IS NULL',
      whereArgs: [userId, storyId],
    );
    return result.isNotEmpty;
  }

  /// Get the active favorite record (for soft-delete toggling).
  Future<Favorite?> getActiveFavorite(String userId, String storyId) async {
    final db = await database;
    final result = await db.query(
      'favorites',
      where: 'user_id = ? AND story_id = ? AND deleted_at IS NULL',
      whereArgs: [userId, storyId],
    );
    if (result.isEmpty) return null;
    return Favorite.fromMap(result.first);
  }

  Future<int> softDeleteFavorite(String id) async {
    final db = await database;
    final now = DateTime.now().toIso8601String();
    return db.update(
      'favorites',
      {'deleted_at': now, 'is_synced': 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Get all favorited stories for a user (JOIN).
  Future<List<Story>> getFavoriteStories(String userId) async {
    final db = await database;
    final maps = await db.rawQuery('''
      SELECT s.* FROM stories s
      INNER JOIN favorites f ON s.id = f.story_id
      WHERE f.user_id = ? AND f.deleted_at IS NULL AND s.deleted_at IS NULL
      ORDER BY f.created_at DESC
    ''', [userId]);

    final stories = <Story>[];
    for (final map in maps) {
      final storyId = map['id'] as String;
      final pageCount = await getPageCount(storyId);
      stories.add(Story.fromMap(map, pageCount: pageCount, isFavorite: true));
    }
    return stories;
  }

  /// Count favorites for a user.
  Future<int> getFavoriteCount(String userId) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM favorites WHERE user_id = ? AND deleted_at IS NULL',
      [userId],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // ─────────────────────── SYNC QUEUE ───────────────────────

  Future<int> enqueueSyncOperation({
    required String tableName,
    required String recordId,
    required String operation,
    required Map<String, dynamic> payload,
  }) async {
    final db = await database;
    return db.insert('sync_queue', {
      'table_name': tableName,
      'record_id': recordId,
      'operation': operation,
      'payload': jsonEncode(payload),
      'created_at': DateTime.now().toIso8601String(),
      'status': 'pending',
      'retry_count': 0,
    });
  }

  /// Dequeue the next pending operation (FIFO by id).
  Future<Map<String, dynamic>?> dequeueSyncOperation() async {
    final db = await database;
    final result = await db.query(
      'sync_queue',
      where: 'status = ?',
      whereArgs: ['pending'],
      orderBy: 'id ASC',
      limit: 1,
    );
    if (result.isEmpty) return null;
    return result.first;
  }

  Future<int> updateSyncQueueStatus(int id, String status,
      {int? retryCount}) async {
    final db = await database;
    final updates = <String, dynamic>{'status': status};
    if (retryCount != null) updates['retry_count'] = retryCount;
    return db.update('sync_queue', updates,
        where: 'id = ?', whereArgs: [id]);
  }

  /// Remove completed sync operations.
  Future<int> clearCompletedSyncOps() async {
    final db = await database;
    return db.delete('sync_queue', where: 'status = ?', whereArgs: ['done']);
  }

  /// Check if there are pending sync operations.
  Future<bool> hasPendingSyncOps() async {
    final db = await database;
    final result = await db.rawQuery(
      "SELECT COUNT(*) as count FROM sync_queue WHERE status IN ('pending', 'processing')",
    );
    return (Sqflite.firstIntValue(result) ?? 0) > 0;
  }

  // ─────────────────────── SYNC HELPERS ───────────────────────

  Future<void> markSynced(String tableName, String id) async {
    final db = await database;
    final updates = <String, dynamic>{'is_synced': 1};
    if (tableName != 'favorites') {
      updates['is_dirty'] = 0;
    }
    await db.update(tableName, updates, where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Map<String, dynamic>>> getUnsyncedRecords(
      String tableName) async {
    final db = await database;
    return db.query(tableName, where: 'is_synced = 0');
  }

  Future<List<Map<String, dynamic>>> getDirtyRecords(String tableName) async {
    final db = await database;
    return db.query(tableName, where: 'is_dirty = 1');
  }

  /// Get the latest updated_at timestamp for synced records in a table.
  Future<String?> getLatestSyncedTimestamp(String tableName) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT MAX(updated_at) as latest FROM $tableName WHERE is_synced = 1',
    );
    if (result.isEmpty) return null;
    return result.first['latest'] as String?;
  }

  // ─────────────────────── SEED DATA ───────────────────────

  /// Seeds the database with mock data on first launch.
  Future<void> seedIfEmpty(String userId) async {
    final count = await getStoryCount(userId);
    if (count > 0) return; // Already has data

    // Ensure a local profile exists
    final existingProfile = await getProfile(userId);
    if (existingProfile == null) {
      await insertProfile(Profile(
        id: userId,
        username: 'Writer',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ));
    }

    final seeds = mockStories;
    for (final story in seeds) {
      final seededStory = story.copyWith(userId: userId);
      await insertStory(seededStory);

      // Create a default first page for each seeded story
      await insertStoryPage(StoryPage(
        id: '${seededStory.id}-page-1',
        storyId: seededStory.id,
        pageNumber: 1,
        content: 'Once upon a time...',
        createdAt: seededStory.createdAt,
        updatedAt: seededStory.updatedAt,
      ));

      // Seed favorites for stories that were marked favorite in mock.
      if (story.isFavorite) {
        await insertFavorite(Favorite(
          id: 'fav-${seededStory.id}',
          userId: userId,
          storyId: seededStory.id,
          createdAt: seededStory.createdAt,
        ));
      }
    }
  }

  /// Close the database (for testing or cleanup).
  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }
}
