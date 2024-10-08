class Employee {
  final int employeeId;
  final String firstName;
  final String lastName;
  int status;

  Employee({
    required this.employeeId,
    required this.firstName,
    required this.lastName,
    required this.status,
  });

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      employeeId: json['employee_id'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      status: json['status'],
    );
  }
}
