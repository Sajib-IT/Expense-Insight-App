import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:expense_insight/app/common/widgets/custom_snackbar.dart';
import 'package:expense_insight/app/common/widgets/result_dialog.dart';
import 'package:expense_insight/app/data/models/user_model.dart';
import 'package:expense_insight/app/data/network/api_exceptions.dart';
import 'package:expense_insight/app/data/services/storage_service.dart';
import 'package:expense_insight/app/routes/app_pages.dart';
import 'package:expense_insight/features/profile/repositories/user_repository.dart';

class ProfileController extends GetxController {
  final UserRepository _repository = UserRepository();
  final StorageService _storageService = Get.find<StorageService>();
  final ImagePicker _picker = ImagePicker();

  final isLoading = false.obs;
  final isRefreshing = false.obs;
  final isSaving = false.obs;
  final isUploadingAvatar = false.obs;
  final Rx<UserModel?> user = Rx<UserModel?>(null);

  @override
  void onInit() {
    super.onInit();
    fetchProfile();
  }

  Future<void> fetchProfile({bool isRefresh = false}) async {
    try {
      if (isRefresh) {
        isRefreshing.value = true;
      }
      isLoading.value = true;
      final response = await _repository.getProfile();

      if (response['success'] == true && response['data'] != null) {
        user.value = UserModel.fromJson(response['data']);
      }
    } catch (e) {
      CustomSnackbar.error(ApiExceptions.handleError(e));
    } finally {
      isLoading.value = false;
      isRefreshing.value = false;
    }
  }

  Future<void> updateProfile({String? name, String? avatar}) async {
    try {
      isSaving.value = true;
      final response = await _repository.updateProfile(
        name: name,
        avatar: avatar,
      );

      if (response['success'] == true && response['data'] != null) {
        user.value = UserModel.fromJson(response['data']);
        await ResultDialog.success(
          title: 'Profile Updated!',
          message: 'Your profile has been updated successfully.',
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

  Future<void> logout() async {
    await _storageService.clearAll();
    Get.offAllNamed(Routes.login);
    CustomSnackbar.info('Logged out successfully');
  }

  /// Pick and upload/update profile picture
  Future<void> pickAndUploadAvatar({ImageSource source = ImageSource.gallery}) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );
      if (image == null) return;

      isUploadingAvatar.value = true;

      final hasAvatar = user.value?.avatar != null && user.value!.avatar!.isNotEmpty;
      final response = hasAvatar
          ? await _repository.updateAvatar(image.path)
          : await _repository.uploadAvatar(image.path);

      if (response['success'] == true && response['data'] != null) {
        user.value = UserModel.fromJson(response['data']);
        await ResultDialog.success(
          title: 'Avatar Updated!',
          message: 'Your profile picture has been updated.',
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
      isUploadingAvatar.value = false;
    }
  }

  /// Delete profile picture
  Future<void> deleteAvatar() async {
    try {
      isUploadingAvatar.value = true;
      final response = await _repository.deleteAvatar();

      if (response['success'] == true) {
        if (response['data'] != null) {
          user.value = UserModel.fromJson(response['data']);
        } else {
          await fetchProfile();
        }
        CustomSnackbar.success('Profile picture removed');
      } else {
        await ResultDialog.error(
          title: 'Delete Failed',
          message: response['message'] ?? 'Something went wrong.',
        );
      }
    } catch (e) {
      await ResultDialog.error(
        title: 'Error',
        message: ApiExceptions.handleError(e),
      );
    } finally {
      isUploadingAvatar.value = false;
    }
  }

  /// Show bottom sheet to choose avatar action
  void showAvatarOptions() {
    final hasAvatar = user.value?.avatar != null && user.value!.avatar!.isNotEmpty;
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
              'Profile Picture',
              style: Get.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            ListTile(
              leading: CircleAvatar(
                backgroundColor: Get.theme.colorScheme.primary.withValues(alpha: 0.1),
                child: Icon(Icons.camera_alt_rounded, color: Get.theme.colorScheme.primary),
              ),
              title: const Text('Take Photo'),
              subtitle: const Text('Use camera to take a picture'),
              onTap: () {
                Get.back();
                pickAndUploadAvatar(source: ImageSource.camera);
              },
            ),
            ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.purple.withValues(alpha: 0.1),
                child: const Icon(Icons.photo_library_rounded, color: Colors.purple),
              ),
              title: const Text('Choose from Gallery'),
              subtitle: const Text('Pick an image from your gallery'),
              onTap: () {
                Get.back();
                pickAndUploadAvatar(source: ImageSource.gallery);
              },
            ),
            if (hasAvatar)
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.red.withValues(alpha: 0.1),
                  child: const Icon(Icons.delete_rounded, color: Colors.red),
                ),
                title: const Text('Remove Photo', style: TextStyle(color: Colors.red)),
                subtitle: const Text('Delete your current profile picture'),
                onTap: () {
                  Get.back();
                  deleteAvatar();
                },
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
