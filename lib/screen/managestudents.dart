import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(
    home: ManageStudentsPage(),
  ));
}

class ManageStudentsPage extends StatelessWidget {
  const ManageStudentsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text(
          "Manage Students",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
            ListTile(
              title: const Text(
                "Add Students",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: const Text("Create an account for the students"),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                // Navigate to Add Students Page
              },
            ),
            const Divider(),
            ListTile(
              title: const Text(
                "View Students",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: const Text("View the list of students"),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                // Navigate to View Students Page
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.blue,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
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
}
