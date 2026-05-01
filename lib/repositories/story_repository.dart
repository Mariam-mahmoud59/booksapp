import 'package:uuid/uuid.dart';
import '../models/story.dart';
import '../models/profile.dart';
import '../models/favorite.dart';
import '../services/database_helper.dart';
import '../services/sync_service.dart';
import '../services/supabase_service.dart';

/// Single interface between UI and data layer.
/// Screens call the repository — never DatabaseHelper or SyncService directly.
///
/// Every mutation writes to SQLite first (instant), enqueues a sync operation,
/// then optionally triggers a background sync.
class StoryRepository {
  static final StoryRepository _instance = StoryRepository._internal();
  factory StoryRepository() => _instance;
  StoryRepository._internal();

  final DatabaseHelper _db = DatabaseHelper();
  final SyncService _syncService = SyncService();
  final SupabaseService _supabase = SupabaseService();
  final Uuid _uuid = const Uuid();

  /// The current user ID. Falls back to 'local-user' for offline-only usage.
  String get _userId => _supabase.currentUserId ?? 'local-user';

  // ─────────────────────── PROFILE ───────────────────────

  Future<Profile?> getProfile() async {
    return _db.getProfile(_userId);
  }

  Future<void> updateProfile({String? username, String? avatarUrl, String? bio}) async {
    final existing = await _db.getProfile(_userId);
    if (existing == null) return;

    final updated = existing.copyWith(
      username: username ?? existing.username,
      avatarUrl: avatarUrl ?? existing.avatarUrl,
      bio: bio ?? existing.bio,
      updatedAt: DateTime.now(),
      isSynced: false,
    );
    await _db.updateProfile(updated);
    await _db.enqueueSyncOperation(
      tableName: 'profiles',
      recordId: updated.id,
      operation: 'UPDATE',
      payload: updated.toSupabaseMap(),
    );
    _syncService.syncAll();
  }

  // ─────────────────────── STORIES ───────────────────────

  Future<List<Story>> getAllStories() async {
    return _db.getStories(_userId);
  }

  Future<Story?> getStory(String id) async {
    return _db.getStory(id, _userId);
  }

  Future<List<Story>> searchStories(String query) async {
    return _db.searchStories(_userId, query);
  }

  Future<Story> createStory({
    required String title,
    String? description,
    String? genre,
  }) async {
    final now = DateTime.now();
    final id = _uuid.v4();

    final story = Story(
      id: id,
      userId: _userId,
      title: title,
      description: description,
      genre: genre,
      status: 'draft',
      createdAt: now,
      updatedAt: now,
      isSynced: false,
      isDirty: true,
    );

    await _db.insertStory(story);

    // Create a default first page
    final page = StoryPage(
      id: _uuid.v4(),
      storyId: id,
      pageNumber: 1,
      content: '',
      createdAt: now,
      updatedAt: now,
    );
    await _db.insertStoryPage(page);

    // Enqueue sync
    await _db.enqueueSyncOperation(
      tableName: 'stories',
      recordId: id,
      operation: 'INSERT',
      payload: story.toSupabaseMap(),
    );
    await _db.enqueueSyncOperation(
      tableName: 'story_pages',
      recordId: page.id,
      operation: 'INSERT',
      payload: page.toSupabaseMap(),
    );

    _syncService.syncAll();

    // Return the story with computed fields
    return story.copyWith(pageCount: 1);
  }

  Future<void> updateStory(Story story) async {
    final updated = story.copyWith(
      updatedAt: DateTime.now(),
      isDirty: true,
      isSynced: false,
    );
    await _db.updateStory(updated);
    await _db.enqueueSyncOperation(
      tableName: 'stories',
      recordId: updated.id,
      operation: 'UPDATE',
      payload: updated.toSupabaseMap(),
    );
    _syncService.syncAll();
  }

  Future<void> deleteStory(String id) async {
    await _db.softDeleteStory(id);

    // Also soft-delete all pages for this story
    final pages = await _db.getStoryPages(id);
    for (final page in pages) {
      await _db.softDeleteStoryPage(page.id);
      await _db.enqueueSyncOperation(
        tableName: 'story_pages',
        recordId: page.id,
        operation: 'DELETE',
        payload: {
          'id': page.id,
          'deleted_at': DateTime.now().toIso8601String()
        },
      );
    }

    final story = await _db.getStory(id, _userId);
    await _db.enqueueSyncOperation(
      tableName: 'stories',
      recordId: id,
      operation: 'DELETE',
      payload: {
        'id': id,
        'deleted_at': story?.deletedAt?.toIso8601String() ??
            DateTime.now().toIso8601String()
      },
    );
    _syncService.syncAll();
  }

