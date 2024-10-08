import 'order_list_response.dart';

class OrderResponse {
  final int customerId;
  final int employeeId;
  final int orderId;
  final int tableId;
  final int totalAmount;
  final DateTime orderDate;
  final int status;
  final String review;
  final List<OrderListResponse> orderList; // รายการอาหาร

  OrderResponse({
    required this.customerId,
    required this.employeeId,
    required this.orderId,
    required this.tableId,
    required this.totalAmount,
    required this.orderDate,
    required this.status,
    required this.review,
    required this.orderList,
  });

  factory OrderResponse.fromJson(Map<String, dynamic> json) {
    var list = json['order_list'] as List;
    List<OrderListResponse> orderList =
    list.map((i) => OrderListResponse.fromJson(i)).toList();

    return OrderResponse(
      customerId: json['customer_id'],
      employeeId: json['employee_id'],
      orderId: json['order_id'],
      tableId: json['table_id'],
      totalAmount: json['total_amount'],
      orderDate: DateTime.parse(json['order_date']),
      status: json['status'],
      review: json['review'] ?? '',
      orderList: orderList,
    );
  }
}
