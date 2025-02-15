import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(
    home: TeacherProfilePage(),
  ));
}

class TeacherProfilePage extends StatelessWidget {
  const TeacherProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1976D2), // Blue
        title: const Text(
          "Teacher Profile",
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
      body: Column(
        children: [
          const SizedBox(height: 20),

          // Teacher Profile Picture
          Center(
            child: CircleAvatar(
              radius: 50,
              backgroundColor: Colors.grey[300], // Placeholder color
              child: const Icon(Icons.person, size: 50, color: Colors.white),
            ),
          ),

          const SizedBox(height: 10),

          // Teacher Details
          const Center(
            child: Column(
              children: [
                Text(
                  "[Name]",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4),
                Text(
                  "[Teacher ID]",
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 4),
                Text(
                  "[Department]",
                  style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Options
          OptionTile(
            title: "Edit Details",
            subtitle: "Make changes to the teacher details",
            icon: Icons.edit,
            onTap: () {
              // Navigate to edit page
            },
          ),

          OptionTile(
            title: "Delete Profile",
            subtitle: "Delete the account of the teacher",
            icon: Icons.delete_forever,
            textColor: Colors.red,
            onTap: () {
              // Delete teacher profile logic
            },
          ),

          const Spacer(),

          // Bottom Navigation Bar
          BottomNavigationBar(
            backgroundColor: const Color(0xFF1976D2), // Blue
            selectedItemColor: Colors.white,
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
        ],
      ),
    );
  }
}

// Option Tile Widget
class OptionTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color? textColor;
  final VoidCallback onTap;

  const OptionTile({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.textColor,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: textColor ?? Colors.black),
      title: Text(
        title,
        style: TextStyle(fontWeight: FontWeight.bold, color: textColor ?? Colors.black),
      ),
      subtitle: Text(subtitle, style: TextStyle(color: textColor ?? Colors.black54)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
}
