class ShoppingItem {
  final int? id;
  final int? shoppingListId;
  final String ingredientName;
  final double? quantity;
  final String? unit;
  final bool isChecked;

  ShoppingItem({
    this.id,
    this.shoppingListId,
    required this.ingredientName,
    this.quantity,
    this.unit,
    this.isChecked = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'shopping_list_id': shoppingListId,
      'ingredient_name': ingredientName,
      'quantity': quantity,
      'unit': unit,
      'is_checked': isChecked ? 1 : 0,
    };
  }

  factory ShoppingItem.fromMap(Map<String, dynamic> map) {
    return ShoppingItem(
      id: map['id'],
      shoppingListId: map['shopping_list_id'],
      ingredientName: map['ingredient_name'],
      quantity: map['quantity'],
      unit: map['unit'],
      isChecked: map['is_checked'] == 1,
    );
  }
}