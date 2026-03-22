import 'recipe.dart';

class Feast {
  final int? id;
  final String name;
  final String? description;
  final DateTime? createdAt;

  List<Recipe>? recipes;

  Feast({
    this.id,
    required this.name,
    this.description,
    this.createdAt,
    this.recipes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  factory Feast.fromMap(Map<String, dynamic> map) {
    return Feast(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      createdAt: map['created_at'] != null ? DateTime.parse(map['created_at']) : null,
    );
  }
}