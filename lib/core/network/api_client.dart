import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../features/scanner/domain/product.dart';

import 'dart:io' show Platform;

String get baseUrl {
  if (kIsWeb) return 'http://localhost:3000/api';
  if (Platform.isAndroid) return 'http://10.0.2.2:3000/api';
  return 'http://127.0.0.1:3000/api';
}

class ApiClient {
  static String? authToken;

  static Future<Product?> fetchProductByQR(String qrCode) async {
    try {
      final response = await http.get(
        Uri.parse('\$baseUrl/products/\$qrCode'),
        headers: {
          'Content-Type': 'application/json',
          if (authToken != null) 'Authorization': 'Bearer \$authToken',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['product'] != null) {
          return Product.fromJson(data['product']);
        }
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching product: \$e');
      return null;
    }
  }

  static Future<Map<String, dynamic>> processPayment(
    List<Map<String, dynamic>> items,
    double total,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('\$baseUrl/payment/process'),
        headers: {
          'Content-Type': 'application/json',
          if (authToken != null) 'Authorization': 'Bearer \$authToken',
        },
        body: jsonEncode({'items': items, 'total_price': total}),
      );

      final data = jsonDecode(response.body);
      return data;
    } catch (e) {
      debugPrint('Payment error: \$e');
      return {'success': false, 'message': e.toString()};
    }
  }
}
