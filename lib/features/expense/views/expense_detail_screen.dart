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

