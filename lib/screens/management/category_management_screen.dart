import 'dart:convert';

import 'package:flutter/material.dart';
import '../../models/category_model.dart';
import '../../services/menu_service.dart';

class CategoryManagementScreen extends StatefulWidget {
  @override
  _CategoryManagementScreenState createState() => _CategoryManagementScreenState();
}

class _CategoryManagementScreenState extends State<CategoryManagementScreen> {
  final MenuService _menuService = MenuService();

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
        future: _menuService.fetchCategories(),
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
                leading: category.imageCategory.isNotEmpty
                    ? Image.memory(base64Decode(category.imageCategory), width: 50, height: 50, fit: BoxFit.cover)
                    : Image.asset('lib/assets/categoryIcon.png', width: 50, height: 50),
                title: Text(category.categoryName),
                trailing: IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () {
                    _showEditCategoryPopup(context, category);
                  },
                ),
                onTap: () {
                  // Navigate to list menu in this category
                },
              );
            },
          );
        },
      ),
    );
  }

  void _showCreateCategoryPopup(BuildContext context) {
    final _categoryNameController = TextEditingController();
    final _imageCategoryController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Create Category'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _categoryNameController,
              decoration: InputDecoration(labelText: 'Category Name'),
            ),
            TextField(
              controller: _imageCategoryController,
              decoration: InputDecoration(labelText: 'Image URL'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // ยกเลิก
            },
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await _menuService.createCategory(
                _categoryNameController.text,
                _imageCategoryController.text,
              );
              Navigator.of(context).pop();
              setState(() {}); // รีเฟรชหน้า
            },
            child: Text('Create'),
          ),
        ],
      ),
    );
  }

  void _showEditCategoryPopup(BuildContext context, Category category) {
    final _categoryNameController = TextEditingController(text: category.categoryName);
    final _imageCategoryController = TextEditingController(text: category.imageCategory);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Category'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _categoryNameController,
              decoration: InputDecoration(labelText: 'Category Name'),
            ),
            TextField(
              controller: _imageCategoryController,
              decoration: InputDecoration(labelText: 'Image URL'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // ยกเลิก
            },
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await _menuService.editCategory(
                category.categoryId,
                _categoryNameController.text,
                _imageCategoryController.text,
              );
              Navigator.of(context).pop();
              setState(() {}); // รีเฟรชหน้า
            },
            child: Text('Edit'),
          ),
        ],
      ),
    );
  }
}
