import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(
    home: ManageUsersPage(),
  ));
}

class ManageUsersPage extends StatelessWidget {
  const ManageUsersPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1976D2), // Blue
        title: const Text(
          "Manage Users",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            buildUserTile("Add Students", "Create an account for the students"),
            const Divider(color: Color(0xFFBDBDBD)), // Light Grey
            buildUserTile("View Students", "View the list of students"),
            const Divider(color: Color(0xFFBDBDBD)),
            buildUserTile("Add Teachers", "Create an account for the teachers"),
            const Divider(color: Color(0xFFBDBDBD)),
            buildUserTile("View Teachers", "View list of the teachers"),
            const Divider(color: Color(0xFFBDBDBD)),
            buildUserTile("Add Doctors", "Create an account for the doctors"),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF1976D2), // Blue
        selectedItemColor: const Color(0xFFFFFFFF), // White
        unselectedItemColor: const Color(0xFFBBDEFB), // Light Blue
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        onTap: (index) {
          // Handle navigation
        },
      ),
    );
  }

  Widget buildUserTile(String title, String subtitle) {
    return ListTile(
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Color(0xFF000000), // Black
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(color: Color(0xFF616161)), // Grey
      ),
      trailing: const Icon(Icons.arrow_forward_ios, color: Color(0xFF424242)), // Dark Grey
      onTap: () {
        // Handle navigation
      },
    );
  }
}
