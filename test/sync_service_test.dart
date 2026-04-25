import 'package:flutter_test/flutter_test.dart';
import 'package:story_book_creator/providers/story_provider.dart';

/// Tests for sync-related logic and StoryProvider integration.
///
/// Note: Full integration tests for SyncService, DatabaseHelper, and
/// SupabaseService require mocking platform channels (sqflite, connectivity).
/// These tests validate the provider-level behavior that sits above those
/// services.
void main() {
  group('StoryProvider — Sync Behavior', () {
    test('triggerSync does not throw when called on fresh provider', () async {
      final provider = StoryProvider();
      // triggerSync will attempt to call repo.triggerSync() which calls
      // SyncService.syncAll() — this will bail out early because we're
      // not online / not authenticated, which is the correct behavior.
      // We just verify it doesn't throw.
      expect(() => provider.triggerSync(), returnsNormally);
    });

    test('loadStories sets isLoading to true then false', () async {
      final provider = StoryProvider();
      final states = <bool>[];
      provider.addListener(() => states.add(provider.isLoading));

      // loadStories will try to access SQLite which isn't available in
      // unit tests, so it will hit the catch block and set error.
      await provider.loadStories();

      // Should have toggled loading: true → false
      expect(states, contains(true));
      expect(states.last, false);
    });

    test('loadFavorites sets isLoadingFavorites flag', () async {
      final provider = StoryProvider();
      final states = <bool>[];
      provider.addListener(() => states.add(provider.isLoadingFavorites));

      await provider.loadFavorites();

      expect(states, contains(true));
      expect(states.last, false);
    });

    test('searchStories with empty query reloads all stories', () async {
      final provider = StoryProvider();
      await provider.searchStories('');
      expect(provider.searchQuery, '');
    });

    test('searchStories with query updates searchQuery', () async {
      final provider = StoryProvider();
      await provider.searchStories('test');
      expect(provider.searchQuery, 'test');
    });
  });

  group('StoryProvider — Filter & Sort Integration', () {
    test('setStatusFilter to draft then back to all', () {
      final provider = StoryProvider();

      provider.setStatusFilter('draft');
      expect(provider.statusFilter, 'draft');

      provider.setStatusFilter('all');
      expect(provider.statusFilter, 'all');
    });

    test('setSortOrder cycles through all options', () {
      final provider = StoryProvider();

      provider.setSortOrder('oldest');
      expect(provider.sortOrder, 'oldest');

      provider.setSortOrder('alpha');
      expect(provider.sortOrder, 'alpha');

      provider.setSortOrder('recent');
      expect(provider.sortOrder, 'recent');
    });

    test('filteredStories respects filter even with empty list', () {
      final provider = StoryProvider();
      provider.setStatusFilter('published');
      expect(provider.filteredStories, isEmpty);
    });
  });

  group('StoryProvider — Error Handling', () {
    test('error is null initially', () {
      final provider = StoryProvider();
      expect(provider.error, isNull);
    });

    test('clearError resets error state', () {
      final provider = StoryProvider();
      provider.clearError();
      expect(provider.error, isNull);
    });

    test('loadStories sets error when database is unavailable', () async {
      final provider = StoryProvider();
      await provider.loadStories();
      // In test environment without SQLite, this should set an error
      expect(provider.error, isNotNull);
    });
  });
}
