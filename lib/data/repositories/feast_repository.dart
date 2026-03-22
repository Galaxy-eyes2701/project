import 'package:sqflite/sqflite.dart';
import '../interface/ifeast_repository.dart';
import '../local/database_helper.dart';

class FeastRepository implements IFeastRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;


  @override
  Future<int> createFeast(Map<String, dynamic> feast) async {
    final db = await _dbHelper.database;
    return await db.insert('feasts', feast);
  }


  @override
  Future<List<Map<String, dynamic>>> getAllFeasts() async {
    final db = await _dbHelper.database;
    return await db.query('feasts', orderBy: 'created_at DESC');
  }


  @override
  Future<int> addRecipeToFeast(int feastId, int recipeId) async {
    final db = await _dbHelper.database;
    return await db.insert('feast_recipes', {
      'feast_id': feastId,
      'recipe_id': recipeId,
    });
  }


  @override
  Future<List<Map<String, dynamic>>> getRecipesForFeast(int feastId) async {
    final db = await _dbHelper.database;
    // Dùng INNER JOIN để lấy thông tin món ăn từ bảng recipes
    return await db.rawQuery('''
      SELECT r.* FROM recipes r
      INNER JOIN feast_recipes fr ON r.id = fr.recipe_id
      WHERE fr.feast_id = ?
    ''', [feastId]);
  }

  @override
  Future<int?> getTotalCookingSeconds(int feastId) async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery('''
      SELECT SUM(rs.duration_seconds) AS total
      FROM recipe_steps rs
      INNER JOIN feast_recipes fr ON rs.recipe_id = fr.recipe_id
      WHERE fr.feast_id = ?
    ''', [feastId]);


    final total = result.first['total'];
    if (total == null) return null;
    return (total as num).toInt();
  }


  @override
  Future<int> updateFeast(Map<String, dynamic> feast) async {
    final db = await _dbHelper.database;
    return await db.update(
      'feasts',
      feast,
      where: 'id = ?',
      whereArgs: [feast['id']],
    );
  }


  @override
  Future<int> deleteFeast(int id) async {
    final db = await _dbHelper.database;
    return await db.delete('feasts', where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<int> removeRecipeFromFeast(int feastId, int recipeId) async {
    final db = await _dbHelper.database;
    return await db.delete(
      'feast_recipes',
      where: 'feast_id = ? AND recipe_id = ?',
      whereArgs: [feastId, recipeId],
    );
  }
}