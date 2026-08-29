class HoleScore {
  const HoleScore({
    required this.holeNumber,
    required this.strokes,
    this.putts,
    this.fairwayHit,
    this.greenInRegulation,
  });

  final int holeNumber;
  final int strokes;
  final int? putts;
  final bool? fairwayHit;
  final bool? greenInRegulation;

  factory HoleScore.fromJson(Map<String, dynamic> json) {
    return HoleScore(
      holeNumber: json['hole_number'] as int,
      strokes: json['strokes'] as int,
      putts: json['putts'] as int?,
      fairwayHit: json['fairway_hit'] as bool?,
      greenInRegulation: json['green_in_regulation'] as bool?,
    );
  }

  Map<String, dynamic> toInsertJson(String roundId) {
    return {
      'round_id': roundId,
      'hole_number': holeNumber,
      'strokes': strokes,
      'putts': putts,
      'fairway_hit': fairwayHit,
      'green_in_regulation': greenInRegulation,
    };
  }
}