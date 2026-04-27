import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../expenses/expense_controller.dart';
import '../expenses/expenses_screen.dart';
import '../home/home_controller.dart';
import '../home/home_screen.dart';
import '../sales/sales_controller.dart';
import '../sales/sales_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  static const _pages = <Widget>[
    HomeScreen(),
    SalesScreen(),
    ExpensesScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.inventory_2_outlined),
            label: 'Productos',
          ),
          NavigationDestination(
            icon: Icon(Icons.point_of_sale_outlined),
            label: 'Ventas',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            label: 'Egresos',
          ),
        ],
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });

          if (index == 0) {
            context.read<HomeController>().loadProducts();
          } else if (index == 1) {
            context.read<SalesController>().loadProducts();
          } else {
            context.read<ExpenseController>().loadExpenses();
          }
        },
      ),
    );
  }
}
