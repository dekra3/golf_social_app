class Tee {
  const Tee({
    required this.id,
    required this.courseId,
    required this.name,
    required this.par,
    this.rating,
    this.slope,
    this.yardage,
  });

  final String id;
  final String courseId;
  final String name;
  final int par;
  final double? rating;
  final int? slope;
  final int? yardage;

  factory Tee.fromJson(Map<String, dynamic> json) {
    return Tee(
      id: json['id'] as String,
      courseId: json['course_id'] as String,
      name: json['name'] as String,
      par: json['par'] as int,
      rating: (json['rating'] as num?)?.toDouble(),
      slope: json['slope'] as int?,
      yardage: json['yardage'] as int?,
    );
  }
}

class Hole {
  const Hole({
    required this.id,
    required this.teeId,
    required this.holeNumber,
    required this.par,
    this.yardage,
    this.strokeIndex,
  });

  final String id;
  final String teeId;
  final int holeNumber;
  final int par;
  final int? yardage;
  final int? strokeIndex;

  factory Hole.fromJson(Map<String, dynamic> json) {
    return Hole(
      id: json['id'] as String,
      teeId: json['tee_id'] as String,
      holeNumber: json['hole_number'] as int,
      par: json['par'] as int,
      yardage: json['yardage'] as int?,
      strokeIndex: json['stroke_index'] as int?,
    );
  }
}