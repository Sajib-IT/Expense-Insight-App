import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:expense_insight/app/common/widgets/custom_button.dart';
import 'package:expense_insight/app/common/widgets/custom_text_field.dart';
import 'package:expense_insight/features/budget/controllers/budget_controller.dart';
import 'package:expense_insight/features/category/controllers/category_controller.dart';

class AddBudgetScreen extends StatelessWidget {
  const AddBudgetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final budgetController = Get.find<BudgetController>();
    final categoryController = Get.find<CategoryController>();
    final String? editBudgetId = Get.arguments;
    final isEditing = editBudgetId != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Budget' : 'Add Budget'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: budgetController.budgetFormKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Amount
              CustomTextField(
                controller: budgetController.amountController,
                labelText: 'Budget Amount',
                hintText: 'Enter budget amount',
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                prefixIcon: const Icon(Icons.attach_money),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Please enter an amount';
                  if (double.tryParse(value) == null) return 'Please enter a valid number';
                  if (double.parse(value) <= 0) return 'Amount must be positive';
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Category Selector (only for new budgets)
              if (!isEditing) ...[
                Text('Category', style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 8),
                Obx(() {
                  final cats = categoryController.expenseCategories;
                  return Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: cats.map((cat) {
                      final isSelected = budgetController.selectedCategory.value?.id == cat.id;
                      return ChoiceChip(
                        label: Text('${cat.icon ?? '📦'} ${cat.name}'),
                        selected: isSelected,
                        onSelected: (_) {
                          budgetController.selectedCategory.value = cat;
                        },
                      );
                    }).toList(),
                  );
                }),
                const SizedBox(height: 24),
              ],

              // Submit
              Obx(() => CustomButton(
                    text: isEditing ? 'Update Budget' : 'Create Budget',
                    isLoading: budgetController.isSaving.value,
                    onPressed: () {
                      if (isEditing) {
                        budgetController.updateBudget(editBudgetId);
                      } else {
                        budgetController.createBudget();
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

