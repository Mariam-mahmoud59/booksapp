/// Junction table model mapping user ↔ story favorites.
/// Replaces the old `isFavorite` boolean on Story.
class Favorite {
  final String id;
  final String userId;
  final String storyId;
  final DateTime createdAt;
  final DateTime? deletedAt;
  final bool isSynced;

  const Favorite({
    required this.id,
    required this.userId,
    required this.storyId,
    required this.createdAt,
    this.deletedAt,
    this.isSynced = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'story_id': storyId,
      'created_at': createdAt.toIso8601String(),
      'deleted_at': deletedAt?.toIso8601String(),
      'is_synced': isSynced ? 1 : 0,
    };
  }

  factory Favorite.fromMap(Map<String, dynamic> map) {
    return Favorite(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      storyId: map['story_id'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
      deletedAt: map['deleted_at'] != null
          ? DateTime.parse(map['deleted_at'] as String)
          : null,
      isSynced: (map['is_synced'] as int?) == 1,
    );
  }

  Map<String, dynamic> toSupabaseMap() {
    return {
      'id': id,
      'user_id': userId,
      'story_id': storyId,
      'created_at': createdAt.toIso8601String(),
      'deleted_at': deletedAt?.toIso8601String(),
    };
  }

  Favorite copyWith({
    String? id,
    String? userId,
    String? storyId,
    DateTime? createdAt,
    DateTime? deletedAt,
    bool? isSynced,
  }) {
    return Favorite(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      storyId: storyId ?? this.storyId,
      createdAt: createdAt ?? this.createdAt,
      deletedAt: deletedAt ?? this.deletedAt,
      isSynced: isSynced ?? this.isSynced,
    );
  }
}
