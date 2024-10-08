// lib/model/order_list_request_model.dart
class OrderListRequest {
  final int foodId;
  final int quantity;

  OrderListRequest({
    required this.foodId,
    required this.quantity,
  });

  Map<String, dynamic> toJson() {
    return {
      'food_id': foodId,
      'quantity': quantity,
    };
  }
}

class OrderRequest {
  final int number;
  final List<OrderListRequest> orderList;

  OrderRequest({
    required this.number,
    required this.orderList,
  });

  Map<String, dynamic> toJson() {
    return {
      'number': number,
      'order_list': orderList.map((order) => order.toJson()).toList(),
    };
  }
}
