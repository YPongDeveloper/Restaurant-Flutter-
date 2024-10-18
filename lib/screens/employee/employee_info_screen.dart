import 'package:flutter/material.dart';
import '../../models/order_model.dart';
import '../../services/order_service.dart';

class EmployeeInfoScreen extends StatefulWidget {
  final int employeeId; // Pass employeeId from the previous screen

  EmployeeInfoScreen({required this.employeeId});

  @override
  _EmployeeInfoScreenState createState() => _EmployeeInfoScreenState();
}

class _EmployeeInfoScreenState extends State<EmployeeInfoScreen> {
  final OrderService orderService = OrderService();
  List<Order> orders = [];

  @override
  void initState() {
    super.initState();
    fetchOrdersForEmployee();
  }

  Future<void> fetchOrdersForEmployee() async {
    try {
      final orderList = await orderService.fetchOrdersByEmployee(widget.employeeId);
      setState(() {
        orders = orderList;
      });
    } catch (e) {
      // Handle errors if needed
      print('Error fetching orders: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Orders for Employee ID ${widget.employeeId}'),
        backgroundColor: Colors.yellow[400],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: orders.isEmpty
            ? Center(child: CircularProgressIndicator()) // Show loading spinner
            : GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10.0,
            mainAxisSpacing: 10.0,
            childAspectRatio: 2 / 3,
          ),
          itemCount: orders.length,
          itemBuilder: (context, index) {
            final order = orders[index];
            return OrderCard(order: order);
          },
        ),
      ),
    );
  }
}

class OrderCard extends StatelessWidget {
  final Order order;

  OrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Order ID: ${order.orderId}', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 5),
            Text('Customer ID: ${order.customerId}'),
            Text('Table ID: ${order.tableId}'),
            Text('Total Menu: ${order.totalMenu}'),
            Text('Total Amount: \$${order.totalAmount}'),
            SizedBox(height: 10),
            Text('Status: ${getStatusText(order.status)}', style: TextStyle(color: getStatusColor(order.status))),
            SizedBox(height: 5),
            Text('Date: ${order.orderDate.toLocal()}'),
            if (order.review.isNotEmpty) Text('Review: "${order.review}"'),
          ],
        ),
      ),
    );
  }

  // Helper method to convert status code to text
  String getStatusText(int status) {
    switch (status) {
      case 1:
        return 'Waiting';
      case 2:
        return 'Eating';
      case 4:
        return 'Paid';
      case 3:
        return 'Canceled';
      default:
        return 'Unknown';
    }
  }

  // Helper method to get status color
  Color getStatusColor(int status) {
    switch (status) {
      case 1:
        return Colors.orange;
      case 2:
        return Colors.green;
      case 4:
        return Colors.blue;
      case 3:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
