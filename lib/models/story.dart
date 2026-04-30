import 'package:flutter/material.dart';

/// Story model aligned to the Supabase `stories` table schema.
/// `coverColors`, `pageCount`, and `isFavorite` are UI-convenience
/// fields computed at query time — they are NOT stored in the DB.
class Story {
  final String id;
  final String userId;
  final String title;
  final String? description;
  final String? coverImageUrl;
  final String? genre;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final bool isSynced; //isSynced = البيانات اتبعتت للسيرفر ولا لا
  final bool isDirty; //isDirty = البيانات اتغيرت ولا لا

  // Computed / UI-convenience (not stored in stories table)
  final List<Color> coverColors;
  final int pageCount;
  final bool isFavorite;

  const Story({
    required this.id,
    required this.userId,
    required this.title,
    this.description,
    this.coverImageUrl,
    this.genre,
    this.status = 'draft',
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.isSynced = false,
    this.isDirty = true,
    this.coverColors = const [Color(0xFFB08968), Color(0xFF8D6E63)],
    this.pageCount = 0,
    this.isFavorite = false,
  });

  /// Deserialize from SQLite row.
  factory Story.fromMap(
    Map<String, dynamic> map, {
    List<Color>? coverColors,
    int pageCount = 0,
    bool isFavorite = false,
  }) {
    return Story(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      title: map['title'] as String,
      description: map['description'] as String?,
      coverImageUrl: map['cover_image_url'] as String?,
      genre: map['genre'] as String?,
      status: (map['status'] as String?) ?? 'draft',
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
      deletedAt: map['deleted_at'] != null
          ? DateTime.parse(map['deleted_at'] as String)
          : null,
      isSynced: (map['is_synced'] as int?) == 1,
      isDirty: (map['is_dirty'] as int?) == 1,
      coverColors: coverColors ?? _colorsForGenre(map['genre'] as String?),
      pageCount: pageCount,
      isFavorite: isFavorite,
    );
  }

