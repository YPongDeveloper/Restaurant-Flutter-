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
              image: NetworkImage(
                  'https://scontent.fbkk13-3.fna.fbcdn.net/v/t1.15752-9/271527617_458558425802892_6061554732953425168_n.jpg?stp=dst-jpg_s2048x2048&_nc_cat=110&ccb=1-7&_nc_sid=9f807c&_nc_eui2=AeEsBWMEXiWgkzhj_W0j_f8qBo_14t7Diy4Gj_Xi3sOLLodQG_hA_WtM6ywzeE4PR-W940LQE5a6kORZe8Ph21I_&_nc_ohc=w9WCnU5tQ8MQ7kNvgHWMEXO&_nc_ht=scontent.fbkk13-3.fna&_nc_gid=AqK2aeifXzAiFPNLAJJVugM&oh=03_Q7cD1QH5XLcp18otfIn1hcMYMblY68_Z6SkB_fcrre1g1NgSQQ&oe=672862FD'), // Background image
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 8), // Top spacing
                  Text(
                    food.foodName,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white, // Text color for contrast
                    ),
                  ),
                  SizedBox(height: 30),
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
                  Text(
                    '$orderCount',
                    style: TextStyle(fontSize: 16, color: Colors.white), // Text color for contrast
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
