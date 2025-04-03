import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DepartmentHealthPage extends StatefulWidget {
  const DepartmentHealthPage({super.key});

  @override
  _DepartmentHealthPageState createState() => _DepartmentHealthPageState();
}

class _DepartmentHealthPageState extends State<DepartmentHealthPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? selectedDepartment;
  List<String> departments = [];

  int totalUsers = 0;
  int totalMales = 0;
  int totalFemales = 0;
  double averageHeight = 0.0;
  double averageWeight = 0.0;
  double averageBMI = 0.0;

  @override
  void initState() {
    super.initState();
    _fetchDepartments();
  }

  Future<void> _fetchDepartments() async {
    QuerySnapshot usersSnapshot = await _firestore.collection('users').get();
    Set<String> departmentSet = {};

    for (var doc in usersSnapshot.docs) {
      String? department = doc['department'];
      if (department != null) {
        departmentSet.add(department);
      }
    }

    setState(() {
      departments = departmentSet.toList();
    });
  }

  Future<void> _fetchDepartmentStats() async {
    if (selectedDepartment == null) return;

    QuerySnapshot usersSnapshot = await _firestore
        .collection('users')
        .where('department', isEqualTo: selectedDepartment)
        .get();

    int maleCount = 0;
    int femaleCount = 0;
    double totalHeight = 0.0;
    double totalWeight = 0.0;
    double totalBMI = 0.0;
    int count = usersSnapshot.docs.length;

    for (var userDoc in usersSnapshot.docs) {
      String userId = userDoc.id;

      // Fetch gender from bioData collection
      var bioSnapshot =
      await _firestore.collection('bioData').doc(userId).get();
      String gender = bioSnapshot.data()?['sex'] ?? 'Unknown';

      if (gender.toLowerCase() == 'male') {
        maleCount++;
      } else if (gender.toLowerCase() == 'female') {
        femaleCount++;
      }

      // Fetch BMI details
      var bmiSnapshot = await _firestore.collection('bmi').doc(userId).get();
      double height = double.tryParse(bmiSnapshot.data()?['height']?.toString() ?? '0') ?? 0.0;
      double weight = double.tryParse(bmiSnapshot.data()?['weight']?.toString() ?? '0') ?? 0.0;
      double bmi = double.tryParse(bmiSnapshot.data()?['bmi']?.toString() ?? '0') ?? 0.0;

      totalHeight += height;
      totalWeight += weight;
      totalBMI += bmi;
    }

    setState(() {
      totalUsers = count;
      totalMales = maleCount;
      totalFemales = femaleCount;
      averageHeight = count > 0 ? totalHeight / count : 0.0;
      averageWeight = count > 0 ? totalWeight / count : 0.0;
      averageBMI = count > 0 ? totalBMI / count : 0.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Department Health Overview")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              value: selectedDepartment,
              decoration: const InputDecoration(labelText: "Select Department"),
              items: departments.map<DropdownMenuItem<String>>((department) {
                return DropdownMenuItem<String>(
                  value: department,
                  child: Text(department),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedDepartment = value;
                });
                _fetchDepartmentStats();
              },
            ),
            const SizedBox(height: 20),
            _buildStatsCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Department Statistics",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Divider(),
            _buildStatRow("Total Students", totalUsers.toString()),
            _buildStatRow("Total Males", totalMales.toString()),
            _buildStatRow("Total Females", totalFemales.toString()),
            _buildStatRow("Average Height", "${averageHeight.toStringAsFixed(2)} cm"),
            _buildStatRow("Average Weight", "${averageWeight.toStringAsFixed(2)} kg"),
            _buildStatRow("Average BMI", averageBMI.toStringAsFixed(2)),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 16)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
