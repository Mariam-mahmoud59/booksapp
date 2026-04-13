# Strict Offline-First Architecture — Implementation Plan

## Current State Assessment

The app is a **UI-only Flutter project** with:
- **No database** — all data comes from `mockStories` list in `story.dart`
- **No authentication** — login/signup screens just navigate with `context.go('/app')`
- **No Supabase** — only dependencies are `go_router` and `shared_preferences`
- **No services layer** — screens read mock data directly
- **14 screens**, 2 widgets, 1 theme file, 1 model file

We are building the **entire data infrastructure from scratch**.

---

## Dependency Additions

> [!IMPORTANT]
> These packages will be added to `pubspec.yaml`:

| Package | Purpose |
|---------|---------|
| `supabase_flutter` | Supabase client (auth + database + storage) |
| `sqflite` | Local SQLite database |
| `path` | File path manipulation for DB location |
| `uuid` | Client-side UUID generation for offline creates |
| `connectivity_plus` | Network state detection for sync triggers |

---

## Phase 1: Local SQLite Table Migration

### [NEW] [database_helper.dart](file:///d:/ppflutter/storybook/booksapp/lib/services/database_helper.dart)

Singleton `DatabaseHelper` class managing all local SQLite operations. Tables will mirror the Supabase schema column-for-column, **plus** offline-only metadata columns (`is_synced`, `is_dirty`).

#### Tables Created

**`profiles`**
| Column | Type | Notes |
|--------|------|-------|
| `id` | TEXT PK | Maps to `auth.uid()` |
| `username` | TEXT | |
| `avatar_url` | TEXT | nullable, path to storage |
| `created_at` | TEXT | ISO 8601 |
| `updated_at` | TEXT | ISO 8601 |
| `is_synced` | INTEGER | 0/1, default 0 |

**`stories`**
| Column | Type | Notes |
|--------|------|-------|
| `id` | TEXT PK | UUID, generated client-side |
| `user_id` | TEXT FK→profiles | |
| `title` | TEXT | |
| `description` | TEXT | nullable |
| `cover_image_url` | TEXT | nullable |
| `genre` | TEXT | nullable |
| `status` | TEXT | 'draft'/'published'/'archived', default 'draft' |
| `created_at` | TEXT | ISO 8601 |
| `updated_at` | TEXT | ISO 8601 |
| `deleted_at` | TEXT | nullable, soft delete |
| `is_synced` | INTEGER | 0/1 |
| `is_dirty` | INTEGER | 0/1 |

**`story_pages`**
| Column | Type | Notes |
|--------|------|-------|
| `id` | TEXT PK | UUID |
| `story_id` | TEXT FK→stories | |
| `page_number` | INTEGER | |
| `title` | TEXT | nullable |
| `content` | TEXT | |
| `audio_url` | TEXT | nullable |
| `background_color` | TEXT | nullable, hex string |
| `image_url` | TEXT | nullable |
| `created_at` | TEXT | ISO 8601 |
| `updated_at` | TEXT | ISO 8601 |
| `deleted_at` | TEXT | nullable, soft delete |
| `is_synced` | INTEGER | |
| `is_dirty` | INTEGER | |

**`favorites`**
| Column | Type | Notes |
|--------|------|-------|
| `id` | TEXT PK | UUID |
| `user_id` | TEXT FK→profiles | |
| `story_id` | TEXT FK→stories | |
| `created_at` | TEXT | ISO 8601 |
| `deleted_at` | TEXT | nullable, soft delete |
| `is_synced` | INTEGER | |

**`sync_queue`** *(local only — sequential lock queue)*
| Column | Type | Notes |
|--------|------|-------|
| `id` | INTEGER PK AUTOINCREMENT | Provides strict ordering |
| `table_name` | TEXT | e.g. 'stories', 'story_pages', 'favorites' |
| `record_id` | TEXT | The row's UUID |
| `operation` | TEXT | 'INSERT', 'UPDATE', 'DELETE' |
| `payload` | TEXT | JSON of the row data |
| `created_at` | TEXT | When the change was queued |
| `status` | TEXT | 'pending'/'processing'/'done'/'failed' |
| `retry_count` | INTEGER | default 0 |

#### Key Methods
- `initDatabase()` — creates all tables
- CRUD for each table (`insertStory`, `updateStory`, `getStories`, etc.)
- `getUnsyncedRecords(tableName)` — WHERE `is_synced = 0`
- `getDirtyRecords(tableName)` — WHERE `is_dirty = 1`
- `markSynced(tableName, id)` — sets `is_synced = 1, is_dirty = 0`
- `softDelete(tableName, id)` — sets `deleted_at` = now, `is_dirty = 1`
- `enqueueSyncOperation(...)` — inserts into `sync_queue`
- `dequeueSyncOperation()` — gets the next `pending` item by `id` ASC
- `isFavorite(userId, storyId)` — quick boolean lookup

