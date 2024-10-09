// lib/widgets/category_filter.dart

import 'package:flutter/material.dart';

class CategoryFilter extends StatelessWidget {
  final List<Map<String, dynamic>> categories;
  final int? selectedCategoryId;
  final ValueChanged<int?> onCategorySelected;

  const CategoryFilter({
    Key? key,
    required this.categories,
    required this.selectedCategoryId,
    required this.onCategorySelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.chevron_left),
            onPressed: () {
              // Implement scroll left functionality if needed
            },
          ),
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                return GestureDetector(
                  onTap: () {
                    onCategorySelected(category['category_id']);
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: selectedCategoryId == category['category_id']
                          ? Colors.green
                          : Colors.grey[200],
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Column(
                      children: [
                        Image(
                          image: AssetImage('lib/assets/${category['category_name']}.png'),
                          width: 40,
                          height: 40,
                          fit: BoxFit.fill,
                        ),
                        Text(
                          category['category_name'],
                          style: TextStyle(
                            color: selectedCategoryId == category['category_id']
                                ? Colors.white
                                : Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          IconButton(
            icon: Icon(Icons.chevron_right),
            onPressed: () {
              // Implement scroll right functionality if needed
            },
          ),
        ],
      ),
    );
  }
}
