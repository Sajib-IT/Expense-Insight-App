import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:expense_insight/app/config/app_colors.dart';
import 'package:expense_insight/app/routes/app_pages.dart';
import 'package:expense_insight/features/budget/controllers/budget_controller.dart';

class BudgetListScreen extends GetView<BudgetController> {
  const BudgetListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Budgets')),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'addBudgetFab',
        onPressed: () => Get.toNamed(Routes.addBudget),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add'),
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.budgets.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        return RefreshIndicator(
          onRefresh: controller.fetchBudgets,
          child: Column(
            children: [
              // Month Selector
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                child: Obx(() {
                  final monthName = DateFormat('MMMM yyyy').format(
                    DateTime(controller.selectedYear.value, controller.selectedMonth.value),
                  );
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardTheme.color,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.divider.withValues(alpha: 0.5)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          onPressed: () {
                            if (controller.selectedMonth.value == 1) {
                              controller.changeMonth(12, controller.selectedYear.value - 1);
                            } else {
                              controller.changeMonth(controller.selectedMonth.value - 1, controller.selectedYear.value);
                            }
                          },
                          icon: const Icon(Icons.chevron_left_rounded, size: 28),
                          style: IconButton.styleFrom(
                            backgroundColor: AppColors.primary.withValues(alpha: 0.08),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                        Text(monthName,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -0.3,
                                )),
                        IconButton(
                          onPressed: () {
                            if (controller.selectedMonth.value == 12) {
                              controller.changeMonth(1, controller.selectedYear.value + 1);
                            } else {
                              controller.changeMonth(controller.selectedMonth.value + 1, controller.selectedYear.value);
                            }
                          },
                          icon: const Icon(Icons.chevron_right_rounded, size: 28),
                          style: IconButton.styleFrom(
                            backgroundColor: AppColors.primary.withValues(alpha: 0.08),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ),

              const SizedBox(height: 16),

              // Budget List
              Expanded(
                child: controller.budgets.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.08),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.savings_outlined, size: 48, color: AppColors.primary.withValues(alpha: 0.5)),
                            ),
                            const SizedBox(height: 20),
                            Text('No budgets set',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textSecondary,
                                    )),
                            const SizedBox(height: 8),
                            Text('Create a budget to track spending',
                                style: TextStyle(color: AppColors.textTertiary, fontSize: 14)),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                        itemCount: controller.budgets.length,
                        itemBuilder: (context, index) {
                          final budget = controller.budgets[index];
                          final isOverBudget = budget.percentage > 100;
                          final progressColor = isOverBudget
                              ? AppColors.expense
                              : budget.percentage > 75
                                  ? AppColors.warning
                                  : AppColors.income;

                          return Dismissible(
                            key: Key(budget.id),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              alignment: Alignment.centerRight,
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.only(right: 24),
                              decoration: BoxDecoration(
                                color: AppColors.expense,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Icon(Icons.delete_outline_rounded, color: Colors.white),
                            ),
                            confirmDismiss: (_) async {
                              return await Get.dialog<bool>(
                                AlertDialog(
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                  title: const Text('Delete Budget'),
                                  content: const Text('Are you sure?'),
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
                            onDismissed: (_) => controller.deleteBudget(budget.id),
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(18),
                              decoration: BoxDecoration(
                                color: Theme.of(context).cardTheme.color,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isOverBudget
                                      ? AppColors.expense.withValues(alpha: 0.3)
                                      : AppColors.divider.withValues(alpha: 0.5),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        width: 44,
                                        height: 44,
                                        decoration: BoxDecoration(
                                          color: progressColor.withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Center(
                                          child: Text(budget.categoryIcon ?? '📦', style: const TextStyle(fontSize: 22)),
                                        ),
                                      ),
                                      const SizedBox(width: 14),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              budget.categoryName ?? 'Category',
                                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              '\$${budget.spent.toStringAsFixed(2)} of \$${budget.amount.toStringAsFixed(2)}',
                                              style: TextStyle(fontSize: 12, color: AppColors.textTertiary),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: progressColor.withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          '${budget.percentage.toStringAsFixed(0)}%',
                                          style: TextStyle(
                                            color: progressColor,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 14),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(6),
                                    child: LinearProgressIndicator(
                                      value: (budget.percentage / 100).clamp(0.0, 1.0),
                                      minHeight: 8,
                                      backgroundColor: progressColor.withValues(alpha: 0.1),
                                      valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Remaining: \$${budget.remaining.toStringAsFixed(2)}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: isOverBudget ? AppColors.expense : AppColors.textSecondary,
                                          fontWeight: isOverBudget ? FontWeight.w600 : FontWeight.w400,
                                        ),
                                      ),
                                      if (isOverBudget)
                                        Row(
                                          children: [
                                            Icon(Icons.warning_amber_rounded, size: 14, color: AppColors.expense),
                                            const SizedBox(width: 4),
                                            Text('Over budget', style: TextStyle(fontSize: 12, color: AppColors.expense, fontWeight: FontWeight.w600)),
                                          ],
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

