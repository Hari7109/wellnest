import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(
    home: ViewStudentsPage(),
  ));
}

class ViewStudentsPage extends StatefulWidget {
  const ViewStudentsPage({Key? key}) : super(key: key);

  @override
  _ViewStudentsPageState createState() => _ViewStudentsPageState();
}

class _ViewStudentsPageState extends State<ViewStudentsPage> {
  String selectedDepartment = 'Computer Science'; // Default department
  String selectedYear = '1st Year'; // Default year

  // Sample student data
  final Map<String, Map<String, List<Map<String, String>>>> studentsData = {
    'Computer Science': {
      '1st Year': [
        {'name': 'Alice Johnson', 'registerNumber': 'CS101'},
        {'name': 'Bob Smith', 'registerNumber': 'CS102'},
      ],
      '2nd Year': [
        {'name': 'Charlie Brown', 'registerNumber': 'CS201'},
      ],
    },
    'Mathematics': {
      '1st Year': [
        {'name': 'David Williams', 'registerNumber': 'MTH101'},
      ],
      '3rd Year': [
        {'name': 'Emma Wilson', 'registerNumber': 'MTH301'},
      ],
    },
    'Physics': {
      '4th Year': [
        {'name': 'Franklin Carter', 'registerNumber': 'PHY401'},
      ],
    },
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1976D2), // Blue
        title: const Text(
          "View Students",
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

          // Department Dropdown
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              height: 40,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFF1976D2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ButtonTheme(
                alignedDropdown: true, // Ensures dropdown matches button width
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedDepartment,
                    icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                    dropdownColor: const Color(0xFF1976D2),
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                    isExpanded: true,
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedDepartment = newValue!;
                        selectedYear = '1st Year'; // Reset year on department change
                      });
                    },
                    items: studentsData.keys.map((String department) {
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
          ),

          const SizedBox(height: 10), // Spacing between dropdowns

          // Year Dropdown
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              height: 40,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFF1976D2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ButtonTheme(
                alignedDropdown: true, // Ensures dropdown matches button width
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedYear,
                    icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                    dropdownColor: const Color(0xFF1976D2),
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                    isExpanded: true,
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedYear = newValue!;
                      });
                    },
                    items: ['1st Year', '2nd Year', '3rd Year', '4th Year']
                        .map((String year) {
                      return DropdownMenuItem<String>(
                        value: year,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text(year),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 20), // Spacing before the list

          // List of Students
          Expanded(
            child: ListView.builder(
              itemCount: studentsData[selectedDepartment]?[selectedYear]?.length ?? 0,
              itemBuilder: (context, index) {
                final student =
                studentsData[selectedDepartment]?[selectedYear]?[index];
                return student != null
                    ? StudentCard(
                  name: student['name']!,
                  registerNumber: student['registerNumber']!,
                  onTap: () {
                    // Navigate to student details page
                  },
                )
                    : const SizedBox.shrink();
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

// Widget for displaying each student
class StudentCard extends StatelessWidget {
  final String name;
  final String registerNumber;
  final VoidCallback onTap;

  const StudentCard({
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
          radius: 24, // Placeholder for student's image
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
