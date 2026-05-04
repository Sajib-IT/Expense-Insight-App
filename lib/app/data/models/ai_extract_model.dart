class AiExtractModel {
  final double? amount;
  final String? description;
  final String? date;
  final String? type;
  final String? category;
  final String? merchant;
  final String? currency;
  final List<AiExtractItem>? items;
  final double? confidence;

  AiExtractModel({
    this.amount,
    this.description,
    this.date,
    this.type,
    this.category,
    this.merchant,
    this.currency,
    this.items,
    this.confidence,
  });

  factory AiExtractModel.fromJson(Map<String, dynamic> json) {
    return AiExtractModel(
      amount: (json['amount'] ?? 0).toDouble(),
      description: json['description'],
      date: json['date'],
      type: json['type'] ?? 'EXPENSE',
      category: json['category'],
      merchant: json['merchant'],
      currency: json['currency'],
      items: json['items'] != null
          ? (json['items'] as List).map((e) => AiExtractItem.fromJson(e)).toList()
          : null,
      confidence: (json['confidence'] ?? 0).toDouble(),
    );
  }
}

class AiExtractItem {
  final String? name;
  final int? quantity;
  final double? price;

  AiExtractItem({this.name, this.quantity, this.price});

  factory AiExtractItem.fromJson(Map<String, dynamic> json) {
    return AiExtractItem(
      name: json['name'],
      quantity: json['quantity'],
      price: (json['price'] ?? 0).toDouble(),
    );
  }
}

