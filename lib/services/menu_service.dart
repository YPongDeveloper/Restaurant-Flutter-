import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_constants.dart';
import '../models/category_model.dart';
import '../models/food_info_model.dart';
import '../models/food_model.dart';

class MenuService {
  // Fetch all menu items
  Future<List<Food>> fetchMenu() async {
    final response = await http.get(Uri.parse(ApiConstants.foodAPI));

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

  // Fetch specific food details by ID
  Future<FoodInfo> fetchFoodById(int foodId) async {
    final url = Uri.parse('${ApiConstants.foodAPI}/$foodId');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body)['data'];
      return FoodInfo.fromJson(data);
    } else {
      throw Exception('Failed to load food details');
    }
  }

  // Update food details
  Future<void> updateFood(String foodName, int foodId, String imageBase64, String description,int available, int price, int calorie, int categoryId) async {
    final response = await http.put(
      Uri.parse('${ApiConstants.foodAPI}/edit/$foodId'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'food_name': foodName,
        'image_base64': imageBase64,
        'description': description,
        'available':available,
        'price': price,
        'calories': calorie,
        'category_id': categoryId,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update food');
    }
  }

  // Delete a food by ID
  Future<void> deleteFood(int foodId) async {
    final response = await http.delete(
      Uri.parse('${ApiConstants.foodAPI}/delete/$foodId'),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to delete food');
    }
  }

  // Create a new food item
  Future<void> createFood(String foodName, String description, String imageBase64, int price, int calories, int available, int categoryId) async {
    final response = await http.post(
      Uri.parse('${ApiConstants.foodAPI}/create'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'food_name': foodName,
        'description': description,
        'image_base64': imageBase64,
        'price': price,
        'calories': calories,
        'available': available,
        'category_id': categoryId,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to create food');
    }
  }
  // In menu_service.dart
  Future<List<Category>> fetchCategories() async {
    final response = await http.get(Uri.parse('${ApiConstants.foodAPI}/categorys'));

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      List<Category> categories = (jsonData['data'] as List)
          .map((item) => Category.fromJson(item))
          .toList();
      return categories;
    } else {
      throw Exception('Failed to load categories');
    }
  }
  Future<void> createCategory(String categoryName, String imageCategory) async {
    final response = await http.post(
      Uri.parse('${ApiConstants.foodAPI}/create/category'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'category_name': categoryName,
        'image_category': imageCategory,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to create category');
    }
  }

  Future<void> editCategory(int categoryId, String categoryName, String imageCategory) async {
    final response = await http.put(
      Uri.parse('${ApiConstants.foodAPI}/category/edit/$categoryId'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'category_name': categoryName,
        'image_category': imageCategory,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to edit category');
    }
  }
}
