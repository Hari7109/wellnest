import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

import '../services/user_service.dart';

class BodyCompositionDisplayPage extends StatefulWidget {
  //final Map<String, dynamic> studentData;

  //const BodyCompositionDisplayPage({Key? key, required this.studentData}) : super(key: key);
  const BodyCompositionDisplayPage({Key? key}) : super(key: key);

  @override
  _BodyCompositionDisplayPageState createState() => _BodyCompositionDisplayPageState();
}

class _BodyCompositionDisplayPageState extends State<BodyCompositionDisplayPage> {

  final FirestoreService _firestoreService = FirestoreService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Map<String, dynamic>? studentData;
  String? userId;

  @override
  void initState() {
    super.initState();
    fetchAndLoadData();
  }

  Future<void> fetchAndLoadData() async {
    await fetchStudentData();  // Wait until studentData is fetched
    _fetchBodyCompositionData(); // Now fetch body composition data
  }



  Future<void> fetchStudentData() async {
    User? user = _auth.currentUser; // Get the logged-in user
    if (user != null) {
      userId = user.uid; // Get UID

      Map<String, dynamic>? data = await _firestoreService.getStudentData(userId!);
      if (data != null) {
        setState(() {
          studentData = data;
        });

        print("Student Data: $studentData");
      } else {
        print("Failed to fetch student data.");
      }
    } else {
      print("No user is logged in");
    }
  }



  // Medical theme colors
  final Color _primaryColor = Color(0xFF1E88E5); // Blue
  final Color _accentColor = Color(0xFF26A69A);  // Teal
  final Color _backgroundColor = Color(0xFFF5F5F7); // Light Gray
  final Color _cardColor = Colors.white;
  final Color _textColor = Color(0xFF37474F); // Dark Blue Gray

  bool _isLoading = true;
  Map<String, dynamic> _bodyCompositionData = {};




