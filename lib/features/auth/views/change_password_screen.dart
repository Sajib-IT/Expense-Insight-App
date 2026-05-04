import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:expense_insight/app/common/widgets/custom_button.dart';
import 'package:expense_insight/app/common/widgets/custom_text_field.dart';
import 'package:expense_insight/features/auth/controllers/auth_controller.dart';

class ChangePasswordScreen extends GetView<AuthController> {
  const ChangePasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Change Password')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: controller.changePasswordFormKey,
            child: Column(
              children: [
                const SizedBox(height: 24),
                CustomTextField(
                  controller: controller.currentPasswordController,
                  labelText: 'Current Password',
                  hintText: 'Enter current password',
                  obscureText: true,
                  prefixIcon: const Icon(Icons.lock_outlined),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter current password';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: controller.newPasswordController,
                  labelText: 'New Password',
                  hintText: 'Enter new password',
                  obscureText: true,
                  prefixIcon: const Icon(Icons.lock_outlined),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter new password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),
                Obx(
                  () => CustomButton(
                    text: 'Change Password',
                    isLoading: controller.isLoading.value,
                    onPressed: controller.changePassword,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

