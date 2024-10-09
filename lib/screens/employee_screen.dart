import 'package:flutter/material.dart';
import '../services/employee_service.dart';
import '../models/employee_model.dart';
import '../widgets/employee_item_widget.dart';

class EmployeeScreen extends StatefulWidget {
  @override
  _EmployeeScreenState createState() => _EmployeeScreenState();
}

class _EmployeeScreenState extends State<EmployeeScreen> {
  final EmployeeService employeeService = EmployeeService();
  List<Employee> employees = [];
  int selectedStatus = -1;

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

        return StatefulBuilder(
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
                      DropdownMenuItem(value: 2, child: Text('Adsent from work')),
                      DropdownMenuItem(value: 3, child: Text('Fired')),
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
                Navigator.of(context).pop();
                Navigator.of(context).pop();

                fetchEmployees(); // อัปเดตหน้าจอ
              },
              child: Text('Confirm'),
            ),
          ],
        );
      },
    );
  }

  void confirmTermination(Employee employee) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Fire'),
          content: Text('Are you sure you want to fire this employee?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: ()  async {
                await employeeService.terminateEmployee(employee.employeeId);
                await fetchEmployees();
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

                await employeeService.hireEmployee(
                  firstNameController.text,
                  lastNameController.text,
                );

                await fetchEmployees();

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
            onPressed: addEmployee,
          ),
        ],
      ),
      body: Column(
        children: [

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
                    DropdownMenuItem(value: -1, child: Text('All', style: TextStyle(color: Colors.black))),
                    DropdownMenuItem(value: 0, child: Text('Available', style: TextStyle(color: Colors.green[400]))),
                    DropdownMenuItem(value: 1, child: Text('Working', style: TextStyle(color: Colors.orange))),
                    DropdownMenuItem(value: 2, child: Text('Absent from work', style: TextStyle(color: Colors.blue))),
                    DropdownMenuItem(value: 3, child: Text('Fired', style: TextStyle(color: Colors.red))),
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
