/// Local profile model mapping to the Supabase `profiles` table.
class Profile {
  final String id;
  final String? username;
  final String? avatarUrl;
  final String? bio;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isSynced;

  const Profile({
    required this.id,
    this.username,
    this.avatarUrl,
    this.bio,
    required this.createdAt,
    required this.updatedAt,
    this.isSynced = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'avatar_url': avatarUrl,
      'bio': bio,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'is_synced': isSynced ? 1 : 0,
    };
  }

  factory Profile.fromMap(Map<String, dynamic> map) {
    return Profile(
      id: map['id'] as String,
      username: map['username'] as String?,
      avatarUrl: map['avatar_url'] as String?,
      bio: map['bio'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
      isSynced: (map['is_synced'] as int?) == 1,
    );
  }

  /// For pushing to Supabase — excludes local-only fields.
  Map<String, dynamic> toSupabaseMap() {
    return {
      'id': id,
      'username': username,
      'avatar_url': avatarUrl,
      'bio': bio,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Profile copyWith({
    String? id,
    String? username,
    String? avatarUrl,
    String? bio,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isSynced,
  }) {
    return Profile(
      id: id ?? this.id,
      username: username ?? this.username,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      bio: bio ?? this.bio,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isSynced: isSynced ?? this.isSynced,
    );
  }
}
