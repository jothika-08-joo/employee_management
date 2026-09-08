import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class Employee {
  int id;
  String name;
  String email;
  String department;
  double salary;

  Employee(this.id, this.name, this.email, this.department, this.salary);

  Employee.fromJson(Map<String, dynamic> json)
    : id = json["id"],
      name = json["name"],
      email = json["email"],
      department = json["department"],
      salary = double.parse(json["salary"].toString());
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
  @override
  void initState() {
    super.initState();
    getEmployees();
  }

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final departmentController = TextEditingController();
  final salaryController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  List<Employee> employees = [];
  bool isSubmitting = false;
  int? deletingEmployeeId;

  Future<void> getEmployees() async {
    final url = Uri.parse("http://localhost:3000/employees");
    final response = await http.get(url);
    final data = jsonDecode(response.body);
    final employeeList = data
        .map<Employee>((json) => Employee.fromJson(json))
        .toList();
    setState(() {
      employees = employeeList;
    });
  }

  Future<void> addEmployee() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    final url = Uri.parse("http://localhost:3000/employees");
    final body = {
      "name": nameController.text.trim(),
      "email": emailController.text.trim(),
      "department": departmentController.text.trim(),
      "salary": double.parse(salaryController.text.trim()),
    };
    setState(() {
      isSubmitting = true;
    });

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );
      final data = jsonDecode(response.body);

      if (response.statusCode != 201) {
        throw Exception(data["message"] ?? "Unable to create employee");
      }

      nameController.clear();
      emailController.clear();
      departmentController.clear();
      salaryController.clear();
      await getEmployees();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(data["message"] ?? "Employee created successfully"),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Could not save employee: $error")),
      );
    } finally {
      if (mounted) {
        setState(() {
          isSubmitting = false;
        });
      }
    }
  }

  Future<void> showEditEmployeeDialog(Employee employee) async {
    final editFormKey = GlobalKey<FormState>();
    final editNameController = TextEditingController(text: employee.name);
    final editEmailController = TextEditingController(text: employee.email);
    final editDepartmentController = TextEditingController(
      text: employee.department,
    );
    final editSalaryController = TextEditingController(
      text: employee.salary.toString(),
    );
    var isUpdating = false;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text("Edit employee"),
              content: SingleChildScrollView(
                child: Form(
                  key: editFormKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: editNameController,
                        decoration: const InputDecoration(labelText: "Name"),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return "Name is required";
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: editEmailController,
                        decoration: const InputDecoration(labelText: "Email"),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          final email = value?.trim() ?? "";
                          if (email.isEmpty) return "Email is required";
                          if (!RegExp(
                            r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                          ).hasMatch(email)) {
                            return "Enter a valid email address";
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: editDepartmentController,
                        decoration: const InputDecoration(
                          labelText: "Department",
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return "Department is required";
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: editSalaryController,
                        decoration: const InputDecoration(labelText: "Salary"),
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        validator: (value) {
                          final salary = double.tryParse(value?.trim() ?? "");
                          if (salary == null) return "Enter a valid salary";
                          if (salary <= 0)
                            return "Salary must be greater than 0";
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isUpdating
                      ? null
                      : () => Navigator.of(dialogContext).pop(),
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: isUpdating
                      ? null
                      : () async {
                          if (!editFormKey.currentState!.validate()) return;

                          setDialogState(() {
                            isUpdating = true;
                          });

                          try {
                            final response = await http.put(
                              Uri.parse(
                                "http://localhost:3000/employees/${employee.id}",
                              ),
                              headers: {"Content-Type": "application/json"},
                              body: jsonEncode({
                                "name": editNameController.text.trim(),
                                "email": editEmailController.text.trim(),
                                "department": editDepartmentController.text
                                    .trim(),
                                "salary": double.parse(
                                  editSalaryController.text.trim(),
                                ),
                              }),
                            );
                            final data = jsonDecode(response.body);

                            if (response.statusCode != 200) {
                              throw Exception(
                                data["message"] ?? "Unable to update employee",
                              );
                            }

                            if (!mounted) return;
                            Navigator.of(dialogContext).pop();
                            await getEmployees();

                            if (!mounted) return;
                            ScaffoldMessenger.of(this.context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  data["message"] ??
                                      "Employee updated successfully",
                                ),
                              ),
                            );
                          } catch (error) {
                            if (!mounted) return;
                            ScaffoldMessenger.of(this.context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  "Could not update employee: $error",
                                ),
                              ),
                            );
                          } finally {
                            if (dialogContext.mounted) {
                              setDialogState(() {
                                isUpdating = false;
                              });
                            }
                          }
                        },
                  child: Text(isUpdating ? "Saving..." : "Save"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> deleteEmployee(Employee employee) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text("Delete employee?"),
          content: Text("Delete ${employee.name}? This cannot be undone."),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true) return;

    setState(() {
      deletingEmployeeId = employee.id;
    });

    try {
      final response = await http.delete(
        Uri.parse("http://localhost:3000/employees/${employee.id}"),
      );
      final data = jsonDecode(response.body);

      if (response.statusCode != 200) {
        throw Exception(data["message"] ?? "Unable to delete employee");
      }

      await getEmployees();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(data["message"] ?? "Employee deleted successfully"),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Could not delete employee: $error")),
      );
    } finally {
      if (mounted) {
        setState(() {
          deletingEmployeeId = null;
        });
      }
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    departmentController.dispose();
    salaryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Employee Management")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: "Name"),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "Name is required";
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: emailController,
                    decoration: const InputDecoration(labelText: "Email"),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      final email = value?.trim() ?? "";
                      if (email.isEmpty) return "Email is required";
                      if (!RegExp(
                        r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                      ).hasMatch(email)) {
                        return "Enter a valid email address";
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: departmentController,
                    decoration: const InputDecoration(labelText: "Department"),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "Department is required";
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: salaryController,
                    decoration: const InputDecoration(labelText: "Salary"),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    validator: (value) {
                      final salary = double.tryParse(value?.trim() ?? "");
                      if (salary == null) return "Enter a valid salary";
                      if (salary <= 0) return "Salary must be greater than 0";
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: isSubmitting ? null : addEmployee,
                    child: Text(isSubmitting ? "Saving..." : "Add employee"),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: employees.length,
              itemBuilder: (context, index) {
                final employee = employees[index];

                return ListTile(
                  title: Text(employee.name),
                  subtitle: Text(employee.email),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: () => showEditEmployeeDialog(employee),
                        icon: const Icon(Icons.edit),
                        tooltip: "Edit employee",
                      ),
                      IconButton(
                        onPressed: deletingEmployeeId == employee.id
                            ? null
                            : () => deleteEmployee(employee),
                        icon: const Icon(Icons.delete),
                        tooltip: "Delete employee",
                      ),
                    ],
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

class AddEmployeeScreen extends StatelessWidget {
  const AddEmployeeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("add employee")),
      body: Center(
        child: ElevatedButton(onPressed: () async {}, child: Text("back")),
      ),
    );
  }
}
