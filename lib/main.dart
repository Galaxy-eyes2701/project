import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'di.dart';
import 'viewmodels/feast_viewmodel.dart';
import 'viewmodels/recipe_viewmodel.dart';
import 'viewmodels/shopping_list_viewmodel.dart';


 import 'views/home/main_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  setupDI();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider.value(value: null),

        ChangeNotifierProvider(create: (_) => getIt<FeastViewModel>()),
        ChangeNotifierProvider(create: (_) => getIt<RecipeViewModel>()),
        ChangeNotifierProvider(create: (_) => getIt<ShoppingListViewModel>()),
      ],
      child: MaterialApp(
        title: 'Sổ tay Mâm cỗ',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.red,
            primary: Colors.red,
            secondary: Colors.amber,
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            centerTitle: true,
            elevation: 0,
          ),
          useMaterial3: true,
        ),
        home: const MainView(),
      ),
    );
  }
}

class PlaceholderScreen extends StatelessWidget {
  const PlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sổ tay Mâm cỗ Tết'),
      ),
      body: const Center(
        child: Text(
          'Đang chờ xây dựng View và ViewModel... 🚀',
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      ),
    );
  }
}