import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: const EmployeeScreen());
  }
}

class EmployeeScreen extends StatefulWidget {
  const EmployeeScreen({super.key});

  @override
  State<EmployeeScreen> createState() {
    return _EmployeeScreen();
  }
}

class _EmployeeScreen extends State<EmployeeScreen> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final departmentController = TextEditingController();
  final salaryController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Employee Management")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: formKey,
          child: Column(
            children: [
              Text("Name"),
              TextFormField(
                controller: nameController,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "name is required";
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              Text("Email"),
              TextFormField(
                controller: emailController,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "email is required";
                  }
                  if (!value.contains("@")) {
                    return "enter a vaild email";
                  }
                  if (!value.contains(".")) {
                    return "enter a vaild email";
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              Text("Department"),
              TextFormField(
                controller: departmentController,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "department is required";
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              Text("salary"),
              TextFormField(
                controller: salaryController,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "salary is required";
                  }
                  final num = int.tryParse(value.trim());
                  if (num == null) {
                    return "enter salary in number";
                  }
                  if (num <= 0) {
                    return "salary must be greater than 0";
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),

              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AddEmployeeScreen(),
                    ),
                  );
                },
                child: const Text("add employee"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AddEmployeeScreen extends StatelessWidget {
  const AddEmployeeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("add employee")),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            final result = await getEmployees();
          },
          child: Text("back"),
        ),
      ),
    );
  }
}

Future<void> getEmployees() async {
  final url = Uri.parse("http://localhost:3000/employees");
  final response = await http.get(url);
  print(response.statusCode);
  print(response.body);
}
