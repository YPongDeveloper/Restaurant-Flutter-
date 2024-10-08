// lib/widgets/food_card.dart
import 'dart:io';
import 'package:flutter/material.dart';
import '../models/food_model.dart';

class FoodCard extends StatelessWidget {
  final Food food;
  final int orderCount;
  final Function() incrementOrder;
  final Function() decrementOrder;

  FoodCard({
    required this.food,
    required this.orderCount,
    required this.incrementOrder,
    required this.decrementOrder,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        color:Color(0xFFCEC336),
        elevation: 4,
        child: Container(
          padding: const EdgeInsets.all(12.0), // Padding around the content
          child: Column(
            mainAxisSize: MainAxisSize.min, // Adjust height based on children
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 8), // Top spacing
              Text(
                food.foodName,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text('Price: \$${food.price}'),
              SizedBox(height: 20),
              // Load image from the network (or you can use file path)
              Center(
                child: Image.network(
                 'https://scontent.fbkk13-3.fna.fbcdn.net/v/t1.15752-9/271527617_458558425802892_6061554732953425168_n.jpg?stp=dst-jpg_s2048x2048&_nc_cat=110&ccb=1-7&_nc_sid=9f807c&_nc_eui2=AeEsBWMEXiWgkzhj_W0j_f8qBo_14t7Diy4Gj_Xi3sOLLodQG_hA_WtM6ywzeE4PR-W940LQE5a6kORZe8Ph21I_&_nc_ohc=w9WCnU5tQ8MQ7kNvgHWMEXO&_nc_ht=scontent.fbkk13-3.fna&_nc_gid=AqK2aeifXzAiFPNLAJJVugM&oh=03_Q7cD1QH5XLcp18otfIn1hcMYMblY68_Z6SkB_fcrre1g1NgSQQ&oe=672862FD', // Use the food image URL directly from the model
                  width: 120,
                  height: 120,
                  fit: BoxFit.cover, // Cover ensures the image maintains its aspect ratio
                ),
              ),
              SizedBox(height: 8), // Bottom spacing
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Decrement button
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle, // Makes the container circular
                    ),
                    child: IconButton(
                      onPressed: decrementOrder,
                      icon: Icon(Icons.remove),
                      color: Colors.white, // Icon color
                    ),
                  ),
                  // Display order count
                  Text(
                    '$orderCount',
                    style: TextStyle(fontSize: 16),
                  ),
                  // Increment button
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      onPressed: incrementOrder,
                      icon: Icon(Icons.add),
                      color: Colors.white, // Icon color
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
