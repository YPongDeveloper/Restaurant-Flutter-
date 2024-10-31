import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/employee_service.dart';
import '../../models/employee_model.dart';
import '../../widgets/employee_item_widget.dart';
import '../home/login_screen.dart';
import 'employee_info_screen.dart';

class EmployeeScreen extends StatefulWidget {
  @override
  _EmployeeScreenState createState() => _EmployeeScreenState();
}

class _EmployeeScreenState extends State<EmployeeScreen> {
  bool _obscurePassword = true;
  int? position;
  final EmployeeService employeeService = EmployeeService();

  List<Employee> employees = [];
  int selectedStatus = -1;


  @override
  void initState() {
    super.initState();
    fetchEmployees();
    _loadPosition();
  }
  Future<void> _loadPosition() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      position = prefs.getInt('position');
    });
  }

  Future<void> _logout() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('position');

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
          (Route<dynamic> route) => false,  // This removes all previous routes
    );
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
    TextEditingController usernameController = TextEditingController();
    TextEditingController passwordController = TextEditingController();
    String selectedPosition = '1'; // For dropdown selection

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add Employee'),
          content: SingleChildScrollView( // Use SingleChildScrollView to handle keyboard appearance
            child: Column(
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
                TextField(
                  controller: usernameController,
                  decoration: InputDecoration(labelText: 'Username'),
                ),
                TextField(
                  controller: passwordController,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword; // Update password visibility state
                        });
                      },
                    ),
                  ),
                  obscureText: _obscurePassword,
                ),
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(labelText: 'Position'),
                  value: selectedPosition,
                  items: [
                    DropdownMenuItem(
                      child: Text('Employee'),
                      value: '1',
                    ),
                    DropdownMenuItem(
                      child: Text('Admin'),
                      value: '2',
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      selectedPosition = value!; // Use null check and assign new value
                    });
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                int positionValue = int.parse(selectedPosition); // Convert String to int

                await employeeService.hireEmployee(
                  firstNameController.text,
                  lastNameController.text,
                  usernameController.text,
                  passwordController.text,
                  positionValue,
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
      backgroundColor: Colors.yellow[100],
      appBar: AppBar(
        backgroundColor: Colors.yellow[400],
        title: Text('Employee List'),
        actions: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              color: Colors.green[200]
            ),
            child: IconButton(
              icon: Icon(Icons.add),
              onPressed: addEmployee,
            ),
          ),
        ],
      ),
      drawer: Drawer(
        backgroundColor: Colors.blue[50],
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'Employee',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.home, color: Colors.red), // เปลี่ยนสีเป็นสีแดง
              title: Text('Home'),
              onTap: () {
                Navigator.pushNamed(context, '/home');
              },
            ),
            ListTile(
              leading: Icon(Icons.shopping_bag, color: Colors.orange), // เปลี่ยนสีเป็นสีส้ม
              title: Text('Orders'),
              onTap: () {
                Navigator.pushNamed(context, '/orders');
              },
            ),
            ListTile(
              leading: Icon(Icons.queue, color: Colors.pink), // เปลี่ยนสีเป็นสีส้ม
              title: Text('Queue'),
              onTap: () {
                Navigator.pushNamed(context, '/queueScreen');
              },
            ),
            ListTile(
              leading: Icon(Icons.person, color: Colors.green), // เปลี่ยนสีเป็นสีเขียว
              title: Text('Employees',style: TextStyle(color: Colors.red),),
              onTap: () {
                Navigator.pushNamed(context, '/employees');
              },
            ),
            ListTile(
              leading: Icon(Icons.shopping_bag, color: Colors.grey), // เปลี่ยนสีเป็นสีส้ม
              title: Text('Management'),
              onTap: () {
                Navigator.pushNamed(context, '/management');
              },
            ),

            ListTile(
              leading: Icon(Icons.logout, color: Colors.red),
              title: Text('Logout'),
              onTap: _logout,
            ),
          ],
        ),
      ),
      body: Column(
        children: [

          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [

              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                      color: Colors.red[50],
                  child: DropdownButton<int>(
                    borderRadius: BorderRadius.circular(16),
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
              ),
            ],
          ),
          Expanded(
            child: ListView.builder(
              itemCount: getFilteredEmployees().length,
              itemBuilder: (context, index) {
                final employee = getFilteredEmployees()[index];
                return InkWell(
                  onTap: (){
                    Navigator.push(context, MaterialPageRoute(
                      builder: (context) => EmployeeInfoScreen(employeeId: employee.employeeId),
                    ));
                  },
                  child: EmployeeItemWidget(
                    employee: employee,
                    onEdit: () => editEmployee(employee),
                    onDelete: () => confirmTermination(employee),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
