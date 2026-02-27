import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../features/scanner/domain/product.dart';

import 'dart:io' show Platform;

String get baseUrl {
  if (kIsWeb) return 'http://localhost:3000/api';
  // Production APK Build: Point directly to the host PC's Wi-Fi IP address
  // Ensures phones can connect over the local network without a USB cable.
  if (Platform.isAndroid) return 'http://192.168.137.55:3000/api';
  return 'http://192.168.137.55:3000/api';
}

class ApiClient {
  static String? authToken;

  static Future<Product?> fetchProductByQR(
    String qrCode,
    String storeId,
  ) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/products/$qrCode?storeId=$storeId'),
        headers: {
          'Content-Type': 'application/json',
          if (authToken != null) 'Authorization': 'Bearer $authToken',
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
        Uri.parse('$baseUrl/payment/process'),
        headers: {
          'Content-Type': 'application/json',
          if (authToken != null) 'Authorization': 'Bearer $authToken',
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

  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      return jsonDecode(response.body);
    } catch (e) {
      debugPrint('Login error: \$e');
      return {'error': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> register({
    required String firstName,
    required String lastName,
    required String phone,
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'firstName': firstName,
          'lastName': lastName,
          'phone': phone,
          'email': email,
          'password': password,
        }),
      );

      return jsonDecode(response.body);
    } catch (e) {
      debugPrint('Registration error: \$e');
      return {'error': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> updateBudget(double monthlyBudget) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/budget'),
        headers: {
          'Content-Type': 'application/json',
          if (authToken != null) 'Authorization': 'Bearer $authToken',
        },
        body: jsonEncode({'monthlyBudget': monthlyBudget}),
      );

      return jsonDecode(response.body);
    } catch (e) {
      debugPrint('Update budget error: \$e');
      return {'error': e.toString()};
    }
  }

  static Future<List<dynamic>> fetchHistory() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/receipt/history'),
        headers: {
          'Content-Type': 'application/json',
          if (authToken != null) 'Authorization': 'Bearer $authToken',
        },
      );
      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        return data['receipts'];
      }
      return [];
    } catch (e) {
      debugPrint('History fetch error: \$e');
      return [];
    }
  }
}
