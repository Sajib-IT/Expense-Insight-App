import 'package:get/get.dart';
import 'package:expense_insight/features/splash/bindings/splash_binding.dart';
import 'package:expense_insight/features/splash/views/splash_screen.dart';
import 'package:expense_insight/features/auth/bindings/auth_binding.dart';
import 'package:expense_insight/features/auth/views/login_screen.dart';

class AppPages {
  AppPages._();

  static const initial = Routes.splash;

  static final pages = [
    GetPage(
      name: Routes.splash,
      page: () => const SplashScreen(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: Routes.login,
      page: () => const LoginScreen(),
      binding: AuthBinding(),
    ),
    // Add more pages here as features are built
  ];
}

class Routes {
  Routes._();

  static const String splash = '/splash';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String dashboard = '/dashboard';
  static const String addExpense = '/add-expense';
  static const String expenseDetail = '/expense-detail';
  static const String profile = '/profile';
  static const String settings = '/settings';
}


