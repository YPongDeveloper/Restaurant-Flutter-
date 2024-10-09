import 'package:flutter/material.dart';
import '../../../models/food_model.dart';
import '../../../services/menu_service.dart';
import '../../../widgets/food_card.dart'; // Import the FoodCard widget
import '../../../models/order_list_request_model.dart'; // Import the OrderRequest model
import '../../../services/order_service.dart'; // Import OrderService

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Food>> futureMenu;
  Map<int, int> orderCount = {};
  final TextEditingController _customerCountController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  int? selectedCategoryId;

  final List<Map<String, dynamic>> categories = [
    {"category_id": 0, "category_name": "All"}, // Add All category
    {"category_id": 1, "category_name": "Lasagne"},
    {"category_id": 2, "category_name": "Desserts"},
    {"category_id": 3, "category_name": "Beverages"},
    {"category_id": 4, "category_name": "Salads"},
    {"category_id": 5, "category_name": "Soups"},
    {"category_id": 6, "category_name": "Pasta"},
    {"category_id": 7, "category_name": "Pizza"},
    {"category_id": 8, "category_name": "Burgers"},
    {"category_id": 9, "category_name": "Sandwiches"},
    {"category_id": 10, "category_name": "Steaks"},
    {"category_id": 11, "category_name": "Breakfast"},
    {"category_id": 12, "category_name": "Noodles"},
    {"category_id": 13, "category_name": "Sushi"},
    {"category_id": 14, "category_name": "Curry"},
    {"category_id": 15, "category_name": "Sushi"},
  ];

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

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollRight() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.offset + 100, // Adjust the scroll distance as needed
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _scrollLeft() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.offset - 100, // Adjust the scroll distance as needed
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  List<Food> filterMenuByCategory(List<Food> menu) {
    // If selectedCategoryId is 0 (All), return all items
    if (selectedCategoryId == null || selectedCategoryId == 0) {
      return menu;
    } else {
      return menu.where((food) => food.categoryId == selectedCategoryId).toList();
    }
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
  // ... (rest of your existing code)

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
                  borderRadius: BorderRadius.circular(30), color: Colors.yellow[200]),
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
                  'Employee',
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
        body: LayoutBuilder(
        builder: (context, constraints) {
      double screenWidth = constraints.maxWidth;
      int itemsPerRow = screenWidth > 600 ? 3 : 2;

      return Column(
        children: [
          // Horizontal category filter
          Container(
            height: 80,
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.chevron_left),
                  onPressed: _scrollLeft,
                ),
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController, // Assign the controller
                    scrollDirection: Axis.horizontal,
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      final category = categories[index];
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedCategoryId = category['category_id'];
                          });
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: selectedCategoryId == category['category_id']
                                ? Colors.green
                                : Colors.grey[200],
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Column(
                            children: [
                              Image(
                                image: AssetImage('lib/assets/${category['category_name']}.png'),
                                width: 40,
                                height: 40,
                                fit: BoxFit.fill,
                              ),
                              Text(
                                category['category_name'],
                                style: TextStyle(
                                  color: selectedCategoryId == category['category_id']
                                      ? Colors.white
                                      : Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.chevron_right),
                  onPressed: _scrollRight,
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Food>>(
              future: futureMenu,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Failed to load menu: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No food items available.'));
                }

                // Filter menu based on selected category
                List<Food> filteredMenu = filterMenuByCategory(snapshot.data!);

                return GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: itemsPerRow,
                    childAspectRatio: 0.8,
                  ),
                  itemCount: filteredMenu.length,
                  itemBuilder: (context, index) {
                    final food = filteredMenu[index];
                    return FoodCard(
                      food: food,
                      orderCount: orderCount[food.foodId] ?? 0,
                      incrementOrder: () => incrementOrder(food.foodId),
                      decrementOrder: () => decrementOrder(food.foodId),
                    );
                  },
                );
              },
            ),
          ),
        ],
      );
        },
        ),
    );
  }
}
