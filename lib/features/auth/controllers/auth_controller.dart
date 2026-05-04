import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:expense_insight/app/common/widgets/custom_snackbar.dart';
import 'package:expense_insight/app/data/models/user_model.dart';
import 'package:expense_insight/app/data/network/api_exceptions.dart';
import 'package:expense_insight/app/data/services/storage_service.dart';
import 'package:expense_insight/app/routes/app_pages.dart';
import 'package:expense_insight/features/auth/repositories/auth_repository.dart';

class AuthController extends GetxController {
  final AuthRepository _authRepository = AuthRepository();
  final StorageService _storageService = Get.find<StorageService>();

  // Observables
  final isLoading = false.obs;
  final isPasswordVisible = false.obs;
  final isConfirmPasswordVisible = false.obs;

  // Text Controllers
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final currentPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();

  // Form Keys
  final loginFormKey = GlobalKey<FormState>();
  final registerFormKey = GlobalKey<FormState>();
  final forgotPasswordFormKey = GlobalKey<FormState>();
  final changePasswordFormKey = GlobalKey<FormState>();

  // Current user
  final Rx<UserModel?> currentUser = Rx<UserModel?>(null);

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  void toggleConfirmPasswordVisibility() {
    isConfirmPasswordVisible.value = !isConfirmPasswordVisible.value;
  }

  // Login
  Future<void> login() async {
    if (!loginFormKey.currentState!.validate()) return;

    try {
      isLoading.value = true;
      final response = await _authRepository.login(
        emailController.text.trim(),
        passwordController.text,
      );

      if (response['success'] == true) {
        final data = response['data'];
        await _storageService.saveToken(data['accessToken']);
        await _storageService.saveRefreshToken(data['refreshToken']);

        if (data['user'] != null) {
          currentUser.value = UserModel.fromJson(data['user']);
        }

        _clearLoginFields();
        CustomSnackbar.success('Login successful!');
        Get.offAllNamed(Routes.home);
      } else {
        CustomSnackbar.error(response['message'] ?? 'Login failed');
      }
    } catch (e) {
      CustomSnackbar.error(ApiExceptions.handleError(e));
    } finally {
      isLoading.value = false;
    }
  }

  // Register
  Future<void> register() async {
    if (!registerFormKey.currentState!.validate()) return;

    try {
      isLoading.value = true;
      final response = await _authRepository.register(
        name: nameController.text.trim(),
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      if (response['success'] == true) {
        _clearRegisterFields();
        CustomSnackbar.success(
          response['message'] ?? 'Registration successful! Please verify your email.',
        );
        Get.offAllNamed(Routes.login);
      } else {
        CustomSnackbar.error(response['message'] ?? 'Registration failed');
      }
    } catch (e) {
      CustomSnackbar.error(ApiExceptions.handleError(e));
    } finally {
      isLoading.value = false;
    }
  }

  // Forgot Password
  Future<void> forgotPassword() async {
    if (!forgotPasswordFormKey.currentState!.validate()) return;

    try {
      isLoading.value = true;
      final response = await _authRepository.forgotPassword(
        emailController.text.trim(),
      );

      CustomSnackbar.success(
        response['message'] ?? 'If the email exists, a reset link has been sent.',
      );
      Get.back();
    } catch (e) {
      CustomSnackbar.error(ApiExceptions.handleError(e));
    } finally {
      isLoading.value = false;
    }
  }

  // Change Password
  Future<void> changePassword() async {
    if (!changePasswordFormKey.currentState!.validate()) return;

    try {
      isLoading.value = true;
      final response = await _authRepository.changePassword(
        currentPassword: currentPasswordController.text,
        newPassword: newPasswordController.text,
      );

      if (response['success'] == true) {
        currentPasswordController.clear();
        newPasswordController.clear();
        CustomSnackbar.success(response['message'] ?? 'Password changed successfully');
        Get.back();
      } else {
        CustomSnackbar.error(response['message'] ?? 'Failed to change password');
      }
    } catch (e) {
      CustomSnackbar.error(ApiExceptions.handleError(e));
    } finally {
      isLoading.value = false;
    }
  }

  // Logout
  Future<void> logout() async {
    await _storageService.clearAll();
    Get.offAllNamed(Routes.login);
    CustomSnackbar.info('Logged out successfully');
  }

  void _clearLoginFields() {
    emailController.clear();
    passwordController.clear();
    isPasswordVisible.value = false;
  }

  void _clearRegisterFields() {
    nameController.clear();
    emailController.clear();
    passwordController.clear();
    confirmPasswordController.clear();
    isPasswordVisible.value = false;
    isConfirmPasswordVisible.value = false;
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    currentPasswordController.dispose();
    newPasswordController.dispose();
    super.onClose();
  }
}
