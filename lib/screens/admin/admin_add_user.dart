import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminAddUser extends StatefulWidget {
  const AdminAddUser({super.key});

  @override
  _AdminAddUserState createState() => _AdminAddUserState();
}

class _AdminAddUserState extends State<AdminAddUser> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController regNumberController = TextEditingController();
  final TextEditingController batchController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  String selectedRole = "user";
  String selectedDepartment = "Computer Science";
  String selectedSpecialization = "Dietitian";
  bool isLoading = false;
  bool obscurePassword = true;
  bool obscureConfirmPassword = true;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final List<String> departments = ["Computer Science", "MSW", "Chemistry", "Mathematics"];
  final List<String> specializations = ["Dietitian", "Physiotherapist", "Psychologist"];
  final List<String> roles = ["user", "teacher", "specialist"];

  @override
  void dispose() {
    nameController.dispose();
    regNumberController.dispose();
    batchController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  void _updateRegisterNumber() {
    String email = emailController.text.trim();
    if (email.contains("@")) {
      regNumberController.text = email.split("@")[0];
    }
  }

  Future<void> addUser() async {
    if (!_formKey.currentState!.validate()) return;

    if (passwordController.text != confirmPasswordController.text) {
      _showSnackBar("Passwords do not match");
      return;
    }

    setState(() => isLoading = true);

    try {
      // Check if email already exists in Firestore
      QuerySnapshot query = await _firestore
          .collection('users')
          .where('email', isEqualTo: emailController.text.trim())
          .get();

      if (query.docs.isNotEmpty) {
        _showSnackBar("Error: A user with this email already exists!");
        setState(() => isLoading = false);
        return;
      }

      // Create user in Firebase Auth
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
      String uid = userCredential.user!.uid;

      // Prepare user data
      Map<String, dynamic> userData = {
        'name': nameController.text.trim(),
        'email': emailController.text.trim(),
        'role': selectedRole,
        'created_at': FieldValue.serverTimestamp(),
      };

      if (selectedRole == "user") {
        userData.addAll({
          'reg_no': regNumberController.text.trim(),
          'department': selectedDepartment,
          'batch': batchController.text.trim(),
          'first_login': true,
        });
      } else if (selectedRole == "teacher") {
        userData['department'] = selectedDepartment;
        userData['first_login'] = false;
      } else if (selectedRole == "specialist") {
        userData['specialization'] = selectedSpecialization;
        userData['first_login'] = false;
      }

      // Store user data in Firestore
      await _firestore.collection('users').doc(uid).set(userData);

      _showSnackBar("User added successfully!", success: true);
      _clearFields();
    } catch (e) {
      _showSnackBar("Error: ${e.toString().split('] ').last}");
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _clearFields() {
    nameController.clear();
    regNumberController.clear();
    batchController.clear();
    emailController.clear();
    passwordController.clear();
    confirmPasswordController.clear();
    setState(() {
      selectedRole = "user";
      selectedDepartment = "Computer Science";
      selectedSpecialization = "Dietitian";
    });
  }

  void _showSnackBar(String message, {bool success = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: success ? Colors.green.shade700 : Colors.red.shade700,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.all(12),
    ));
  }

  Widget _buildRoleTile(String role, IconData icon) {
    final bool isSelected = selectedRole == role;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => selectedRole = role),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: isSelected ? Theme.of(context).primaryColor.withOpacity(0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? Theme.of(context).primaryColor : Colors.grey.shade300,
              width: 2,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected ? Theme.of(context).primaryColor : Colors.grey,
                size: 32,
              ),
              const SizedBox(height: 8),
              Text(
                role.toUpperCase(),
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? Theme.of(context).primaryColor : Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add New User"),
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Select User Type",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _buildRoleTile("user", Icons.person),
                      const SizedBox(width: 12),
                      _buildRoleTile("teacher", Icons.school),
                      const SizedBox(width: 12),
                      _buildRoleTile("specialist", Icons.medical_services),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "User Information",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: nameController,
                            decoration: InputDecoration(
                              labelText: "Full Name",
                              prefixIcon: const Icon(Icons.person_outline),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              filled: true,
                              fillColor: Colors.grey.shade50,
                            ),
                            validator: (val) => val!.isEmpty ? "Name is required" : null,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: emailController,
                            decoration: InputDecoration(
                              labelText: "Email Address",
                              prefixIcon: const Icon(Icons.email_outlined),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              filled: true,
                              fillColor: Colors.grey.shade50,
                            ),
                            validator: (val) {
                              if (val!.isEmpty) return "Email is required";
                              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(val)) {
                                return "Enter a valid email";
                              }
                              return null;
                            },
                            onChanged: (_) => _updateRegisterNumber(),
                          ),
                          const SizedBox(height: 16),
                          if (selectedRole == "user") ...[
                            TextFormField(
                              controller: regNumberController,
                              decoration: InputDecoration(
                                labelText: "Register Number",
                                prefixIcon: const Icon(Icons.numbers),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                filled: true,
                                fillColor: Colors.grey.shade100,
                                enabled: false,
                              ),
                            ),
                            const SizedBox(height: 16),
                            DropdownButtonFormField(
                              value: selectedDepartment,
                              onChanged: (value) => setState(() => selectedDepartment = value as String),
                              items: departments.map((dep) => DropdownMenuItem(value: dep, child: Text(dep))).toList(),
                              decoration: InputDecoration(
                                labelText: "Department",
                                prefixIcon: const Icon(Icons.business),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                filled: true,
                                fillColor: Colors.grey.shade50,
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: batchController,
                              decoration: InputDecoration(
                                labelText: "Batch Year",
                                prefixIcon: const Icon(Icons.date_range),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                filled: true,
                                fillColor: Colors.grey.shade50,
                              ),
                              keyboardType: TextInputType.number,
                              validator: (val) => val!.isEmpty ? "Batch year is required" : null,
                            ),
                          ],
                          if (selectedRole == "teacher") ...[
                            DropdownButtonFormField(
                              value: selectedDepartment,
                              onChanged: (value) => setState(() => selectedDepartment = value as String),
                              items: departments.map((dep) => DropdownMenuItem(value: dep, child: Text(dep))).toList(),
                              decoration: InputDecoration(
                                labelText: "Department",
                                prefixIcon: const Icon(Icons.business),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                filled: true,
                                fillColor: Colors.grey.shade50,
                              ),
                            ),
                          ],
                          if (selectedRole == "specialist") ...[
                            DropdownButtonFormField(
                              value: selectedSpecialization,
                              onChanged: (value) => setState(() => selectedSpecialization = value as String),
                              items: specializations.map((spec) => DropdownMenuItem(value: spec, child: Text(spec))).toList(),
                              decoration: InputDecoration(
                                labelText: "Specialization",
                                prefixIcon: const Icon(Icons.medical_services_outlined),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                filled: true,
                                fillColor: Colors.grey.shade50,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Security",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: passwordController,
                            decoration: InputDecoration(
                              labelText: "Password",
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                icon: Icon(obscurePassword ? Icons.visibility : Icons.visibility_off),
                                onPressed: () => setState(() => obscurePassword = !obscurePassword),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              filled: true,
                              fillColor: Colors.grey.shade50,
                            ),
                            obscureText: obscurePassword,
                            validator: (val) {
                              if (val!.isEmpty) return "Password is required";
                              if (val.length < 6) return "Password must be at least 6 characters";
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: confirmPasswordController,
                            decoration: InputDecoration(
                              labelText: "Confirm Password",
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                icon: Icon(obscureConfirmPassword ? Icons.visibility : Icons.visibility_off),
                                onPressed: () => setState(() => obscureConfirmPassword = !obscureConfirmPassword),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              filled: true,
                              fillColor: Colors.grey.shade50,
                            ),
                            obscureText: obscureConfirmPassword,
                            validator: (val) {
                              if (val!.isEmpty) return "Please confirm password";
                              if (val != passwordController.text) return "Passwords don't match";
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : addUser,
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                      child: isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                        "CREATE USER",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}