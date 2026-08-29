class TournamentEntry {
  const TournamentEntry({
    required this.id,
    required this.tournamentId,
    required this.userId,
    required this.joinedAt,
    required this.username,
    this.fullName,
    this.avatarUrl,
  });

  final String id;
  final String tournamentId;
  final String userId;
  final DateTime joinedAt;
  final String username;
  final String? fullName;
  final String? avatarUrl;

  factory TournamentEntry.fromJson(Map<String, dynamic> json) {
    final profile = json['profiles'] as Map<String, dynamic>?;
    return TournamentEntry(
      id: json['id'] as String,
      tournamentId: json['tournament_id'] as String,
      userId: json['user_id'] as String,
      joinedAt: DateTime.parse(json['joined_at'] as String),
      username: profile?['username'] as String? ?? 'Unknown',
      fullName: profile?['full_name'] as String?,
      avatarUrl: profile?['avatar_url'] as String?,
    );
  }
}