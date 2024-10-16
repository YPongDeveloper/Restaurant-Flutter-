class Category {
  final int categoryId;
  final String categoryName;
  final String imageCategory;

  Category({
    required this.categoryId,
    required this.categoryName,
    required this.imageCategory,
  });

  // ฟังก์ชันสำหรับแปลง JSON เป็น Category object
  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      categoryId: json['category_id'],
      categoryName: json['category_name'],
      imageCategory: json['image_category'],
    );
  }
}
