import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:expense_insight/app/common/widgets/custom_button.dart';
import 'package:expense_insight/app/common/widgets/custom_text_field.dart';
import 'package:expense_insight/app/data/models/category_model.dart';
import 'package:expense_insight/app/data/models/expense_model.dart';
import 'package:expense_insight/features/expense/controllers/expense_controller.dart';
import 'package:expense_insight/features/category/controllers/category_controller.dart';

class AddExpenseScreen extends StatelessWidget {
  const AddExpenseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final expenseController = Get.find<ExpenseController>();
    final categoryController = Get.find<CategoryController>();
    final ExpenseModel? editExpense = Get.arguments;
    final isEditing = editExpense != null;

    if (isEditing) {
      expenseController.loadExpenseForEdit(editExpense);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Transaction' : 'Add Transaction'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: expenseController.expenseFormKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Type Toggle
              Text('Type', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8),
              Obx(() => SegmentedButton<TransactionType>(
                    segments: const [
                      ButtonSegment(
                        value: TransactionType.EXPENSE,
                        label: Text('Expense'),
                        icon: Icon(Icons.arrow_upward),
                      ),
                      ButtonSegment(
                        value: TransactionType.INCOME,
                        label: Text('Income'),
                        icon: Icon(Icons.arrow_downward),
                      ),
                    ],
                    selected: {expenseController.selectedTransactionType.value},
                    onSelectionChanged: (selected) {
                      expenseController.selectedTransactionType.value = selected.first;
                    },
                  )),
              const SizedBox(height: 20),

              // Amount
              CustomTextField(
                controller: expenseController.amountController,
                labelText: 'Amount',
                hintText: 'Enter amount',
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                prefixIcon: const Icon(Icons.attach_money),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Please enter an amount';
                  if (double.tryParse(value) == null) return 'Please enter a valid number';
                  if (double.parse(value) <= 0) return 'Amount must be positive';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Description
              CustomTextField(
                controller: expenseController.descriptionController,
                labelText: 'Description',
                hintText: 'Enter description (optional)',
                prefixIcon: const Icon(Icons.description_outlined),
                maxLines: 2,
              ),
              const SizedBox(height: 16),

              // Date Picker
              Obx(() => InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: expenseController.selectedDate.value,
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now().add(const Duration(days: 1)),
                      );
                      if (picked != null) {
                        expenseController.selectedDate.value = picked;
                      }
                    },
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Date',
                        prefixIcon: Icon(Icons.calendar_today),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                        ),
                      ),
                      child: Text(
                        DateFormat('MMM dd, yyyy').format(expenseController.selectedDate.value),
                      ),
                    ),
                  )),
              const SizedBox(height: 16),

              // Category Selector
              Text('Category', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8),
              Obx(() {
                final cats = expenseController.selectedTransactionType.value == TransactionType.EXPENSE
                    ? categoryController.expenseCategories
                    : categoryController.incomeCategories;

                return Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: cats.map((cat) {
                    final isSelected = expenseController.selectedCategory.value?.id == cat.id;
                    return ChoiceChip(
                      label: Text('${cat.icon ?? '📦'} ${cat.name}'),
                      selected: isSelected,
                      onSelected: (_) {
                        expenseController.selectedCategory.value = cat;
                      },
                    );
                  }).toList(),
                );
              }),
              const SizedBox(height: 32),

              // Submit Button
              Obx(() => CustomButton(
                    text: isEditing ? 'Update' : 'Add Transaction',
                    isLoading: expenseController.isSaving.value,
                    onPressed: () {
                      if (isEditing) {
                        expenseController.updateExpense(editExpense.id);
                      } else {
                        expenseController.createExpense();
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

