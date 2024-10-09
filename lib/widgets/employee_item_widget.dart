import 'package:flutter/material.dart';
import '../models/employee_model.dart';

class EmployeeItemWidget extends StatelessWidget {
  final Employee employee;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  static int count = 0; // Static count variable

  EmployeeItemWidget({
    Key? key,
    required this.employee,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key) {
    count++; // Increment count each time a new EmployeeItemWidget is created
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      decoration: BoxDecoration(
        color: count % 2 == 0 ? Colors.red[50] : Colors.orange[100], // Alternate color based on count
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('ID: ${employee.employeeId}', style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18)),
                    SizedBox(height: 5),
                    Row(
                      children: [
                        Text('Name',style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),),
                        Text(':${employee.firstName} ${employee.lastName}',style: TextStyle(fontWeight: FontWeight.bold),),
                      ],
                    ),
                  ],
                ),
                SizedBox(width: 3),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(
              _getStatusIcon(employee.status),
              size: 30,
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.edit),
                onPressed: onEdit,
                tooltip: 'Edit Employee',
              ),
              IconButton(
                icon: Icon(Icons.delete),
                onPressed: onDelete,
                tooltip: 'Delete Employee',
              ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _getStatusIcon(int status) {
    switch (status) {
      case 0:
        return Icons.person_outline;
      case 1:
        return Icons.work;
      case 2:
        return Icons.beach_access;
      case 3:
        return Icons.block;
      default:
        return Icons.help_outline;
    }
  }
}
