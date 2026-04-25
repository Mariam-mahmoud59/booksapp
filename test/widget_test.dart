import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:story_book_creator/providers/story_provider.dart';

/// Widget tests that validate the StoryProvider contract used by
/// HomeScreen, MyStoriesScreen, and FavoritesScreen.
///
/// Full widget rendering tests for screens that depend on SQLite/Supabase
/// require integration test setup (sqflite_common_ffi + Supabase mocks).
/// These unit tests validate the provider logic that screens consume.
void main() {
  group('StoryProvider — Initial State', () {
    test('initial state has empty stories list', () {
      final provider = StoryProvider();
      expect(provider.stories, isEmpty);
      expect(provider.favoriteStories, isEmpty);
      expect(provider.isLoading, false);
      expect(provider.isLoadingFavorites, false);
      expect(provider.error, isNull);
      expect(provider.searchQuery, '');
    });

    test('default status filter is "all"', () {
      final provider = StoryProvider();
      expect(provider.statusFilter, 'all');
    });

    test('default sort order is "recent"', () {
      final provider = StoryProvider();
      expect(provider.sortOrder, 'recent');
    });

    test('recentStories returns at most 2 items', () {
      final provider = StoryProvider();
      expect(provider.recentStories.length, lessThanOrEqualTo(2));
    });

    test('filteredStories returns all stories when filter is "all"', () {
      final provider = StoryProvider();
      expect(provider.filteredStories, isEmpty);
    });
  });

  group('StoryProvider — Filter & Sort', () {
    test('setStatusFilter updates filter and notifies', () {
      final provider = StoryProvider();
      bool notified = false;
      provider.addListener(() => notified = true);

      provider.setStatusFilter('draft');
      expect(provider.statusFilter, 'draft');
      expect(notified, true);
    });

    test('setStatusFilter to published', () {
      final provider = StoryProvider();
      provider.setStatusFilter('published');
      expect(provider.statusFilter, 'published');
    });

    test('setStatusFilter back to all', () {
      final provider = StoryProvider();
      provider.setStatusFilter('draft');
      provider.setStatusFilter('all');
      expect(provider.statusFilter, 'all');
    });

    test('setSortOrder updates sort and notifies', () {
      final provider = StoryProvider();
      bool notified = false;
      provider.addListener(() => notified = true);

      provider.setSortOrder('alpha');
      expect(provider.sortOrder, 'alpha');
      expect(notified, true);
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
  });

  group('StoryProvider — Error Handling', () {
    test('error is null initially', () {
      final provider = StoryProvider();
      expect(provider.error, isNull);
    });

    test('clearError resets error state and notifies', () {
      final provider = StoryProvider();
      bool notified = false;
      provider.addListener(() => notified = true);

      provider.clearError();
      expect(provider.error, isNull);
      expect(notified, true);
    });

    test('loadStories sets error when database is unavailable', () async {
      final provider = StoryProvider();
      await provider.loadStories();
      // In test environment without SQLite, this should set an error
      expect(provider.error, isNotNull);
      expect(provider.isLoading, false);
    });
  });

  group('StoryProvider — Loading States', () {
    test('loadStories toggles isLoading', () async {
      final provider = StoryProvider();
      final states = <bool>[];
      provider.addListener(() => states.add(provider.isLoading));

      await provider.loadStories();

      // Should have been true then false
      expect(states, contains(true));
      expect(states.last, false);
    });

    test('loadFavorites toggles isLoadingFavorites', () async {
      final provider = StoryProvider();
      final states = <bool>[];
      provider.addListener(() => states.add(provider.isLoadingFavorites));

      await provider.loadFavorites();

      expect(states, contains(true));
      expect(states.last, false);
    });

    test('searchStories updates searchQuery', () async {
      final provider = StoryProvider();
      await provider.searchStories('test');
      expect(provider.searchQuery, 'test');
    });

    test('searchStories with empty query resets', () async {
      final provider = StoryProvider();
      await provider.searchStories('test');
      await provider.searchStories('');
      expect(provider.searchQuery, '');
    });
  });

  group('StoryProvider — Consumer Contract', () {
    testWidgets('StoryProvider can be provided and consumed',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider(
            create: (_) => StoryProvider(),
            child: Builder(
              builder: (context) {
                final provider = context.watch<StoryProvider>();
                return Scaffold(
                  body: Column(
                    children: [
                      Text('Loading: ${provider.isLoading}'),
                      Text('Stories: ${provider.stories.length}'),
                      Text('Filter: ${provider.statusFilter}'),
                      Text('Sort: ${provider.sortOrder}'),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      );

      expect(find.text('Loading: false'), findsOneWidget);
      expect(find.text('Stories: 0'), findsOneWidget);
      expect(find.text('Filter: all'), findsOneWidget);
      expect(find.text('Sort: recent'), findsOneWidget);
    });

    testWidgets('StoryProvider filter change triggers rebuild',
        (WidgetTester tester) async {
      final provider = StoryProvider();

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider.value(
            value: provider,
            child: Builder(
              builder: (context) {
                final p = context.watch<StoryProvider>();
                return Scaffold(
                  body: Text('Filter: ${p.statusFilter}'),
                );
              },
            ),
          ),
        ),
      );

      expect(find.text('Filter: all'), findsOneWidget);

      provider.setStatusFilter('draft');
      await tester.pump();

      expect(find.text('Filter: draft'), findsOneWidget);
    });
  });
}
