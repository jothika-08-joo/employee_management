import 'package:flutter/material.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Employee Management")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text("Name"),
            TextField(controller: nameController),
            SizedBox(height: 16),
            Text("Email"),
            TextField(controller: emailController),
            SizedBox(height: 16),
            Text("Department"),
            TextField(controller: departmentController),
            SizedBox(height: 16),
            Text("salary"),
            TextField(controller: salaryController),
            SizedBox(height: 16),

            ElevatedButton(
              onPressed: () {
                print(nameController.text);
                print(emailController.text);
                print(departmentController.text);
                print(salaryController.text);
              },
              child: Text("add employee"),
            ),
          ],
        ),
      ),
    );
  }
}
