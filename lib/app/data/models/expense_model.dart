import 'package:expense_insight/app/data/models/category_model.dart';

class ExpenseModel {
  final String id;
  final double amount;
  final String? description;
  final DateTime date;
  final TransactionType type;
  final String? receiptUrl;
  final String categoryId;
  final String userId;
  final CategoryModel? category;
  final DateTime createdAt;
  final DateTime updatedAt;

  ExpenseModel({
    required this.id,
    required this.amount,
    this.description,
    required this.date,
    required this.type,
    this.receiptUrl,
    required this.categoryId,
    required this.userId,
    this.category,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ExpenseModel.fromJson(Map<String, dynamic> json) {
    return ExpenseModel(
      id: json['id'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      description: json['description'],
      date: DateTime.parse(json['date'] ?? DateTime.now().toIso8601String()),
      type: TransactionType.fromString(json['type'] ?? 'EXPENSE'),
      receiptUrl: json['receiptUrl'],
      categoryId: json['categoryId'] ?? '',
      userId: json['userId'] ?? '',
      category: json['category'] != null
          ? CategoryModel.fromJson(json['category'])
          : null,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'amount': amount,
      'description': description,
      'date': date.toIso8601String().split('T').first,
      'type': type.value,
      'categoryId': categoryId,
    };
  }
}


