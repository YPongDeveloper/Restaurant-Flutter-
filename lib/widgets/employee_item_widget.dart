import 'package:flutter/material.dart';
import '../models/employee_model.dart';

class EmployeeItemWidget extends StatelessWidget {
  final Employee employee;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const EmployeeItemWidget({
    Key? key,
    required this.employee,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
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
          // Align text and icon in a row
          Expanded(
            child: Row(
              children: [
                // Column for ID and Name
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('ID: ${employee.employeeId}', style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(height: 5), // Add space between ID and Name
                    Text('Name: ${employee.firstName} ${employee.lastName}'),
                  ],
                ),
                SizedBox(width: 3), // Spacing between text and icon

              ],
            ),
          ),
          // Action buttons for edit and delete
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(
              _getStatusIcon(employee.status),
              size: 30, // Adjust the icon size if needed
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.edit),
                onPressed: onEdit,
                tooltip: 'Edit Employee', // Tooltip for the edit button
              ),
              IconButton(
                icon: Icon(Icons.delete),
                onPressed: onDelete,
                tooltip: 'Delete Employee', // Tooltip for the delete button
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
        return Icons.person_outline; // Available
      case 1:
        return Icons.work; // Working
      case 2:
        return Icons.beach_access; // On leave
      case 3:
        return Icons.block; // Resigned
      default:
        return Icons.help_outline; // Unknown
    }
  }
}
