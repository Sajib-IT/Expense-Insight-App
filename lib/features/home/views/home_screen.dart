import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:expense_insight/features/home/controllers/home_controller.dart';
import 'package:expense_insight/features/dashboard/views/dashboard_screen.dart';
import 'package:expense_insight/features/expense/views/expense_list_screen.dart';
import 'package:expense_insight/features/budget/views/budget_list_screen.dart';
import 'package:expense_insight/features/profile/views/profile_screen.dart';

class HomeScreen extends GetView<HomeController> {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screens = [
      const DashboardScreen(),
      const ExpenseListScreen(),
      const BudgetListScreen(),
      const ProfileScreen(),
    ];

    return Obx(
      () => Scaffold(
        body: IndexedStack(
          index: controller.currentIndex.value,
          children: screens,
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: controller.currentIndex.value,
          onDestinationSelected: controller.changePage,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.dashboard_outlined),
              selectedIcon: Icon(Icons.dashboard),
              label: 'Dashboard',
            ),
            NavigationDestination(
              icon: Icon(Icons.receipt_long_outlined),
              selectedIcon: Icon(Icons.receipt_long),
              label: 'Transactions',
            ),
            NavigationDestination(
              icon: Icon(Icons.account_balance_wallet_outlined),
              selectedIcon: Icon(Icons.account_balance_wallet),
              label: 'Budgets',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outlined),
              selectedIcon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}

