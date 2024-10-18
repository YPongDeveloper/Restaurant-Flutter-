import 'package:flutter/material.dart';
import '/models/order_model.dart';
import '../../../services/order_service.dart';
import '../../../widgets/order_detail_dialog.dart';

class OrdersScreen extends StatefulWidget {
  @override
  _OrdersScreenState createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  late Future<List<Order>> futureOrders;
  List<Order>? filteredOrders;
  int? selectedStatus;

  @override
  void initState() {
    super.initState();
    futureOrders = OrderService().fetchOrders();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFE5D7FF),
      appBar: AppBar(
        title: Text('Orders'),
        backgroundColor: Color(0xFFC9A1EF),
      ),
      drawer: Drawer(
        backgroundColor: Colors.blue[50],
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'Orders',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.home, color: Colors.red), // เปลี่ยนสีเป็นสีแดง
              title: Text('Home'),
              onTap: () {
                Navigator.pushNamed(context, '/home');
              },
            ),
            ListTile(
              leading: Icon(Icons.person, color: Colors.green), // เปลี่ยนสีเป็นสีเขียว
              title: Text('Employees'),
              onTap: () {
                Navigator.pushNamed(context, '/employees');
              },
            ),
            ListTile(
              leading: Icon(Icons.shopping_bag, color: Colors.orange), // เปลี่ยนสีเป็นสีส้ม
              title: Text('Orders',style: TextStyle(color: Colors.red),),
              onTap: () {
                Navigator.pushNamed(context, '/orders');
              },
            ),
            ListTile(
              leading: Icon(Icons.shopping_bag, color: Colors.grey), // เปลี่ยนสีเป็นสีส้ม
              title: Text('Management'),
              onTap: () {
                Navigator.pushNamed(context, '/management');
              },
            ),
          ],
        ),
      ),
      body: Column(
        children: [

          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.white
                ),
                child: Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: DropdownButton<int>(
                    borderRadius: BorderRadius.circular(16),
                    value: selectedStatus,
                    hint: Text('Filter by Status', style: TextStyle(color: Colors.grey)),
                    onChanged: (int? newStatus) {
                      setState(() {
                        selectedStatus = newStatus;

                      });
                    },
                    items: [
                      DropdownMenuItem(
                        value: null,
                        child: Text('All', style: TextStyle(color: Colors.blue)),
                      ),
                      DropdownMenuItem(
                        value: 0,
                        child: Text('Online Waiting', style: TextStyle(color: Colors.pink)),
                      ),
                      DropdownMenuItem(
                        value: 1,
                        child: Text('Onsite Waiting', style: TextStyle(color: Colors.orange)),
                      ),
                      DropdownMenuItem(
                        value: 2,
                        child: Text('Eating', style: TextStyle(color: Colors.green)),
                      ),
                      DropdownMenuItem(
                        value: 4,
                        child: Text('Paid', style: TextStyle(color: Colors.purple)),
                      ),
                      DropdownMenuItem(
                        value: 3,
                        child: Text('Canceled', style: TextStyle(color: Colors.red)),
                      ),
                    ],
                    dropdownColor: Colors.white,
                    iconEnabledColor: Colors.black,
                    style: TextStyle(color: Colors.black),
                  ),

                ),
              ),
            ],
          ),
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
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.grey.shade600,
                                  spreadRadius: 1,
                                  blurRadius: 13
                              )
                            ] ,
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
