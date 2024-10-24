import 'package:employee/routes/app_routes.dart';
import 'package:employee/screens/order/order_screen.dart';
import 'package:flutter/material.dart';
import 'screens/employee/employee_screen.dart';
import 'screens/home/home_screen.dart';
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Restaurant App',
      initialRoute: '/home',
      onGenerateRoute: AppRoutes.generateRoute,
    );
  }
}
