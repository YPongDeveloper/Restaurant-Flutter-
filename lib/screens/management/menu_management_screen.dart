import 'package:flutter/material.dart';
import 'food_management_screen.dart';
import 'category_management_screen.dart';

class MenuManagementScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Menu Management'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildManagementCard(context, 'Food', Icons.fastfood, FoodManagementScreen()),
                _buildManagementCard(context, 'Category', Icons.category, CategoryManagementScreen()),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildManagementCard(BuildContext context, String title, IconData icon, Widget screen) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => screen));
      },
      child: Card(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 80),
            Text(title, style: TextStyle(fontSize: 24)),
          ],
        ),
      ),
    );
  }
}
