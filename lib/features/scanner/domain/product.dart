class Product {
  final String id;
  final String name;
  final double price;
  final String qrCode;
  final String imageUrl;
  final String category;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.qrCode,
    required this.imageUrl,
    required this.category,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      price: (json['price'] ?? 0.0).toDouble(),
      qrCode: json['qr_code'] ?? '',
      imageUrl: json['image_url'] ?? '',
      category: json['category'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'qr_code': qrCode,
      'image_url': imageUrl,
      'category': category,
    };
  }
}
