import 'package:get/get.dart';
import 'package:expense_insight/features/splash/bindings/splash_binding.dart';
import 'package:expense_insight/features/splash/views/splash_screen.dart';
import 'package:expense_insight/features/auth/bindings/auth_binding.dart';
import 'package:expense_insight/features/auth/views/login_screen.dart';
import 'package:expense_insight/features/auth/views/register_screen.dart';
import 'package:expense_insight/features/auth/views/forgot_password_screen.dart';
import 'package:expense_insight/features/auth/views/change_password_screen.dart';
import 'package:expense_insight/features/home/bindings/home_binding.dart';
import 'package:expense_insight/features/home/views/home_screen.dart';
import 'package:expense_insight/features/expense/views/add_expense_screen.dart';
import 'package:expense_insight/features/expense/views/expense_detail_screen.dart';
import 'package:expense_insight/features/budget/views/add_budget_screen.dart';
import 'package:expense_insight/features/category/views/category_list_screen.dart';
import 'package:expense_insight/features/category/views/add_category_screen.dart';
import 'package:expense_insight/features/profile/views/edit_profile_screen.dart';
import 'package:expense_insight/features/ai_extract/bindings/ai_extract_binding.dart';
import 'package:expense_insight/features/ai_extract/views/ai_extract_screen.dart';

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
    GetPage(
      name: Routes.register,
      page: () => const RegisterScreen(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: Routes.forgotPassword,
      page: () => const ForgotPasswordScreen(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: Routes.changePassword,
      page: () => const ChangePasswordScreen(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: Routes.home,
      page: () => const HomeScreen(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: Routes.addExpense,
      page: () => const AddExpenseScreen(),
    ),
    GetPage(
      name: Routes.expenseDetail,
      page: () => const ExpenseDetailScreen(),
    ),
    GetPage(
      name: Routes.addBudget,
      page: () => const AddBudgetScreen(),
    ),
    GetPage(
      name: Routes.categories,
      page: () => const CategoryListScreen(),
    ),
    GetPage(
      name: Routes.addCategory,
      page: () => const AddCategoryScreen(),
    ),
    GetPage(
      name: Routes.editProfile,
      page: () => const EditProfileScreen(),
    ),
    GetPage(
      name: Routes.aiExtract,
      page: () => const AiExtractScreen(),
      binding: AiExtractBinding(),
    ),
  ];
}

class Routes {
  Routes._();

  static const String splash = '/splash';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String changePassword = '/change-password';
  static const String home = '/home';
  static const String addExpense = '/add-expense';
  static const String expenseDetail = '/expense-detail';
  static const String addBudget = '/add-budget';
  static const String categories = '/categories';
  static const String addCategory = '/add-category';
  static const String profile = '/profile';
  static const String editProfile = '/edit-profile';
  static const String aiExtract = '/ai-extract';
  static const String settings = '/settings';
}

