import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StudentProfileDetailPage extends StatefulWidget {
  const StudentProfileDetailPage({super.key});

  @override
  _StudentProfileDetailPageState createState() => _StudentProfileDetailPageState();
}

class _StudentProfileDetailPageState extends State<StudentProfileDetailPage> {
  // Controllers for search and filtering
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // Student details related states
  Map<String, dynamic>? _selectedStudentDetails;
  bool _isLoading = false;

  // Fetch student list
  Stream<QuerySnapshot> _getStudentStream() {
    return FirebaseFirestore.instance
        .collection('users')
        .where('userType', isEqualTo: 'student')
        .snapshots();
  }

  // Fetch full student details
  Future<void> _fetchStudentFullDetails(String uid) async {
    setState(() {
      _isLoading = true;
      _selectedStudentDetails = null;
    });

    try {
      // Fetch from multiple collections
      final bioData = await FirebaseFirestore.instance
          .collection('bio_data')
          .doc(uid)
          .get();

      final personalHistory = await FirebaseFirestore.instance
          .collection('personal_history')
          .doc(uid)
          .get();

      final immunizationData = await FirebaseFirestore.instance
          .collection('immunization')
          .doc(uid)
          .get();

      setState(() {
        _selectedStudentDetails = {
          'bio': bioData.data() ?? {},
          'personal_history': personalHistory.data() ?? {},
          'immunization': immunizationData.data() ?? {},
        };
      });
    } catch (e) {
      print('Error fetching student details: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load student details')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Build detailed view of student
  Widget _buildStudentDetailsView() {
    if (_selectedStudentDetails == null) {
      return const Center(child: Text('Select a student to view details'));
    }

    final bioData = _selectedStudentDetails!['bio'];
    final personalHistory = _selectedStudentDetails!['personal_history'];
    final immunizationData = _selectedStudentDetails!['immunization'];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Personal Information Section
          _buildSectionHeader('Personal Information'),
          _buildDetailRow('Name', bioData['name'] ?? 'N/A'),
          _buildDetailRow('Date of Birth', bioData['dob'] ?? 'N/A'),
          _buildDetailRow('Age', bioData['age'] ?? 'N/A'),
          _buildDetailRow('Gender', bioData['sex'] ?? 'N/A'),
          _buildDetailRow('Blood Group', bioData['bloodGroup'] ?? 'N/A'),

          // Academic Information Section
          _buildSectionHeader('Academic Information'),
          _buildDetailRow('Course', bioData['courseName'] ?? 'N/A'),
          _buildDetailRow('Admission Date', bioData['admissionDate'] ?? 'N/A'),
          _buildDetailRow('Completion Date', bioData['completionDate'] ?? 'N/A'),

          // Personal History Section
          _buildSectionHeader('Personal History'),
          _buildListRow('Communicable Diseases',
              personalHistory['communicableDiseases'] ?? []),
          _buildListRow('Non-Communicable Diseases',
              personalHistory['nonCommunicableDiseases'] ?? []),
          _buildDetailRow('Dietary Pattern',
              personalHistory['dietaryPattern'] ?? 'N/A'),
          _buildDetailRow('Sleep Pattern',
              personalHistory['sleep'] ?? 'N/A'),

          // Immunization Section
          _buildSectionHeader('Immunization'),
          ..._buildVaccineDetails(immunizationData['vaccines'] ?? []),
        ],
      ),
    );
  }

  // Build vaccine details
  List<Widget> _buildVaccineDetails(List<dynamic> vaccines) {
    return vaccines.map((vaccine) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
                vaccine['name'] ?? 'Unknown Vaccine',
                style: const TextStyle(fontWeight: FontWeight.bold)
            ),
            _buildDetailRow('First Dose',
                vaccine['firstDose'] == true ? 'Completed' : 'Pending'),
            _buildDetailRow('Second Dose',
                vaccine['secondDose'] == true ? 'Completed' : 'Pending'),
            _buildDetailRow('Third Dose',
                vaccine['thirdDose'] == true ? 'Completed' : 'Pending'),
          ],
        ),
      );
    }).toList();
  }

  // Utility widgets for formatting
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Text(
          title,
          style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.blue
          )
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
                label,
                style: const TextStyle(fontWeight: FontWeight.bold)
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(value),
          ),
        ],
      ),
    );
  }

  Widget _buildListRow(String label, List<dynamic> values) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold)
          ),
          ...values.map((value) => Text('• $value')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Profile Details'),
      ),
      body: Row(
        children: [
          // Student List Section
          Expanded(
            flex: 2,
            child: Column(
              children: [
                // Search Bar
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search students...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value.toLowerCase();
                      });
                    },
                  ),
                ),

                // Student List
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: _getStudentStream(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return const Center(child: Text('No students found'));
                      }

                      // Filter students based on search query
                      final filteredStudents = snapshot.data!.docs.where((doc) {
                        final name = (doc.data() as Map<String, dynamic>)['name']
                            ?.toString()
                            .toLowerCase() ?? '';
                        return name.contains(_searchQuery);
                      }).toList();

                      return ListView.builder(
                        itemCount: filteredStudents.length,
                        itemBuilder: (context, index) {
                          final student = filteredStudents[index];
                          final studentData = student.data() as Map<String, dynamic>;

                          return ListTile(
                            title: Text(studentData['name'] ?? 'Unknown'),
                            subtitle: Text(studentData['courseName'] ?? ''),
                            onTap: () => _fetchStudentFullDetails(student.id),
                            selected: _selectedStudentDetails != null,
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // Vertical Divider
          const VerticalDivider(width: 1, color: Colors.grey),

          // Student Details Section
          Expanded(
            flex: 3,
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _buildStudentDetailsView(),
          ),
        ],
      ),
    );
  }
}