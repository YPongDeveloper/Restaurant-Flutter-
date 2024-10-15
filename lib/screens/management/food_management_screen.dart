import 'dart:convert';
import 'package:flutter/material.dart';
import '../../models/food_model.dart';
import '../../models/category_model.dart'; // Import Category model
import '../../services/menu_service.dart';

class FoodManagementScreen extends StatefulWidget {
  @override
  _FoodManagementScreenState createState() => _FoodManagementScreenState();
}

class _FoodManagementScreenState extends State<FoodManagementScreen> {
  final MenuService _foodService = MenuService();
  late Future<List<Food>> _foodsFuture;
  late Future<List<Category>> _categoriesFuture; // Add Future for categories

  @override
  void initState() {
    super.initState();
    _foodsFuture = _foodService.fetchMenu();
    _categoriesFuture = _foodService.fetchCategories(); // Fetch categories
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Food Menu', style: TextStyle(color: Color(0xFFEEEEEE))),
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Color(0xFF222831),
        actions: [
          IconButton(
            icon: Icon(Icons.add, color: Color(0xFFEEEEEE)),
            onPressed: () {
              _showCreatePopup(context);
            },
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          double screenWidth = constraints.maxWidth;
          int itemsPerRow = screenWidth > 600 ? 3 : 2;

          return FutureBuilder<List<Food>>(
            future: _foodsFuture,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Center(child: CircularProgressIndicator());
              }

              final foods = snapshot.data!;
              return GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: itemsPerRow,
                  childAspectRatio: 0.8,
                ),
                itemCount: foods.length,
                itemBuilder: (context, index) {
                  final food = foods[index];
                  return _buildFoodCard(context, food);
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildFoodCard(BuildContext context, Food food) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      elevation: 8,
      color: Color(0xFF393E46), // Background color for the card
      child: Stack(
        children: [
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15.0),
              child: ColorFiltered(
                colorFilter: ColorFilter.mode(
                  Colors.black.withOpacity(0.4),
                  BlendMode.darken,
                ),
                child: Image.memory(
                  base64Decode(food.imageBase64),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 8,
            left: 8,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(food.foodName, style: TextStyle(color: Color(0xFFEEEEEE), fontSize: 18)),
                Text('\$${food.price}', style: TextStyle(color: Color(0xFFEEEEEE))),
              ],
            ),
          ),
          Positioned(
            right: 8,
            top: 8,
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.edit),
                  color: Color(0xFF00ADB5),
                  onPressed: () {
                    _showEditPopup(context, food);
                  },
                ),
                IconButton(
                  icon: Icon(Icons.delete),
                  color: Color(0xFF00ADB5),
                  onPressed: () {
                    _showDeleteConfirmation(context, food.foodId);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showCreatePopup(BuildContext context) {
    final _foodNameController = TextEditingController();
    final _descriptionController = TextEditingController();
    final _priceController = TextEditingController();
    final _caloriesController = TextEditingController();
    int _categoryId = 1; // Default category
    bool _available = true;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Color(0xFF393E46),
          title: Text('Create New Food', style: TextStyle(color: Color(0xFFEEEEEE))),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: _foodNameController,
                  decoration: InputDecoration(
                    labelText: 'Food Name',
                    labelStyle: TextStyle(color: Color(0xFFEEEEEE)),
                  ),
                  style: TextStyle(color: Color(0xFFEEEEEE)),
                ),
                TextField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    labelText: 'Description',
                    labelStyle: TextStyle(color: Color(0xFFEEEEEE)),
                  ),
                  style: TextStyle(color: Color(0xFFEEEEEE)),
                ),
                TextField(
                  controller: _priceController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Price',
                    labelStyle: TextStyle(color: Color(0xFFEEEEEE)),
                  ),
                  style: TextStyle(color: Color(0xFFEEEEEE)),
                ),
                TextField(
                  controller: _caloriesController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Calories',
                    labelStyle: TextStyle(color: Color(0xFFEEEEEE)),
                  ),
                  style: TextStyle(color: Color(0xFFEEEEEE)),
                ),
                FutureBuilder<List<Category>>(
                  future: _categoriesFuture,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return CircularProgressIndicator();
                    }
                    final categories = snapshot.data!;
                    return DropdownButton<int>(
                      value: _categoryId,
                      dropdownColor: Color(0xFF393E46),
                      items: categories.map((Category category) {
                        return DropdownMenuItem<int>(
                          value: category.categoryId,
                          child: Text(
                            category.categoryName,
                            style: TextStyle(color: Color(0xFFEEEEEE)),
                          ),
                        );
                      }).toList(),
                      onChanged: (val) {
                        setState(() {
                          _categoryId = val ?? 1;
                        });
                      },
                    );
                  },
                ),
                SwitchListTile(
                  title: Text('Available', style: TextStyle(color: Color(0xFFEEEEEE))),
                  value: _available,
                  activeColor: Color(0xFF00ADB5),
                  onChanged: (val) {
                    setState(() {
                      _available = val;
                    });
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel', style: TextStyle(color: Color(0xFF00ADB5))),
            ),
            TextButton(
              onPressed: () async {
                final newFood = Food(
                  foodId: 0,
                  foodName: _foodNameController.text,
                  description: _descriptionController.text,
                  imageBase64: '', // Add image handling logic if needed
                  price: int.parse(_priceController.text),
                  available: _available ? 1 : 0,
                  calories: int.parse(_caloriesController.text),
                  categoryId: _categoryId,
                );

                await _foodService.createFood(
                  newFood.foodName,
                  newFood.description,
                  newFood.imageBase64,
                  newFood.price,
                  newFood.calories,
                  newFood.available,
                  newFood.categoryId,
                );

                Navigator.of(context).pop(); // Close popup
                _refreshMenu(); // Refresh the menu after creation
              },
              child: Text('Create', style: TextStyle(color: Color(0xFF00ADB5))),
            ),
          ],
        );
      },
    );
  }

  void _refreshMenu() {
    setState(() {
      _foodsFuture = _foodService.fetchMenu();
    });
  }

  void _showEditPopup(BuildContext context, Food food) {
    final _foodNameController = TextEditingController(text: food.foodName);
    final _descriptionController = TextEditingController(text: food.description);
    final _priceController = TextEditingController(text: food.price.toString());
    final _caloriesController = TextEditingController(text: food.calories.toString());
    int _categoryId = food.categoryId;
    bool _available = food.available == 1;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Color(0xFF393E46),
          title: Text('Edit Food', style: TextStyle(color: Color(0xFFEEEEEE))),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: _foodNameController,
                  decoration: InputDecoration(
                    labelText: 'Food Name',
                    labelStyle: TextStyle(color: Color(0xFFEEEEEE)),
                  ),
                  style: TextStyle(color: Color(0xFFEEEEEE)),
                ),
                TextField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    labelText: 'Description',
                    labelStyle: TextStyle(color: Color(0xFFEEEEEE)),
                  ),
                  style: TextStyle(color: Color(0xFFEEEEEE)),
                ),
                TextField(
                  controller: _priceController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Price',
                    labelStyle: TextStyle(color: Color(0xFFEEEEEE)),
                  ),
                  style: TextStyle(color: Color(0xFFEEEEEE)),
                ),
                TextField(
                  controller: _caloriesController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Calories',
                    labelStyle: TextStyle(color: Color(0xFFEEEEEE)),
                  ),
                  style: TextStyle(color: Color(0xFFEEEEEE)),
                ),
                FutureBuilder<List<Category>>(
                  future: _categoriesFuture,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return CircularProgressIndicator();
                    }
                    final categories = snapshot.data!;
                    return DropdownButton<int>(
                      value: _categoryId,
                      dropdownColor: Color(0xFF393E46),
                      items: categories.map((Category category) {
                        return DropdownMenuItem<int>(
                          value: category.categoryId,
                          child: Text(
                            category.categoryName,
                            style: TextStyle(color: Color(0xFFEEEEEE)),
                          ),
                        );
                      }).toList(),
                      onChanged: (val) {
                        setState(() {
                          _categoryId = val ?? food.categoryId;
                        });
                      },
                    );
                  },
                ),
                SwitchListTile(
                  title: Text('Available', style: TextStyle(color: Color(0xFFEEEEEE))),
                  value: _available,
                  activeColor: Color(0xFF00ADB5),
                  onChanged: (val) {
                    setState(() {
                      _available = val;
                    });
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel', style: TextStyle(color: Color(0xFF00ADB5))),
            ),
            TextButton(
              onPressed: () async {
              final updatedFood = Food(
                foodId: food.foodId,
                foodName: _foodNameController.text,
                description: _descriptionController.text,
                imageBase64: food.imageBase64,
                price: int.parse(_priceController.text),
                available: _available ? 1 : 0,
                calories: int.parse(_caloriesController.text),
                categoryId: _categoryId,
              );

              await _foodService.updateFood(
                updatedFood.foodName,
                updatedFood.foodId,
                updatedFood.imageBase64,
                updatedFood.description,
                updatedFood.price,
                updatedFood.calories,
                updatedFood.categoryId,
              );

              Navigator.of(context).pop(); // Close popup
              _refreshMenu(); // Refresh the menu after update
            },
              child: Text('Save', style: TextStyle(color: Color(0xFF00ADB5))),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmation(BuildContext context, int foodId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Color(0xFF393E46),
          title: Text('Delete Food', style: TextStyle(color: Color(0xFFEEEEEE))),
          content: Text('Are you sure you want to delete this food?', style: TextStyle(color: Color(0xFFEEEEEE))),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel', style: TextStyle(color: Color(0xFF00ADB5))),
            ),
            TextButton(
              onPressed: () async {
                await _foodService.deleteFood(foodId);
                Navigator.of(context).pop();
                _refreshMenu(); // Refresh the menu after deletion
              },
              child: Text('Delete', style: TextStyle(color: Color(0xFF00ADB5))),
            ),
          ],
        );
      },
    );
  }
}
