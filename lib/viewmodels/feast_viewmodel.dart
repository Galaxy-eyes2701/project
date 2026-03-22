import 'package:flutter/foundation.dart';
import '../data/repositories/feast_repository.dart';
import '../domain/entities/feast.dart';
import '../domain/entities/recipe.dart';

class FeastViewModel extends ChangeNotifier {
  final FeastRepository _repository;

  List<Feast> _feasts = [];
  List<Feast> get feasts => _feasts;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  final Map<int, List<Recipe>> _recipesCache = {};

  FeastViewModel(this._repository) {
    loadFeasts();
  }

  // ── Tải danh sách mâm cỗ ────────────────────────────────────────────────────
  Future<void> loadFeasts() async {
    _isLoading = true;
    notifyListeners();

    final List<Map<String, dynamic>> maps = await _repository.getAllFeasts();
    _feasts = maps.map((map) => Feast.fromMap(map)).toList();

    _isLoading = false;
    notifyListeners();
  }

  // ── CRUD mâm cỗ ─────────────────────────────────────────────────────────────
  Future<void> createFeast(Feast feast) async {
    final map = feast.toMap()..remove('id');
    await _repository.createFeast(map);
    await loadFeasts();
  }

  Future<void> updateFeast(Feast feast) async {
    await _repository.updateFeast(feast.toMap());
    await loadFeasts();
  }

  Future<void> deleteFeast(int id) async {
    await _repository.deleteFeast(id);
    _recipesCache.remove(id);
    await loadFeasts();
  }

  Future<List<Recipe>> loadRecipesForFeast(int feastId) async {
    if (_recipesCache.containsKey(feastId)) {
      return _recipesCache[feastId]!;
    }
    final maps = await _repository.getRecipesForFeast(feastId);
    final recipes = maps.map((map) => Recipe.fromMap(map)).toList();
    _recipesCache[feastId] = recipes;
    return recipes;
  }

  // ── Thêm / xoá món ăn khỏi mâm cỗ ──────────────────────────────────────────
  Future<void> addRecipeToFeast(int feastId, int recipeId) async {
    await _repository.addRecipeToFeast(feastId, recipeId);
    _recipesCache.remove(feastId);
    notifyListeners();
  }

  Future<void> removeRecipeFromFeast(int feastId, int recipeId) async {
    await _repository.removeRecipeFromFeast(feastId, recipeId);
    _recipesCache.remove(feastId);
    notifyListeners();
  }

  // ── Tính tổng thời gian nấu của mâm cỗ ─────────────────────────────────────
  Future<String?> getTotalCookingTime(int feastId) async {
    final totalSeconds = await _repository.getTotalCookingSeconds(feastId);

    if (totalSeconds == null || totalSeconds == 0) return null;

    final hours   = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;

    if (hours > 0 && minutes > 0) return '~$hours giờ $minutes phút';
    if (hours > 0) return '~$hours giờ';
    return '~$minutes phút';
  }
}