import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:expense_insight/app/common/widgets/custom_button.dart';
import 'package:expense_insight/app/common/widgets/custom_text_field.dart';
import 'package:expense_insight/features/profile/controllers/profile_controller.dart';

class EditProfileScreen extends GetView<ProfileController> {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final nameController = TextEditingController(text: controller.user.value?.name ?? '');
    final formKey = GlobalKey<FormState>();

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: formKey,
          child: Column(
            children: [
              // Avatar
              Obx(() {
                final user = controller.user.value;
                return CircleAvatar(
                  radius: 50,
                  backgroundImage: user?.avatar != null ? NetworkImage(user!.avatar!) : null,
                  child: user?.avatar == null
                      ? Text(
                          (user?.name ?? 'U')[0].toUpperCase(),
                          style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
                        )
                      : null,
                );
              }),
              const SizedBox(height: 32),

              CustomTextField(
                controller: nameController,
                labelText: 'Name',
                hintText: 'Enter your name',
                prefixIcon: const Icon(Icons.person_outlined),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Please enter your name';
                  return null;
                },
              ),
              const SizedBox(height: 32),

              Obx(() => CustomButton(
                    text: 'Save Changes',
                    isLoading: controller.isSaving.value,
                    onPressed: () {
                      if (formKey.currentState!.validate()) {
                        controller.updateProfile(name: nameController.text.trim());
                      }
                    },
                  )),
            ],
          ),
        ),
      ),
    );
  }
}

