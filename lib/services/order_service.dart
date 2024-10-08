// lib/services/order_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/order_model.dart'; // Import your order model

class OrderService {
  static const String _baseUrl = 'http://localhost:8080/order/create';

  Future<void> createOrder(OrderRequest orderRequest) async {
    final response = await http.post(
      Uri.parse(_baseUrl),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(orderRequest.toJson()),
    );

    if (response.statusCode == 200) {
      // Handle successful response if needed
      print('Order created successfully: ${response.body}');
    } else {
      // Handle error response
      throw Exception('Failed to create order: ${response.body}');
    }
  }
}
