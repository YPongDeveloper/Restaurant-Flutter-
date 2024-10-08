import 'package:flutter/material.dart';
import '../screens/employee_screen.dart';
import '../screens/home_screen.dart';
import '../screens/order_screen.dart';

class AppRoutes {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/home':
        return MaterialPageRoute(builder: (_) => HomeScreen());
      case '/employees':
        return MaterialPageRoute(builder: (_) => EmployeeScreen());
      case '/orders':
        return MaterialPageRoute(builder: (_) => OrdersScreen());
      default:
        return MaterialPageRoute(builder: (_) => Scaffold(body: Center(child: Text('No route defined'))));
    }
  }
}
