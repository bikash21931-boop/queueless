class TransactionModel {
  final String id;
  final String userId;
  final double totalAmount;
  final DateTime timestamp;
  final String receiptQr;
  final List<TransactionItem> items;

  TransactionModel({
    required this.id,
    required this.userId,
    required this.totalAmount,
    required this.timestamp,
    required this.receiptQr,
    required this.items,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    var itemsList = json['items'] as List? ?? [];
    List<TransactionItem> parsedItems = itemsList
        .map((i) => TransactionItem.fromJson(i))
        .toList();

    return TransactionModel(
      id: json['transaction_id'] ?? '',
      userId: json['user_id'] ?? '',
      totalAmount: (json['total_price'] ?? 0).toDouble(),
      timestamp: DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now(),
      receiptQr: json['receipt_qr'] ?? '',
      items: parsedItems,
    );
  }
}

class TransactionItem {
  final String productId;
  final String name;
  final double price;
  final int quantity;

  TransactionItem({
    required this.productId,
    required this.name,
    required this.price,
    required this.quantity,
  });

  factory TransactionItem.fromJson(Map<String, dynamic> json) {
    return TransactionItem(
      productId: json['product_id'] ?? '',
      name: json['name'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      quantity: json['quantity'] ?? 1,
    );
  }
}
