class Food {
  final int foodId;
  final String foodName;
  final String description;
  final String image;
  final int price;
  final int available;
  final int calories;
  final int categoryId;

  Food({
    required this.foodId,
    required this.foodName,
    required this.description,
    required this.image,
    required this.price,
    required this.available,
    required this.calories,
    required this.categoryId,
  });

  factory Food.fromJson(Map<String, dynamic> json) {
    return Food(
      foodId: json['food_id'],
      foodName: json['food_name'],
      description: json['description'],
      image: json['image'], // Assuming you have an image field in your API
      price: json['price'],
      available: json['available'],
      calories: json['calories'],
      categoryId: json['category_id'],
    );
  }
}

