import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ManageUsersPage extends StatefulWidget {
  const ManageUsersPage({super.key});

  @override
  _ManageUsersPageState createState() => _ManageUsersPageState();
}

class _ManageUsersPageState extends State<ManageUsersPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController searchController = TextEditingController();
  String searchQuery = "";
  String _filterRole = "All";
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

  Future<void> _deleteUser(String uid, String userName) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirm Delete"),
        content: Text("Are you sure you want to delete $userName? This action cannot be undone."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("CANCEL"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("DELETE", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isLoading = true);
    try {
      await _firestore.collection('users').doc(uid).delete();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("$userName deleted successfully"),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error deleting user: $e"),
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
        title: const Text("Manage Users"),
        elevation: 0,
        backgroundColor: theme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: theme.primaryColor.withOpacity(0.05),
            child: Column(
              children: [
                TextField(
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
                const SizedBox(height: 12),
                _buildRoleFilter(),
              ],
            ),
          ),
          Expanded(
            child: _buildUserList(),
          ),
        ],
      ),
      // Removed FloatingActionButton for adding new users
    );
  }

  Widget _buildRoleFilter() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _filterChip("All"),
          _filterChip("user"),
          _filterChip("teacher"),
          _filterChip("specialist"),
        ],
      ),
    );
  }

  Widget _filterChip(String role) {
    final isSelected = _filterRole == role;
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(role == "All" ? "All Roles" : role.toUpperCase()),
        selected: isSelected,
        selectedColor: theme.primaryColor.withOpacity(0.2),
        checkmarkColor: theme.primaryColor,
        onSelected: (selected) {
          setState(() {
            _filterRole = role;
          });
        },
      ),
    );
  }

  Widget _buildUserList() {
    return StreamBuilder(
      stream: _firestore.collection('users').snapshots(),
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
                  "No users found",
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
          String role = userData['role'] ?? "";

          bool matchesSearch = name.contains(searchQuery) || registerNumber.contains(searchQuery);
          bool matchesFilter = _filterRole == "All" || role == _filterRole;

          return matchesSearch && matchesFilter;
        }).toList();

        if (filteredUsers.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                const Text(
                  "No matching users found",
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

    // Get role-specific color
    Color roleColor;
    switch (userData['role']) {
      case 'teacher':
        roleColor = Colors.blue;
        break;
      case 'specialist':
        roleColor = Colors.purple;
        break;
      default:
        roleColor = Colors.teal;
    }

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
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: roleColor.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                (userData['role'] ?? 'user').toUpperCase(),
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: roleColor,
                                ),
                              ),
                            ),
                            if (userData['reg_no'] != null) ...[
                              const SizedBox(width: 8),
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
                      } else if (value == 'delete') {
                        _deleteUser(uid, userData['name'] ?? 'User');
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(value: 'edit', child: Text("Edit User")),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Text("Delete User", style: TextStyle(color: Colors.red)),
                      ),
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
    String selectedRole = userData['role'] ?? 'user';

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
                TextFormField(
                  controller: passwordController,
                  decoration: const InputDecoration(
                    labelText: "New Password (leave blank to keep unchanged)",
                    prefixIcon: Icon(Icons.lock),
                    helperText: "Minimum 6 characters",
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField(
                  value: selectedRole,
                  decoration: const InputDecoration(
                    labelText: "User Role",
                    prefixIcon: Icon(Icons.admin_panel_settings),
                  ),
                  items: ["user", "teacher", "specialist"].map((role) {
                    return DropdownMenuItem(
                      value: role,
                      child: Text(role.toUpperCase()),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      selectedRole = value;
                    }
                  },
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
                  'role': selectedRole,
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