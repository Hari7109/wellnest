import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TeacherManageUsersPage extends StatefulWidget {
  const TeacherManageUsersPage({super.key});

  @override
  _TeacherManageUsersPageState createState() => _TeacherManageUsersPageState();
}

class _TeacherManageUsersPageState extends State<TeacherManageUsersPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController searchController = TextEditingController();
  String searchQuery = "";
  bool _isLoading = false;

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> _updateUser(String uid, Map<String, dynamic> updatedData) async {
    setState(() => _isLoading = true);
    try {
      await _firestore.collection('users').doc(uid).update(updatedData);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("User updated successfully!"),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Update failed: $e"),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Manage Students"),
        elevation: 0,
        backgroundColor: theme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: theme.primaryColor.withOpacity(0.05),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: "Search by name or register number",
                prefixIcon: const Icon(Icons.search),
                suffixIcon: searchQuery.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    searchController.clear();
                    setState(() => searchQuery = "");
                  },
                )
                    : null,
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: theme.primaryColor, width: 2),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value.toLowerCase();
                });
              },
            ),
          ),
          Expanded(
            child: _buildUserList(),
          ),
        ],
      ),
    );
  }

  Widget _buildUserList() {
    return StreamBuilder(
      stream: _firestore.collection('users')
          .where('role', isEqualTo: 'user') // Only show user role
          .snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting || _isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.person_off, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                const Text(
                  "No students found",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        final filteredUsers = snapshot.data!.docs.where((userDoc) {
          Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
          String name = userData['name']?.toLowerCase() ?? "";
          String registerNumber = userData['reg_no']?.toLowerCase() ?? "";

          return name.contains(searchQuery) || registerNumber.contains(searchQuery);
        }).toList();

        if (filteredUsers.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                const Text(
                  "No matching students found",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: filteredUsers.length,
          itemBuilder: (context, index) {
            Map<String, dynamic> userData = filteredUsers[index].data() as Map<String, dynamic>;
            String userId = filteredUsers[index].id;
            return _buildUserCard(userId, userData);
          },
        );
      },
    );
  }

  Widget _buildUserCard(String uid, Map<String, dynamic> userData) {
    final theme = Theme.of(context);
    final bool isEnabled = userData['enabled'] ?? true;

    // Fix for the RangeError - safely get the first character of name
    String nameInitial = '?';
    if ((userData['name'] ?? '').isNotEmpty) {
      nameInitial = userData['name']![0].toUpperCase();
    }

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Opacity(
        opacity: isEnabled ? 1.0 : 0.6,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    backgroundColor: theme.primaryColor.withOpacity(0.2),
                    radius: 24,
                    child: Text(
                      nameInitial,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: theme.primaryColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          userData['name'] ?? 'No Name',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          userData['email'] ?? 'No Email',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            if (userData['reg_no'] != null) ...[
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  userData['reg_no'],
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton(
                    icon: const Icon(Icons.more_vert),
                    onSelected: (value) {
                      if (value == 'edit') {
                        _showEditUserDialog(uid, userData);
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(value: 'edit', child: Text("Edit Student")),
                    ],
                  ),
                ],
              ),
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Text(
                        "Account Status: ",
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                      Text(
                        isEnabled ? "Enabled" : "Disabled",
                        style: TextStyle(
                          color: isEnabled ? Colors.green : Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Switch(
                    value: isEnabled,
                    activeColor: theme.primaryColor,
                    onChanged: (value) {
                      _updateUser(uid, {'enabled': value});
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditUserDialog(String uid, Map<String, dynamic> userData) {
    TextEditingController nameController = TextEditingController(text: userData['name']);
    TextEditingController emailController = TextEditingController(text: userData['email']);
    TextEditingController regNoController = TextEditingController(text: userData['reg_no'] ?? '');
    TextEditingController passwordController = TextEditingController();
    String selectedDepartment = userData['department'] ?? 'Computer Science';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Edit ${userData['name']}"),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: "Full Name",
                    prefixIcon: Icon(Icons.person),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: "Email Address",
                    prefixIcon: Icon(Icons.email),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: regNoController,
                  decoration: const InputDecoration(
                    labelText: "Register Number",
                    prefixIcon: Icon(Icons.badge),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField(
                  value: selectedDepartment,
                  decoration: const InputDecoration(
                    labelText: "Department",
                    prefixIcon: Icon(Icons.school),
                  ),
                  items: ["Computer Science", "MSW", "Chemistry", "Mathematics"].map((dep) {
                    return DropdownMenuItem(
                      value: dep,
                      child: Text(dep),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      selectedDepartment = value;
                    }
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: passwordController,
                  decoration: const InputDecoration(
                    labelText: "New Password (leave blank to keep unchanged)",
                    prefixIcon: Icon(Icons.lock),
                    helperText: "Minimum 6 characters",
                  ),
                  obscureText: true,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("CANCEL"),
            ),
            ElevatedButton(
              onPressed: () async {
                // Validate inputs
                if (nameController.text.isEmpty || emailController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Name and email are required"),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                Map<String, dynamic> updates = {
                  'name': nameController.text,
                  'email': emailController.text,
                  'department': selectedDepartment,
                };

                if (regNoController.text.isNotEmpty) {
                  updates['reg_no'] = regNoController.text;
                }

                Navigator.pop(context);

                // Handle password update separately if provided
                if (passwordController.text.isNotEmpty) {
                  try {
                    // Fixed: Use Admin SDK or Cloud Functions for password updates
                    // This client-side approach won't work properly
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Password updates require admin privileges. Please use Firebase Admin SDK."),
                        backgroundColor: Colors.orange,
                      ),
                    );
                    // Note: The proper way would be to call a Cloud Function
                    // that has admin privileges to update the user's password
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Error updating password: $e"),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }

                _updateUser(uid, updates);
              },
              child: const Text("UPDATE"),
            ),
          ],
        );
      },
    );
  }
}