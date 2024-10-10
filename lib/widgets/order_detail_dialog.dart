import 'package:flutter/material.dart';
import '../models/order_response_model.dart';
import '../services/order_service.dart';

class OrderDetailDialog extends StatefulWidget {
  final int orderId;

  OrderDetailDialog({required this.orderId});

  @override
  _OrderDetailDialogState createState() => _OrderDetailDialogState();
}

class _OrderDetailDialogState extends State<OrderDetailDialog> {
  late Future<OrderResponse> futureOrder;
  int? selectedStatus;
  String? review; // To store the review if required

  @override
  void initState() {
    super.initState();
    futureOrder = OrderService().fetchOrderById(widget.orderId);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<OrderResponse>(
      future: futureOrder,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return AlertDialog(
            content: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasError) {
          return AlertDialog(
            content: Text('Error: ${snapshot.error}'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('OK'),
              ),
            ],
          );
        }

        final  order = snapshot.data!;
        return AlertDialog(
          title: Text('Order Details'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Order ID: ${order.orderId}', style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 5),
                Text('Customer ID: ${order.customerId}'),
                Text('Employee ID: ${order.employeeId}'),
                Text('Table ID: ${order.tableId}'),
                Text('Total Amount: \$${order.totalAmount}'),
                Text('Order Date: ${order.orderDate}'),
                Text('Status: ${getStatusText(order.status)}'),
                Text('Review: ${order.review}'),
                SizedBox(height: 10),
                Text('Order List:', style: TextStyle(fontWeight: FontWeight.bold)),
                ...order.orderList.map((item) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2.0),
                  child: Text('${item.foodName} (${item.categoryName}) x${item.quantity} - \$${item.totalPrice}'),
                )),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                  _showEditStatusDialog(order.status);
              },
              child: Text('Edit Status'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
          ],
        );
      },
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
        return 'Cancel';
      default:
        return 'Unknown';
    }
  }

  void _showEditStatusDialog(int currentStatus) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Edit Status'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<int>(
                    value: selectedStatus ?? currentStatus,
                    items: [
                      DropdownMenuItem(child: Text('Wait',style: TextStyle(color: Colors.red[400]),), value: 1),
                      DropdownMenuItem(child: Text('Eating'), value: 2),
                      DropdownMenuItem(child: Text('Paid'), value: 4),
                      DropdownMenuItem(child: Text('Cancel'), value: 3),
                    ],
                    onChanged: (value) {
                      setState(() {
                        selectedStatus = value;
                      });
                    },
                    decoration: InputDecoration(
                      labelText: 'Select Status',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  if (selectedStatus == 4 || selectedStatus == 3) // Only show when Paid or Cancel is selected
                    Padding(
                      padding: const EdgeInsets.only(top: 15.0),
                      child: TextFormField(
                        onChanged: (value) {
                          setState(() {
                            review = value; // Update review state
                          });
                        },
                        decoration: InputDecoration(
                          labelText: 'Enter Review',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () async {
                    if (selectedStatus != null && selectedStatus != currentStatus && selectedStatus !=1) {
                      try {
                        // Call updateOrderStatus with the selected status and review if applicable
                        await OrderService().updateOrderStatus(widget.orderId, selectedStatus!, review);
                        Navigator.of(context).pop(); // Close the edit dialog
                        Navigator.of(context).pop(true); // Close the details dialog and refresh
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Failed to update status: $e')),
                        );
                      }
                    } else {
                      // No change, just close
                      Navigator.of(context).pop();
                    }
                  },
                  child: Text('Confirm'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('Cancel'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
