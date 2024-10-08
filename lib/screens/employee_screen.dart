import 'package:flutter/material.dart';
import '../services/employee_service.dart';
import '../model/employee_model.dart';
import '../widgets/employee_item_widget.dart';

class EmployeeScreen extends StatefulWidget {
  @override
  _EmployeeScreenState createState() => _EmployeeScreenState();
}

class _EmployeeScreenState extends State<EmployeeScreen> {
  final EmployeeService employeeService = EmployeeService();
  List<Employee> employees = [];
  int selectedStatus = -1; // ตัวแปรสำหรับเก็บค่าของสถานะที่เลือก (-1 หมายถึงไม่กรอง)

  @override
  void initState() {
    super.initState();
    fetchEmployees();
  }

  Future<void> fetchEmployees() async {
    try {
      final employeeList = await employeeService.fetchEmployees();
      setState(() {
        employees = employeeList;
      });
    } catch (e) {
      // Handle error
    }
  }

  List<Employee> getFilteredEmployees() {
    if (selectedStatus == -1) {
      return employees;
    } else {
      return employees.where((employee) => employee.status == selectedStatus).toList();
    }
  }

  void editEmployee(Employee employee) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        TextEditingController firstNameController = TextEditingController(text: employee.firstName);
        TextEditingController lastNameController = TextEditingController(text: employee.lastName);
        int newStatus = employee.status;

        return StatefulBuilder( // ใช้ StatefulBuilder เพื่อให้ dropdown ทำงานได้
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Edit Employee'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: firstNameController,
                    decoration: InputDecoration(labelText: 'First Name'),
                  ),
                  TextField(
                    controller: lastNameController,
                    decoration: InputDecoration(labelText: 'Last Name'),
                  ),
                  DropdownButton<int>(
                    value: newStatus,
                    onChanged: (int? value) {
                      setState(() {
                        newStatus = value!;
                      });
                    },
                    items: [
                      DropdownMenuItem(value: 0, child: Text('Available')),
                      DropdownMenuItem(value: 1, child: Text('Working')),
                      DropdownMenuItem(value: 2, child: Text('On Leave')),
                      DropdownMenuItem(value: 3, child: Text('Resigned')),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    confirmEdit(employee, firstNameController.text, lastNameController.text, newStatus);
                  },
                  child: Text('Confirm'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void confirmEdit(Employee employee, String firstName, String lastName, int status) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Edit'),
          content: Text('Are you sure you want to update this employee\'s details?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                await employeeService.updateEmployee(employee.employeeId, firstName, lastName, status);
                Navigator.of(context).pop(); // Close confirmation dialog
                Navigator.of(context).pop(); // Close edit dialog

                // Refresh employee list to show updated data
                fetchEmployees(); // อัปเดตหน้าจอ
              },
              child: Text('Confirm'),
            ),
          ],
        );
      },
    );
  }

  // Confirm Termination Dialog
  void confirmTermination(Employee employee) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Termination'),
          content: Text('Are you sure you want to terminate this employee?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: ()  async {
                await employeeService.terminateEmployee(employee.employeeId);
                await fetchEmployees(); // Refresh employee list after termination
                Navigator.of(context).pop();
              },
              child: Text('Confirm'),
            ),
          ],
        );
      },
    );
  }
  void addEmployee() {
    TextEditingController firstNameController = TextEditingController();
    TextEditingController lastNameController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add Employee'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: firstNameController,
                decoration: InputDecoration(labelText: 'First Name'),
              ),
              TextField(
                controller: lastNameController,
                decoration: InputDecoration(labelText: 'Last Name'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                // Send POST request to hire employee
                await employeeService.hireEmployee(
                  firstNameController.text,
                  lastNameController.text,
                );

                // Fetch updated employee list and refresh UI
                await fetchEmployees();

                // Close dialog after completion
                Navigator.of(context).pop();
              },
              child: Text('Confirm'),
            ),
          ],
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Employee List'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: addEmployee, // Show add employee dialog
          ),
        ],
      ),
      body: Column(
        children: [
          // Dropdown ตัวกรองสถานะ
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [

              Padding(
                padding: const EdgeInsets.all(8.0),
                child: DropdownButton<int>(
                  value: selectedStatus,
                  onChanged: (int? value) {
                    setState(() {
                      selectedStatus = value!;
                    });
                  },
                  items: [
                    DropdownMenuItem(value: -1, child: Text('All')),
                    DropdownMenuItem(value: 0, child: Text('Available')),
                    DropdownMenuItem(value: 1, child: Text('Working')),
                    DropdownMenuItem(value: 2, child: Text('On Leave')),
                    DropdownMenuItem(value: 3, child: Text('Resigned')),
                  ],
                  hint: Text('Filter by Status'),
                ),
              ),
            ],
          ),
          Expanded(
            child: ListView.builder(
              itemCount: getFilteredEmployees().length,
              itemBuilder: (context, index) {
                final employee = getFilteredEmployees()[index];
                return EmployeeItemWidget(
                  employee: employee,
                  onEdit: () => editEmployee(employee),
                  onDelete: () => confirmTermination(employee),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
