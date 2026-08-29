class Course {
  const Course({
    required this.id,
    required this.name,
    this.city,
    this.country,
  });

  final String id;
  final String name;
  final String? city;
  final String? country;

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['id'] as String,
      name: json['name'] as String,
      city: json['city'] as String?,
      country: json['country'] as String?,
    );
  }
}