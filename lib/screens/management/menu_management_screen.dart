import 'package:flutter/material.dart';
import 'food_management_screen.dart';
import 'category_management_screen.dart';

class MenuManagementScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Menu Management'),
        backgroundColor: Color(0xFFFF9494), // AppBar color
      ),
      body: Container(
        color: Color(0xFFFFF5E4), // Body background color
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildManagementCard(context, 'Food', Icons.fastfood, FoodManagementScreen(), Color(0xFFFFE3E1)), // Color for Food Card
                _buildManagementCard(context, 'Category', Icons.category, CategoryManagementScreen(), Color(0xFFFFD1D1)), // Color for Category Card
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildManagementCard(BuildContext context, String title, IconData icon, Widget screen, Color cardColor) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => screen));
      },
      child: Container(
        width: 150, // Adjust the width as needed
        height: 150, // Adjust the height as needed
        child: Card(
          color: cardColor, // Set the card color
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center, // Center content vertically
            children: [
              Icon(icon, size: 60, color: Colors.black), // Adjust icon size if needed
              SizedBox(height: 10), // Space between icon and text
              Text(title, style: TextStyle(fontSize: 24)),
            ],
          ),
        ),
      ),
    );
  }
}
