import 'package:get_it/get_it.dart';

import 'data/local/database_helper.dart';
import 'data/repositories/feast_repository.dart';
import 'data/repositories/recipe_repository.dart';
import 'data/repositories/shopping_list_repository.dart';

import 'viewmodels/feast_viewmodel.dart';
import 'viewmodels/recipe_viewmodel.dart';
import 'viewmodels/shopping_list_viewmodel.dart';

final getIt = GetIt.instance;

void setupDI() {

  getIt.registerLazySingleton<DatabaseHelper>(() => DatabaseHelper.instance);

  getIt.registerLazySingleton<FeastRepository>(() => FeastRepository());
  getIt.registerLazySingleton<RecipeRepository>(() => RecipeRepository());
  getIt.registerLazySingleton<ShoppingListRepository>(() => ShoppingListRepository());

  getIt.registerFactory<FeastViewModel>(() => FeastViewModel(getIt<FeastRepository>()));
  getIt.registerFactory<RecipeViewModel>(() => RecipeViewModel(getIt<RecipeRepository>()));
  getIt.registerFactory<ShoppingListViewModel>(() => ShoppingListViewModel(getIt<ShoppingListRepository>()));
}