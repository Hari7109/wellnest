import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BodyCompositionViewPage extends StatefulWidget {
  final Map<String, dynamic> studentData;

  const BodyCompositionViewPage({Key? key, required this.studentData}) : super(key: key);

  @override
  _BodyCompositionViewPageState createState() => _BodyCompositionViewPageState();
}

class _BodyCompositionViewPageState extends State<BodyCompositionViewPage> {
  // Medical theme colors
  final Color _primaryColor = Color(0xFF1E88E5); // Blue
  final Color _accentColor = Color(0xFF26A69A);  // Teal
  final Color _backgroundColor = Color(0xFFF5F5F7); // Light Gray
  final Color _cardColor = Colors.white;
  final Color _textColor = Color(0xFF37474F); // Dark Blue Gray

  // Body composition data
  String _date = 'Not recorded';
  String _height = 'Not recorded';
  String _weight = 'Not recorded';
  String _bmi = 'Not recorded';
  String _fatPercentage = 'Not recorded';
  String _muscleMass = 'Not recorded';
  String _visceralFat = 'Not recorded';
  String _waistCircumference = 'Not recorded';
  String _waistToHipRatio = 'Not recorded';
  String _bmr = 'Not recorded';
  String _tdee = 'Not recorded';

  bool _isLoading = true;
  bool _hasData = false;

  @override
  void initState() {
    super.initState();
    _fetchBodyCompositionData();
  }

  void _fetchBodyCompositionData() async {
    setState(() => _isLoading = true);
    try {
      var regNo = widget.studentData['reg_no'];
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('bodyComposition')
          .doc(regNo)
          .get();

      if (doc.exists && doc.data() != null) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

        setState(() {
          _date = data['date'] ?? 'Not recorded';
          _height = data['height']?.toString() ?? 'Not recorded';
          _weight = data['weight']?.toString() ?? 'Not recorded';
          _bmi = data['bmi']?.toString() ?? 'Not recorded';
          _fatPercentage = data['fatPercentage']?.toString() ?? 'Not recorded';
          _muscleMass = data['muscleMass']?.toString() ?? 'Not recorded';
          _visceralFat = data['visceralFat']?.toString() ?? 'Not recorded';
          _waistCircumference = data['waistCircumference']?.toString() ?? 'Not recorded';
          _waistToHipRatio = data['waistToHipRatio']?.toString() ?? 'Not recorded';
          _bmr = data['bmr']?.toString() ?? 'Not recorded';
          _tdee = data['tdee']?.toString() ?? 'Not recorded';
          _hasData = true;
        });
      }
    } catch (e) {
      print("Error fetching body composition data: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Widget _getBMIInfo() {
    double? bmi = double.tryParse(_bmi);
    if (bmi == null) return SizedBox.shrink();

    String classification;
    Color color;

    if (bmi < 18.5) {
      classification = 'Underweight';
      color = Colors.blue;
    } else if (bmi < 25) {
      classification = 'Normal weight';
      color = Colors.green;
    } else if (bmi < 30) {
      classification = 'Overweight';
      color = Colors.orange;
    } else {
      classification = 'Obesity';
      color = Colors.red;
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(12),
          bottomRight: Radius.circular(12),
        ),
      ),
      child: Text(
        classification,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        title: const Text('Body Composition Assessment',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: _primaryColor,
        elevation: 0,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: _primaryColor))
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            if (!_hasData)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20.0),
                child: Text(
                  'No body composition data available',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[600],
                  ),
                ),
              ),
            if (_hasData) ...[
              // _buildHeader("Patient Health Assessment"),
              _buildInfoCard('Date', _date, Icons.calendar_today),
              const SizedBox(height: 16),

              _buildSectionHeader("Body Measurements"),
              Row(
                children: [
                  Expanded(child: _buildInfoCard('Height (cm)', _height, Icons.height)),
                  SizedBox(width: 8),
                  Expanded(child: _buildInfoCard('Weight (kg)', _weight, Icons.monitor_weight)),
                ],
              ),
              _buildInfoCardWithFooter('BMI', _bmi, Icons.assessment, _getBMIInfo()),
              _buildInfoCard('Fat Percentage (%)', _fatPercentage, Icons.analytics),
              _buildInfoCard('Muscle Mass (%)', _muscleMass, Icons.fitness_center),
              _buildInfoCard('Visceral Fat Level', _visceralFat, Icons.analytics),

              const SizedBox(height: 16),
              _buildSectionHeader("Additional Measurements"),
              _buildInfoCard('Waist Circumference (cm)', _waistCircumference, Icons.straighten),
              _buildInfoCard('Waist-to-Hip Ratio', _waistToHipRatio, Icons.accessibility_new),
              _buildInfoCard('BMR (calories)', _bmr, Icons.local_fire_department),
              _buildInfoCard('TDEE (calories)', _tdee, Icons.local_fire_department),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(String title) {
    return Container(
      margin: EdgeInsets.only(bottom: 20),
      padding: EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: _primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          title,
          style: TextStyle(
            color: _primaryColor,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: _primaryColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Divider(color: _primaryColor.withOpacity(0.3), thickness: 1),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String title, String value, IconData icon) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(icon, color: _primaryColor),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      color: _textColor.withOpacity(0.7),
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: _textColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCardWithFooter(String title, String value, IconData icon, Widget footer) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Icon(icon, color: _primaryColor),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 14,
                          color: _textColor.withOpacity(0.7),
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        value,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: _textColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          footer,
        ],
      ),
    );
  }
}