  /// Serialize to SQLite row.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'description': description,
      'cover_image_url': coverImageUrl,
      'genre': genre,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'deleted_at': deletedAt?.toIso8601String(),
      'is_synced': isSynced ? 1 : 0,
      'is_dirty': isDirty ? 1 : 0,
    };
  }

  /// For pushing to Supabase — excludes local-only fields.
  Map<String, dynamic> toSupabaseMap() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'description': description,
      'cover_image_url': coverImageUrl,
      'genre': genre,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'deleted_at': deletedAt?.toIso8601String(),
    };
  }

  Story copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    String? coverImageUrl,
    String? genre,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
    bool? isSynced,
    bool? isDirty,
    List<Color>? coverColors,
    int? pageCount,
    bool? isFavorite,
  }) {
    return Story(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      genre: genre ?? this.genre,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      isSynced: isSynced ?? this.isSynced,
      isDirty: isDirty ?? this.isDirty,
      coverColors: coverColors ?? this.coverColors,
      pageCount: pageCount ?? this.pageCount,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  /// Derive gradient colors from genre for visual variety.
  static List<Color> _colorsForGenre(String? genre) {
    switch (genre?.toLowerCase()) {
      case 'fantasy':
        return const [Color(0xFF7E57C2), Color(0xFF5C6BC0)];
      case 'adventure':
        return const [Color(0xFFFF8A65), Color(0xFFFFB74D)];
      case 'romance':
        return const [Color(0xFFEC407A), Color(0xFFAB47BC)];
      case 'mystery':
        return const [Color(0xFF546E7A), Color(0xFF37474F)];
      case 'sci-fi':
        return const [Color(0xFF26C6DA), Color(0xFF42A5F5)];
      case 'horror':
        return const [Color(0xFF424242), Color(0xFF212121)];
      default:
        return const [Color(0xFFB08968), Color(0xFF8D6E63)];
    }
  }

  /// Human-readable last-edited string.
  String get lastEditedDisplay {
    final now = DateTime.now();
    final diff = now.difference(updatedAt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours} hours ago';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays} days ago';
    if (diff.inDays < 30) return '${(diff.inDays / 7).floor()} weeks ago';
    return '${updatedAt.month}/${updatedAt.day}/${updatedAt.year}';
  }
}

/// StoryPage model aligned to the Supabase `story_pages` table.
class StoryPage {
  final String id;
  final String storyId;
  final int pageNumber;
  final String? title;
  String content;
  final String? audioUrl;
  final String? backgroundColor; // hex string e.g. '#FFFFFF'
  String? imageUrl;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final bool isSynced;
  final bool isDirty;

  StoryPage({
    required this.id,
    required this.storyId,
    required this.pageNumber,
    this.title,
    this.content = '',
    this.audioUrl,
    this.backgroundColor,
    this.imageUrl,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.isSynced = false,
    this.isDirty = true,
  });

  factory StoryPage.fromMap(Map<String, dynamic> map) {
    return StoryPage(
      id: map['id'] as String,
      storyId: map['story_id'] as String,
      pageNumber: map['page_number'] as int,
      title: map['title'] as String?,
      content: (map['content'] as String?) ?? '',
      audioUrl: map['audio_url'] as String?,
      backgroundColor: map['background_color'] as String?,
      imageUrl: map['image_url'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
      deletedAt: map['deleted_at'] != null
          ? DateTime.parse(map['deleted_at'] as String)
          : null,
      isSynced: (map['is_synced'] as int?) == 1,
      isDirty: (map['is_dirty'] as int?) == 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'story_id': storyId,
      'page_number': pageNumber,
      'title': title,
      'content': content,
      'audio_url': audioUrl,
      'background_color': backgroundColor,
      'image_url': imageUrl,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'deleted_at': deletedAt?.toIso8601String(),
      'is_synced': isSynced ? 1 : 0,
      'is_dirty': isDirty ? 1 : 0,
    };
  }

  Map<String, dynamic> toSupabaseMap() {
    return {
      'id': id,
      'story_id': storyId,
      'page_number': pageNumber,
      'title': title,
      'content': content,
      'audio_url': audioUrl,
      'background_color': backgroundColor,
      'image_url': imageUrl,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'deleted_at': deletedAt?.toIso8601String(),
    };
  }

  StoryPage copyWith({
    String? id,
    String? storyId,
    int? pageNumber,
    String? title,
    String? content,
    String? audioUrl,
    String? backgroundColor,
    String? imageUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
    bool? isSynced,
    bool? isDirty,
  }) {
    return StoryPage(
      id: id ?? this.id,
      storyId: storyId ?? this.storyId,
      pageNumber: pageNumber ?? this.pageNumber,
      title: title ?? this.title,
      content: content ?? this.content,
      audioUrl: audioUrl ?? this.audioUrl,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      isSynced: isSynced ?? this.isSynced,
      isDirty: isDirty ?? this.isDirty,
    );
  }
}

/// Mock stories for initial seeding on first app launch.
List<Story> get mockStories {
  final now = DateTime.now();
  const userId = 'local-user';
  return [
    Story(
      id: '1',
      userId: userId,
      title: 'The Hidden Garden',
      description: 'A magical tale of discovery and wonder.',
      genre: 'fantasy',
      status: 'draft',
      createdAt: now.subtract(const Duration(days: 30)),
      updatedAt: now.subtract(const Duration(hours: 2)),
      coverColors: const [Color(0xFFB08968), Color(0xFF8D6E63)],
      pageCount: 12,
      isFavorite: true,
    ),
    Story(
      id: '2',
      userId: userId,
      title: 'A Journey Through Time',
      description: 'Adventures across the centuries.',
      genre: 'adventure',
      status: 'draft',
      createdAt: now.subtract(const Duration(days: 35)),
      updatedAt: now.subtract(const Duration(days: 1)),
      coverColors: const [Color(0xFFE8DCCB), Color(0xFFC8A27C)],
      pageCount: 8,
      isFavorite: false,
    ),
    Story(
      id: '3',
      userId: userId,
      title: 'Midnight Reflections',
      description: 'A collection of thoughts under the moonlight.',
      genre: 'mystery',
      status: 'draft',
      createdAt: now.subtract(const Duration(days: 44)),
      updatedAt: now.subtract(const Duration(days: 3)),
      coverColors: const [Color(0xFF8D6E63), Color(0xFF5D4037)],
      pageCount: 15,
      isFavorite: true,
    ),
    Story(
      id: '4',
      userId: userId,
      title: 'Summer Adventures',
      description: 'Fun under the sun.',
      genre: 'adventure',
      status: 'draft',
      createdAt: now.subtract(const Duration(days: 53)),
      updatedAt: now.subtract(const Duration(days: 7)),
      coverColors: const [Color(0xFFC8A27C), Color(0xFFB08968)],
      pageCount: 6,
      isFavorite: false,
    ),
  ];
}
