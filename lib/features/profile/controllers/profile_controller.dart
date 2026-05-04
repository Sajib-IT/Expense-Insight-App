import 'package:get/get.dart';
import 'package:expense_insight/app/common/widgets/custom_snackbar.dart';
import 'package:expense_insight/app/data/models/user_model.dart';
import 'package:expense_insight/app/data/network/api_exceptions.dart';
import 'package:expense_insight/app/data/services/storage_service.dart';
import 'package:expense_insight/app/routes/app_pages.dart';
import 'package:expense_insight/features/profile/repositories/user_repository.dart';

class ProfileController extends GetxController {
  final UserRepository _repository = UserRepository();
  final StorageService _storageService = Get.find<StorageService>();

  final isLoading = false.obs;
  final isSaving = false.obs;
  final Rx<UserModel?> user = Rx<UserModel?>(null);

  @override
  void onInit() {
    super.onInit();
    fetchProfile();
  }

  Future<void> fetchProfile() async {
    try {
      isLoading.value = true;
      final response = await _repository.getProfile();

      if (response['success'] == true && response['data'] != null) {
        user.value = UserModel.fromJson(response['data']);
      }
    } catch (e) {
      CustomSnackbar.error(ApiExceptions.handleError(e));
    } finally {
      isLoading.value = false;
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
        CustomSnackbar.success('Profile updated successfully');
        Get.back();
      } else {
        CustomSnackbar.error(response['message'] ?? 'Failed to update profile');
      }
    } catch (e) {
      CustomSnackbar.error(ApiExceptions.handleError(e));
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> logout() async {
    await _storageService.clearAll();
    Get.offAllNamed(Routes.login);
    CustomSnackbar.info('Logged out successfully');
  }
}

