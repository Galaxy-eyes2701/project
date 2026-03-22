abstract class IFeastRepository {

  Future<int> createFeast(Map<String, dynamic> feast);
  Future<List<Map<String, dynamic>>> getAllFeasts();
  Future<int> addRecipeToFeast(int feastId, int recipeId);
  Future<List<Map<String, dynamic>>> getRecipesForFeast(int feastId);
  Future<int?> getTotalCookingSeconds(int feastId);
  Future<int> updateFeast(Map<String, dynamic> feast);
  Future<int> deleteFeast(int id);
  Future<int> removeRecipeFromFeast(int feastId, int recipeId);

}