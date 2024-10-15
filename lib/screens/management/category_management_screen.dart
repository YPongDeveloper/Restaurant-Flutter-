import 'package:flutter/material.dart';

import '../../models/category_model.dart';

class CategoryManagementScreen extends StatelessWidget {
  Future<List<Category>> fetchCategories() async {
    // Implement API fetching logic (GET http://localhost:8080/food/categorys)
    return [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Categories'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              _showCreateCategoryPopup(context);
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Category>>(
        future: fetchCategories(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final categories = snapshot.data!;
          return ListView.builder(
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              return ListTile(
                title: Text(category.categoryName),
                trailing: IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () {
                    _showEditCategoryPopup(context, category);
                  },
                ),
                onTap: () {
                  // Navigate to list menu in this category (GET http://localhost:8080/food/category/:categoryId)
                },
              );
            },
          );
        },
      ),
    );
  }

  void _showCreateCategoryPopup(BuildContext context) {
    // Show popup to create new category (POST http://localhost:8080/food/create/category)
  }

  void _showEditCategoryPopup(BuildContext context, Category category) {
    // Show popup to edit category name (PUT http://localhost:8080/food/edit/:categoryId)
  }
}

