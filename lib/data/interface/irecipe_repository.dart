abstract class IRecipeRepository {

  Future<List<Map<String, dynamic>>> getAllRecipes();
  Future<int> insertRecipeWithSteps(Map<String, dynamic> recipe, List<Map<String, dynamic>> steps);
  Future<int> updateRecipe(Map<String, dynamic> recipe);
  Future<void> updateRecipeSteps(int recipeId, List<Map<String, dynamic>> newSteps);
  Future<int> deleteRecipe(int id);
  Future<List<Map<String, dynamic>>> getStepsForRecipe(int recipeId);

}