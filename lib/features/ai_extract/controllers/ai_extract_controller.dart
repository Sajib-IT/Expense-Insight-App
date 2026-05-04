import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:expense_insight/app/common/widgets/custom_snackbar.dart';
import 'package:expense_insight/app/data/models/ai_extract_model.dart';
import 'package:expense_insight/app/data/network/api_exceptions.dart';
import 'package:expense_insight/features/ai_extract/repositories/ai_extract_repository.dart';

class AiExtractController extends GetxController {
  final AiExtractRepository _repository = AiExtractRepository();
  final ImagePicker _picker = ImagePicker();

  final isLoading = false.obs;
  final Rx<AiExtractModel?> extractedData = Rx<AiExtractModel?>(null);
  final textController = TextEditingController();

  Future<void> extractFromReceipt() async {
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
        extractedData.value = AiExtractModel.fromJson(response['data']);
        CustomSnackbar.success('Receipt data extracted successfully');
      } else {
        CustomSnackbar.error(response['message'] ?? 'Failed to extract data');
      }
    } catch (e) {
      CustomSnackbar.error(ApiExceptions.handleError(e));
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> extractFromGallery() async {
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
        extractedData.value = AiExtractModel.fromJson(response['data']);
        CustomSnackbar.success('Receipt data extracted successfully');
      } else {
        CustomSnackbar.error(response['message'] ?? 'Failed to extract data');
      }
    } catch (e) {
      CustomSnackbar.error(ApiExceptions.handleError(e));
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> extractFromText() async {
    if (textController.text.trim().length < 3) {
      CustomSnackbar.error('Please enter at least 3 characters');
      return;
    }

    try {
      isLoading.value = true;
      final response = await _repository.extractFromText(
        textController.text.trim(),
      );

      if (response['success'] == true && response['data'] != null) {
        extractedData.value = AiExtractModel.fromJson(response['data']);
        CustomSnackbar.success('Data extracted successfully');
      } else {
        CustomSnackbar.error(response['message'] ?? 'Failed to extract data');
      }
    } catch (e) {
      CustomSnackbar.error(ApiExceptions.handleError(e));
    } finally {
      isLoading.value = false;
    }
  }

  void clearExtractedData() {
    extractedData.value = null;
    textController.clear();
  }

  @override
  void onClose() {
    textController.dispose();
    super.onClose();
  }
}

