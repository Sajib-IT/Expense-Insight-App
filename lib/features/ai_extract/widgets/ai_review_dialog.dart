import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:expense_insight/app/common/widgets/custom_button.dart';
import 'package:expense_insight/app/common/widgets/custom_text_field.dart';
import 'package:expense_insight/app/data/models/ai_extract_model.dart';
import 'package:expense_insight/app/data/models/category_model.dart';

class AiReviewSubmission {
  final double amount;
  final String? description;
  final DateTime date;
  final TransactionType type;
  final CategoryModel category;

  const AiReviewSubmission({
    required this.amount,
    this.description,
    required this.date,
    required this.type,
    required this.category,
  });
}

class AiReviewDialog extends StatefulWidget {
  final AiExtractModel data;
  final List<CategoryModel> categories;
  final RxBool isSaving;
  final Future<void> Function(AiReviewSubmission submission) onConfirm;

  const AiReviewDialog({
    super.key,
    required this.data,
    required this.categories,
    required this.isSaving,
    required this.onConfirm,
  });

  @override
  State<AiReviewDialog> createState() => _AiReviewDialogState();
}

class _AiReviewDialogState extends State<AiReviewDialog> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _amountController;
  late final TextEditingController _descriptionController;
  late DateTime _selectedDate;
  late TransactionType _selectedType;
  CategoryModel? _selectedCategory;
  bool _showCategoryError = false;

  List<CategoryModel> get _availableCategories => widget.categories
      .where((category) => category.type == _selectedType)
      .toList();

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(
      text: widget.data.amount != null && widget.data.amount! > 0
          ? widget.data.amount!.toString()
          : '',
    );
    _descriptionController = TextEditingController(
      text: _buildSuggestedDescription(widget.data),
    );
    _selectedType = TransactionType.fromString(widget.data.type ?? 'EXPENSE');
    _selectedDate = _parseExtractedDate(widget.data.date) ?? DateTime.now();
    _selectedCategory = _findMatchingCategory(widget.data.category, _selectedType);
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final confidence = widget.data.confidence;
    final screenSize = MediaQuery.sizeOf(context);
    final dialogWidth = screenSize.width > 620 ? 560.0 : screenSize.width * 0.92;
    final dialogHeight = screenSize.height * 0.82;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: SizedBox(
        width: dialogWidth,
        height: dialogHeight,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        Icons.auto_awesome_rounded,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Overview',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            'Review, edit, and confirm before saving.',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Obx(
                      () => IconButton(
                        onPressed: widget.isSaving.value ? null : () => Get.back(),
                        icon: const Icon(Icons.close_rounded),
                        tooltip: 'Close',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    if (confidence != null)
                      Chip(
                        label: Text('${(confidence * 100).toStringAsFixed(0)}% confidence'),
                        padding: EdgeInsets.zero,
                      ),
                    if ((widget.data.merchant ?? '').trim().isNotEmpty)
                      Chip(
                        avatar: const Icon(Icons.storefront_outlined, size: 16),
                        label: Text(widget.data.merchant!.trim()),
                        padding: EdgeInsets.zero,
                      ),
                    if ((widget.data.currency ?? '').trim().isNotEmpty)
                      Chip(
                        avatar: const Icon(Icons.payments_outlined, size: 16),
                        label: Text(widget.data.currency!.trim()),
                        padding: EdgeInsets.zero,
                      ),
                  ],
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomTextField(
                          controller: _amountController,
                          labelText: 'Amount',
                          hintText: 'Enter amount',
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          prefixIcon: const Icon(Icons.attach_money_rounded),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter an amount';
                            }
                            final amount = double.tryParse(value.trim());
                            if (amount == null) return 'Please enter a valid number';
                            if (amount <= 0) return 'Amount must be positive';
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        CustomTextField(
                          controller: _descriptionController,
                          labelText: 'Description',
                          hintText: 'Add a note for this transaction',
                          maxLines: 2,
                          prefixIcon: const Icon(Icons.description_outlined),
                        ),
                        const SizedBox(height: 16),
                        InkWell(
                          onTap: _pickDate,
                          borderRadius: BorderRadius.circular(12),
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              labelText: 'Date',
                              prefixIcon: Icon(Icons.calendar_today_rounded),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(12)),
                              ),
                            ),
                            child: Text(DateFormat('MMM dd, yyyy').format(_selectedDate)),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text('Type', style: theme.textTheme.titleSmall),
                        const SizedBox(height: 8),
                        SegmentedButton<TransactionType>(
                          segments: const [
                            ButtonSegment(
                              value: TransactionType.EXPENSE,
                              label: Text('Expense'),
                              icon: Icon(Icons.arrow_upward_rounded),
                            ),
                            ButtonSegment(
                              value: TransactionType.INCOME,
                              label: Text('Income'),
                              icon: Icon(Icons.arrow_downward_rounded),
                            ),
                          ],
                          selected: {_selectedType},
                          onSelectionChanged: (selected) {
                            final nextType = selected.first;
                            setState(() {
                              _selectedType = nextType;
                              if (_selectedCategory?.type != nextType) {
                                _selectedCategory =
                                    _findMatchingCategory(widget.data.category, nextType);
                              }
                              _showCategoryError = false;
                            });
                          },
                        ),
                        const SizedBox(height: 20),
                        Text('Category', style: theme.textTheme.titleSmall),
                        const SizedBox(height: 8),
                        if (_availableCategories.isEmpty)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'No categories available for this type yet. Please create one first.',
                            ),
                          )
                        else
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _availableCategories.map((category) {
                              final isSelected = _selectedCategory?.id == category.id;
                              return ChoiceChip(
                                label: Text('${category.icon ?? '📦'} ${category.name}'),
                                selected: isSelected,
                                onSelected: (_) {
                                  setState(() {
                                    _selectedCategory = category;
                                    _showCategoryError = false;
                                  });
                                },
                              );
                            }).toList(),
                          ),
                        if (_showCategoryError)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              'Please select a category',
                              style: TextStyle(
                                color: theme.colorScheme.error,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        if (widget.data.items != null && widget.data.items!.isNotEmpty) ...[
                          const SizedBox(height: 20),
                          Text('Detected Items', style: theme.textTheme.titleSmall),
                          const SizedBox(height: 8),
                          ...widget.data.items!.take(4).map(
                                (item) => Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 4),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          '${item.name ?? 'Item'} x${item.quantity ?? 1}',
                                        ),
                                      ),
                                      Text(
                                        '\$${item.price?.toStringAsFixed(2) ?? '0.00'}',
                                        style: theme.textTheme.bodyMedium?.copyWith(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Obx(
                  () => Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      CustomButton(
                        text: 'Confirm & Save',
                        isLoading: widget.isSaving.value,
                        icon: const Icon(Icons.check_circle_outline_rounded, size: 18),
                        onPressed: _submit,
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton(
                        onPressed: widget.isSaving.value ? null : () => Get.back(),
                        child: const Text('Cancel'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategory == null) {
      setState(() {
        _showCategoryError = true;
      });
      return;
    }

    await widget.onConfirm(
      AiReviewSubmission(
        amount: double.parse(_amountController.text.trim()),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        date: _selectedDate,
        type: _selectedType,
        category: _selectedCategory!,
      ),
    );
  }

  CategoryModel? _findMatchingCategory(String? categoryName, TransactionType type) {
    final query = _normalizeCategory(categoryName);
    if (query.isEmpty) return null;

    final filtered = widget.categories.where((category) => category.type == type).toList();
    for (final category in filtered) {
      if (_normalizeCategory(category.name) == query) {
        return category;
      }
    }

    for (final category in filtered) {
      final normalizedName = _normalizeCategory(category.name);
      if (normalizedName.contains(query) || query.contains(normalizedName)) {
        return category;
      }
    }

    return null;
  }

  DateTime? _parseExtractedDate(String? rawDate) {
    if (rawDate == null || rawDate.trim().isEmpty) return null;

    final parsed = DateTime.tryParse(rawDate.trim());
    if (parsed != null) return parsed;

    const patterns = [
      'yyyy-MM-dd',
      'dd/MM/yyyy',
      'MM/dd/yyyy',
      'dd-MM-yyyy',
      'MMM d, yyyy',
      'MMMM d, yyyy',
      'd MMM yyyy',
      'd MMMM yyyy',
    ];

    for (final pattern in patterns) {
      try {
        return DateFormat(pattern).parseStrict(rawDate.trim());
      } catch (_) {
        // Try next supported format.
      }
    }

    return null;
  }

  String _buildSuggestedDescription(AiExtractModel data) {
    final extractedDescription = data.description?.trim();
    if (extractedDescription != null && extractedDescription.isNotEmpty) {
      return extractedDescription;
    }

    final merchant = data.merchant?.trim();
    final itemNames = data.items
            ?.map((item) => item.name?.trim())
            .whereType<String>()
            .where((item) => item.isNotEmpty)
            .take(3)
            .toList() ??
        <String>[];

    if (merchant != null && merchant.isNotEmpty && itemNames.isNotEmpty) {
      return '$merchant - ${itemNames.join(', ')}';
    }

    if (merchant != null && merchant.isNotEmpty) {
      return merchant;
    }

    return itemNames.join(', ');
  }

  String _normalizeCategory(String? value) {
    return (value ?? '').toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
  }
}





