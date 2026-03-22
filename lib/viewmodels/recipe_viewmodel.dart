import 'package:flutter/foundation.dart';
import '../data/repositories/recipe_repository.dart';
import '../domain/entities/recipe.dart';
import '../domain/entities/recipe_step.dart';

class RecipeViewModel extends ChangeNotifier {
  final RecipeRepository _repository;

  List<Recipe> _recipes = [];
  List<Recipe> _filteredRecipes = [];
  String _selectedCategory = 'Tất cả';

  // ── Getters ──────────────────────────────────────────────────────────────────
  List<Recipe> get recipes => _filteredRecipes;
  String get selectedCategory => _selectedCategory;

  List<String> get categories {
    final cats = _recipes
        .map((r) => r.category ?? 'Chưa phân loại')
        .toSet()
        .toList();
    cats.insert(0, 'Tất cả');
    return cats;
  }

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  RecipeViewModel(this._repository) {
    loadRecipes();
  }

  // ── Lấy danh sách công thức từ DB ────────────────────────────────────────────
  Future<void> loadRecipes() async {
    _isLoading = true;
    notifyListeners();

    final List<Map<String, dynamic>> maps = await _repository.getAllRecipes();
    _recipes = maps.map((map) => Recipe.fromMap(map)).toList();
    _applyFilter();

    _isLoading = false;
    notifyListeners();
  }

  // ── Lọc theo category  ───────────────────────────
  void _applyFilter() {
    if (_selectedCategory == 'Tất cả') {
      _filteredRecipes = List.from(_recipes);
    } else {
      _filteredRecipes = _recipes
          .where((r) => r.category == _selectedCategory)
          .toList();
    }
  }

  // ── Người dùng chọn category ─────────────────────────────────────────────────
  void setCategoryFilter(String category) {
    _selectedCategory = category;
    _applyFilter();
    notifyListeners();
  }

  // ── Thêm công thức mới kèm các bước làm ─────────────────────────────────────
  Future<void> addRecipeWithSteps(
      Recipe recipe, List<RecipeStep> steps) async {
    final recipeMap = recipe.toMap()..remove('id');
    final stepsMap = steps.map((s) => s.toMap()..remove('id')).toList();

    await _repository.insertRecipeWithSteps(recipeMap, stepsMap);
    await loadRecipes();
  }

  // ── Cập nhật công thức ───────────────────────────────────────────────────────
  Future<void> updateRecipeWithSteps(
      Recipe recipe, List<RecipeStep> steps) async {
    final recipeMap = recipe.toMap();
    final stepsMap = steps.map((s) => s.toMap()..remove('id')).toList();

    await _repository.updateRecipe(recipeMap);
    await _repository.updateRecipeSteps(recipe.id!, stepsMap);
    await loadRecipes();
  }

  // ── Xóa công thức ────────────────────────────────────────────────────────────
  Future<void> deleteRecipe(int id) async {
    await _repository.deleteRecipe(id);
    await loadRecipes();
  }

  // ── Lấy các bước làm của 1 công thức ────────────────────────────────────────
  Future<List<RecipeStep>> loadStepsForRecipe(int recipeId) async {
    final maps = await _repository.getStepsForRecipe(recipeId);
    return maps.map((map) => RecipeStep.fromMap(map)).toList();
  }
}