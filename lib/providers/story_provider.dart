import 'package:flutter/foundation.dart';
import '../models/story.dart';
import '../repositories/story_repository.dart';

/// Centralized state for stories and favorites.
/// Screens use `context.watch<StoryProvider>()` to reactively rebuild
/// and `context.read<StoryProvider>()` to trigger mutations.
class StoryProvider extends ChangeNotifier {
  final StoryRepository _repo = StoryRepository();

  List<Story> _stories = [];
  List<Story> _favoriteStories = [];
  bool _isLoading = false;
  bool _isLoadingFavorites = false;
  String _searchQuery = '';
  String? _error;

  // Filter & sort state (used by MyStoriesScreen)
  String _statusFilter = 'all'; // 'all', 'draft', 'published'
  String _sortOrder = 'recent'; // 'recent', 'oldest', 'alpha'

  // ─────────────────── Getters ───────────────────

  List<Story> get stories => _stories;
  List<Story> get favoriteStories => _favoriteStories;
  bool get isLoading => _isLoading;
  bool get isLoadingFavorites => _isLoadingFavorites;
  String get searchQuery => _searchQuery;
  String? get error => _error;
  String get statusFilter => _statusFilter;
  String get sortOrder => _sortOrder;

  /// The two most recent stories (for the Home screen).
  /// Always drawn from the full list, ignoring search/filter.
  List<Story> get recentStories => _stories.take(2).toList();

  /// Stories with status filter + sort applied (for MyStoriesScreen).
  List<Story> get filteredStories {
    List<Story> result = List.from(_stories);

    // Apply status filter
    if (_statusFilter != 'all') {
      result = result.where((s) => s.status == _statusFilter).toList();
    }

    // Apply sort order
    switch (_sortOrder) {
      case 'oldest':
        result.sort((a, b) => a.updatedAt.compareTo(b.updatedAt));
        break;
      case 'alpha':
        result.sort(
            (a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
        break;
      case 'recent':
      default:
        result.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
        break;
    }

    return result;
  }

  // ─────────────────── Filter & Sort ───────────────────

  /// Set status filter and notify listeners.
  void setStatusFilter(String filter) {
    _statusFilter = filter;
    notifyListeners();
  }

  /// Set sort order and notify listeners.
  void setSortOrder(String order) {
    _sortOrder = order;
    notifyListeners();
  }

  /// Clear any error message.
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // ─────────────────── Stories ───────────────────

  /// Load all stories for the current user.
  Future<void> loadStories() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _stories = await _repo.getAllStories();
    } catch (e) {
      _error = 'Failed to load stories. Pull down to retry.';
      debugPrint('[StoryProvider] loadStories error: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Search stories by title.
  Future<void> searchStories(String query) async {
    _searchQuery = query;
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _stories = query.isEmpty
          ? await _repo.getAllStories()
          : await _repo.searchStories(query);
    } catch (e) {
      _error = 'Search failed. Please try again.';
      debugPrint('[StoryProvider] searchStories error: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Get a single story by ID from the repository.
  Future<Story?> getStory(String id) async {
    return _repo.getStory(id);
  }

  /// Get pages for a story.
  Future<List<StoryPage>> getStoryPages(String storyId) async {
    return _repo.getStoryPages(storyId);
  }

  /// Create a new story and refresh the list.
  Future<Story> createStory({
    required String title,
    String? description,
    String? genre,
  }) async {
    final story = await _repo.createStory(
      title: title,
      description: description,
      genre: genre,
    );
    await loadStories();
    return story;
  }

  /// Update an existing story and refresh the list.
  Future<void> updateStory(Story story) async {
    await _repo.updateStory(story);
    await loadStories();
  }

  /// Delete a story and refresh both lists.
  Future<void> deleteStory(String id) async {
    await _repo.deleteStory(id);
    await loadStories();
    await loadFavorites();
  }

  // ─────────────────── Pages ───────────────────

  /// Add a page to a story.
  Future<StoryPage> addPage(String storyId, {String content = ''}) async {
    return _repo.addPage(storyId, content: content);
  }

  /// Update a page.
  Future<void> updatePage(StoryPage page) async {
    await _repo.updatePage(page);
  }

  /// Delete a page.
  Future<void> deletePage(String pageId) async {
    await _repo.deletePage(pageId);
  }

  // ─────────────────── Favorites ───────────────────

  /// Load favorite stories for the current user.
  Future<void> loadFavorites() async {
    _isLoadingFavorites = true;
    notifyListeners();

    try {
      _favoriteStories = await _repo.getFavoriteStories();
    } catch (e) {
      debugPrint('[StoryProvider] loadFavorites error: $e');
    }

    _isLoadingFavorites = false;
    notifyListeners();
  }

  /// Toggle favorite status and refresh both lists.
  Future<bool> toggleFavorite(String storyId) async {
    final newState = await _repo.toggleFavorite(storyId);
    await loadStories();
    await loadFavorites();
    return newState;
  }

  // ─────────────────── Sync ───────────────────

  /// Trigger a manual sync and refresh data.
  Future<void> triggerSync() async {
    await _repo.triggerSync();
    await loadStories();
    await loadFavorites();
  }

  /// Seed database on first launch.
  Future<void> seedIfNeeded() async {
    await _repo.seedIfNeeded();
  }
}