  void _fetchBodyCompositionData() async {
    if (studentData == null) return; // Ensure studentData is loaded

    setState(() => _isLoading = true);
    try {
      var regNo = studentData!['reg_no']; // Use fetched studentData
      print("Fetching data for reg no: $regNo");

      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('bodyComposition')
          .doc(regNo)
          .get();

      if (doc.exists && doc.data() != null) {
        setState(() {
          _bodyCompositionData = doc.data() as Map<String, dynamic>;
        });
      }
    } catch (e) {
      print("Error fetching body composition data: $e");
      _showErrorSnackBar("Failed to load data. Please try again.");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  String _getBMIClassification(double bmi) {
    if (bmi < 18.5) return 'Underweight';
    if (bmi < 25) return 'Normal Weight';
    if (bmi < 30) return 'Overweight';
    return 'Obesity';
  }

  Color _getBMIColor(double bmi) {
    if (bmi < 18.5) return Colors.blue;
    if (bmi < 25) return Colors.green;
    if (bmi < 30) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Body Composition Results',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: _primaryColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.white),
            onPressed: _fetchBodyCompositionData,
            tooltip: 'Refresh Data',
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: _primaryColor))
          : _bodyCompositionData.isEmpty
          ? Center(
        child: Text(
          'No body composition data available',
          style: TextStyle(
            fontSize: 18,
            color: _textColor,
          ),
        ),
      )
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPatientInfoCard(),
            const SizedBox(height: 16),

            _buildBMICard(),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(child: _buildMeasurementCard('Height', '${_bodyCompositionData['height']}', 'cm', Icons.height)),
                const SizedBox(width: 12),
                Expanded(child: _buildMeasurementCard('Weight', '${_bodyCompositionData['weight']}', 'kg', Icons.monitor_weight)),
              ],
            ),
            const SizedBox(height: 16),

            _buildBodyCompositionCard(),
            const SizedBox(height: 16),

            _buildMetabolismCard(),
            const SizedBox(height: 16),

            _buildAdditionalMeasurementsCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildPatientInfoCard() {
    String formattedDate = _bodyCompositionData['date'] ?? DateFormat('yyyy-MM-dd').format(DateTime.now());
    String patientName = studentData!['name'] ?? 'Patient';

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: _primaryColor.withOpacity(0.2),
                  radius: 24,
                  child: Icon(Icons.person, color: _primaryColor, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        patientName,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: _textColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Reg No: ${studentData!['reg_no'] ?? 'N/A'}',
                        style: TextStyle(
                          fontSize: 14,
                          color: _textColor.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Divider(),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 16, color: _accentColor),
                const SizedBox(width: 8),
                Text(
                  'Assessment Date: $formattedDate',
                  style: TextStyle(
                    fontSize: 14,
                    color: _textColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBMICard() {
    double bmi = double.tryParse(_bodyCompositionData['bmi'].toString()) ?? 0.0;
    String classification = _getBMIClassification(bmi);
    Color bmiColor = _getBMIColor(bmi);

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Body Mass Index (BMI)',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: _textColor,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                CircularPercentIndicator(
                  radius: 50,
                  lineWidth: 12,
                  percent: bmi / 40, // Using 40 as max value
                  center: Text(
                    bmi.toStringAsFixed(1),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: bmiColor,
                    ),
                  ),
                  progressColor: bmiColor,
                  backgroundColor: bmiColor.withOpacity(0.2),
                  animation: true,
                  animationDuration: 1000,
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        classification,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: bmiColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _getBMIDescription(classification),
                        style: TextStyle(
                          fontSize: 14,
                          color: _textColor.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            LinearPercentIndicator(
              padding: EdgeInsets.zero,
              lineHeight: 8,
              percent: 1.0,
              backgroundColor: Colors.transparent,
              progressColor: Colors.transparent,
              center: _buildBMIScaleIndicator(bmi),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBMIScaleIndicator(double bmi) {
    return Stack(
      children: [
        Container(
          height: 8,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            gradient: LinearGradient(
              colors: [Colors.blue, Colors.green, Colors.orange, Colors.red],
            ),
          ),
        ),
        Positioned(
          left: (bmi / 40) * 100 > 100 ? 100 : (bmi / 40) * 100,
          child: Icon(Icons.arrow_drop_down, color: _textColor, size: 20),
        ),
      ],
    );
  }

  String _getBMIDescription(String classification) {
    switch(classification) {
      case 'Underweight':
        return 'BMI is below the healthy range. Consider nutritional assessment.';
      case 'Normal Weight':
        return 'BMI is within the healthy range. Keep up the good work!';
      case 'Overweight':
        return 'BMI is above the healthy range. Consider lifestyle modifications.';
      case 'Obesity':
        return 'BMI indicates obesity. Consider medical intervention.';
      default:
        return '';
    }
  }

  Widget _buildMeasurementCard(String title, String value, String unit, IconData icon) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(icon, color: _primaryColor, size: 28),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: _textColor.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '$value $unit',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: _textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBodyCompositionCard() {
    double fatPercentage = _bodyCompositionData['fatPercentage'] ?? 0.0;
    double muscleMass = _bodyCompositionData['muscleMass'] ?? 0.0;
    double visceralFat = _bodyCompositionData['visceralFat'] ?? 0.0;

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Body Composition',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: _textColor,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildCompositionItem(
                    'Body Fat',
                    fatPercentage.toStringAsFixed(1),
                    '%',
                    fatPercentage / 100,
                    Colors.orange,
                  ),
                ),
                Expanded(
                  child: _buildCompositionItem(
                    'Muscle Mass',
                    muscleMass.toStringAsFixed(1),
                    '%',
                    muscleMass / 100,
                    Colors.purple,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildHorizontalProgressBar(
              'Visceral Fat Level',
              visceralFat,
              30, // Using 30 as max value
              Colors.red,
              '${visceralFat.toStringAsFixed(1)}',
              _getVisceralFatStatus(visceralFat),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompositionItem(String title, String value, String unit, double percent, Color color) {
    return Column(
      children: [
        CircularPercentIndicator(
          radius: 40,
          lineWidth: 8,
          percent: percent > 1.0 ? 1.0 : percent,
          center: Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: _textColor,
            ),
          ),
          progressColor: color,
          backgroundColor: color.withOpacity(0.2),
          animation: true,
          animationDuration: 1000,
        ),
        const SizedBox(height: 8),
        Text(
          '$title ($unit)',
          style: TextStyle(
            fontSize: 14,
            color: _textColor.withOpacity(0.7),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  String _getVisceralFatStatus(double level) {
    if (level < 10) return 'Healthy';
    if (level < 15) return 'High';
    return 'Very High';
  }

  Widget _buildMetabolismCard() {
    double bmr = _bodyCompositionData['bmr'] ?? 0.0;
    double tdee = _bodyCompositionData['tdee'] ?? 0.0;

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Metabolism',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: _textColor,
              ),
            ),
            const SizedBox(height: 16),
            _buildMetabolismItem('BMR (Basal Metabolic Rate)', bmr.toStringAsFixed(0), 'calories/day'),
            const SizedBox(height: 12),
            _buildMetabolismItem('TDEE (Total Daily Energy Expenditure)', tdee.toStringAsFixed(0), 'calories/day'),
          ],
        ),
      ),
    );
  }

  Widget _buildMetabolismItem(String title, String value, String unit) {
    return Row(
      children: [
        Icon(Icons.local_fire_department, color: _accentColor),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  color: _textColor,
                ),
              ),
              Text(
                '$value $unit',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: _textColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAdditionalMeasurementsCard() {
    double waistCircumference = _bodyCompositionData['waistCircumference'] ?? 0.0;
    double waistToHipRatio = _bodyCompositionData['waistToHipRatio'] ?? 0.0;

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Additional Measurements',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: _textColor,
              ),
            ),
            const SizedBox(height: 16),
            _buildHorizontalProgressBar(
              'Waist Circumference',
              waistCircumference,
              120, // Using 120 as max value
              _primaryColor,
              '${waistCircumference.toStringAsFixed(1)} cm',
              '',
            ),
            const SizedBox(height: 16),
            _buildHorizontalProgressBar(
              'Waist-to-Hip Ratio',
              waistToHipRatio,
              1.5, // Using 1.5 as max value
              _accentColor,
              waistToHipRatio.toStringAsFixed(2),
              _getWaistToHipRiskStatus(waistToHipRatio),
            ),
          ],
        ),
      ),
    );
  }

  String _getWaistToHipRiskStatus(double ratio) {
    if (ratio < 0.8) return 'Low Risk';
    if (ratio < 0.95) return 'Moderate Risk';
    return 'High Risk';
  }

  Widget _buildHorizontalProgressBar(
      String title,
      double value,
      double maxValue,
      Color color,
      String displayValue,
      String status,
      ) {
    double percentage = value / maxValue;
    if (percentage > 1.0) percentage = 1.0;
    if (percentage < 0.0) percentage = 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: _textColor,
              ),
            ),
            Row(
              children: [
                Text(
                  displayValue,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: _textColor,
                  ),
                ),
                if (status.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(left: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      status,
                      style: TextStyle(
                        fontSize: 12,
                        color: color,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearPercentIndicator(
          padding: EdgeInsets.zero,
          lineHeight: 8,
          percent: percentage,
          backgroundColor: color.withOpacity(0.2),
          progressColor: color,
          animation: true,
          animationDuration: 1000,
          barRadius: const Radius.circular(4),
        ),
      ],
    );
  }
}