  // ─────────────────────── STORY PAGES ───────────────────────

  Future<List<StoryPage>> getStoryPages(String storyId) async {
    return _db.getStoryPages(storyId);
  }

  Future<StoryPage> addPage(String storyId, {String content = ''}) async {
    final now = DateTime.now();
    final nextPageNumber = await _db.getNextPageNumber(storyId);

    final page = StoryPage(
      id: _uuid.v4(),
      storyId: storyId,
      pageNumber: nextPageNumber,
      content: content,
      createdAt: now,
      updatedAt: now,
    );

    await _db.insertStoryPage(page);

    // Update story's updated_at
    final story = await _db.getStory(storyId, _userId);
    if (story != null) {
      await _db.updateStory(story.copyWith(
        updatedAt: now,
        isDirty: true,
        isSynced: false,
      ));
    }

    await _db.enqueueSyncOperation(
      tableName: 'story_pages',
      recordId: page.id,
      operation: 'INSERT',
      payload: page.toSupabaseMap(),
    );
    _syncService.syncAll();

    return page;
  }

  Future<void> updatePage(StoryPage page) async {
    final updated = page.copyWith(
      updatedAt: DateTime.now(),
      isDirty: true,
      isSynced: false,
    );
    await _db.updateStoryPage(updated);

    // Touch the parent story's updated_at
    final story = await _db.getStory(page.storyId, _userId);
    if (story != null) {
      await _db.updateStory(story.copyWith(
        updatedAt: DateTime.now(),
        isDirty: true,
        isSynced: false,
      ));
    }

    await _db.enqueueSyncOperation(
      tableName: 'story_pages',
      recordId: updated.id,
      operation: 'UPDATE',
      payload: updated.toSupabaseMap(),
    );
    _syncService.syncAll();
  }

  Future<void> deletePage(String pageId) async {
    await _db.softDeleteStoryPage(pageId);
    await _db.enqueueSyncOperation(
      tableName: 'story_pages',
      recordId: pageId,
      operation: 'DELETE',
      payload: {'id': pageId, 'deleted_at': DateTime.now().toIso8601String()},
    );
    _syncService.syncAll();
  }

  // ─────────────────────── FAVORITES ───────────────────────

  /// Toggle favorite: if currently favorited → soft-delete; else → insert.
  /// Returns the new favorite state immediately (from SQLite, no network wait).
  Future<bool> toggleFavorite(String storyId) async {
    final existing = await _db.getActiveFavorite(_userId, storyId);

    if (existing != null) {
      // Un-favorite: soft-delete the junction row
      await _db.softDeleteFavorite(existing.id);
      await _db.enqueueSyncOperation(
        tableName: 'favorites',
        recordId: existing.id,
        operation: 'DELETE',
        payload: {
          'id': existing.id,
          'deleted_at': DateTime.now().toIso8601String(),
        },
      );
      _syncService.syncAll();
      return false;
    } else {
      // Favorite: insert new junction row
      final fav = Favorite(
        id: _uuid.v4(),
        userId: _userId,
        storyId: storyId,
        createdAt: DateTime.now(),
      );
      await _db.insertFavorite(fav);
      await _db.enqueueSyncOperation(
        tableName: 'favorites',
        recordId: fav.id,
        operation: 'INSERT',
        payload: fav.toSupabaseMap(),
      );
      _syncService.syncAll();
      return true;
    }
  }

  Future<List<Story>> getFavoriteStories() async {
    return _db.getFavoriteStories(_userId);
  }

  Future<bool> isFavorite(String storyId) async {
    return _db.isFavorite(_userId, storyId);
  }

  // ─────────────────────── STATS ───────────────────────

  Future<int> getStoryCount() async {
    return _db.getStoryCount(_userId);
  }

  Future<int> getTotalWordCount() async {
    return _db.getTotalWordCount(_userId);
  }

  Future<int> getFavoriteCount() async {
    return _db.getFavoriteCount(_userId);
  }

  // ─────────────────────── INITIALIZATION ───────────────────────

  /// Seed database with mock data if this is the first launch.
  Future<void> seedIfNeeded() async {
    await _db.seedIfEmpty(_userId);
  }

  /// Trigger a manual sync (e.g., from a pull-to-refresh).
  Future<void> triggerSync() async {
    await _syncService.syncAll();
  }
}
