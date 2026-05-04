import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:expense_insight/app/common/widgets/custom_button.dart';
import 'package:expense_insight/app/common/widgets/custom_text_field.dart';
import 'package:expense_insight/app/data/models/category_model.dart';
import 'package:expense_insight/features/category/controllers/category_controller.dart';

class AddCategoryScreen extends GetView<CategoryController> {
  const AddCategoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final String? editCategoryId = Get.arguments;
    final isEditing = editCategoryId != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Category' : 'Add Category'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: controller.categoryFormKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Name
              CustomTextField(
                controller: controller.nameController,
                labelText: 'Category Name',
                hintText: 'Enter category name',
                prefixIcon: const Icon(Icons.category_outlined),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Please enter a name';
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Type
              Text('Type', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8),
              Obx(() => SegmentedButton<TransactionType>(
                    segments: const [
                      ButtonSegment(
                        value: TransactionType.EXPENSE,
                        label: Text('Expense'),
                      ),
                      ButtonSegment(
                        value: TransactionType.INCOME,
                        label: Text('Income'),
                      ),
                    ],
                    selected: {controller.selectedType.value},
                    onSelectionChanged: (selected) {
                      controller.selectedType.value = selected.first;
                    },
                  )),
              const SizedBox(height: 20),

              // Icon Selector
              Text('Icon', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8),
              Obx(() => Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: CategoryController.availableIcons.map((icon) {
                      final isSelected = controller.selectedIcon.value == icon;
                      return GestureDetector(
                        onTap: () => controller.selectedIcon.value = icon,
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Theme.of(context).colorScheme.primaryContainer
                                : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(12),
                            border: isSelected
                                ? Border.all(
                                    color: Theme.of(context).colorScheme.primary, width: 2)
                                : null,
                          ),
                          child: Center(child: Text(icon, style: const TextStyle(fontSize: 22))),
                        ),
                      );
                    }).toList(),
                  )),
              const SizedBox(height: 20),

              // Color Selector
              Text('Color', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8),
              Obx(() => Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      '#FF5733', '#28A745', '#007BFF', '#6200EE', '#FFC107',
                      '#E91E63', '#00BCD4', '#FF9800', '#795548', '#9C27B0',
                    ].map((color) {
                      final isSelected = controller.selectedColour.value == color;
                      return GestureDetector(
                        onTap: () => controller.selectedColour.value = color,
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Color(int.parse(color.replaceFirst('#', '0xFF'))),
                            shape: BoxShape.circle,
                            border: isSelected
                                ? Border.all(color: Colors.white, width: 3)
                                : null,
                            boxShadow: isSelected
                                ? [BoxShadow(color: Colors.black26, blurRadius: 4)]
                                : null,
                          ),
                          child: isSelected
                              ? const Icon(Icons.check, color: Colors.white, size: 20)
                              : null,
                        ),
                      );
                    }).toList(),
                  )),
              const SizedBox(height: 32),

              // Submit
              Obx(() => CustomButton(
                    text: isEditing ? 'Update Category' : 'Create Category',
                    isLoading: controller.isSaving.value,
                    onPressed: () {
                      if (isEditing) {
                        controller.updateCategory(editCategoryId);
                      } else {
                        controller.createCategory();
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

