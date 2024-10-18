import 'package:flutter/material.dart';
import '../screens/employee/employee_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/management/menu_management_screen.dart';
import '../screens/order/order_screen.dart';

class AppRoutes {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/home':
        return MaterialPageRoute(builder: (_) => HomeScreen());
      case '/employees':
        return MaterialPageRoute(builder: (_) => EmployeeScreen());
      case '/orders':
        return MaterialPageRoute(builder: (_) => OrdersScreen());
      case '/management':
        return MaterialPageRoute(builder: (_) => MenuManagementScreen());
      default:
        return MaterialPageRoute(builder: (_) => HomeScreen());
    }
  }
}
