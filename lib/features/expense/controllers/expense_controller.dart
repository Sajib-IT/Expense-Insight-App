import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:expense_insight/app/common/widgets/custom_snackbar.dart';
import 'package:expense_insight/app/common/widgets/result_dialog.dart';
import 'package:expense_insight/app/data/models/ai_extract_model.dart';
import 'package:expense_insight/app/data/models/expense_model.dart';
import 'package:expense_insight/app/data/models/api_response.dart';
import 'package:expense_insight/app/data/models/category_model.dart';
import 'package:expense_insight/app/data/network/api_exceptions.dart';
import 'package:expense_insight/features/expense/repositories/expense_repository.dart';

class ExpenseController extends GetxController {
  final ExpenseRepository _repository = ExpenseRepository();
  final ImagePicker _picker = ImagePicker();

  // Observables
  final isLoading = false.obs;
  final isRefreshing = false.obs;
  final isSaving = false.obs;
  final isUploadingReceipt = false.obs;
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

  void resetForm() {
    _clearForm();
  }

  void updateTransactionType(TransactionType type) {
    selectedTransactionType.value = type;
    if (selectedCategory.value?.type != type) {
      selectedCategory.value = null;
    }
  }

  void loadAiExtractDraft(
    AiExtractModel data, {
    List<CategoryModel> availableCategories = const [],
  }) {
    amountController.text = data.amount != null && data.amount! > 0 ? data.amount!.toString() : '';
    descriptionController.text = _buildSuggestedDescription(data);
    selectedDate.value = _parseExtractedDate(data.date) ?? DateTime.now();
    selectedTransactionType.value = TransactionType.fromString(data.type ?? 'EXPENSE');
    selectedCategory.value = findMatchingCategory(
      categoryName: data.category,
      type: selectedTransactionType.value,
      availableCategories: availableCategories,
    );
  }

  CategoryModel? findMatchingCategory({
    required String? categoryName,
    required TransactionType type,
    required List<CategoryModel> availableCategories,
  }) {
    final query = _normalizeCategory(categoryName);
    if (query.isEmpty) return null;

    final filtered = availableCategories.where((category) => category.type == type).toList();
    if (filtered.isEmpty) return null;

    for (final category in filtered) {
      if (_normalizeCategory(category.name) == query) {
        return category;
      }
    }

    for (final category in filtered) {
      final normalizedName = _normalizeCategory(category.name);
      if (normalizedName.contains(query) || query.contains(normalizedName)) {
        return category;
      }
    }

    return null;
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

  String _buildSuggestedDescription(AiExtractModel data) {
    final extractedDescription = data.description?.trim();
    if (extractedDescription != null && extractedDescription.isNotEmpty) {
      return extractedDescription;
    }

    final merchant = data.merchant?.trim();
    final itemNames = data.items
            ?.map((item) => item.name?.trim())
            .whereType<String>()
            .where((item) => item.isNotEmpty)
            .take(3)
            .toList() ??
        <String>[];

    if (merchant != null && merchant.isNotEmpty && itemNames.isNotEmpty) {
      return '$merchant - ${itemNames.join(', ')}';
    }

    if (merchant != null && merchant.isNotEmpty) {
      return merchant;
    }

    return itemNames.join(', ');
  }

  DateTime? _parseExtractedDate(String? rawDate) {
    if (rawDate == null || rawDate.trim().isEmpty) return null;

    final value = rawDate.trim();
    final parsed = DateTime.tryParse(value);
    if (parsed != null) {
      return parsed;
    }

    const patterns = [
      'yyyy-MM-dd',
      'dd/MM/yyyy',
      'MM/dd/yyyy',
      'dd-MM-yyyy',
      'MMM d, yyyy',
      'MMMM d, yyyy',
      'd MMM yyyy',
      'd MMMM yyyy',
    ];

    for (final pattern in patterns) {
      try {
        return DateFormat(pattern).parseStrict(value);
      } catch (_) {
        // Try the next supported format.
      }
    }

    return null;
  }

  String _normalizeCategory(String? value) {
    return (value ?? '').toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
  }

  /// Upload receipt image/PDF for an expense
  Future<void> uploadReceipt(String expenseId, {ImageSource source = ImageSource.gallery}) async {
    try {
      final XFile? file = await _picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      if (file == null) return;

      isUploadingReceipt.value = true;
      final response = await _repository.uploadReceipt(expenseId, file.path);

      if (response['success'] == true) {
        // Update expense in local list
        if (response['data'] != null) {
          final updatedExpense = ExpenseModel.fromJson(response['data']);
          final index = expenses.indexWhere((e) => e.id == expenseId);
          if (index != -1) {
            expenses[index] = updatedExpense;
          }
        }
        await ResultDialog.success(
          title: 'Receipt Uploaded!',
          message: 'Your receipt has been attached to the transaction.',
        );
      } else {
        await ResultDialog.error(
          title: 'Upload Failed',
          message: response['message'] ?? 'Something went wrong.',
        );
      }
    } catch (e) {
      await ResultDialog.error(
        title: 'Error',
        message: ApiExceptions.handleError(e),
      );
    } finally {
      isUploadingReceipt.value = false;
    }
  }

  /// Show bottom sheet to choose receipt upload source
  void showReceiptOptions(String expenseId) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Get.theme.scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Upload Receipt',
              style: Get.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Attach a receipt image to this transaction',
              style: Get.textTheme.bodyMedium?.copyWith(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ListTile(
              leading: CircleAvatar(
                backgroundColor: Get.theme.colorScheme.primary.withValues(alpha: 0.1),
                child: Icon(Icons.camera_alt_rounded, color: Get.theme.colorScheme.primary),
              ),
              title: const Text('Take Photo'),
              subtitle: const Text('Capture receipt with camera'),
              onTap: () {
                Get.back();
                uploadReceipt(expenseId, source: ImageSource.camera);
              },
            ),
            ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.purple.withValues(alpha: 0.1),
                child: const Icon(Icons.photo_library_rounded, color: Colors.purple),
              ),
              title: const Text('Choose from Gallery'),
              subtitle: const Text('Pick receipt from gallery'),
              onTap: () {
                Get.back();
                uploadReceipt(expenseId, source: ImageSource.gallery);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  @override
  void onClose() {
    amountController.dispose();
    descriptionController.dispose();
    super.onClose();
  }
}











