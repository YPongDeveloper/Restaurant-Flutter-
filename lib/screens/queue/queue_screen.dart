import 'package:flutter/material.dart';
import '/models/order_model.dart';
import '../../../services/order_service.dart';
import '../../../widgets/order_detail_dialog.dart';

class QueueScreen extends StatefulWidget {
  @override
  _QueueScreenState createState() => _QueueScreenState();
}

class _QueueScreenState extends State<QueueScreen> {
  late Future<List<Order>> futureOrders;
  List<Order>? filteredOrders;
  int selectedStatus = 5;

  @override
  void initState() {
    super.initState();
    futureOrders = OrderService().fetchOrders();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFEAFFD0), // เปลี่ยนสีพื้นหลังเป็น #EAFFD0
      appBar: AppBar(
        title: Text('Queues'),
        backgroundColor: Color(0xFFF38181), // เปลี่ยนสี AppBar เป็น #F38181
      ),
      drawer: Drawer(
        backgroundColor: Color(0xFFFCE38A), // เปลี่ยนสี Drawer เป็น #FCE38A
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Color(0xFFF38181), // เปลี่ยนสี Header เป็น #F38181
              ),
              child: Text(
                'Queues',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.home, color: Colors.red),
              title: Text('Home'),
              onTap: () {
                Navigator.pushNamed(context, '/home');
              },
            ),
            ListTile(
              leading: Icon(Icons.person, color: Colors.green),
              title: Text('Employees'),
              onTap: () {
                Navigator.pushNamed(context, '/employees');
              },
            ),
            ListTile(
              leading: Icon(Icons.shopping_bag, color: Colors.orange),
              title: Text('Orders'),
              onTap: () {
                Navigator.pushNamed(context, '/orders');
              },
            ),
            ListTile(
              leading: Icon(Icons.shopping_bag, color: Colors.grey),
              title: Text('Management'),
              onTap: () {
                Navigator.pushNamed(context, '/management');
              },
            ),
            ListTile(
              leading: Icon(Icons.queue, color: Colors.pink),
              title: Text('Queue', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pushNamed(context, '/queueScreen');
              },
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<List<Order>>(
              future: futureOrders,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (snapshot.hasData) {
                  List<Order>? orders = snapshot.data;

                  if (selectedStatus != null) {
                    filteredOrders = orders?.where((order) => order.status == selectedStatus).toList();
                  } else {
                    filteredOrders = orders;
                  }
                  return ListView.builder(
                    itemCount: filteredOrders?.length ?? 0,
                    itemBuilder: (context, index) {
                      final order = filteredOrders![index];
                      return GestureDetector(
                        onTap: () {
                          showOrderDetails(context, order.orderId);
                        },
                        child: Container(
                          padding: EdgeInsets.all(10),
                          margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: Color(0xFF95E1D3), // เปลี่ยนสีพื้นหลังของ Container เป็น #95E1D3
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.shade600,
                                spreadRadius: 1,
                                blurRadius: 13,
                              )
                            ],
                            border: Border.all(color: Colors.grey),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Order ID: ${order.orderId}', style: TextStyle(fontWeight: FontWeight.bold)),
                              SizedBox(height: 5),
                              Text('Customer ID: ${order.customerId}'),
                              Text('Total Amount: \$${order.totalAmount}'),
                              Text('Status: ${getStatusText(order.status)}'),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }
                return Center(child: Text('No orders found'));
              },
            ),
          ),
        ],
      ),
    );
  }

  String getStatusText(int status) {
    switch (status) {
      case 0:
        return 'Online Waiting';
      case 1:
        return 'Onsite Waiting';
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

  void showOrderDetails(BuildContext context, int orderId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return OrderDetailDialog(orderId: orderId);
      },
    ).then((value) {
      if (value == true) {
        setState(() {
          futureOrders = OrderService().fetchOrders();
        });
      }
    });
  }
}
