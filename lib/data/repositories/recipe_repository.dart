import 'package:sqflite/sqflite.dart';
import '../interface/irecipe_repository.dart';
import '../local/database_helper.dart';

class RecipeRepository implements IRecipeRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  @override
  Future<List<Map<String, dynamic>>> getAllRecipes() async {
    final db = await _dbHelper.database;
    return await db.query('recipes', orderBy: 'created_at DESC');
  }

  @override
  Future<int> insertRecipeWithSteps(
      Map<String, dynamic> recipe, List<Map<String, dynamic>> steps) async {
    final db = await _dbHelper.database;
    int recipeId = 0;

    await db.transaction((txn) async {
      recipeId = await txn.insert('recipes', recipe);

      for (var step in steps) {
        step['recipe_id'] = recipeId;
        await txn.insert('recipe_steps', step);
      }
    });

    return recipeId;
  }


  @override
  Future<int> updateRecipe(Map<String, dynamic> recipe) async {
    final db = await _dbHelper.database;
    return await db.update(
      'recipes',
      recipe,
      where: 'id = ?',
      whereArgs: [recipe['id']],
    );
  }

  @override
  Future<void> updateRecipeSteps(int recipeId, List<Map<String, dynamic>> newSteps) async {
    final db = await _dbHelper.database;
    await db.transaction((txn) async {
      await txn.delete('recipe_steps', where: 'recipe_id = ?', whereArgs: [recipeId]);
      for (var step in newSteps) {
        step['recipe_id'] = recipeId;
        await txn.insert('recipe_steps', step);
      }
    });
  }

  @override
  Future<int> deleteRecipe(int id) async {
    final db = await _dbHelper.database;
    return await db.delete('recipes', where: 'id = ?', whereArgs: [id]);
  }


  @override
  Future<List<Map<String, dynamic>>> getStepsForRecipe(int recipeId) async {
    final db = await _dbHelper.database;
    return await db.query(
        'recipe_steps',
        where: 'recipe_id = ?',
        whereArgs: [recipeId],
        orderBy: 'step_number ASC'
    );
  }
}