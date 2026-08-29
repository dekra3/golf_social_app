class Group {
  const Group({
    required this.id,
    required this.name,
    this.description,
    required this.isPrivate,
    required this.ownerId,
    this.coverImageUrl,
    required this.createdAt,
  });

  final String id;
  final String name;
  final String? description;
  final bool isPrivate;
  final String ownerId;
  final String? coverImageUrl;
  final DateTime createdAt;

  factory Group.fromJson(Map<String, dynamic> json) {
    return Group(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      isPrivate: json['is_private'] as bool? ?? false,
      ownerId: json['owner_id'] as String,
      coverImageUrl: json['cover_image_url'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}