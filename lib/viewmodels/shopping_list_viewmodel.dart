import 'package:flutter/foundation.dart';
import '../data/repositories/shopping_list_repository.dart';
import '../domain/entities/shopping_list.dart';
import '../domain/entities/shopping_item.dart';

class ShoppingListViewModel extends ChangeNotifier {
  final ShoppingListRepository _repository;

  List<ShoppingList> _shoppingLists = [];
  List<ShoppingList> get shoppingLists => _shoppingLists;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  ShoppingListViewModel(this._repository) {
    loadShoppingLists();
  }

  // ---- QUẢN LÝ DANH SÁCH CHÍNH ----

  Future<void> loadShoppingLists() async {
    _isLoading = true;
    notifyListeners();

    final maps = await _repository.getAllShoppingLists();
    _shoppingLists = maps.map((map) => ShoppingList.fromMap(map)).toList();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> createShoppingList(ShoppingList list) async {
    final map = list.toMap();
    map.remove('id');
    await _repository.createShoppingList(map);
    await loadShoppingLists();
  }

  Future<void> updateShoppingList(ShoppingList list) async {
    await _repository.updateShoppingList(list.toMap());
    await loadShoppingLists();
  }

  Future<void> deleteShoppingList(int id) async {
    await _repository.deleteShoppingList(id);
    await loadShoppingLists();
  }

  // ---- QUẢN LÝ MÓN ĐỒ BÊN TRONG (ITEMS) ----

  Future<List<ShoppingItem>> loadItems(int listId) async {
    final maps = await _repository.getItemsForList(listId);
    return maps.map((map) => ShoppingItem.fromMap(map)).toList();
  }

  Future<void> addItem(ShoppingItem item) async {
    final map = item.toMap();
    map.remove('id');
    await _repository.addItemToList(map);
    notifyListeners();
  }

  Future<void> updateItem(ShoppingItem item) async {
    await _repository.updateItem(item.toMap());
    notifyListeners();
  }

  Future<void> toggleItemCheck(int itemId, bool isChecked) async {
    await _repository.toggleItemChecked(itemId, isChecked);
    notifyListeners();
  }

  Future<void> deleteItem(int itemId) async {
    await _repository.deleteItemFromList(itemId);
    notifyListeners();
  }
}