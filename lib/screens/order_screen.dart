import 'package:flutter/material.dart';
import '/models/order_model.dart';
import '../../services/order_service.dart';
import '../../widgets/order_detail_dialog.dart';

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
      appBar: AppBar(
        title: Text('Orders'),
        backgroundColor: Color(0xFFC9A1EF),
      ),
      body: Column(
        children: [

          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
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
                      value: 1,
                      child: Text('Waiting', style: TextStyle(color: Colors.orange)),
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
                            borderRadius: BorderRadius.circular(10),
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
