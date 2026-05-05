import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:expense_insight/app/config/app_colors.dart';
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
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.tune_rounded, color: AppColors.primary),
              onPressed: () => _showFilterSheet(context),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'addExpenseFab',
        onPressed: () => Get.toNamed(Routes.addExpense),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add'),
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
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.receipt_long_outlined, size: 48, color: AppColors.primary.withValues(alpha: 0.5)),
                ),
                const SizedBox(height: 20),
                Text('No transactions yet',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        )),
                const SizedBox(height: 8),
                Text('Tap + to add your first transaction',
                    style: TextStyle(color: AppColors.textTertiary, fontSize: 14)),
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
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
              itemCount: controller.expenses.length,
              itemBuilder: (context, index) {
                final expense = controller.expenses[index];
                final isExpense = expense.type.value == 'EXPENSE';

                return Dismissible(
                  key: Key(expense.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.only(right: 24),
                    decoration: BoxDecoration(
                      color: AppColors.expense,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Icons.delete_outline_rounded, color: Colors.white, size: 24),
                  ),
                  confirmDismiss: (_) async {
                    return await Get.dialog<bool>(
                      AlertDialog(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        title: const Text('Delete Transaction'),
                        content: const Text('This action cannot be undone.'),
                        actions: [
                          TextButton(onPressed: () => Get.back(result: false), child: const Text('Cancel')),
                          TextButton(
                            onPressed: () => Get.back(result: true),
                            child: const Text('Delete', style: TextStyle(color: AppColors.expense)),
                          ),
                        ],
                      ),
                    ) ?? false;
                  },
                  onDismissed: (_) => controller.deleteExpense(expense.id),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: Material(
                      color: Theme.of(context).cardTheme.color,
                      borderRadius: BorderRadius.circular(16),
                      child: InkWell(
                        onTap: () => Get.toNamed(Routes.expenseDetail, arguments: expense),
                        borderRadius: BorderRadius.circular(16),
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Row(
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: isExpense ? AppColors.expenseLight : AppColors.incomeLight,
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Center(
                                  child: Text(
                                    expense.category?.icon ?? (isExpense ? '💸' : '💰'),
                                    style: const TextStyle(fontSize: 22),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      expense.description ?? expense.category?.name ?? 'Transaction',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${expense.category?.name ?? ''} · ${DateFormat('MMM dd').format(expense.date)}',
                                      style: TextStyle(fontSize: 12, color: AppColors.textTertiary),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                '${isExpense ? '-' : '+'}\$${expense.amount.toStringAsFixed(2)}',
                                style: TextStyle(
                                  color: isExpense ? AppColors.expense : AppColors.income,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
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
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.textTertiary.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Filter', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
                TextButton(
                  onPressed: () {
                    controller.clearFilters();
                    Get.back();
                  },
                  child: const Text('Clear All'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text('Transaction Type', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),
            Obx(() => Row(
                  children: [
                    _filterChip('All', controller.selectedType.value == null, () => controller.selectedType.value = null),
                    const SizedBox(width: 8),
                    _filterChip('Expense', controller.selectedType.value == 'EXPENSE', () => controller.selectedType.value = 'EXPENSE'),
                    const SizedBox(width: 8),
                    _filterChip('Income', controller.selectedType.value == 'INCOME', () => controller.selectedType.value = 'INCOME'),
                  ],
                )),
            const SizedBox(height: 28),
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

  Widget _filterChip(String label, bool selected, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : AppColors.primary.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white : AppColors.textSecondary,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