---

## Phase 2: Dart Model Adaptations

### [MODIFY] [story.dart](file:///d:/ppflutter/storybook/booksapp/lib/models/story.dart)

**Before:** Simple class with `coverColors`, `pages` (int), `progress`, `isFavorite`, string `lastEdited`, `created`.

**After:** Full schema-aligned model:

```dart
class Story {
  final String id;
  final String userId;
  final String title;
  final String? description;
  final String? coverImageUrl;
  final String? genre;
  final String status; // 'draft', 'published', 'archived'
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final bool isSynced;
  final bool isDirty;

  // Computed / UI-convenience (not stored)
  final List<Color> coverColors; // derived from genre or fallback gradient
  final int pageCount;           // from story_pages count
  final bool isFavorite;         // from favorites table lookup
}
```

- `toMap()` / `fromMap(Map<String, dynamic>)` for SQLite serialization.
- `toSupabaseMap()` — excludes local-only fields (`is_synced`, `is_dirty`, `coverColors`, `pageCount`, `isFavorite`).
- `copyWith(...)` for immutable updates.
- **Mock data stays** as a static list for initial seeding.

### [MODIFY] StoryPage class (same file)

```dart
class StoryPage {
  final String id;
  final String storyId;
  final int pageNumber;
  final String? title;
  String content;
  final String? audioUrl;
  final String? backgroundColor; // hex string
  String? imageUrl;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final bool isSynced;
  final bool isDirty;
}
```

- `toMap()` / `fromMap()` / `toSupabaseMap()` / `copyWith(...)`

### [NEW] [profile.dart](file:///d:/ppflutter/storybook/booksapp/lib/models/profile.dart)

```dart
class Profile {
  final String id;
  final String? username;
  final String? avatarUrl;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isSynced;
}
```

### [NEW] [favorite.dart](file:///d:/ppflutter/storybook/booksapp/lib/models/favorite.dart)

```dart
class Favorite {
  final String id;
  final String userId;
  final String storyId;
  final DateTime createdAt;
  final DateTime? deletedAt;
  final bool isSynced;
}
```

---

## Phase 3: Sync Service Schema Compatibility

### [NEW] [sync_service.dart](file:///d:/ppflutter/storybook/booksapp/lib/services/sync_service.dart)

The **core engine** implementing all offline-first rules:

#### Architecture Rules Enforced

1. **SQLite is absolute truth** — UI always reads from local DB, never directly from Supabase.
2. **Locked sequential sync queue** — operations are dequeued one-at-a-time by `sync_queue.id ASC`. No parallel pushes.
3. **Push-then-Pull** — local dirty changes are pushed first, then remote changes are pulled.
4. **Soft deletes** — `deleted_at` is set instead of hard deleting. Push propagates the soft delete.
5. **Conditional pull** — only pull rows where `remote.updated_at > local.updated_at AND local.is_synced == true` (never overwrite unsynced local changes).

#### Key Methods

```
syncAll() → async
  1. Check connectivity
  2. pushLocalChanges()
  3. pullRemoteChanges()

pushLocalChanges() → async
  - Loop: dequeueSyncOperation()
    - Mark 'processing'
    - Supabase upsert/delete based on operation type
    - On success: mark 'done', markSynced(record)
    - On failure: increment retry_count, mark 'failed' if retry_count > 3

pullRemoteChanges() → async
  - For each table [profiles, stories, story_pages, favorites]:
    - Get local max(updated_at) for synced records
    - Supabase SELECT WHERE updated_at > localMax
    - For each remote row:
      - If local row exists AND is_dirty: SKIP (local wins)
      - If local row exists AND is_synced: UPDATE local
      - If no local row: INSERT local with is_synced=1
```

### [NEW] [supabase_service.dart](file:///d:/ppflutter/storybook/booksapp/lib/services/supabase_service.dart)

Thin wrapper around `Supabase.instance.client`:
- `initialize()` — call `Supabase.initialize(url, anonKey)`
- `signUp(email, password)` / `signIn(email, password)` / `signOut()`
- `currentUserId` getter
- `upsertRow(table, data)` / `deleteRow(table, id)`
- `fetchRowsAfter(table, DateTime after)`

### [NEW] [connectivity_service.dart](file:///d:/ppflutter/storybook/booksapp/lib/services/connectivity_service.dart)

- Listens to `connectivity_plus` stream
- Exposes `isOnline` getter
- On transition offline→online: triggers `SyncService.syncAll()`

---

## Phase 4: UI/Repository Re-link

