import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class BioDataProfilePage extends StatefulWidget {
  const BioDataProfilePage({super.key});

  @override
  _BioDataProfilePageState createState() => _BioDataProfilePageState();
}

class _BioDataProfilePageState extends State<BioDataProfilePage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Map<String, dynamic>? bioData;
  bool isLoading = true;
  bool isEditing = false;
  String? error;

  // Map of controllers for editing
  final Map<String, TextEditingController> _controllers = {};

  @override
  void initState() {
    super.initState();
    _fetchBioData();
  }

  @override
  void dispose() {
    // Dispose all controllers
    _controllers.forEach((_, controller) => controller.dispose());
    super.dispose();
  }

  // Fetch bio data from Firestore
  Future<void> _fetchBioData() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      User? user = _auth.currentUser;

      if (user == null) {
        throw Exception("No user is signed in");
      }

      DocumentSnapshot doc = await _firestore.collection('bioData').doc(user.uid).get();

      if (!doc.exists) {
        throw Exception("Bio data not found for this user");
      }

      setState(() {
        bioData = doc.data() as Map<String, dynamic>?;
        isLoading = false;
      });

      // Initialize controllers with existing data
      if (bioData != null) {
        bioData!.forEach((key, value) {
          _controllers[key] = TextEditingController(text: value?.toString() ?? '');
        });
      }
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  // Update bio data in Firestore
  Future<void> _updateBioData() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      User? user = _auth.currentUser;

      if (user == null) {
        throw Exception("No user is signed in");
      }

      // Create updated data map from controllers
      Map<String, dynamic> updatedData = {};
      _controllers.forEach((key, controller) {
        updatedData[key] = controller.text;
      });

      await _firestore.collection('bioData').doc(user.uid).update(updatedData);

      setState(() {
        bioData = updatedData;
        isLoading = false;
        isEditing = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully')),
      );
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating profile: $e')),
      );
    }
  }

  // Select date method
  Future<void> _selectDate(BuildContext context, String field) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );

    if (picked != null && _controllers.containsKey(field)) {
      setState(() {
        _controllers[field]!.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  // Field widget for viewing and editing
  Widget _buildField({
    required String label,
    required String field,
    bool isMultiline = false,
    bool isDate = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: isEditing
          ? Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 4),
          if (isMultiline)
            TextFormField(
              controller: _controllers[field],
              maxLines: 3,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                contentPadding: const EdgeInsets.all(12),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
            )
          else
            TextFormField(
              controller: _controllers[field],
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                filled: true,
                fillColor: Colors.grey.shade50,
                suffixIcon: isDate
                    ? IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: () => _selectDate(context, field),
                )
                    : null,
              ),
              readOnly: isDate,
            ),
        ],
      )
          : Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(8.0),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Text(
              bioData?[field] ?? 'Not provided',
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  // Build section
  Widget _buildSection(String title, List<Map<String, dynamic>> fields) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0D47A1),
            ),
          ),
        ),
        Card(
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: fields.map((field) => _buildField(
                label: field['label'],
                field: field['field'],
                isMultiline: field['isMultiline'] ?? false,
                isDate: field['isDate'] ?? false,
              )).toList(),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D47A1),
        elevation: 0,
        title: const Text(
          "Bio Data Profile",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        actions: [
          if (!isEditing && !isLoading && bioData != null)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                setState(() {
                  isEditing = true;
                });
              },
            ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error != null
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Error: $error',
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _fetchBioData,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0D47A1),
                foregroundColor: Colors.white,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      )
          : bioData == null
          ? const Center(child: Text('No bio data available'))
          : Stack(
        children: [
          // Main content
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Header
                if (!isEditing)
                  Center(
                    child: Column(
                      children: [
                        const CircleAvatar(
                          radius: 50,
                          backgroundColor: Color(0xFF0D47A1),
                          child: Icon(
                            Icons.person,
                            size: 50,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          bioData?['name'] ?? 'Student',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          bioData?['courseName'] ?? 'Course',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),

                // Personal Information Section
                _buildSection('Personal Information', [
                  {'label': 'Name', 'field': 'name'},
                  {'label': 'Age', 'field': 'age'},
                  {'label': 'Sex', 'field': 'sex'},
                  {'label': 'Date of Birth', 'field': 'dob', 'isDate': true},
                  {'label': 'Blood Group', 'field': 'bloodGroup'},
                  {'label': 'Religion', 'field': 'religion'},
                  {'label': 'Identification Mark', 'field': 'idMark'},
                ]),

                // Course Information Section
                _buildSection('Course Information', [
                  {'label': 'Course Name', 'field': 'courseName'},
                  {'label': 'Date of Admission', 'field': 'admissionDate', 'isDate': true},
                  {'label': 'Course Duration', 'field': 'courseDuration'},
                  {'label': 'Date of Completion', 'field': 'completionDate', 'isDate': true},
                ]),

                // Address Information Section
                _buildSection('Address Information', [
                  {'label': 'Permanent Address', 'field': 'permanentAddress', 'isMultiline': true},
                  {'label': 'Residential Address', 'field': 'residentialAddress', 'isMultiline': true},
                  {'label': 'Local Guardian', 'field': 'guardian'},
                ]),

                // Father's Details Section
                _buildSection('Father\'s Details', [
                  {'label': 'Name', 'field': 'fatherName'},
                  {'label': 'Education', 'field': 'fatherEducation'},
                  {'label': 'Occupation', 'field': 'fatherOccupation'},
                  {'label': 'Income', 'field': 'fatherIncome'},
                ]),

                // Mother's Details Section
                _buildSection('Mother\'s Details', [
                  {'label': 'Name', 'field': 'motherName'},
                  {'label': 'Education', 'field': 'motherEducation'},
                  {'label': 'Occupation', 'field': 'motherOccupation'},
                  {'label': 'Income', 'field': 'motherIncome'},
                ]),

                // Bottom spacing for floating action button
                const SizedBox(height: 80),
              ],
            ),
          ),

          // Floating action buttons for editing
          if (isEditing)
            Positioned(
              bottom: 20,
              right: 20,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  FloatingActionButton(
                    heroTag: 'cancel',
                    backgroundColor: Colors.grey.shade300,
                    onPressed: () {
                      setState(() {
                        isEditing = false;
                        // Reset controllers to original values
                        bioData!.forEach((key, value) {
                          _controllers[key]?.text = value?.toString() ?? '';
                        });
                      });
                    },
                    child: const Icon(Icons.close, color: Colors.black54),
                  ),
                  const SizedBox(width: 12),
                  FloatingActionButton(
                    heroTag: 'save',
                    backgroundColor: const Color(0xFF0D47A1),
                    onPressed: _updateBioData,
                    child: const Icon(Icons.save),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}