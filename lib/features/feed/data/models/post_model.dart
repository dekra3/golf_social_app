class Post {
  const Post({
    required this.id,
    required this.userId,
    this.roundId,
    this.tournamentId,
    this.content,
    this.imageUrl,
    required this.createdAt,
    required this.username,
    this.fullName,
    this.avatarUrl,
    required this.likeCount,
    required this.commentCount,
  });

  final String id;
  final String userId;
  final String? roundId;
  final String? tournamentId;
  final String? content;
  final String? imageUrl;
  final DateTime createdAt;
  final String username;
  final String? fullName;
  final String? avatarUrl;
  final int likeCount;
  final int commentCount;

  factory Post.fromJson(Map<String, dynamic> json) {
    final profile = json['profiles'] as Map<String, dynamic>?;
    // Postgrest's `likes(count)` / `comments(count)` embeds come back as
    // a one-element list like [{count: N}] rather than a bare number.
    final likesAgg = json['likes'] as List?;
    final commentsAgg = json['comments'] as List?;
    return Post(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      roundId: json['round_id'] as String?,
      tournamentId: json['tournament_id'] as String?,
      content: json['content'] as String?,
      imageUrl: json['image_url'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      username: profile?['username'] as String? ?? 'Unknown',
      fullName: profile?['full_name'] as String?,
      avatarUrl: profile?['avatar_url'] as String?,
      likeCount:
          (likesAgg != null && likesAgg.isNotEmpty) ? (likesAgg.first['count'] as int? ?? 0) : 0,
      commentCount: (commentsAgg != null && commentsAgg.isNotEmpty)
          ? (commentsAgg.first['count'] as int? ?? 0)
          : 0,
    );
  }
}