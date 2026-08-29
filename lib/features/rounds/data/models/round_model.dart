class Round {
  const Round({
    required this.id,
    required this.userId,
    this.courseId,
    this.teeId,
    this.tournamentId,
    required this.playedAt,
    this.totalScore,
    this.courseName,
    this.username,
    this.fullName,
  });

  final String id;
  final String userId;
  final String? courseId;
  final String? teeId;
  final String? tournamentId;
  final DateTime playedAt;
  final int? totalScore;
  final String? courseName; // populated via a join when fetching rounds
  final String? username; // populated via a profiles join (tournament leaderboards)
  final String? fullName;

  factory Round.fromJson(Map<String, dynamic> json) {
    final profile = json['profiles'] as Map<String, dynamic>?;
    return Round(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      courseId: json['course_id'] as String?,
      teeId: json['tee_id'] as String?,
      tournamentId: json['tournament_id'] as String?,
      playedAt: DateTime.parse(json['played_at'] as String),
      totalScore: json['total_score'] as int?,
      courseName: (json['courses'] as Map<String, dynamic>?)?['name'] as String?,
      username: profile?['username'] as String?,
      fullName: profile?['full_name'] as String?,
    );
  }
}