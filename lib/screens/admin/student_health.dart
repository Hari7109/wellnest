import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StudentHealthPage extends StatefulWidget {
  const StudentHealthPage({super.key});

  @override
  _StudentHealthPageState createState() => _StudentHealthPageState();
}

class _StudentHealthPageState extends State<StudentHealthPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  TextEditingController searchController = TextEditingController();
  String searchQuery = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Student Health Records"),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60.0),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: "Search by name or register number",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value.toLowerCase();
                });
              },
            ),
          ),
        ),
      ),
      body: StreamBuilder(
        stream: _firestore.collection('users').where('role', isEqualTo: 'user').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No students found"));
          }

          final filteredStudents = snapshot.data!.docs.where((doc) {
            Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
            String name = data['name']?.toLowerCase() ?? "";
            String registerNumber = data['reg_no']?.toLowerCase() ?? "";
            return name.contains(searchQuery) || registerNumber.contains(searchQuery);
          }).toList();

          return ListView(
            padding: const EdgeInsets.all(8),
            children: filteredStudents.map((doc) {
              Map<String, dynamic> studentData = doc.data() as Map<String, dynamic>;
              return Card(
                elevation: 4,
                margin: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  title: Text(studentData['name'] ?? 'No Name', style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Register No: ${studentData['reg_no'] ?? 'N/A'}"),
                      Text("Email: ${studentData['email'] ?? 'N/A'}"),
                      Text("Department: ${studentData['department'] ?? 'N/A'}"),
                    ],
                  ),
                  onTap: () => _showStudentDetailsDialog(studentData),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }

  void _showStudentDetailsDialog(Map<String, dynamic> studentData) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Student Details - ${studentData['name']}"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Register Number: ${studentData['reg_no']}", style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text("Email: ${studentData['email'] ?? 'N/A'}"),
              Text("Department: ${studentData['department'] ?? 'N/A'}"),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Close"),
            ),
          ],
        );
      },
    );
  }
}
