import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'forms_page.dart';

class UpdateHealthDetailsPage extends StatefulWidget {
  @override
  _UpdateHealthDetailsPageState createState() => _UpdateHealthDetailsPageState();
}

class _UpdateHealthDetailsPageState extends State<UpdateHealthDetailsPage> {
  final TextEditingController _searchController = TextEditingController();
  Map<String, dynamic>? _studentData;

  Future<void> _searchStudent() async {
    String regNo = _searchController.text.trim();
    if (regNo.isEmpty) return;

    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('reg_no', isEqualTo: regNo)
        .where('role', isEqualTo: 'user')
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      setState(() {
        _studentData = querySnapshot.docs.first.data() as Map<String, dynamic>?;
      });
    } else {
      setState(() {
        _studentData = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Student not found')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Update Health Details')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Enter Register Number',
                suffixIcon: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: _searchStudent,
                ),
              ),
              onSubmitted: (_) => _searchStudent(),
            ),
            SizedBox(height: 20),
            if (_studentData != null) ...[
              Card(
                elevation: 4,
                child: ListTile(
                  title: Text('Name: ${_studentData!['name']}'),
                  subtitle: Text('Register No: ${_studentData!['reg_no']}'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FormsPage(studentData: _studentData!),
                      ),
                    );
                  },
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }
}