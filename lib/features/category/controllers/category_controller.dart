import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:expense_insight/app/common/widgets/custom_snackbar.dart';
import 'package:expense_insight/app/common/widgets/result_dialog.dart';
import 'package:expense_insight/app/data/models/category_model.dart';
import 'package:expense_insight/app/data/network/api_exceptions.dart';
import 'package:expense_insight/features/category/repositories/category_repository.dart';

class CategoryController extends GetxController {
  final CategoryRepository _repository = CategoryRepository();

  final isLoading = false.obs;
  final isSaving = false.obs;
  final isCreatingQuickCategory = false.obs;
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

  static const List<String> availableColours = [
    '#FF5733', '#28A745', '#007BFF', '#6200EE', '#FFC107',
    '#E91E63', '#00BCD4', '#FF9800', '#795548', '#9C27B0',
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
        _setCategories(list);
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
        if (response['data'] != null) {
          _upsertCategory(CategoryModel.fromJson(response['data']));
        } else {
          await fetchCategories();
        }
        _clearForm();
        await ResultDialog.success(
          title: 'Category Created!',
          message: 'Your new category has been created successfully.',
        );
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
        if (response['data'] != null) {
          _upsertCategory(CategoryModel.fromJson(response['data']));
        } else {
          await fetchCategories();
        }
        _clearForm();
        await ResultDialog.success(
          title: 'Category Updated!',
          message: 'Your category has been updated successfully.',
        );
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

  Future<CategoryModel?> createQuickCategory({
    required String name,
    required TransactionType type,
    required String icon,
    required String colour,
  }) async {
    try {
      isCreatingQuickCategory.value = true;

      final response = await _repository.createCategory(
        name: name.trim(),
        type: type.value,
        icon: icon,
        colour: colour,
      );

      if (response['success'] != true) {
        CustomSnackbar.error(response['message'] ?? 'Failed to create category');
        return null;
      }

      CategoryModel? createdCategory;
      if (response['data'] != null) {
        createdCategory = CategoryModel.fromJson(response['data']);
        _upsertCategory(createdCategory);
      } else {
        await fetchCategories();
        createdCategory = _findCategoryByNameAndType(name, type);
      }

      if (createdCategory != null) {
        CustomSnackbar.success('Category created successfully');
      }

      return createdCategory;
    } catch (e) {
      CustomSnackbar.error(ApiExceptions.handleError(e));
      return null;
    } finally {
      isCreatingQuickCategory.value = false;
    }
  }

  Future<void> deleteCategory(String id) async {
    try {
      final response = await _repository.deleteCategory(id);
      if (response['success'] == true) {
        categories.removeWhere((c) => c.id == id);
        expenseCategories.removeWhere((c) => c.id == id);
        incomeCategories.removeWhere((c) => c.id == id);
        CustomSnackbar.success('Category deleted successfully');
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

  void _setCategories(List<CategoryModel> list) {
    categories.value = list;
    expenseCategories.value = list.where((c) => c.type == TransactionType.EXPENSE).toList();
    incomeCategories.value = list.where((c) => c.type == TransactionType.INCOME).toList();
  }

  void _upsertCategory(CategoryModel category) {
    final updated = [...categories];
    final index = updated.indexWhere((item) => item.id == category.id);

    if (index == -1) {
      updated.add(category);
    } else {
      updated[index] = category;
    }

    _setCategories(updated);
  }

  CategoryModel? _findCategoryByNameAndType(String name, TransactionType type) {
    final normalized = name.trim().toLowerCase();

    try {
      return categories.firstWhere(
        (category) =>
            category.type == type && category.name.trim().toLowerCase() == normalized,
      );
    } catch (_) {
      return null;
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    super.onClose();
  }
}

