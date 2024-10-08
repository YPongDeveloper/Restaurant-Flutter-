import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/food_model.dart';

class MenuService {
  Future<List<Food>> fetchMenu() async {
    final response = await http.get(Uri.parse('http://localhost:8080/menu'));

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      List<Food> menu = (jsonData['data'] as List)
          .map((item) => Food.fromJson(item))
          .toList();
      return menu;
    } else {
      throw Exception('Failed to load menu');
    }
  }
}
