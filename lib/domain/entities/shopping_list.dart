class ShoppingList {
  final int? id;
  final String name;
  final DateTime? createdAt;

  ShoppingList({
    this.id,
    required this.name,
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  factory ShoppingList.fromMap(Map<String, dynamic> map) {
    return ShoppingList(
      id: map['id'],
      name: map['name'],
      createdAt: map['created_at'] != null ? DateTime.parse(map['created_at']) : null,
    );
  }
}