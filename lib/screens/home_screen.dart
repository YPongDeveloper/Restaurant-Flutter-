// lib/screens/home/home_screen.dart
import 'package:flutter/material.dart';
import '../../models/food_model.dart';
import '../../services/menu_service.dart';
import '../../widgets/food_card.dart'; // Import the FoodCard widget
import '../../models/order_list_request_model.dart'; // Import the OrderRequest model
import '../../services/order_service.dart'; // Import OrderService

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Food>> futureMenu;
  Map<int, int> orderCount = {};
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
                    image: 'assets/images/default_image.png',
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
                    ...orderDetails,
                  ],
                ),
                actions: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(primary: Colors.red),
                    onPressed: () {
                      _customerCountController.clear();
                      Navigator.of(context).pop();
                    },
                    child: Text('Cancel'),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(primary: Colors.green),
                    onPressed: () async {
                      String customerCount = _customerCountController.text;

                      if (customerCount.isEmpty || int.tryParse(customerCount) == null || int.parse(customerCount) < 0) {
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

                        setState(() {
                          orderCount.clear();
                          _customerCountController.clear();
                          futureMenu = MenuService().fetchMenu();
                        });

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
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[100],
      appBar: AppBar(
      backgroundColor: Color(0xff6fbb0f),
        title: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text('Pir Restaurant'),
            ),
        actions: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30)
                  ,color: Colors.yellow[200]
            ),
            child: IconButton(
              icon: Icon(Icons.shopping_cart),
              onPressed: _showOrderDialog,
            ),
          ),
        ],
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
                'Home',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.home, color: Colors.red), // เปลี่ยนสีเป็นสีแดง
              title: Text('Home',style: TextStyle(color: Colors.red),),
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
              title: Text('Orders'),
              onTap: () {
                Navigator.pushNamed(context, '/orders');
              },
            ),
          ],
        ),
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
