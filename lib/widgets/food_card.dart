import 'package:flutter/material.dart';
import '../models/food_model.dart';

class FoodCard extends StatelessWidget {
  final Food food;
  final int orderCount;
  final Function() incrementOrder;
  final Function() decrementOrder;

  FoodCard({
    required this.food,
    required this.orderCount,
    required this.incrementOrder,
    required this.decrementOrder,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        elevation: 4,
        child: Container(
          // Add background image with BoxDecoration
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('lib/assets/${food.foodName}.jpg'),
              fit: BoxFit.cover, // Adjust image fit
              colorFilter: ColorFilter.mode(
                Colors.black.withOpacity(0.4), // Add dark overlay for readability
                BlendMode.darken,
              ),
            ),
            borderRadius: BorderRadius.circular(8), // Rounded corners for the card
          ),
          padding: const EdgeInsets.all(12.0), // Padding around the content
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.min, // Adjust height based on children
            crossAxisAlignment: CrossAxisAlignment.stretch, // Align text to the start
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 10), // Top spacing
                  Text(
                    food.foodName,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white, // Text color for contrast
                    ),
                  ),

                  Text(
                    'Price: ฿${food.price}',
                    style: TextStyle(color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,), // Text color for contrast
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
                      shape: BoxShape.circle, // Makes the container circular
                    ),
                    child: IconButton(
                      onPressed: decrementOrder,
                      icon: Icon(Icons.remove),
                      color: Colors.white, // Icon color
                    ),
                  ),
                  // Display order count
                  Container(
                    
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12)
                    ),
                    width: 45,
                    child: Center(
                      child: Text(
                        '$orderCount',
                        style: TextStyle(fontSize: 16, color: Colors.black), // Text color for contrast
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
                      onPressed: incrementOrder,
                      icon: Icon(Icons.add),
                      color: Colors.white, // Icon color
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
