import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../home/login_screen.dart';
import 'food_management_screen.dart';
import 'category_management_screen.dart';

class MenuManagementScreen extends StatefulWidget {
  @override
  _MenuManagementScreenState createState() => _MenuManagementScreenState();
}

class _MenuManagementScreenState extends State<MenuManagementScreen> {
  int? position;
  @override
  void initState() {
    super.initState();
    _loadPosition();
  }
  Future<void> _loadPosition() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      position = prefs.getInt('position');
    });
  }

  Future<void> _logout() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('position');

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
          (Route<dynamic> route) => false,  // This removes all previous routes
    );
  }
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
              leading: Icon(Icons.home, color: Colors.red),
              // เปลี่ยนสีเป็นสีแดง
              title: Text('Home'),
              onTap: () {
                Navigator.pushNamed(context, '/home');
              },
            ),
            ListTile(
              leading: Icon(Icons.shopping_bag, color: Colors.orange),
              // เปลี่ยนสีเป็นสีส้ม
              title: Text('Orders'),
              onTap: () {
                Navigator.pushNamed(context, '/orders');
              },
            ),
            ListTile(
              leading: Icon(Icons.queue, color: Colors.pink),
              // เปลี่ยนสีเป็นสีส้ม
              title: Text('Queue'),
              onTap: () {
                Navigator.pushNamed(context, '/queueScreen');
              },
            ),
            ListTile(
              leading: Icon(Icons.person, color: Colors.green),
              // เปลี่ยนสีเป็นสีเขียว
              title: Text('Employees'),
              onTap: () {
                Navigator.pushNamed(context, '/employees');
              },
            ),
            ListTile(
              leading: Icon(Icons.shopping_bag, color: Colors.grey),
              // เปลี่ยนสีเป็นสีส้ม
              title: Text('Management', style: TextStyle(color: Colors.red),),
              onTap: () {
                Navigator.pushNamed(context, '/management');
              },
            ),
            ListTile(
              leading: Icon(Icons.logout, color: Colors.red),
              title: Text('Logout'),
              onTap: _logout,
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
                _buildManagementCard(context, 'Food', Image.asset(
                  "lib/assets/food.png", fit: BoxFit.cover, height: 65,),
                    FoodManagementScreen(), Color(0xFFFFE3E1)),
                // Color for Food Card
                _buildManagementCard(context, 'Category', Image.asset(
                  "lib/assets/categoryIcon.png", fit: BoxFit.cover,
                  height: 65,), CategoryManagementScreen(), Color(0xFFFFD1D1)),
                // Color for Category Card
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildManagementCard(BuildContext context, String title, Widget icon,
      Widget screen, Color cardColor) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => screen));
      },
      child: Container(
        width: 150, // Adjust the width as needed
        height: 150, // Adjust the height as needed
        child: Card(
          color: cardColor, // Set the card color
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            // Center content vertically
            children: [
              icon, // Adjust icon size if needed
              SizedBox(height: 10), // Space between icon and text
              Text(title, style: TextStyle(fontSize: 24)),
            ],
          ),
        ),
      ),
    );
  }
}