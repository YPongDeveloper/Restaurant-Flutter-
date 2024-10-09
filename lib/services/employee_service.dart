import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_constants.dart';
import '../models/employee_model.dart';

class EmployeeService {
  Future<List<Employee>> fetchEmployees() async {
    final response = await http.get(Uri.parse(ApiConstants.employeesAPI));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body)['data'];
      return data.map((e) => Employee.fromJson(e)).toList();
    }
    throw Exception('Failed to load employees');
  }

  Future<void> updateEmployee(int employeeId, String firstName, String lastName, int status) async {
    final response = await http.put(
      Uri.parse('${ApiConstants.employeesAPI}/edit/$employeeId'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        'employee_id': employeeId,
        'first_name': firstName,
        'last_name': lastName,
        'status': status,
      }),
    );

    if (response.statusCode == 200) {
      fetchEmployees(); // Refresh employee list after update
    } else {
      // Handle error case
      print('Failed to update employee');
    }
  }
  Future<void> terminateEmployee(int employeeId) async {
    final response = await http.put(
      Uri.parse('${ApiConstants.employeesAPI}/fire/$employeeId'),
      headers: {"Content-Type": "application/json"},
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to terminate employee');
    }
  }
  Future<void> hireEmployee(String firstName, String lastName) async {
    final response = await http.post(
      Uri.parse('${ApiConstants.employeesAPI}/hire'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "first_name": firstName,
        "last_name": lastName,
        "status": 0 // Assuming default status is 'Available'
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to hire employee');
    }
  }

}
