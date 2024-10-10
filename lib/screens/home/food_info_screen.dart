import 'package:flutter/material.dart';
import '../../models/food_info_model.dart';
import '../../models/food_model.dart';
import '../../services/menu_service.dart';

class FoodInfoScreen extends StatefulWidget {
  final int foodId;

  FoodInfoScreen({required this.foodId});

  @override
  _FoodInfoScreenState createState() => _FoodInfoScreenState();
}

class _FoodInfoScreenState extends State<FoodInfoScreen> {
  final MenuService menuService = MenuService();
  Future<FoodInfo>? food;

  @override
  void initState() {
    super.initState();
    food = fetchFoodDetails();
  }

  Future<FoodInfo> fetchFoodDetails() async {
    return await menuService.fetchFoodById(widget.foodId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Food Details'),
        backgroundColor: Color(0xff6fbb0f),
      ),
      body: FutureBuilder<FoodInfo>(
        future: food,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator()); // Show loading
          } else if (snapshot.hasError) {
            return Center(child: Text('Error loading food details ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return Center(child: Text('Food not found'));
          }
          final food = snapshot.data!;
          return Padding(
            padding: const EdgeInsets.all(90.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  // Food Image
                  Center(
                    child: Container(
                      width: MediaQuery.of(context).size.width*0.8, // ใช้ขนาดหน้าจอที่ยืดหดได้
                      height: MediaQuery.of(context).size.height * 0.4, // สูงเท่ากับ 40% ของความสูงหน้าจอ
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        image: DecorationImage(
                          image: AssetImage('lib/assets/${food.foodName}.jpg'), // สมมติว่า foodName สอดคล้องกับชื่อรูป
                          fit: BoxFit.cover, // ปรับขนาดรูปภาพให้ครอบคลุมพื้นที่ทั้งหมด
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Center(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [
                        Text(
                          food.foodName,
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 10),

                        SizedBox(height: 10),

                        // Calories
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${food.calorie} calories',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[600],
                              ),
                            ),
                            Text(
                              '฿${food.price}',
                              style: TextStyle(
                                fontSize: 22,
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),

                        // Food Description
                        Text(
                          food.description,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[800],
                          ),
                        ),
                        SizedBox(height: 20),

                        // Food Availability
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(width: 20),
                            Text(
                              food.available == 1 ? 'Available' : 'Not Available',
                              style: TextStyle(
                                fontSize: 18,
                                color: food.available == 1 ? Colors.green : Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Food Name

                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
