// lib/screens/home/home_screen.dart
import 'package:flutter/material.dart';
import '../../model/food_model.dart';
import '../../services/menu_service.dart';
import '../../widgets/food_card.dart'; // Import the FoodCard widget
import '../../model/order_model.dart'; // Import the OrderRequest model
import '../../services/order_service.dart'; // Import OrderService

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Food>> futureMenu;
  Map<int, int> orderCount = {}; // Holds the quantity of each food ordered
  final TextEditingController _customerCountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    futureMenu = MenuService().fetchMenu();
  }

  void incrementOrder(int foodId) {
    setState(() {
      orderCount[foodId] = (orderCount[foodId] ?? 0) + 1;
    });
  }

  void decrementOrder(int foodId) {
    setState(() {
      if ((orderCount[foodId] ?? 0) > 0) {
        orderCount[foodId] = orderCount[foodId]! - 1;
      }
    });
  }

  void _showOrderDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return FutureBuilder<List<Food>>(
          future: futureMenu, // This gets the menu items asynchronously
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
              List<Food> menu = snapshot.data!; // Extract the list of foods

              // Create a list of order details based on the current orderCount
              List<Widget> orderDetails = orderCount.entries
                  .where((entry) => entry.value > 0) // Only include items with quantity > 0
                  .map((entry) {
                final foodId = entry.key;
                final quantity = entry.value;

                // Find the food item based on the foodId
                Food? orderedFood = menu.firstWhere(
                      (food) => food.foodId == foodId,
                  orElse: () => Food(
                    foodId: 0,
                    foodName: 'Unknown',
                    description: 'No description available',
                    image: 'assets/images/default_image.png', // Default image path
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
                      controller: _customerCountController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Number of Customers',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 16),
                    Text('Your Order:'),
                    ...orderDetails, // Display the order details
                  ],
                ),
                actions: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(primary: Colors.red),
                    onPressed: () {
                      _customerCountController.clear();
                      Navigator.of(context).pop(); // Close the dialog
                    },
                    child: Text('Cancel'),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(primary: Colors.green),
                    onPressed: () async {
                      String customerCount = _customerCountController.text;

                      // Input validation
                      if (customerCount.isEmpty || int.tryParse(customerCount) == null || int.parse(customerCount) < 0) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Please enter a valid number of customers.')),
                        );
                        return; // Don't proceed if invalid
                      }

                      // Prepare the order request
                      List<OrderListRequest> orderList = orderCount.entries
                          .where((entry) => entry.value > 0) // Only include items with quantity > 0
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
                        await OrderService().createOrder(orderRequest); // Call the service to create order

                        // Clear the order count and customer count after successful submission
                        setState(() {
                          orderCount.clear(); // Clear order counts
                          _customerCountController.clear(); // Clear the text field
                          futureMenu = MenuService().fetchMenu(); // Reload the menu
                        });

                        Navigator.of(context).pop(); // Close the dialog
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
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
      backgroundColor: Color(0xff123a86),
        title: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
                color: Colors.green
          ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text('Pir Restaurant'),
            )),
        actions: [
          IconButton(
            icon: Icon(Icons.shopping_cart),
            onPressed: _showOrderDialog, // Show the order dialog when pressed
          ),
        ],
      ),
      body: FutureBuilder<List<Food>>(
        future: futureMenu,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final menu = snapshot.data!;
            return GridView.builder(
              padding: EdgeInsets.all(8),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 3 / 4,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: menu.length,
              itemBuilder: (context, index) {
                final food = menu[index];
                return FoodCard(
                  food: food,
                  orderCount: orderCount[food.foodId] ?? 0,
                  incrementOrder: () => incrementOrder(food.foodId),
                  decrementOrder: () => decrementOrder(food.foodId),
                );
              },
            );
          } else {
            return Center(child: Text('No data available'));
          }
        },
      ),
    );
  }
}
