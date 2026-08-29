class Tournament {
  const Tournament({
    required this.id,
    required this.name,
    this.groupId,
    this.courseId,
    this.teeId,
    required this.format,
    required this.startDate,
    this.endDate,
    required this.createdBy,
    required this.createdAt,
    this.courseName,
    this.teeName,
  });

  final String id;
  final String name;
  final String? groupId;
  final String? courseId;
  final String? teeId;
  final String format; // 'stroke_play' | 'match_play' | 'scramble' | 'stableford'
  final DateTime startDate;
  final DateTime? endDate;
  final String createdBy;
  final DateTime createdAt;
  final String? courseName;
  final String? teeName;

  factory Tournament.fromJson(Map<String, dynamic> json) {
    return Tournament(
      id: json['id'] as String,
      name: json['name'] as String,
      groupId: json['group_id'] as String?,
      courseId: json['course_id'] as String?,
      teeId: json['tee_id'] as String?,
      format: json['format'] as String,
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: json['end_date'] != null ? DateTime.parse(json['end_date'] as String) : null,
      createdBy: json['created_by'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      courseName: (json['courses'] as Map<String, dynamic>?)?['name'] as String?,
      teeName: (json['tees'] as Map<String, dynamic>?)?['name'] as String?,
    );
  }
}