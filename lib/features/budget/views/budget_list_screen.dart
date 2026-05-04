import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:expense_insight/app/routes/app_pages.dart';
import 'package:expense_insight/features/budget/controllers/budget_controller.dart';

class BudgetListScreen extends GetView<BudgetController> {
  const BudgetListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Budgets')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.toNamed(Routes.addBudget),
        child: const Icon(Icons.add),
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
                padding: const EdgeInsets.all(16),
                child: Obx(() {
                  final monthName = DateFormat('MMMM yyyy').format(
                    DateTime(controller.selectedYear.value, controller.selectedMonth.value),
                  );
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: () {
                          if (controller.selectedMonth.value == 1) {
                            controller.changeMonth(12, controller.selectedYear.value - 1);
                          } else {
                            controller.changeMonth(
                                controller.selectedMonth.value - 1, controller.selectedYear.value);
                          }
                        },
                        icon: const Icon(Icons.chevron_left),
                      ),
                      Text(monthName,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              )),
                      IconButton(
                        onPressed: () {
                          if (controller.selectedMonth.value == 12) {
                            controller.changeMonth(1, controller.selectedYear.value + 1);
                          } else {
                            controller.changeMonth(
                                controller.selectedMonth.value + 1, controller.selectedYear.value);
                          }
                        },
                        icon: const Icon(Icons.chevron_right),
                      ),
                    ],
                  );
                }),
              ),

              // Budget List
              Expanded(
                child: controller.budgets.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.account_balance_wallet_outlined,
                                size: 64, color: Colors.grey.shade400),
                            const SizedBox(height: 16),
                            Text('No budgets set',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(color: Colors.grey)),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: controller.budgets.length,
                        itemBuilder: (context, index) {
                          final budget = controller.budgets[index];
                          final isOverBudget = budget.percentage > 100;

                          return Dismissible(
                            key: Key(budget.id),
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
                                  title: const Text('Delete Budget'),
                                  content: const Text('Are you sure?'),
                                  actions: [
                                    TextButton(
                                        onPressed: () => Get.back(result: false),
                                        child: const Text('Cancel')),
                                    TextButton(
                                      onPressed: () => Get.back(result: true),
                                      child: const Text('Delete',
                                          style: TextStyle(color: Colors.red)),
                                    ),
                                  ],
                                ),
                              ) ?? false;
                            },
                            onDismissed: (_) => controller.deleteBudget(budget.id),
                            child: Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(budget.categoryIcon ?? '📦',
                                            style: const TextStyle(fontSize: 24)),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            budget.categoryName ?? 'Category',
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleMedium
                                                ?.copyWith(fontWeight: FontWeight.w600),
                                          ),
                                        ),
                                        Text(
                                          '${budget.percentage.toStringAsFixed(0)}%',
                                          style: TextStyle(
                                            color: isOverBudget ? Colors.red : Colors.green,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: LinearProgressIndicator(
                                        value: (budget.percentage / 100).clamp(0.0, 1.0),
                                        minHeight: 8,
                                        backgroundColor: Colors.grey.shade200,
                                        valueColor: AlwaysStoppedAnimation<Color>(
                                          isOverBudget ? Colors.red : Colors.green,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Spent: \$${budget.spent.toStringAsFixed(2)}',
                                          style: Theme.of(context).textTheme.bodySmall,
                                        ),
                                        Text(
                                          'Remaining: \$${budget.remaining.toStringAsFixed(2)}',
                                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                color: isOverBudget ? Colors.red : null,
                                              ),
                                        ),
                                        Text(
                                          'Budget: \$${budget.amount.toStringAsFixed(2)}',
                                          style: Theme.of(context).textTheme.bodySmall,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
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

