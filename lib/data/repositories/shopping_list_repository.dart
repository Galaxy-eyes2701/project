import 'package:sqflite/sqflite.dart';
import '../interface/ishopping_list_repository.dart';
import '../local/database_helper.dart';

class ShoppingListRepository implements IShoppingListRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  @override
  Future<int> createShoppingList(Map<String, dynamic> listInfo) async {
    final db = await _dbHelper.database;
    return await db.insert('shopping_lists', listInfo);
  }

  @override
  Future<int> addItemToList(Map<String, dynamic> item) async {
    final db = await _dbHelper.database;
    return await db.insert('shopping_list_items', item);
  }

  @override
  Future<List<Map<String, dynamic>>> getItemsForList(int listId) async {
    final db = await _dbHelper.database;
    return await db.query(
      'shopping_list_items',
      where: 'shopping_list_id = ?',
      whereArgs: [listId],
    );
  }

  @override
  Future<List<Map<String, dynamic>>> getAllShoppingLists() async {
    final db = await _dbHelper.database;
    return await db.query('shopping_lists', orderBy: 'created_at DESC');
  }

  @override
  Future<int> toggleItemChecked(int itemId, bool isChecked) async {
    final db = await _dbHelper.database;
    return await db.update(
      'shopping_list_items',
      {'is_checked': isChecked ? 1 : 0},
      where: 'id = ?',
      whereArgs: [itemId],
    );
  }

  @override
  Future<int> updateItem(Map<String, dynamic> item) async {
    final db = await _dbHelper.database;
    return await db.update(
      'shopping_list_items',
      {
        'ingredient_name': item['ingredient_name'],
        'quantity':        item['quantity'],
        'unit':            item['unit'],
      },
      where: 'id = ?',
      whereArgs: [item['id']],
    );
  }

  @override
  Future<int> updateShoppingList(Map<String, dynamic> listInfo) async {
    final db = await _dbHelper.database;
    return await db.update(
      'shopping_lists',
      listInfo,
      where: 'id = ?',
      whereArgs: [listInfo['id']],
    );
  }

  @override
  Future<int> deleteShoppingList(int id) async {
    final db = await _dbHelper.database;
    return await db.delete(
        'shopping_lists', where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<int> deleteItemFromList(int itemId) async {
    final db = await _dbHelper.database;
    return await db.delete(
        'shopping_list_items', where: 'id = ?', whereArgs: [itemId]);
  }
}