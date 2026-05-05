import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:expense_insight/app/common/widgets/custom_snackbar.dart';
import 'package:expense_insight/app/common/widgets/result_dialog.dart';
import 'package:expense_insight/app/data/models/budget_model.dart';
import 'package:expense_insight/app/data/models/category_model.dart';
import 'package:expense_insight/app/data/network/api_exceptions.dart';
import 'package:expense_insight/features/budget/repositories/budget_repository.dart';

class BudgetController extends GetxController {
  final BudgetRepository _repository = BudgetRepository();

  final isLoading = false.obs;
  final isRefreshing = false.obs;
  final isSaving = false.obs;
  final budgets = <BudgetModel>[].obs;
  final selectedMonth = DateTime.now().month.obs;
  final selectedYear = DateTime.now().year.obs;

  // Form
  final amountController = TextEditingController();
  final Rx<CategoryModel?> selectedCategory = Rx<CategoryModel?>(null);
  final budgetFormKey = GlobalKey<FormState>();

  @override
  void onInit() {
    super.onInit();
    fetchBudgets();
  }

  Future<void> fetchBudgets({bool isRefresh = false}) async {
    try {
      if (isRefresh) {
        isRefreshing.value = true;
      }
      isLoading.value = true;
      final response = await _repository.getBudgets(
        month: selectedMonth.value,
        year: selectedYear.value,
      );

      if (response['success'] == true) {
        final List<dynamic> data = response['data'] ?? [];
        budgets.value = data.map((e) => BudgetModel.fromJson(e)).toList();
      }
    } catch (e) {
      CustomSnackbar.error(ApiExceptions.handleError(e));
    } finally {
      isLoading.value = false;
      isRefreshing.value = false;
    }
  }

  Future<void> createBudget() async {
    if (!budgetFormKey.currentState!.validate()) return;
    if (selectedCategory.value == null) {
      CustomSnackbar.error('Please select a category');
      return;
    }

    try {
      isSaving.value = true;
      final response = await _repository.createBudget(
        amount: double.parse(amountController.text),
        month: selectedMonth.value,
        year: selectedYear.value,
        categoryId: selectedCategory.value!.id,
      );

      if (response['success'] == true) {
        amountController.clear();
        selectedCategory.value = null;
        await ResultDialog.success(
          title: 'Budget Created!',
          message: 'Your budget has been set successfully.',
        );
        fetchBudgets();
      } else {
        await ResultDialog.error(
          title: 'Failed to Create',
          message: response['message'] ?? 'Something went wrong.',
        );
      }
    } catch (e) {
      await ResultDialog.error(
        title: 'Error',
        message: ApiExceptions.handleError(e),
      );
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> updateBudget(String id) async {
    if (!budgetFormKey.currentState!.validate()) return;

    try {
      isSaving.value = true;
      final response = await _repository.updateBudget(
        id,
        amount: double.parse(amountController.text),
      );

      if (response['success'] == true) {
        amountController.clear();
        await ResultDialog.success(
          title: 'Budget Updated!',
          message: 'Your budget has been updated successfully.',
        );
        fetchBudgets();
      } else {
        await ResultDialog.error(
          title: 'Failed to Update',
          message: response['message'] ?? 'Something went wrong.',
        );
      }
    } catch (e) {
      await ResultDialog.error(
        title: 'Error',
        message: ApiExceptions.handleError(e),
      );
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> deleteBudget(String id) async {
    try {
      final response = await _repository.deleteBudget(id);
      if (response['success'] == true) {
        budgets.removeWhere((b) => b.id == id);
        CustomSnackbar.success('Budget deleted successfully');
      } else {
        await ResultDialog.error(
          title: 'Failed to Delete',
          message: response['message'] ?? 'Something went wrong.',
        );
      }
    } catch (e) {
      await ResultDialog.error(
        title: 'Error',
        message: ApiExceptions.handleError(e),
      );
    }
  }

  void changeMonth(int month, int year) {
    selectedMonth.value = month;
    selectedYear.value = year;
    fetchBudgets();
  }

  @override
  void onClose() {
    amountController.dispose();
    super.onClose();
  }
}








