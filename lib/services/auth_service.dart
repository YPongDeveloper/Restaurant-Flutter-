import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_constants.dart';

class AuthService {
  Future<int?> login(String username, String password) async {
    if (username.isEmpty || password.isEmpty) {
      return null;
    }

    final response = await http.post(
      Uri.parse('${ApiConstants.employeesAPI}/login'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'username': username,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      final int? position = responseData['data'];

      // Save position to SharedPreferences
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      if (position != null) {
        await prefs.setInt('position', position);
      }

      return position; // Return the position
    } else {
      return null; // Handle failed login
    }
  }
}
