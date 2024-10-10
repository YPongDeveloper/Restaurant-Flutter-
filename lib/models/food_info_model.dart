class FoodInfo {
  final int foodId;
  final String foodName;
  final String categoryName;
  final String description;
  final int price;
  final int available;
  final int calorie;

  FoodInfo({
    required this.foodId,
    required this.foodName,
    required this.categoryName,
    required this.description,
    required this.price,
    required this.available,
    required this.calorie,
  });

  factory FoodInfo.fromJson(Map<String, dynamic> json) {
    return FoodInfo(
      foodId: json['food_id'],
      foodName: json['food_name'],
      categoryName: json['category_name'],
      description: json['description'],
      price: json['price'],
      available: json['available'],
      calorie: json['calorie'],
    );
  }
}
