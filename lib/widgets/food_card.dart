import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/food_model.dart';

class FoodCard extends StatefulWidget {
  final Food food;
  final int orderCount;
  final Function() incrementOrder;
  final Function() decrementOrder;

  const FoodCard({
    Key? key,
    required this.food,
    required this.orderCount,
    required this.incrementOrder,
    required this.decrementOrder,
  }) : super(key: key);

  @override
  _FoodCardState createState() => _FoodCardState();
}

class _FoodCardState extends State<FoodCard> {
  late Uint8List imageBytes;

  @override
  void initState() {
    super.initState();
    if (widget.food.imageBase64 != null && widget.food.imageBase64!.isNotEmpty) {
      // แปลง Base64 เป็น Uint8List เมื่อเริ่มต้น
      imageBytes = base64Decode(widget.food.imageBase64!);
    }else{

      _loadDefaultImage();
    }
  }
  Future<void> _loadDefaultImage() async {
    final byteData = await rootBundle.load('lib/assets/food.png');
    setState(() {
      imageBytes = byteData.buffer.asUint8List();
    });
  }
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        elevation: 4,
        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: MemoryImage(imageBytes), // ใช้ MemoryImage
              fit: BoxFit.cover,
              colorFilter: ColorFilter.mode(
                Colors.black.withOpacity(0.4),
                BlendMode.darken,
              ),
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  Text(
                    widget.food.foodName,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Price: ฿${widget.food.price}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Decrement button
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      onPressed: () {
                        widget.decrementOrder();
                        setState(() {}); // Update the state
                      },
                      icon: const Icon(Icons.remove),
                      color: Colors.white,
                    ),
                  ),
                  // Display order count
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    width: 45,
                    child: Center(
                      child: Text(
                        '${widget.orderCount}',
                        style: const TextStyle(fontSize: 16, color: Colors.black),
                      ),
                    ),
                  ),
                  // Increment button
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      onPressed: () {
                        widget.incrementOrder();
                        setState(() {}); // Update the state
                      },
                      icon: const Icon(Icons.add),
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