### [NEW] [story_repository.dart](file:///d:/ppflutter/storybook/booksapp/lib/repositories/story_repository.dart)

The **single interface** between UI and data. Screens will call the repository—**never** `DatabaseHelper` or `SyncService` directly.

#### Key Methods

| Method | Behavior |
|--------|----------|
| `getAllStories(userId)` | Read from SQLite WHERE `deleted_at IS NULL` AND `user_id = userId` |
| `getStory(id)` | Read single story + page count + favorite status |
| `createStory(title, ...)` | Insert into SQLite with UUID, `is_synced=0`, enqueue sync |
| `updateStory(story)` | Update SQLite, set `is_dirty=1`, enqueue sync |
| `deleteStory(id)` | Soft delete in SQLite, enqueue sync |
| `getStoryPages(storyId)` | Read from SQLite ordered by `page_number` |
| `addPage(storyId, ...)` | Insert page, enqueue sync |
| `updatePage(page)` | Update page, enqueue sync |
| `deletePage(pageId)` | Soft delete page, enqueue sync |
| `toggleFavorite(userId, storyId)` | If favorite exists → soft delete it; else → insert. Enqueue sync. Returns new boolean state instantly from SQLite. |
| `getFavoriteStories(userId)` | JOIN favorites + stories WHERE `favorites.deleted_at IS NULL` |
| `getProfile(userId)` | Read from SQLite |

### UI Screen Modifications (Summary)

| Screen | Change |
|--------|--------|
| `main.dart` | Initialize Supabase + `DatabaseHelper` + seed data if first run. Wrap app in providers. |
| `login_screen.dart` | Call `SupabaseService.signIn()`, then navigate |
| `signup_screen.dart` | Call `SupabaseService.signUp()`, create local profile, trigger initial pull |
| `home_screen.dart` | Read from `StoryRepository` instead of `mockStories` |
| `my_stories_screen.dart` | Read from `StoryRepository`, search against local DB |
| `favorites_screen.dart` | Read from `StoryRepository.getFavoriteStories()` |
| `story_details_screen.dart` | Read from `StoryRepository.getStory()`, toggle favorite via repository |
| `story_creation_screen.dart` | Create via `StoryRepository.createStory()`, pages via `addPage()` |
| `story_editor_screen.dart` | Load from DB, save via `updateStory()`/`updatePage()` |
| `reading_mode_screen.dart` | Load pages from `StoryRepository.getStoryPages()` |
| `profile_screen.dart` | Load from `StoryRepository.getProfile()`, compute stats from local DB |

---

## User Review Required

> [!IMPORTANT]
> **Favorites decoupling**: `isFavorite` is being removed as a field on `Story` and will instead be resolved via a JOIN to the local `favorites` table. This changes the data flow for every screen that currently checks `story.isFavorite`.

> [!WARNING]
> **Sync Queue — Client-Direct vs Backend Queue**: Your Supabase schema includes a `sync_queue` table server-side. **This plan has the Flutter client pushing directly to the target tables** (`stories`, `story_pages`, `favorites`) via Supabase RPC/REST, NOT routing through the server-side `sync_queue`. The local `sync_queue` is client-only for ordering. If you want the client to push into the server-side `sync_queue` table and have an edge function unravel it, that is a different pattern — please confirm.

> [!IMPORTANT]
> **Supabase credentials**: I will need your Supabase **project URL** and **anon key** to wire up `SupabaseService.initialize()`. I will create a placeholder config file for now.

---

## Open Questions

1. **Auth provider**: Should we support only email/password auth, or also Google/Apple sign-in?
2. **Initial seed**: On first app launch (empty DB), should we seed with mock stories, or start completely blank and let the user create?
3. **Cover colors**: The current model uses `List<Color> coverColors` for visual gradients. Since the Supabase schema uses `cover_image_url`, should we:
   - (a) Derive gradient colors from `genre` (e.g. adventure = warm tones)?
   - (b) Store a color hex pair in a new local-only column?
   - (c) Drop gradients entirely and only use cover images?

---

## Verification Plan

### Automated Tests
```bash
flutter analyze          # No type errors after model refactor
flutter test             # Schema mapping unit tests
```

### Manual Verification
1. Boot the app → confirm SQLite tables are created with all columns
2. Create a story offline → confirm it appears in `stories` table with `is_synced=0`
3. Add pages → confirm `story_pages` rows with correct `story_id`
4. Toggle favorite → confirm `favorites` junction row created
5. Go online → confirm `sync_queue` drains and Supabase tables reflect the data
6. Modify a story on Supabase directly → pull sync should update local copy
7. Soft delete → confirm `deleted_at` is set, row hidden from UI, push propagates
