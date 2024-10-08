class Order {
  final int orderId;
  final int customerId;
  final int number;
  final int employeeId;
  final int tableId;
  final int totalMenu;
  final int totalAmount;
  final DateTime orderDate;
  final int status;
  final String review;

  Order({
    required this.orderId,
    required this.customerId,
    required this.number,
    required this.employeeId,
    required this.tableId,
    required this.totalMenu,
    required this.totalAmount,
    required this.orderDate,
    required this.status,
    required this.review,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      orderId: json['order_id'],
      customerId: json['customer_id'],
      number: json['number'],
      employeeId: json['employee_id'],
      tableId: json['table_id'],
      totalMenu: json['total_menu'],
      totalAmount: json['total_amount'],
      orderDate: DateTime.parse(json['order_date']),
      status: json['status'],
      review: json['review'],
    );
  }
}
