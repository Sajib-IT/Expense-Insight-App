import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:expense_insight/app/common/widgets/custom_snackbar.dart';
import 'package:expense_insight/app/common/widgets/result_dialog.dart';
import 'package:expense_insight/app/data/models/expense_model.dart';
import 'package:expense_insight/app/data/models/api_response.dart';
import 'package:expense_insight/app/data/models/category_model.dart';
import 'package:expense_insight/app/data/network/api_exceptions.dart';
import 'package:expense_insight/features/expense/repositories/expense_repository.dart';

class ExpenseController extends GetxController {
  final ExpenseRepository _repository = ExpenseRepository();

  // Observables
  final isLoading = false.obs;
  final isRefreshing = false.obs;
  final isSaving = false.obs;
  final expenses = <ExpenseModel>[].obs;
  final Rx<PaginationMeta?> paginationMeta = Rx<PaginationMeta?>(null);

  // Filters
  final currentPage = 1.obs;
  final selectedType = Rx<String?>(null);
  final selectedCategoryId = Rx<String?>(null);
  final selectedStartDate = Rx<DateTime?>(null);
  final selectedEndDate = Rx<DateTime?>(null);
  final searchTerm = ''.obs;

  // Form controllers
  final amountController = TextEditingController();
  final descriptionController = TextEditingController();
  final selectedDate = DateTime.now().obs;
  final selectedTransactionType = TransactionType.EXPENSE.obs;
  final Rx<CategoryModel?> selectedCategory = Rx<CategoryModel?>(null);
  final expenseFormKey = GlobalKey<FormState>();

  @override
  void onInit() {
    super.onInit();
    fetchExpenses();
  }

  Future<void> fetchExpenses({bool loadMore = false, bool isRefresh = false}) async {
    try {
      if (loadMore) {
        if (paginationMeta.value != null &&
            currentPage.value >= paginationMeta.value!.totalPages) {
          return;
        }
        currentPage.value++;
      } else {
        currentPage.value = 1;
        if (isRefresh) {
          isRefreshing.value = true;
        }
        isLoading.value = true;
      }

      final response = await _repository.getExpenses(
        page: currentPage.value,
        type: selectedType.value,
        categoryId: selectedCategoryId.value,
        startDate: selectedStartDate.value?.toIso8601String().split('T').first,
        endDate: selectedEndDate.value?.toIso8601String().split('T').first,
        searchTerm: searchTerm.value.isNotEmpty ? searchTerm.value : null,
      );

      if (response['success'] == true) {
        final List<dynamic> data = response['data'] ?? [];
        final list = data.map((e) => ExpenseModel.fromJson(e)).toList();

        if (loadMore) {
          expenses.addAll(list);
        } else {
          expenses.value = list;
        }

        if (response['meta'] != null) {
          paginationMeta.value = PaginationMeta.fromJson(response['meta']);
        }
      }
    } catch (e) {
      CustomSnackbar.error(ApiExceptions.handleError(e));
    } finally {
      isLoading.value = false;
      isRefreshing.value = false;
    }
  }

  Future<void> createExpense() async {
    if (!expenseFormKey.currentState!.validate()) return;
    if (selectedCategory.value == null) {
      CustomSnackbar.error('Please select a category');
      return;
    }

    try {
      isSaving.value = true;
      final response = await _repository.createExpense(
        amount: double.parse(amountController.text),
        description: descriptionController.text.isNotEmpty
            ? descriptionController.text
            : null,
        date: selectedDate.value.toIso8601String().split('T').first,
        type: selectedTransactionType.value.value,
        categoryId: selectedCategory.value!.id,
      );

      if (response['success'] == true) {
        _clearForm();
        await ResultDialog.success(
          title: 'Transaction Added!',
          message: 'Your transaction has been added successfully.',
        );
        fetchExpenses();
      } else {
        await ResultDialog.error(
          title: 'Failed to Add',
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

  Future<void> updateExpense(String id) async {
    if (!expenseFormKey.currentState!.validate()) return;

    try {
      isSaving.value = true;
      final response = await _repository.updateExpense(
        id,
        amount: double.parse(amountController.text),
        description: descriptionController.text.isNotEmpty
            ? descriptionController.text
            : null,
        date: selectedDate.value.toIso8601String().split('T').first,
        type: selectedTransactionType.value.value,
        categoryId: selectedCategory.value?.id,
      );

      if (response['success'] == true) {
        _clearForm();
        await ResultDialog.success(
          title: 'Transaction Updated!',
          message: 'Your transaction has been updated successfully.',
        );
        fetchExpenses();
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

  Future<void> deleteExpense(String id) async {
    try {
      final response = await _repository.deleteExpense(id);
      if (response['success'] == true) {
        expenses.removeWhere((e) => e.id == id);
        CustomSnackbar.success('Transaction deleted successfully');
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

  void loadExpenseForEdit(ExpenseModel expense) {
    amountController.text = expense.amount.toString();
    descriptionController.text = expense.description ?? '';
    selectedDate.value = expense.date;
    selectedTransactionType.value = expense.type;
    selectedCategory.value = expense.category;
  }

  void applyFilters({
    String? type,
    String? categoryId,
    DateTime? startDate,
    DateTime? endDate,
    String? search,
  }) {
    selectedType.value = type;
    selectedCategoryId.value = categoryId;
    selectedStartDate.value = startDate;
    selectedEndDate.value = endDate;
    if (search != null) searchTerm.value = search;
    fetchExpenses();
  }

  void clearFilters() {
    selectedType.value = null;
    selectedCategoryId.value = null;
    selectedStartDate.value = null;
    selectedEndDate.value = null;
    searchTerm.value = '';
    fetchExpenses();
  }

  void _clearForm() {
    amountController.clear();
    descriptionController.clear();
    selectedDate.value = DateTime.now();
    selectedTransactionType.value = TransactionType.EXPENSE;
    selectedCategory.value = null;
  }

  @override
  void onClose() {
    amountController.dispose();
    descriptionController.dispose();
    super.onClose();
  }
}







