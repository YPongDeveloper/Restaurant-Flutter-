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
                'Management',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.home, color: Colors.red), // เปลี่ยนสีเป็นสีแดง
              title: Text('Home'),
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
              title: Text('Management',style: TextStyle(color: Colors.red),),
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
