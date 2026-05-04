import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:expense_insight/app/routes/app_pages.dart';
import 'package:expense_insight/features/category/controllers/category_controller.dart';

class CategoryListScreen extends GetView<CategoryController> {
  const CategoryListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Categories'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => Get.toNamed(Routes.addCategory),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.categories.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.categories.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.category_outlined, size: 64, color: Colors.grey.shade400),
                const SizedBox(height: 16),
                Text('No categories yet',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey)),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.fetchCategories,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: controller.categories.length,
            itemBuilder: (context, index) {
              final category = controller.categories[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: _parseColor(category.colour).withValues(alpha: 0.2),
                    child: Text(category.icon ?? '📦', style: const TextStyle(fontSize: 20)),
                  ),
                  title: Text(category.name),
                  subtitle: Text(category.type.value),
                  trailing: category.isDefault
                      ? Chip(
                          label: const Text('Default', style: TextStyle(fontSize: 11)),
                          padding: EdgeInsets.zero,
                        )
                      : PopupMenuButton(
                          itemBuilder: (_) => [
                            const PopupMenuItem(value: 'edit', child: Text('Edit')),
                            const PopupMenuItem(value: 'delete', child: Text('Delete')),
                          ],
                          onSelected: (value) {
                            if (value == 'edit') {
                              controller.loadCategoryForEdit(category);
                              Get.toNamed(Routes.addCategory, arguments: category.id);
                            } else if (value == 'delete') {
                              Get.dialog(
                                AlertDialog(
                                  title: const Text('Delete Category'),
                                  content: const Text('Are you sure?'),
                                  actions: [
                                    TextButton(
                                        onPressed: () => Get.back(), child: const Text('Cancel')),
                                    TextButton(
                                      onPressed: () {
                                        Get.back();
                                        controller.deleteCategory(category.id);
                                      },
                                      child: const Text('Delete',
                                          style: TextStyle(color: Colors.red)),
                                    ),
                                  ],
                                ),
                              );
                            }
                          },
                        ),
                ),
              );
            },
          ),
        );
      }),
    );
  }

  Color _parseColor(String? colorStr) {
    if (colorStr == null || colorStr.isEmpty) return Colors.blue;
    try {
      return Color(int.parse(colorStr.replaceFirst('#', '0xFF')));
    } catch (_) {
      return Colors.blue;
    }
  }
}

