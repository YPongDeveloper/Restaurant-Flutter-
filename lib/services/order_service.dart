// lib/services/order_service.dart
import 'dart:convert';
import 'dart:js';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/order_list_request_model.dart'; // Import your order model
import '../config/api_constants.dart';
import '../models/order_model.dart';
import '../models/order_response_model.dart';

class OrderService {
  Future<int> createOrder(OrderRequest orderRequest) async {
    final response = await http.post(
      Uri.parse('${ApiConstants.orderAPI}/create'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(orderRequest.toJson()),
    );

    if (response.statusCode == 200) {
      // Handle successful response if needed
      print('Order created successfully: ${response.body}');
      return 0;
    } else if(response.statusCode == 201){

      final responseBody = jsonDecode(response.body);
      final dataResponse = responseBody['data'];
      final queueId = dataResponse['queue_id'];
      print('Order created successfully: ${queueId}');
      return queueId;
    }else{
      // Handle error response
      throw Exception('Failed to create order: ${response.body}');
      return 0;
    }
  }
  Future<List<Order>> fetchOrders() async {
    final response = await http.get(Uri.parse(ApiConstants.orderAPI));

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body)['data'];
      return jsonResponse.map((order) => Order.fromJson(order)).toList();
    } else {
      throw Exception('Failed to load orders');
    }
  }

  Future<OrderResponse> fetchOrderById(int orderId) async {
    final response = await http.get(Uri.parse(ApiConstants.orderAPI+'/$orderId'));

    if (response.statusCode == 200) {
      var jsonResponse = json.decode(response.body)['data'];
      return OrderResponse.fromJson(jsonResponse);
    } else {
      throw Exception('Failed to load order details');
    }
  }
  Future<void> updateOrderStatus(int orderId, int newStatus, [String? review]) async {
    String statusCase ="";
    if(newStatus==2){
      statusCase ="eating";
    }else if(newStatus==3){
      statusCase ="cancel";
    }else if(newStatus==4){
      statusCase ="paid";
    }
    final response = await http.put(
      Uri.parse('${ApiConstants.orderAPI}/$statusCase/$orderId'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'review': review,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update order status');
    }
  }
  Future<List<Order>> fetchOrdersByEmployee(int employeeId) async {
    final response = await http.get(Uri.parse('${ApiConstants.orderAPI}/employee/$employeeId'));

    if (response.statusCode == 200) {
      final List<dynamic> orderData = json.decode(response.body)['data'];
      return orderData.map((json) => Order.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load orders');
    }
  }
  Future<void> updateNewOrder(int orderId, List<OrderListRequest> orderList) async {
    final response = await http.put(
      Uri.parse('${ApiConstants.orderAPI}/update/$orderId'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(orderList.map((order) => order.toJson()).toList()),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update order');
    } else {
      print('Order updated successfully: ${response.body}');
    }
  }
}
