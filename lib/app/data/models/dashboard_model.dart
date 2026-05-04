import 'package:expense_insight/app/data/models/expense_model.dart';

class DashboardModel {
  final DashboardPeriod period;
  final DashboardSummary summary;
  final List<CategoryBreakdown> categoryBreakdown;
  final List<BudgetOverview> budgetOverview;
  final List<ExpenseModel> recentTransactions;

  DashboardModel({
    required this.period,
    required this.summary,
    required this.categoryBreakdown,
    required this.budgetOverview,
    required this.recentTransactions,
  });

  factory DashboardModel.fromJson(Map<String, dynamic> json) {
    return DashboardModel(
      period: DashboardPeriod.fromJson(json['period'] ?? {}),
      summary: DashboardSummary.fromJson(json['summary'] ?? {}),
      categoryBreakdown: (json['categoryBreakdown'] as List? ?? [])
          .map((e) => CategoryBreakdown.fromJson(e))
          .toList(),
      budgetOverview: (json['budgetOverview'] as List? ?? [])
          .map((e) => BudgetOverview.fromJson(e))
          .toList(),
      recentTransactions: (json['recentTransactions'] as List? ?? [])
          .map((e) => ExpenseModel.fromJson(e))
          .toList(),
    );
  }
}

class DashboardPeriod {
  final int month;
  final int year;

  DashboardPeriod({required this.month, required this.year});

  factory DashboardPeriod.fromJson(Map<String, dynamic> json) {
    return DashboardPeriod(
      month: json['month'] ?? DateTime.now().month,
      year: json['year'] ?? DateTime.now().year,
    );
  }
}

class DashboardSummary {
  final double totalIncome;
  final double totalExpenses;
  final double balance;
  final int transactionCount;

  DashboardSummary({
    required this.totalIncome,
    required this.totalExpenses,
    required this.balance,
    required this.transactionCount,
  });

  factory DashboardSummary.fromJson(Map<String, dynamic> json) {
    return DashboardSummary(
      totalIncome: (json['totalIncome'] ?? 0).toDouble(),
      totalExpenses: (json['totalExpenses'] ?? 0).toDouble(),
      balance: (json['balance'] ?? 0).toDouble(),
      transactionCount: json['transactionCount'] ?? 0,
    );
  }
}

class CategoryBreakdown {
  final String categoryId;
  final String categoryName;
  final String? categoryColour;
  final String? categoryIcon;
  final double total;
  final int count;
  final double percentage;

  CategoryBreakdown({
    required this.categoryId,
    required this.categoryName,
    this.categoryColour,
    this.categoryIcon,
    required this.total,
    required this.count,
    required this.percentage,
  });

  factory CategoryBreakdown.fromJson(Map<String, dynamic> json) {
    return CategoryBreakdown(
      categoryId: json['categoryId'] ?? '',
      categoryName: json['categoryName'] ?? '',
      categoryColour: json['categoryColour'],
      categoryIcon: json['categoryIcon'],
      total: (json['total'] ?? 0).toDouble(),
      count: json['count'] ?? 0,
      percentage: (json['percentage'] ?? 0).toDouble(),
    );
  }
}

class BudgetOverview {
  final String id;
  final String categoryName;
  final double budgetAmount;
  final double spent;
  final double remaining;
  final double percentage;

  BudgetOverview({
    required this.id,
    required this.categoryName,
    required this.budgetAmount,
    required this.spent,
    required this.remaining,
    required this.percentage,
  });

  factory BudgetOverview.fromJson(Map<String, dynamic> json) {
    return BudgetOverview(
      id: json['id'] ?? '',
      categoryName: json['categoryName'] ?? '',
      budgetAmount: (json['budgetAmount'] ?? 0).toDouble(),
      spent: (json['spent'] ?? 0).toDouble(),
      remaining: (json['remaining'] ?? 0).toDouble(),
      percentage: (json['percentage'] ?? 0).toDouble(),
    );
  }
}

