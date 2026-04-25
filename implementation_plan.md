# Abdelrahman Alaa — Home, Listings, Favorites, Reliability & Testing

## Scope
- **Screens**: `home_screen.dart`, `my_stories_screen.dart`, `favorites_screen.dart`
- **Logic**: `story_provider.dart`, `story_repository.dart`
- **Tests**: `widget_test.dart`, `sync_service_test.dart`

## Proposed Changes

### 1. Home Screen
- Add `RefreshIndicator` for pull-to-refresh (triggers sync)
- Add error state with retry button
- Replace deprecated `withOpacity` calls
- Add fade-in animations for story cards
- Show favorite indicator (heart) on cards
- Add rotating writing tips
- Improve empty state design

### 2. My Stories Screen
- Add `RefreshIndicator` for pull-to-refresh
- Add error state with retry
- Add filter chips: All / Draft / Published
- Add sort: Recent / Oldest / A-Z
- Add `Dismissible` swipe-to-delete with confirmation
- Add colored status badges
- Add favorite toggle on cards
- Add story count in header

### 3. Favorites Screen
- Add `RefreshIndicator` for pull-to-refresh
- Add error state with retry
- Add SnackBar with undo after un-favoriting
- Add genre tag on cards
- Add favorites count in header
- Improve empty state

### 4. StoryProvider
- Add `_error` field with getter
- Add `_statusFilter` and `_sortOrder` fields
- Add `filteredStories` getter (filter + sort)
- Fix `loadFavorites` to set loading flag
- Add `_isLoadingFavorites` separate flag

### 5. StoryRepository
- Add `getStoriesByStatus()` method

### 6. Tests
- Replace broken widget_test.dart with real screen tests
- Add sync_service_test.dart with provider/sync unit tests
