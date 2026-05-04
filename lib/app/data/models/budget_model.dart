class BudgetModel {
  final String id;
  final double amount;
  final double spent;
  final double remaining;
  final double percentage;
  final int month;
  final int year;
  final String categoryId;
  final String userId;
  final String? categoryName;
  final String? categoryColour;
  final String? categoryIcon;
  final DateTime createdAt;
  final DateTime updatedAt;

  BudgetModel({
    required this.id,
    required this.amount,
    this.spent = 0,
    this.remaining = 0,
    this.percentage = 0,
    required this.month,
    required this.year,
    required this.categoryId,
    required this.userId,
    this.categoryName,
    this.categoryColour,
    this.categoryIcon,
    required this.createdAt,
    required this.updatedAt,
  });

  factory BudgetModel.fromJson(Map<String, dynamic> json) {
    final category = json['category'];
    return BudgetModel(
      id: json['id'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      spent: (json['spent'] ?? 0).toDouble(),
      remaining: (json['remaining'] ?? 0).toDouble(),
      percentage: (json['percentage'] ?? 0).toDouble(),
      month: json['month'] ?? 1,
      year: json['year'] ?? 2026,
      categoryId: json['categoryId'] ?? '',
      userId: json['userId'] ?? '',
      categoryName: category != null ? category['name'] : json['categoryName'],
      categoryColour: category != null ? category['colour'] : json['categoryColour'],
      categoryIcon: category != null ? category['icon'] : json['categoryIcon'],
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'amount': amount,
      'month': month,
      'year': year,
      'categoryId': categoryId,
    };
  }
}

