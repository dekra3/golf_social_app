class Profile {
  const Profile({
    required this.id,
    required this.username,
    this.fullName,
    this.avatarUrl,
    this.bio,
    this.homeCourse,
    this.handicapIndex,
    this.isPublic = true,
  });

  final String id;
  final String username;
  final String? fullName;
  final String? avatarUrl;
  final String? bio;
  final String? homeCourse;
  final double? handicapIndex;
  final bool isPublic;

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      id: json['id'] as String,
      username: json['username'] as String,
      fullName: json['full_name'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      bio: json['bio'] as String?,
      homeCourse: json['home_course'] as String?,
      handicapIndex: (json['handicap_index'] as num?)?.toDouble(),
      isPublic: json['is_public'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toUpdateJson() {
    return {
      'username': username,
      'full_name': fullName,
      'avatar_url': avatarUrl,
      'bio': bio,
      'home_course': homeCourse,
      'handicap_index': handicapIndex,
      'is_public': isPublic,
    };
  }

  Profile copyWith({
    String? username,
    String? fullName,
    String? avatarUrl,
    String? bio,
    String? homeCourse,
    double? handicapIndex,
    bool? isPublic,
  }) {
    return Profile(
      id: id,
      username: username ?? this.username,
      fullName: fullName ?? this.fullName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      bio: bio ?? this.bio,
      homeCourse: homeCourse ?? this.homeCourse,
      handicapIndex: handicapIndex ?? this.handicapIndex,
      isPublic: isPublic ?? this.isPublic,
    );
  }
}