import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/food_model.dart';
import '../../models/category_model.dart' as c; // Import Category model
import '../../services/menu_service.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img; // ไลบรารีสำหรับการจัดการภาพ
import 'package:flutter/foundation.dart'; // สำหรับการตรวจสอบแพลตฟอร์ม
import 'dart:io'; // สำหรับการจัดการไฟล์

class FoodManagementScreen extends StatefulWidget {
  @override
  _FoodManagementScreenState createState() => _FoodManagementScreenState();
}

class _FoodManagementScreenState extends State<FoodManagementScreen> {
  final MenuService _foodService = MenuService();
  late Future<List<Food>> _foodsFuture;
  late Future<List<c.Category>> _categoriesFuture; // Add Future for categories
  String? _base64Image;
  File? _imageFile;
  @override
  void initState() {
    super.initState();
    _foodsFuture = _foodService.fetchMenu();
    _categoriesFuture = _foodService.fetchCategories();

  }
  Future<void> _convertToBase64ForWeb(XFile pickedFile) async {
    try {
      final bytes = await pickedFile.readAsBytes();
      img.Image? originalImage = img.decodeImage(bytes);
      if (originalImage != null) {
        img.Image resizedImage = img.copyResize(originalImage, width: 620  , height: 600);
        // กำหนดความละเอียด (Quality) ที่ต้องการ (0-100)
        int quality = 100; // เปลี่ยนค่าตามที่ต้องการ

        final resizedBytes = img.encodeJpg(resizedImage, quality: quality);
        final String base64Image = base64Encode(resizedBytes);
        setState(() {
          _base64Image = base64Image;
        });

        print('Image encode to base64 complete!');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> _convertToBase64ForMobile(File imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      img.Image? originalImage = img.decodeImage(bytes);
      if (originalImage != null) {
        img.Image resizedImage = img.copyResize(originalImage, width: 620, height: 600);
        int quality = 100; // กำหนดคุณภาพที่ต้องการ
        final resizedBytes = img.encodeJpg(resizedImage, quality: quality);
        final String base64Image = base64Encode(resizedBytes);

        setState(() {
          _base64Image = base64Image;
        });

        print('Image encode to base64 complete!');
      }
    } catch (e) {
      print('Error: $e');
    }
  }



  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      if (kIsWeb) {
        _convertToBase64ForWeb(pickedFile);
      } else if (Platform.isAndroid || Platform.isIOS) {
        final File imageFile = File(pickedFile.path);
        setState(() {
          _imageFile = imageFile;
        });
        _convertToBase64ForMobile(imageFile);
      } else {
        print('แพลตฟอร์มนี้ยังไม่ได้รับการรองรับ');
      }
    }
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
                child: food.imageBase64 != null && food.imageBase64.isNotEmpty
                    ? Image.memory(
                  base64Decode(food.imageBase64),
                  fit: BoxFit.cover,
                )
                    : Image.asset(
                  'lib/assets/food.png',
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
                _base64Image != null
                    ? (kIsWeb
                    ? Image.memory(base64Decode(_base64Image!)
                  ,width: 100,
                  height: 100,
                  fit: BoxFit.cover,) // สำหรับ Web
                    : Image.file(_imageFile!,width: 100,
                  height: 100,
                  fit: BoxFit.cover,))
                    : Image.asset('lib/assets/food.png',width: 100,
                  height: 100,
                  fit: BoxFit.cover,),
                ElevatedButton(
                  onPressed: _pickImage,
                  child: Text('Select Image', style: TextStyle(color: Color(0xFF00ADB5))),
                ),
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
                FutureBuilder<List<c.Category>>(
                  future: _categoriesFuture,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return CircularProgressIndicator();
                    }
                    final categories = snapshot.data!;
                    return DropdownButton<int>(
                      value: _categoryId,
                      dropdownColor: Color(0xFF393E46),
                      items: categories.map((c.Category category) {
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
                  onChanged: (val) { print(val);
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
                _base64Image =null;
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
                  imageBase64: _base64Image ?? '', // Add image handling logic if needed
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
                _base64Image = null ;
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
                _base64Image != null
                    ? (kIsWeb
                // แสดงรูปจาก Base64 ถ้าเป็น Web
                    ? Image.memory(
                  base64Decode(_base64Image!), // แปลง Base64 เป็นรูปภาพ
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                )
                // แสดงรูปจากไฟล์ ถ้าไม่ใช่ Web (เป็น Mobile)
                    : Image.file(
                  _imageFile!,
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                )
                )
                // ถ้า _base64Image เป็น null, ตรวจสอบว่า food.imageBase64 มีค่าหรือไม่
                    : (food.imageBase64 != null && food.imageBase64.isNotEmpty)
                // แสดงรูปจาก Base64 ใน `food.imageBase64`
                    ? Image.memory(
                  base64Decode(food.imageBase64),
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                )
                // ถ้าไม่มีรูปเลย ให้แสดงรูปเริ่มต้นจาก assets
                    : Image.asset(
                  'lib/assets/food.png',
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                ),
                ElevatedButton(
                  onPressed: _pickImage,
                  child: Text('Select Image', style: TextStyle(color: Color(0xFF00ADB5))),
                ),
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
                FutureBuilder<List<c.Category>>(
                  future: _categoriesFuture,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return CircularProgressIndicator();
                    }
                    final categories = snapshot.data!;
                    return DropdownButton<int>(
                      value: _categoryId,
                      dropdownColor: Color(0xFF393E46),
                      items: categories.map((c.Category category) {
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
                _base64Image = null;
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
                  imageBase64: _base64Image ?? food.imageBase64, // Use selected image or existing
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
                  updatedFood.available,
                  updatedFood.price,
                  updatedFood.calories,
                  updatedFood.categoryId,
                );
                _base64Image = null;
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
