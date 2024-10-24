import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../models/food_model.dart';
import '../../../services/menu_service.dart';
import '../../../widgets/food_card.dart'; // Import the FoodCard widget
import '../../../models/order_list_request_model.dart'; // Import the OrderRequest model
import '../../../services/order_service.dart';
import '../../models/category_model.dart';
import 'food_info_screen.dart'; // Import OrderService

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Food>> futureMenu;
  late Future<List<Category>> futureCategory;
  Map<int, int> orderCount = {};
  final TextEditingController _customerCountController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  int? selectedCategoryId;
  List<Category> categories = [];
  final TextEditingController _searchController = TextEditingController();
  String searchQuery = "";

  @override
  void initState() {
    super.initState();
    _loadCategories();
    futureMenu = MenuService().fetchMenu();
  }
  Future<void> _loadCategories() async {
    String categoryIcon = await getBase64Image();
    Category all = Category(categoryId: 0, categoryName: "All", imageCategory: categoryIcon);

    MenuService().fetchCategories().then((fetchedCategories) {
      setState(() {
        categories = [all, ...fetchedCategories.cast<Category>()];
      });
    });
  }
  Future<String> getBase64Image() async {
    ByteData bytes = await rootBundle.load('lib/assets/categoryIcon.png');
    List<int> imageBytes = bytes.buffer.asUint8List();
    return base64Encode(imageBytes);
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
    _searchController.dispose();
    super.dispose();
  }

  void _scrollRight() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.offset + 240, // Adjust the scroll distance as needed
        duration: Duration(milliseconds: 900),
        curve: Curves.easeInOut,
      );
    }
  }

  void _scrollLeft() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.offset - 240, // Adjust the scroll distance as needed
        duration: Duration(milliseconds: 900),
        curve: Curves.easeInOut,
      );
    }
  }

  List<Food> filterMenuByCategoryAndSearch(List<Food> menu) {
    List<Food> filteredMenu =
    menu.where((food) => food.available != 2).toList();

    // Filter by category
    if (selectedCategoryId != null && selectedCategoryId != 0) {
      filteredMenu = filteredMenu
          .where((food) => food.categoryId == selectedCategoryId)
          .toList();
    }

    // Filter by search query
    if (searchQuery.isNotEmpty) {
      filteredMenu = filteredMenu
          .where((food) =>
          food.foodName.toLowerCase().contains(searchQuery.toLowerCase()))
          .toList();
    }

    return filteredMenu;
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
            ListTile(
              leading: Icon(Icons.shopping_bag, color: Colors.grey), // เปลี่ยนสีเป็นสีส้ม
              title: Text('Management'),
              onTap: () {
                Navigator.pushNamed(context, '/management');
              },
            ),
            ListTile(
              leading: Icon(Icons.queue, color: Colors.pink), // เปลี่ยนสีเป็นสีส้ม
              title: Text('Queue'),
              onTap: () {
                Navigator.pushNamed(context, '/queueScreen');
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
                                selectedCategoryId = category.categoryId;
                              });
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: selectedCategoryId == category.categoryId
                                    ? Colors.green
                                    : Colors.grey[200],
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Column(
                                children: [
                                  category.imageCategory.isNotEmpty
                                      ? Image(
                                    image: MemoryImage(base64Decode(category.imageCategory)),
                                    width: 40,
                                    height: 40,
                                    fit: BoxFit.fill,
                                  )
                                      : Image(
                                    image: AssetImage('lib/assets/categoryIcon.png'),
                                    width: 40,
                                    height: 40,
                                    fit: BoxFit.fill,
                                  ),
                                  Text(
                                    category.categoryName,
                                    style: TextStyle(
                                      color: selectedCategoryId == category.categoryId
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
              SizedBox(height: 15,),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    labelText: 'Search food...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    setState(() {
                      searchQuery = value;
                    });
                  },
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
                    List<Food> filteredMenu = filterMenuByCategoryAndSearch(snapshot.data!);

                    return GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: itemsPerRow,
                        childAspectRatio: 0.8,
                      ),
                      itemCount: filteredMenu.length,
                      itemBuilder: (context, index) {
                        final food = filteredMenu[index];
                        return InkWell(
                          onTap: (){
                            Navigator.push(context, MaterialPageRoute(
                              builder: (context) => FoodInfoScreen(foodId: food.foodId),
                            ));
                          },
                          child: FoodCard(
                            food: food,
                            orderCount: orderCount[food.foodId] ?? 0,
                            incrementOrder: () => incrementOrder(food.foodId),
                            decrementOrder: () => decrementOrder(food.foodId),
                          ),
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