import 'package:get/get.dart';
import 'package:expense_insight/features/home/controllers/home_controller.dart';
import 'package:expense_insight/features/dashboard/controllers/dashboard_controller.dart';
import 'package:expense_insight/features/expense/controllers/expense_controller.dart';
import 'package:expense_insight/features/budget/controllers/budget_controller.dart';
import 'package:expense_insight/features/profile/controllers/profile_controller.dart';
import 'package:expense_insight/features/category/controllers/category_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeController>(() => HomeController());
    Get.lazyPut<DashboardController>(() => DashboardController());
    Get.lazyPut<ExpenseController>(() => ExpenseController());
    Get.lazyPut<BudgetController>(() => BudgetController());
    Get.lazyPut<ProfileController>(() => ProfileController());
    Get.lazyPut<CategoryController>(() => CategoryController());
  }
}

