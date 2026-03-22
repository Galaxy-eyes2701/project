class Recipe {
  final int? id;
  final String name;
  final String? description;
  final String? imageUrl;
  final String? category;
  final String? origin;
  final DateTime? createdAt;
  final bool isFamilySecret;

  Recipe({
    this.id,
    required this.name,
    this.description,
    this.imageUrl,
    this.category,
    this.origin,
    this.createdAt,
    this.isFamilySecret = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'image_url': imageUrl,
      'category': category,
      'origin': origin,
      'created_at': createdAt?.toIso8601String(),
      'is_family_secret': isFamilySecret ? 1 : 0,
    };
  }

  factory Recipe.fromMap(Map<String, dynamic> map) {
    return Recipe(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      imageUrl: map['image_url'],
      category: map['category'],
      origin: map['origin'],
      createdAt: map['created_at'] != null ? DateTime.parse(map['created_at']) : null,
      isFamilySecret: map['is_family_secret'] == 1,
    );
  }
}