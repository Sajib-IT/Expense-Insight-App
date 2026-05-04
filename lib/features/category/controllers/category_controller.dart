import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:expense_insight/app/common/widgets/custom_snackbar.dart';
import 'package:expense_insight/app/data/models/category_model.dart';
import 'package:expense_insight/app/data/network/api_exceptions.dart';
import 'package:expense_insight/features/category/repositories/category_repository.dart';

class CategoryController extends GetxController {
  final CategoryRepository _repository = CategoryRepository();

  final isLoading = false.obs;
  final isSaving = false.obs;
  final categories = <CategoryModel>[].obs;
  final expenseCategories = <CategoryModel>[].obs;
  final incomeCategories = <CategoryModel>[].obs;

  // Form
  final nameController = TextEditingController();
  final selectedType = TransactionType.EXPENSE.obs;
  final selectedIcon = '📦'.obs;
  final selectedColour = '#6200EE'.obs;
  final categoryFormKey = GlobalKey<FormState>();

  // Available icons for selection
  static const List<String> availableIcons = [
    '🍔', '🛒', '🏠', '🚗', '💊', '🎬', '📚', '✈️', '👕', '💰',
    '💼', '🎮', '⚡', '📱', '🎁', '🏋️', '🍕', '☕', '🚌', '📦',
    '💳', '🏥', '🎓', '🔧', '💄', '🐕', '🌐', '📰', '🏦', '💵',
  ];

  @override
  void onInit() {
    super.onInit();
    fetchCategories();
  }

  Future<void> fetchCategories({String? type}) async {
    try {
      isLoading.value = true;
      final response = await _repository.getCategories(type: type);

      if (response['success'] == true) {
        final List<dynamic> data = response['data'] ?? [];
        final list = data.map((e) => CategoryModel.fromJson(e)).toList();
        categories.value = list;
        expenseCategories.value =
            list.where((c) => c.type == TransactionType.EXPENSE).toList();
        incomeCategories.value =
            list.where((c) => c.type == TransactionType.INCOME).toList();
      }
    } catch (e) {
      CustomSnackbar.error(ApiExceptions.handleError(e));
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createCategory() async {
    if (!categoryFormKey.currentState!.validate()) return;

    try {
      isSaving.value = true;
      final response = await _repository.createCategory(
        name: nameController.text.trim(),
        type: selectedType.value.value,
        icon: selectedIcon.value,
        colour: selectedColour.value,
      );

      if (response['success'] == true) {
        _clearForm();
        CustomSnackbar.success('Category created successfully');
        Get.back();
        fetchCategories();
      } else {
        CustomSnackbar.error(response['message'] ?? 'Failed to create category');
      }
    } catch (e) {
      CustomSnackbar.error(ApiExceptions.handleError(e));
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> updateCategory(String id) async {
    if (!categoryFormKey.currentState!.validate()) return;

    try {
      isSaving.value = true;
      final response = await _repository.updateCategory(
        id,
        name: nameController.text.trim(),
        type: selectedType.value.value,
        icon: selectedIcon.value,
        colour: selectedColour.value,
      );

      if (response['success'] == true) {
        _clearForm();
        CustomSnackbar.success('Category updated successfully');
        Get.back();
        fetchCategories();
      } else {
        CustomSnackbar.error(response['message'] ?? 'Failed to update category');
      }
    } catch (e) {
      CustomSnackbar.error(ApiExceptions.handleError(e));
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> deleteCategory(String id) async {
    try {
      final response = await _repository.deleteCategory(id);
      if (response['success'] == true) {
        categories.removeWhere((c) => c.id == id);
        expenseCategories.removeWhere((c) => c.id == id);
        incomeCategories.removeWhere((c) => c.id == id);
        CustomSnackbar.success('Category deleted');
      } else {
        CustomSnackbar.error(response['message'] ?? 'Failed to delete category');
      }
    } catch (e) {
      CustomSnackbar.error(ApiExceptions.handleError(e));
    }
  }

  void loadCategoryForEdit(CategoryModel category) {
    nameController.text = category.name;
    selectedType.value = category.type;
    selectedIcon.value = category.icon ?? '📦';
    selectedColour.value = category.colour ?? '#6200EE';
  }

  void _clearForm() {
    nameController.clear();
    selectedType.value = TransactionType.EXPENSE;
    selectedIcon.value = '📦';
    selectedColour.value = '#6200EE';
  }

  @override
  void onClose() {
    nameController.dispose();
    super.onClose();
  }
}

