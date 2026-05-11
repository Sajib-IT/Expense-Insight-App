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
  late final TextEditingController _newCategoryNameController;

  bool _isCreateCategoryExpanded = false;
  bool _isCreatingCategory = false;
  String _selectedNewCategoryIcon = '📦';
  String _selectedNewCategoryColour = CategoryController.availableColours[3];
  String? _newCategoryError;

  bool get isEditing => editExpense != null;
  bool get isAiReview => aiDraft != null;

  @override
  void initState() {
    super.initState();
    _newCategoryNameController = TextEditingController();
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
    _newCategoryNameController.dispose();
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
                      _resetQuickCategoryError();
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
              Row(
                children: [
                  Expanded(
                    child: Text('Category', style: Theme.of(context).textTheme.titleSmall),
                  ),
                  TextButton.icon(
                    onPressed: _toggleCreateCategory,
                    icon: Icon(
                      _isCreateCategoryExpanded ? Icons.close_rounded : Icons.add_rounded,
                      size: 18,
                    ),
                    label: Text(
                      _isCreateCategoryExpanded ? 'Close Creator' : 'Create Category',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Obx(() {
                final cats = expenseController.selectedTransactionType.value == TransactionType.EXPENSE
                    ? categoryController.expenseCategories
                    : categoryController.incomeCategories;

                if (cats.isEmpty) {
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text('No categories available for this type yet. Please create one first.'),
                  );
                }

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
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                child: _isCreateCategoryExpanded
                    ? Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: _buildQuickCategoryCreator(context),
                      )
                    : const SizedBox.shrink(),
              ),
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

  Widget _buildQuickCategoryCreator(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.7),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Create category instantly',
            style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(
            'Create a new ${expenseController.selectedTransactionType.value == TransactionType.EXPENSE ? 'expense' : 'income'} category and use it right away.',
            style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: _newCategoryNameController,
            labelText: 'New Category Name',
            hintText: 'e.g., Snacks, Bonus, Fuel',
            prefixIcon: const Icon(Icons.category_outlined),
            onChanged: (_) => _resetQuickCategoryError(),
          ),
          const SizedBox(height: 16),
          Text('Choose Icon', style: theme.textTheme.titleSmall),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: CategoryController.availableIcons.take(12).map((icon) {
              final isSelected = _selectedNewCategoryIcon == icon;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedNewCategoryIcon = icon;
                  });
                },
                child: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? theme.colorScheme.primaryContainer
                        : theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? theme.colorScheme.primary
                          : theme.colorScheme.outlineVariant,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Center(child: Text(icon, style: const TextStyle(fontSize: 20))),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          Text('Choose Color', style: theme.textTheme.titleSmall),
          const SizedBox(height: 8),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: CategoryController.availableColours.map((color) {
              final isSelected = _selectedNewCategoryColour == color;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedNewCategoryColour = color;
                  });
                },
                child: Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: Color(int.parse(color.replaceFirst('#', '0xFF'))),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? Colors.white : Colors.transparent,
                      width: 3,
                    ),
                    boxShadow: isSelected
                        ? [BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 8)]
                        : null,
                  ),
                  child: isSelected
                      ? const Icon(Icons.check_rounded, color: Colors.white, size: 18)
                      : null,
                ),
              );
            }).toList(),
          ),
          if (_newCategoryError != null)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(
                _newCategoryError!,
                style: TextStyle(color: theme.colorScheme.error, fontSize: 12),
              ),
            ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _isCreatingCategory ? null : _closeCreateCategory,
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: CustomButton(
                  text: 'Create Now',
                  isLoading: _isCreatingCategory,
                  onPressed: _createCategory,
                  icon: const Icon(Icons.add_circle_outline_rounded, size: 18),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _toggleCreateCategory() {
    setState(() {
      _isCreateCategoryExpanded = !_isCreateCategoryExpanded;
      if (!_isCreateCategoryExpanded) {
        _resetQuickCategoryForm();
      }
    });
  }

  void _closeCreateCategory() {
    setState(() {
      _isCreateCategoryExpanded = false;
      _resetQuickCategoryForm();
    });
  }

  Future<void> _createCategory() async {
    final name = _newCategoryNameController.text.trim();
    if (name.isEmpty) {
      setState(() {
        _newCategoryError = 'Please enter a category name';
      });
      return;
    }

    final selectedType = expenseController.selectedTransactionType.value;
    final duplicateExists = categoryController.categories.any(
      (category) =>
          category.type == selectedType &&
          _normalizeCategoryName(category.name) == _normalizeCategoryName(name),
    );
    if (duplicateExists) {
      setState(() {
        _newCategoryError = 'A category with this name already exists';
      });
      return;
    }

    setState(() {
      _isCreatingCategory = true;
      _newCategoryError = null;
    });

    final createdCategory = await categoryController.createQuickCategory(
      name: name,
      type: selectedType,
      icon: _selectedNewCategoryIcon,
      colour: _selectedNewCategoryColour,
    );

    if (!mounted) return;

    if (createdCategory == null) {
      setState(() {
        _isCreatingCategory = false;
        _newCategoryError = 'Unable to create category. Please try again.';
      });
      return;
    }

    setState(() {
      _isCreatingCategory = false;
      _isCreateCategoryExpanded = false;
      expenseController.selectedCategory.value = createdCategory;
      _resetQuickCategoryForm();
    });
  }

  void _resetQuickCategoryError() {
    if (_newCategoryError == null) return;
    setState(() {
      _newCategoryError = null;
    });
  }

  void _resetQuickCategoryForm() {
    _newCategoryNameController.clear();
    _selectedNewCategoryIcon = '📦';
    _selectedNewCategoryColour = CategoryController.availableColours[3];
    _newCategoryError = null;
    _isCreatingCategory = false;
  }

  String _normalizeCategoryName(String value) {
    return value.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
  }
}

