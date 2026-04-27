import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'data/database/app_database.dart';
import 'data/repositories/product_repository.dart';
import 'data/repositories/stock_repository.dart';
import 'ui/screens/home/home_screen.dart';
import 'ui/screens/home/home_controller.dart';

class App extends StatelessWidget {
  final AppDatabase database;

  const App({super.key, required this.database});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AppDatabase>.value(value: database),
        Provider<ProductRepository>(
          create: (context) => ProductRepository(context.read<AppDatabase>()),
        ),
        Provider<StockRepository>(
          create: (context) => StockRepository(context.read<AppDatabase>()),
        ),
        ChangeNotifierProvider<HomeController>(
          create: (context) => HomeController(
            productRepository: context.read<ProductRepository>(),
            stockRepository: context.read<StockRepository>(),
          )..loadProducts(),
        ),
      ],
      child: MaterialApp(
        title: 'Panaderia ERP',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),
          useMaterial3: true,
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
