import 'package:flutter/material.dart';
import '../screens/employee_screen.dart';

class AppRoutes {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/employees':
        return MaterialPageRoute(builder: (_) => EmployeeScreen());
      default:
        return MaterialPageRoute(builder: (_) => Scaffold(body: Center(child: Text('No route defined'))));
    }
  }
}
