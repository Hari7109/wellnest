import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(
    home: ViewTeachersPage(),
  ));
}

class ViewTeachersPage extends StatefulWidget {
  const ViewTeachersPage({Key? key}) : super(key: key);

  @override
  _ViewTeachersPageState createState() => _ViewTeachersPageState();
}

class _ViewTeachersPageState extends State<ViewTeachersPage> {
  String selectedDepartment = 'Computer Science'; // Default department

  // Sample teacher data
  final Map<String, List<Map<String, String>>> teachersData = {
    'Computer Science': [
      {'name': 'John Doe', 'registerNumber': 'CS101'},
      {'name': 'Jane Smith', 'registerNumber': 'CS102'},
    ],
    'Mathematics': [
      {'name': 'Alice Brown', 'registerNumber': 'MTH201'},
    ],
    'Physics': [
      {'name': 'Michael Johnson', 'registerNumber': 'PHY301'},
    ],
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1976D2), // Blue
        title: const Text(
          "View Teachers",
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
          const SizedBox(height: 20), // Spacing from app bar

          // Department Dropdown (Horizontally Centered but near the top)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20), // Match container width
            child: Container(
              height: 40, // Reduced height
              width: double.infinity, // Full width to match list container
              decoration: BoxDecoration(
                color: const Color(0xFF1976D2), // Blue background
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: selectedDepartment,
                  icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                  dropdownColor: const Color(0xFF1976D2),
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                  isExpanded: true, // Expand dropdown to fit width
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedDepartment = newValue!;
                    });
                  },
                  items: teachersData.keys.map((String department) {
                    return DropdownMenuItem<String>(
                      value: department,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(department),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),

          const SizedBox(height: 20), // Spacing before the list

          // List of Teachers
          Expanded(
            child: ListView.builder(
              itemCount: teachersData[selectedDepartment]?.length ?? 0,
              itemBuilder: (context, index) {
                final teacher = teachersData[selectedDepartment]![index];
                return TeacherCard(
                  name: teacher['name']!,
                  registerNumber: teacher['registerNumber']!,
                  onTap: () {
                    // Navigate to teacher details page
                  },
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
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
    );
  }
}

// Widget for displaying each teacher
class TeacherCard extends StatelessWidget {
  final String name;
  final String registerNumber;
  final VoidCallback onTap;

  const TeacherCard({
    Key? key,
    required this.name,
    required this.registerNumber,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.red.shade50, // Light red background
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: Colors.grey,
          radius: 24, // Placeholder for teacher's image
        ),
        title: Text(
          name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(registerNumber),
        trailing: const Icon(Icons.arrow_forward_ios, color: Colors.black54),
        onTap: onTap,
      ),
    );
  }
}
