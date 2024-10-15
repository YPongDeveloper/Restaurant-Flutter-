class Category {
  final int categoryId;
  final String categoryName;

  // Constructor
  Category({
    required this.categoryId,
    required this.categoryName,
  });

  // Method to create Category from JSON
  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      categoryId: json['category_id'],
      categoryName: json['category_name'],
    );
  }

  // Method to convert Category to JSON
  Map<String, dynamic> toJson() {
    return {
      'category_id': categoryId,
      'category_name': categoryName,
    };
  }
}
