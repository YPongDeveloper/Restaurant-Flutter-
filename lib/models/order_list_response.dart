class OrderListResponse {
  final int orderId;
  final String foodName;
  final String categoryName;
  final int quantity;
  final int totalPrice;
  final int foodId; // Add foodId property

  OrderListResponse({
    required this.orderId,
    required this.foodName,
    required this.categoryName,
    required this.quantity,
    required this.totalPrice,
    required this.foodId, // Include foodId in the constructor
  });

  factory OrderListResponse.fromJson(Map<String, dynamic> json) {
    return OrderListResponse(
      orderId: json['order_id'],
      foodName: json['food_name'],
      categoryName: json['category_name'],
      quantity: json['quantity'],
      totalPrice: json['total_price'],
      foodId: json['food_id'], // Parse foodId from JSON
    );
  }
}
