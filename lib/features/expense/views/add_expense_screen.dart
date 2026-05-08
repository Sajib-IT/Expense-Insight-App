import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:expense_insight/app/common/widgets/custom_button.dart';
import 'package:expense_insight/app/common/widgets/custom_text_field.dart';
import 'package:expense_insight/app/data/models/ai_extract_model.dart';
import 'package:expense_insight/app/data/models/category_model.dart';
import 'package:expense_insight/app/data/models/expense_model.dart';
import 'package:expense_insight/features/expense/controllers/expense_controller.dart';
import 'package:expense_insight/features/category/controllers/category_controller.dart';

class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final ExpenseController expenseController = Get.find<ExpenseController>();
  final CategoryController categoryController = Get.find<CategoryController>();

  ExpenseModel? editExpense;
  AiExtractModel? aiDraft;
  Worker? _categoryWorker;

  bool get isEditing => editExpense != null;
  bool get isAiReview => aiDraft != null;

  @override
  void initState() {
    super.initState();
    _readArguments();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeForm();
    });
  }

  void _readArguments() {
    final args = Get.arguments;

    if (args is ExpenseModel) {
      editExpense = args;
      return;
    }

    if (args is AiExtractModel) {
      aiDraft = args;
      return;
    }

    if (args is Map) {
      if (args['expense'] is ExpenseModel) {
        editExpense = args['expense'] as ExpenseModel;
      }
      if (args['aiDraft'] is AiExtractModel) {
        aiDraft = args['aiDraft'] as AiExtractModel;
      }
    }
  }

  Future<void> _initializeForm() async {
    expenseController.resetForm();

    if (isEditing) {
      expenseController.loadExpenseForEdit(editExpense!);
      return;
    }

    if (!isAiReview) return;

    expenseController.loadAiExtractDraft(
      aiDraft!,
      availableCategories: categoryController.categories,
    );

    if (expenseController.selectedCategory.value == null &&
        categoryController.categories.isEmpty &&
        !categoryController.isLoading.value) {
      await categoryController.fetchCategories();
    }

    _tryApplySuggestedCategory();

    _categoryWorker?.dispose();
    if (expenseController.selectedCategory.value == null && categoryController.categories.isEmpty) {
      _categoryWorker = ever(categoryController.categories, (_) {
        _tryApplySuggestedCategory();
        if (expenseController.selectedCategory.value != null || categoryController.categories.isNotEmpty) {
          _categoryWorker?.dispose();
          _categoryWorker = null;
        }
      });
    }
  }

  void _tryApplySuggestedCategory() {
    if (!isAiReview || expenseController.selectedCategory.value != null) return;

    final match = expenseController.findMatchingCategory(
      categoryName: aiDraft?.category,
      type: expenseController.selectedTransactionType.value,
      availableCategories: categoryController.categories,
    );

    if (match != null) {
      expenseController.selectedCategory.value = match;
    }
  }

  @override
  void dispose() {
    _categoryWorker?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEditing
              ? 'Edit Transaction'
              : isAiReview
                  ? 'Review Extracted Data'
                  : 'Add Transaction',
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: expenseController.expenseFormKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isAiReview) ...[
                _buildAiReviewBanner(context),
                const SizedBox(height: 20),
              ],

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
                      expenseController.updateTransactionType(selected.first);
                      if (isAiReview) {
                        _tryApplySuggestedCategory();
                      }
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
                    text: isEditing
                        ? 'Update'
                        : isAiReview
                            ? 'Confirm & Save'
                            : 'Add Transaction',
                    isLoading: expenseController.isSaving.value,
                    onPressed: () {
                      if (isEditing) {
                        expenseController.updateExpense(editExpense!.id);
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

  Widget _buildAiReviewBanner(BuildContext context) {
    final confidence = aiDraft?.confidence;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.18),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_awesome_rounded, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Review before saving',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
              if (confidence != null)
                Chip(
                  label: Text('${(confidence * 100).toStringAsFixed(0)}% confidence'),
                  padding: EdgeInsets.zero,
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'We prefilled this form from your AI extraction. Update any field if needed, then confirm to save it as a transaction.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

