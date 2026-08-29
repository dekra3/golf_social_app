class GroupMember {
  const GroupMember({
    required this.id,
    required this.groupId,
    required this.userId,
    required this.role,
    required this.joinedAt,
    required this.username,
    this.fullName,
    this.avatarUrl,
  });

  final String id;
  final String groupId;
  final String userId;
  final String role; // 'admin' | 'member'
  final DateTime joinedAt;
  final String username;
  final String? fullName;
  final String? avatarUrl;

  bool get isAdmin => role == 'admin';

  factory GroupMember.fromJson(Map<String, dynamic> json) {
    final profile = json['profiles'] as Map<String, dynamic>?;
    return GroupMember(
      id: json['id'] as String,
      groupId: json['group_id'] as String,
      userId: json['user_id'] as String,
      role: json['role'] as String,
      joinedAt: DateTime.parse(json['joined_at'] as String),
      username: profile?['username'] as String? ?? 'Unknown',
      fullName: profile?['full_name'] as String?,
      avatarUrl: profile?['avatar_url'] as String?,
    );
  }
}