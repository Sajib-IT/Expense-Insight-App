// ignore_for_file: constant_identifier_names

enum TransactionType {
  INCOME('INCOME'),
  EXPENSE('EXPENSE');

  final String value;
  const TransactionType(this.value);

  static TransactionType fromString(String value) {
    switch (value.toUpperCase()) {
      case 'INCOME':
        return TransactionType.INCOME;
      case 'EXPENSE':
        return TransactionType.EXPENSE;
      default:
        return TransactionType.EXPENSE;
    }
  }
}

class CategoryModel {
  final String id;
  final String name;
  final TransactionType type;
  final String? icon;
  final String? colour;
  final bool isDefault;
  final String userId;
  final DateTime createdAt;
  final DateTime updatedAt;

  CategoryModel({
    required this.id,
    required this.name,
    required this.type,
    this.icon,
    this.colour,
    required this.isDefault,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      type: TransactionType.fromString(json['type'] ?? 'EXPENSE'),
      icon: json['icon'],
      colour: json['colour'],
      isDefault: json['isDefault'] ?? false,
      userId: json['userId'] ?? '',
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'type': type.value,
      'icon': icon,
      'colour': colour,
    };
  }
}



