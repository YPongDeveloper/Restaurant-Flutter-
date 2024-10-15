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
        title: Text('Manage Food Menu'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              _showCreatePopup(context);
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Food>>(
        future: _foodsFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final foods = snapshot.data!;
          return GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 3 / 2,
            ),
            itemCount: foods.length,
            itemBuilder: (context, index) {
              final food = foods[index];
              return _buildFoodCard(context, food);
            },
          );
        },
      ),
    );
  }

  Widget _buildFoodCard(BuildContext context, Food food) {
    return Card(
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.memory(
              base64Decode(food.imageBase64),
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            bottom: 8,
            left: 8,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(food.foodName, style: TextStyle(color: Colors.white, fontSize: 18)),
                Text('\$${food.price}', style: TextStyle(color: Colors.white)),
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
                  color: Colors.white,
                  onPressed: () {
                    _showEditPopup(context, food);
                  },
                ),
                IconButton(
                  icon: Icon(Icons.delete),
                  color: Colors.white,
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
          title: Text('Create New Food'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: _foodNameController,
                  decoration: InputDecoration(labelText: 'Food Name'),
                ),
                TextField(
                  controller: _descriptionController,
                  decoration: InputDecoration(labelText: 'Description'),
                ),
                TextField(
                  controller: _priceController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: 'Price'),
                ),
                TextField(
                  controller: _caloriesController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: 'Calories'),
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
                      items: categories.map((Category category) {
                        return DropdownMenuItem<int>(
                          value: category.categoryId,
                          child: Text(category.categoryName),
                        );
                      }).toList(),
                      onChanged: (val) {
                        setState(() {
                          _categoryId = val ?? 1; // Update selected category
                        });
                      },
                    );
                  },
                ),
                SwitchListTile(
                  title: Text('Available'),
                  value: _available,
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
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                final newFood = Food(
                  foodId: 0, // New food doesn't have an ID yet
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
              child: Text('Create'),
            ),
          ],
        );
      },
    );
  }

  void _refreshMenu() {
    setState(() {
      _foodsFuture = _foodService.fetchMenu(); // Refresh the food menu
    });
  }

  void _showEditPopup(BuildContext context, Food food) {
    final _foodNameController = TextEditingController(text: food.foodName);
    final _descriptionController = TextEditingController(text: food.description);
    final _priceController = TextEditingController(text: food.price.toString());
    final _caloriesController = TextEditingController(text: food.calories.toString());
    int _categoryId = food.categoryId; // Use the food's current category
    bool _available = food.available == 1;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Food'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: _foodNameController,
                  decoration: InputDecoration(labelText: 'Food Name'),
                ),
                TextField(
                  controller: _descriptionController,
                  decoration: InputDecoration(labelText: 'Description'),
                ),
                TextField(
                  controller: _priceController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: 'Price'),
                ),
                TextField(
                  controller: _caloriesController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: 'Calories'),
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
                      items: categories.map((Category category) {
                        return DropdownMenuItem<int>(
                          value: category.categoryId,
                          child: Text(category.categoryName),
                        );
                      }).toList(),
                      onChanged: (val) {
                        setState(() {
                          _categoryId = val ?? food.categoryId; // Update selected category
                        });
                      },
                    );
                  },
                ),
                SwitchListTile(
                  title: Text('Available'),
                  value: _available,
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
              child: Text('Cancel'),
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
                Navigator.of(context).pop();
                _refreshMenu(); // Refresh the menu after editing
              },
              child: Text('Save'),
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
          title: Text('Delete Confirmation'),
          content: Text('Are you sure you want to delete this food item?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                await _foodService.deleteFood(foodId);
                Navigator.of(context).pop();
                _refreshMenu(); // Refresh the menu after deletion
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}
