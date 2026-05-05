import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:expense_insight/app/common/widgets/shimmer_loading.dart';
import 'package:expense_insight/app/routes/app_pages.dart';
import 'package:expense_insight/features/dashboard/controllers/dashboard_controller.dart';

class DashboardScreen extends GetView<DashboardController> {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => controller.fetchDashboard(isRefresh: true),
            tooltip: 'Reload',
          ),
          IconButton(
            icon: const Icon(Icons.document_scanner_outlined),
            onPressed: () => Get.toNamed(Routes.aiExtract),
            tooltip: 'AI Extract',
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value &&
            (controller.dashboard.value == null || controller.isRefreshing.value)) {
          return ShimmerLoading.dashboard(context);
        }

        return RefreshIndicator(
          onRefresh: () => controller.fetchDashboard(isRefresh: true),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Month Selector
                _buildMonthSelector(context),
                const SizedBox(height: 20),

                // Summary Cards
                _buildSummaryCards(context),
                const SizedBox(height: 24),

                // Category Breakdown
                _buildSectionTitle(context, 'Category Breakdown'),
                const SizedBox(height: 12),
                _buildCategoryBreakdown(context),
                const SizedBox(height: 24),

                // Budget Overview
                _buildSectionTitle(context, 'Budget Overview'),
                const SizedBox(height: 12),
                _buildBudgetOverview(context),
                const SizedBox(height: 24),

                // Recent Transactions
                _buildSectionTitle(context, 'Recent Transactions'),
                const SizedBox(height: 12),
                _buildRecentTransactions(context),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildMonthSelector(BuildContext context) {
    return Obx(() {
      final monthName = DateFormat('MMMM yyyy').format(
        DateTime(controller.selectedYear.value, controller.selectedMonth.value),
      );
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: controller.previousMonth,
            icon: const Icon(Icons.chevron_left),
          ),
          Text(
            monthName,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          IconButton(
            onPressed: controller.nextMonth,
            icon: const Icon(Icons.chevron_right),
          ),
        ],
      );
    });
  }

  Widget _buildSummaryCards(BuildContext context) {
    final summary = controller.dashboard.value?.summary;
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _summaryCard(
                context,
                'Income',
                summary?.totalIncome ?? 0,
                Colors.green,
                Icons.arrow_downward,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _summaryCard(
                context,
                'Expenses',
                summary?.totalExpenses ?? 0,
                Colors.red,
                Icons.arrow_upward,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _summaryCard(
                context,
                'Balance',
                summary?.balance ?? 0,
                Colors.blue,
                Icons.account_balance_wallet,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _summaryCard(
                context,
                'Transactions',
                (summary?.transactionCount ?? 0).toDouble(),
                Colors.purple,
                Icons.receipt_long,
                isCount: true,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _summaryCard(
    BuildContext context,
    String title,
    double value,
    Color color,
    IconData icon, {
    bool isCount = false,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Text(title, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              isCount
                  ? value.toInt().toString()
                  : '\$${value.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
    );
  }

  Widget _buildCategoryBreakdown(BuildContext context) {
    final breakdown = controller.dashboard.value?.categoryBreakdown ?? [];
    if (breakdown.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Center(child: Text('No data for this period')),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: breakdown.map((item) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  Text(item.categoryIcon ?? '📦', style: const TextStyle(fontSize: 20)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.categoryName,
                            style: Theme.of(context).textTheme.bodyMedium),
                        const SizedBox(height: 4),
                        LinearProgressIndicator(
                          value: item.percentage / 100,
                          backgroundColor: Colors.grey.shade200,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            _parseColor(item.categoryColour),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '\$${item.total.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      Text('${item.percentage.toStringAsFixed(0)}%',
                          style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildBudgetOverview(BuildContext context) {
    final budgets = controller.dashboard.value?.budgetOverview ?? [];
    if (budgets.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Center(child: Text('No budgets set for this period')),
        ),
      );
    }

    return Column(
      children: budgets.map((budget) {
        final isOverBudget = budget.percentage > 100;
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(budget.categoryName,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            )),
                    Text(
                      '${budget.percentage.toStringAsFixed(0)}%',
                      style: TextStyle(
                        color: isOverBudget ? Colors.red : Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: (budget.percentage / 100).clamp(0.0, 1.0),
                  backgroundColor: Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isOverBudget ? Colors.red : Colors.green,
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
                      'Budget: \$${budget.budgetAmount.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildRecentTransactions(BuildContext context) {
    final transactions = controller.dashboard.value?.recentTransactions ?? [];
    if (transactions.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Center(child: Text('No recent transactions')),
        ),
      );
    }

    return Card(
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: transactions.length,
        separatorBuilder: (context2, index2) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final tx = transactions[index];
          final isExpense = tx.type.value == 'EXPENSE';
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: isExpense
                  ? Colors.red.withValues(alpha: 0.1)
                  : Colors.green.withValues(alpha: 0.1),
              child: Text(
                tx.category?.icon ?? (isExpense ? '💸' : '💰'),
                style: const TextStyle(fontSize: 18),
              ),
            ),
            title: Text(
              tx.description ?? tx.category?.name ?? 'Transaction',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(DateFormat('MMM dd').format(tx.date)),
            trailing: Text(
              '${isExpense ? '-' : '+'}\$${tx.amount.toStringAsFixed(2)}',
              style: TextStyle(
                color: isExpense ? Colors.red : Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
          );
        },
      ),
    );
  }

  Color _parseColor(String? colorStr) {
    if (colorStr == null || colorStr.isEmpty) return Colors.blue;
    try {
      return Color(int.parse(colorStr.replaceFirst('#', '0xFF')));
    } catch (_) {
      return Colors.blue;
    }
  }
}





