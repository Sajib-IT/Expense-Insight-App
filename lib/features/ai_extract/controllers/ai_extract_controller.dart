import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:expense_insight/app/common/widgets/custom_snackbar.dart';
import 'package:expense_insight/app/common/widgets/result_dialog.dart';
import 'package:expense_insight/app/data/models/ai_extract_model.dart';
import 'package:expense_insight/app/data/network/api_exceptions.dart';
import 'package:expense_insight/features/ai_extract/repositories/ai_extract_repository.dart';
import 'package:expense_insight/features/ai_extract/widgets/ai_review_dialog.dart';
import 'package:expense_insight/features/category/controllers/category_controller.dart';
import 'package:expense_insight/features/dashboard/controllers/dashboard_controller.dart';
import 'package:expense_insight/features/expense/controllers/expense_controller.dart';
import 'package:expense_insight/features/expense/repositories/expense_repository.dart';

class AiExtractController extends GetxController {
  final AiExtractRepository _repository = AiExtractRepository();
  final ExpenseRepository _expenseRepository = ExpenseRepository();
  final ImagePicker _picker = ImagePicker();

  final isLoading = false.obs;
  final isSavingReview = false.obs;
  final Rx<AiExtractModel?> extractedData = Rx<AiExtractModel?>(null);
  final textController = TextEditingController();

  Future<void> extractFromReceipt() async {
    AiExtractModel? extracted;

    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image == null) return;

      isLoading.value = true;
      final response = await _repository.extractFromReceipt(image.path);

      if (response['success'] == true && response['data'] != null) {
        extracted = AiExtractModel.fromJson(response['data']);
        extractedData.value = extracted;
      } else {
        CustomSnackbar.error(response['message'] ?? 'Failed to extract data');
      }
    } catch (e) {
      CustomSnackbar.error(ApiExceptions.handleError(e));
    } finally {
      isLoading.value = false;
    }

    if (extracted != null) {
      await openOverviewDialog(extracted);
    }
  }

  Future<void> extractFromGallery() async {
    AiExtractModel? extracted;

    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image == null) return;

      isLoading.value = true;
      final response = await _repository.extractFromReceipt(image.path);

      if (response['success'] == true && response['data'] != null) {
        extracted = AiExtractModel.fromJson(response['data']);
        extractedData.value = extracted;
      } else {
        CustomSnackbar.error(response['message'] ?? 'Failed to extract data');
      }
    } catch (e) {
      CustomSnackbar.error(ApiExceptions.handleError(e));
    } finally {
      isLoading.value = false;
    }

    if (extracted != null) {
      await openOverviewDialog(extracted);
    }
  }

  Future<void> extractFromText() async {
    if (textController.text.trim().length < 3) {
      CustomSnackbar.error('Please enter at least 3 characters');
      return;
    }

    AiExtractModel? extracted;

    try {
      isLoading.value = true;
      final response = await _repository.extractFromText(
        textController.text.trim(),
      );

      if (response['success'] == true && response['data'] != null) {
        extracted = AiExtractModel.fromJson(response['data']);
        extractedData.value = extracted;
      } else {
        CustomSnackbar.error(response['message'] ?? 'Failed to extract data');
      }
    } catch (e) {
      CustomSnackbar.error(ApiExceptions.handleError(e));
    } finally {
      isLoading.value = false;
    }

    if (extracted != null) {
      await openOverviewDialog(extracted);
    }
  }

  Future<void> openOverviewDialog([AiExtractModel? data]) async {
    final extracted = data ?? extractedData.value;
    if (extracted == null) return;

    final categoryController = _ensureCategoryController();
    if (categoryController.categories.isEmpty && !categoryController.isLoading.value) {
      await categoryController.fetchCategories();
    }

    await Get.dialog(
      AiReviewDialog(
        data: extracted,
        categories: categoryController.categories.toList(),
        isSaving: isSavingReview,
        onConfirm: saveReviewedTransaction,
      ),
      barrierDismissible: false,
    );
  }

  Future<void> saveReviewedTransaction(AiReviewSubmission submission) async {
    try {
      isSavingReview.value = true;

      final response = await _expenseRepository.createExpense(
        amount: submission.amount,
        description: submission.description,
        date: submission.date.toIso8601String().split('T').first,
        type: submission.type.value,
        categoryId: submission.category.id,
      );

      if (response['success'] == true) {
        if (Get.isDialogOpen == true) {
          Get.back();
        }
        clearExtractedData();
        _refreshLinkedData();
        await ResultDialog.success(
          title: 'Transaction Added!',
          message: 'Your extracted transaction has been saved successfully.',
          navigateBack: false,
        );
      } else {
        await ResultDialog.error(
          title: 'Failed to Save',
          message: response['message'] ?? 'Something went wrong.',
        );
      }
    } catch (e) {
      await ResultDialog.error(
        title: 'Error',
        message: ApiExceptions.handleError(e),
      );
    } finally {
      isSavingReview.value = false;
    }
  }

  void clearExtractedData() {
    extractedData.value = null;
    textController.clear();
  }

  CategoryController _ensureCategoryController() {
    if (!Get.isRegistered<CategoryController>()) {
      Get.put<CategoryController>(CategoryController());
    }
    return Get.find<CategoryController>();
  }

  void _refreshLinkedData() {
    if (Get.isRegistered<ExpenseController>()) {
      Get.find<ExpenseController>().fetchExpenses(isRefresh: true);
    }
    if (Get.isRegistered<DashboardController>()) {
      Get.find<DashboardController>().fetchDashboard(isRefresh: true);
    }
  }

  @override
  void onClose() {
    textController.dispose();
    super.onClose();
  }
}


