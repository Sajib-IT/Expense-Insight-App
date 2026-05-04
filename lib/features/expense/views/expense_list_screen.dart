import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:expense_insight/app/routes/app_pages.dart';
import 'package:expense_insight/features/expense/controllers/expense_controller.dart';

class ExpenseListScreen extends GetView<ExpenseController> {
  const ExpenseListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transactions'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterSheet(context),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.toNamed(Routes.addExpense),
        child: const Icon(Icons.add),
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.expenses.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.expenses.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.receipt_long_outlined, size: 64, color: Colors.grey.shade400),
                const SizedBox(height: 16),
                Text('No transactions yet',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey)),
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: () => Get.toNamed(Routes.addExpense),
                  icon: const Icon(Icons.add),
                  label: const Text('Add Transaction'),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.fetchExpenses,
          child: NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              if (notification is ScrollEndNotification &&
                  notification.metrics.extentAfter < 100) {
                controller.fetchExpenses(loadMore: true);
              }
              return false;
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: controller.expenses.length,
              itemBuilder: (context, index) {
                final expense = controller.expenses[index];
                final isExpense = expense.type.value == 'EXPENSE';

                return Dismissible(
                  key: Key(expense.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    color: Colors.red,
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  confirmDismiss: (_) async {
                    return await Get.dialog<bool>(
                      AlertDialog(
                        title: const Text('Delete Transaction'),
                        content: const Text('Are you sure you want to delete this transaction?'),
                        actions: [
                          TextButton(onPressed: () => Get.back(result: false), child: const Text('Cancel')),
                          TextButton(
                            onPressed: () => Get.back(result: true),
                            child: const Text('Delete', style: TextStyle(color: Colors.red)),
                          ),
                        ],
                      ),
                    ) ?? false;
                  },
                  onDismissed: (_) => controller.deleteExpense(expense.id),
                  child: Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      onTap: () => Get.toNamed(Routes.expenseDetail, arguments: expense),
                      leading: CircleAvatar(
                        backgroundColor: isExpense
                            ? Colors.red.withValues(alpha: 0.1)
                            : Colors.green.withValues(alpha: 0.1),
                        child: Text(
                          expense.category?.icon ?? (isExpense ? '💸' : '💰'),
                          style: const TextStyle(fontSize: 18),
                        ),
                      ),
                      title: Text(
                        expense.description ?? expense.category?.name ?? 'Transaction',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        '${expense.category?.name ?? ''} • ${DateFormat('MMM dd, yyyy').format(expense.date)}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      trailing: Text(
                        '${isExpense ? '-' : '+'}\$${expense.amount.toStringAsFixed(2)}',
                        style: TextStyle(
                          color: isExpense ? Colors.red : Colors.green,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      }),
    );
  }

  void _showFilterSheet(BuildContext context) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Filter', style: Theme.of(context).textTheme.titleLarge),
                TextButton(
                  onPressed: () {
                    controller.clearFilters();
                    Get.back();
                  },
                  child: const Text('Clear All'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text('Type', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            Obx(() => Wrap(
                  spacing: 8,
                  children: [
                    ChoiceChip(
                      label: const Text('All'),
                      selected: controller.selectedType.value == null,
                      onSelected: (_) => controller.selectedType.value = null,
                    ),
                    ChoiceChip(
                      label: const Text('Expense'),
                      selected: controller.selectedType.value == 'EXPENSE',
                      onSelected: (_) => controller.selectedType.value = 'EXPENSE',
                    ),
                    ChoiceChip(
                      label: const Text('Income'),
                      selected: controller.selectedType.value == 'INCOME',
                      onSelected: (_) => controller.selectedType.value = 'INCOME',
                    ),
                  ],
                )),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  controller.applyFilters(type: controller.selectedType.value);
                  Get.back();
                },
                child: const Text('Apply Filters'),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}



