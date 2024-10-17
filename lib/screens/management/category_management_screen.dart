import 'dart:convert';
import 'package:flutter/material.dart';
import '../../models/category_model.dart' as c;
import '../../services/menu_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'dart:io';

class CategoryManagementScreen extends StatefulWidget {
  @override
  _CategoryManagementScreenState createState() =>
      _CategoryManagementScreenState();
}

class _CategoryManagementScreenState extends State<CategoryManagementScreen> {
  final MenuService _menuService = MenuService();
  String? _base64Image;
  File? _imageFile;

  Future<void> _convertToBase64ForWeb(XFile pickedFile) async {
    try {
      final bytes = await pickedFile.readAsBytes();
      img.Image? originalImage = img.decodeImage(bytes);

      if (originalImage != null) {
        // ลบพื้นหลัง
        img.Image transparentImage = _removeBackground(originalImage);

        // เปลี่ยนเป็น PNG
        final pngBytes = img.encodePng(transparentImage);
        final String base64Image = base64Encode(pngBytes);
        setState(() {
          _base64Image = base64Image;
        });

        print('Image encode to base64 as PNG complete!');
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
        // ลบพื้นหลัง
        img.Image transparentImage = _removeBackground(originalImage);

        // เปลี่ยนเป็น PNG
        final pngBytes = img.encodePng(transparentImage);
        final String base64Image = base64Encode(pngBytes);
        setState(() {
          _base64Image = base64Image;
        });

        print('Image encode to base64 as PNG complete!');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  img.Image _removeBackground(img.Image image) {
    // ทำการลบพื้นหลังโดยการตรวจสอบค่า RGB และเปลี่ยนพิกเซลที่เป็นพื้นหลังให้โปร่งใส
    for (int y = 0; y < image.height; y++) {
      for (int x = 0; x < image.width; x++) {
        int pixel = image.getPixel(x, y);
        int r = img.getRed(pixel);
        int g = img.getGreen(pixel);
        int b = img.getBlue(pixel);

        // สมมติว่าพื้นหลังเป็นสีขาว (สามารถปรับเปลี่ยนตามความเหมาะสม)
        if (r > 200 && g > 200 && b > 200) {
          // เปลี่ยนพิกเซลเป็นโปร่งใส
          image.setPixel(
              x, y, img.getColor(255, 255, 255, 0)); // ทำให้ alpha เป็น 0
        }
      }
    }
    return image;
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
        backgroundColor: Color(0xFFAA96DA), // Using the purple shade
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
      body: FutureBuilder<List<c.Category>>(
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
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  height: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: index % 2 == 0
                        ? Color(0xFFA8D8EA) // Alternating between two colors
                        : Color(0xFFFFFFD2), // Light yellow shade
                  ),
                  child: Center(
                    child: ListTile(
                      leading: category.imageCategory.isNotEmpty
                          ? Image.memory(base64Decode(category.imageCategory),
                              width: 50, height: 50, fit: BoxFit.cover)
                          : Image.asset('lib/assets/categoryIcon.png',
                              width: 50, height: 50),
                      title: Text(
                        category.categoryName,
                        style: TextStyle(
                            color: Colors
                                .black), // Ensures text is readable on light backgrounds
                      ),
                      trailing: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(
                              0xFFFCBAD3), // Soft pink for the circle background
                        ),
                        child: IconButton(
                          icon: Icon(Icons.edit, color: Color(0xFFFFFFD2)),
                          // Soft pink for the edit icon
                          onPressed: () {
                            _showEditCategoryPopup(context, category);
                          },
                        ),
                      ),
                      onTap: () {
                        // Navigate to list menu in this category
                      },
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showCreateCategoryPopup(BuildContext context) {
    final _categoryNameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Color(0xFFFFFFD2), // Light yellow background
        title: Text('Create Category', style: TextStyle(color: Colors.black)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _base64Image != null
                ? (kIsWeb
                    ? Image.memory(
                        base64Decode(_base64Image!),
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                      ) // สำหรับ Web
                    : Image.file(
                        _imageFile!,
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                      ))
                : Image.asset(
                    'lib/assets/categoryIcon.png',
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                  ),
            ElevatedButton(
              onPressed: _pickImage,
              child: Text('Select Image',
                  style: TextStyle(color: Color(0xFF00ADB5))),
            ),
            TextField(
              controller: _categoryNameController,
              decoration: InputDecoration(labelText: 'Category Name'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              _base64Image = null;
              Navigator.of(context).pop(); // Cancel
            },
            child: Text('Cancel', style: TextStyle(color: Colors.black)),
          ),
          ElevatedButton(
            onPressed: () async {
              await _menuService.createCategory(
                _categoryNameController.text,
                _base64Image ?? '',
              );
              _base64Image = null;
              Navigator.of(context).pop();
              setState(() {}); // Refresh the screen
            },
            child: Text('Create'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFFAA96DA), // Purple shade for the button
            ),
          ),
        ],
      ),
    );
  }

  void _showEditCategoryPopup(BuildContext context, c.Category category) {
    final _categoryNameController =
        TextEditingController(text: category.categoryName);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Color(0xFFA8D8EA), // Light blue background
        title: Text('Edit Category', style: TextStyle(color: Colors.black)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
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
                      ))
                // ถ้า _base64Image เป็น null, ตรวจสอบว่า food.imageBase64 มีค่าหรือไม่
                : (category.imageCategory.isNotEmpty)
                    // แสดงรูปจาก Base64 ใน `food.imageBase64`
                    ? Image.memory(
                        base64Decode(category.imageCategory),
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                      )
                    // ถ้าไม่มีรูปเลย ให้แสดงรูปเริ่มต้นจาก assets
                    : Image.asset(
                        'lib/assets/categoryIcon.png',
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                      ),
            ElevatedButton(
              onPressed: _pickImage,
              child: Text('Select Image',
                  style: TextStyle(color: Color(0xFF00ADB5))),
            ),
            TextField(
              controller: _categoryNameController,
              decoration: InputDecoration(labelText: 'Category Name'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              _base64Image = null;
              Navigator.of(context).pop(); // Cancel
            },
            child: Text('Cancel', style: TextStyle(color: Colors.black)),
          ),
          ElevatedButton(
            onPressed: () async {
              await _menuService.editCategory(
                category.categoryId,
                _categoryNameController.text,
                _base64Image ?? category.imageCategory,
              );
              _base64Image = null;
              Navigator.of(context).pop();
              setState(() {}); // Refresh the screen
            },
            child: Text('Edit'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFFFCBAD3), // Soft pink for the button
            ),
          ),
        ],
      ),
    );
  }
}
