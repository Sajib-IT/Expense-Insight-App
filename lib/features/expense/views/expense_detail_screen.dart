import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:expense_insight/app/data/models/expense_model.dart';
import 'package:expense_insight/app/routes/app_pages.dart';
import 'package:expense_insight/features/expense/controllers/expense_controller.dart';

class ExpenseDetailScreen extends StatelessWidget {
  const ExpenseDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ExpenseModel expense = Get.arguments;
    final controller = Get.find<ExpenseController>();
    final isExpense = expense.type.value == 'EXPENSE';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction Detail'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => Get.toNamed(Routes.addExpense, arguments: expense),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: () async {
              final confirm = await Get.dialog<bool>(
                AlertDialog(
                  title: const Text('Delete Transaction'),
                  content: const Text('Are you sure?'),
                  actions: [
                    TextButton(onPressed: () => Get.back(result: false), child: const Text('Cancel')),
                    TextButton(
                      onPressed: () => Get.back(result: true),
                      child: const Text('Delete', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );
              if (confirm == true) {
                await controller.deleteExpense(expense.id);
                Get.back();
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Amount
            CircleAvatar(
              radius: 40,
              backgroundColor: isExpense
                  ? Colors.red.withValues(alpha: 0.1)
                  : Colors.green.withValues(alpha: 0.1),
              child: Text(
                expense.category?.icon ?? (isExpense ? '💸' : '💰'),
                style: const TextStyle(fontSize: 32),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '${isExpense ? '-' : '+'}\$${expense.amount.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isExpense ? Colors.red : Colors.green,
                  ),
            ),
            const SizedBox(height: 8),
            Chip(
              label: Text(expense.type.value),
              backgroundColor: isExpense
                  ? Colors.red.withValues(alpha: 0.1)
                  : Colors.green.withValues(alpha: 0.1),
            ),
            const SizedBox(height: 32),

            // Details
            _detailRow(context, 'Description', expense.description ?? 'N/A'),
            _detailRow(context, 'Category', expense.category?.name ?? 'N/A'),
            _detailRow(context, 'Date', DateFormat('MMMM dd, yyyy').format(expense.date)),
            _detailRow(context, 'Created', DateFormat('MMM dd, yyyy HH:mm').format(expense.createdAt)),

            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),

            // Receipt Section
            _buildReceiptSection(context, expense, controller),
          ],
        ),
      ),
    );
  }

  Widget _buildReceiptSection(BuildContext context, ExpenseModel expense, ExpenseController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Receipt',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            Obx(() => controller.isUploadingReceipt.value
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : TextButton.icon(
                    onPressed: () => controller.showReceiptOptions(expense.id),
                    icon: Icon(
                      expense.receiptUrl != null ? Icons.sync_rounded : Icons.upload_rounded,
                      size: 18,
                    ),
                    label: Text(expense.receiptUrl != null ? 'Replace' : 'Upload'),
                  )),
          ],
        ),
        const SizedBox(height: 8),
        if (expense.receiptUrl != null && expense.receiptUrl!.isNotEmpty)
          GestureDetector(
            onTap: () => _showReceiptFullScreen(context, expense.receiptUrl!),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: double.infinity,
                constraints: const BoxConstraints(maxHeight: 300),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
                ),
                child: Image.network(
                  expense.receiptUrl!,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return SizedBox(
                      height: 200,
                      child: Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 120,
                      color: Colors.grey.withValues(alpha: 0.1),
                      child: const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.broken_image_outlined, size: 40, color: Colors.grey),
                            SizedBox(height: 8),
                            Text('Failed to load receipt', style: TextStyle(color: Colors.grey)),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          )
        else
          GestureDetector(
            onTap: () => controller.showReceiptOptions(expense.id),
            child: Container(
              width: double.infinity,
              height: 120,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.withValues(alpha: 0.3), style: BorderStyle.solid),
                color: Colors.grey.withValues(alpha: 0.05),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.receipt_long_outlined, size: 40, color: Colors.grey[400]),
                  const SizedBox(height: 8),
                  Text(
                    'No receipt attached',
                    style: TextStyle(color: Colors.grey[500]),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Tap to upload',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  void _showReceiptFullScreen(BuildContext context, String imageUrl) {
    Get.dialog(
      Dialog(
        insetPadding: const EdgeInsets.all(16),
        backgroundColor: Colors.transparent,
        child: Stack(
          children: [
            InteractiveViewer(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: CircleAvatar(
                backgroundColor: Colors.black54,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Get.back(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey)),
          Flexible(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}

