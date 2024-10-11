// lib/screens/home/order_dialog.dart

import 'package:flutter/material.dart';
import '../../models/food_model.dart';
import '../../models/order_list_request_model.dart';
import '../../services/order_service.dart';

class OrderDialog extends StatelessWidget {
  final Future<List<Food>> futureMenu;
  final Map<int, int> orderCount;
  final TextEditingController customerCountController;
  final Function() onOrderSubmitted;

  const OrderDialog({
    Key? key,
    required this.futureMenu,
    required this.orderCount,
    required this.customerCountController,
    required this.onOrderSubmitted,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Food>>(
      future: futureMenu,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return AlertDialog(
            title: Text('Loading...'),
            content: CircularProgressIndicator(),
          );
        } else if (snapshot.hasError) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('Failed to load menu: ${snapshot.error}'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('Close'),
              ),
            ],
          );
        } else if (snapshot.hasData) {
          List<Food> menu = snapshot.data!;

          List<Widget> orderDetails = orderCount.entries
              .where((entry) => entry.value > 0)
              .map((entry) {
            final foodId = entry.key;
            final quantity = entry.value;

            Food? orderedFood = menu.firstWhere(
                  (food) => food.foodId == foodId,
              orElse: () => Food(
                foodId: 0,
                foodName: 'Unknown',
                description: 'No description available',
                imageBase64: 'assets/images/default_image.png',
                price: 0,
                available: 0,
                calories: 0,
                categoryId: 0,
              ),
            );

            return Text('${orderedFood.foodName}: $quantity');
          }).toList();

          return AlertDialog(
            title: Text('Order Summary'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: customerCountController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Number of Customers',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16),
                Text('Your Order:'),
                ...orderDetails,
              ],
            ),
            actions: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(primary: Colors.red),
                onPressed: () {
                  customerCountController.clear();
                  Navigator.of(context).pop();
                },
                child: Text('Cancel'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(primary: Colors.green),
                onPressed: () async {
                  String customerCount = customerCountController.text;

                  if (customerCount.isEmpty ||
                      int.tryParse(customerCount) == null ||
                      int.parse(customerCount) < 0) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Please enter a valid number of customers.')),
                    );
                    return;
                  }

                  List<OrderListRequest> orderList = orderCount.entries
                      .where((entry) => entry.value > 0)
                      .map((entry) => OrderListRequest(
                    foodId: entry.key,
                    quantity: entry.value,
                  ))
                      .toList();

                  OrderRequest orderRequest = OrderRequest(
                    number: int.parse(customerCount),
                    orderList: orderList,
                  );

                  try {
                    await OrderService().createOrder(orderRequest);
                    onOrderSubmitted();
                    Navigator.of(context).pop();
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to create order: $e')),
                    );
                  }
                },
                child: Text('Submit'),
              ),
            ],
          );
        } else {
          return AlertDialog(
            title: Text('Error'),
            content: Text('No data available.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('Close'),
              ),
            ],
          );
        }
      },
    );
  }
}
