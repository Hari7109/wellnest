import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class LaboratoryReportPage extends StatefulWidget {
  const LaboratoryReportPage({Key? key}) : super(key: key);

  @override
  State<LaboratoryReportPage> createState() => _LaboratoryReportPageState();
}

class _LaboratoryReportPageState extends State<LaboratoryReportPage> {
  bool _isLoading = true;
  String? _errorMessage;
  Map<String, dynamic>? _labData;

  @override
  void initState() {
    super.initState();
    _fetchLabData();
  }

  Future<void> _fetchLabData() async {
    try {
      // Get current user
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        setState(() {
          _errorMessage = "User not authenticated";
          _isLoading = false;
        });
        return;
      }

      // Get user document to find registration number
      final userDoc = await FirebaseFirestore.instance
          .collection("users")
          .doc(currentUser.uid)
          .get();

      if (!userDoc.exists) {
        setState(() {
          _errorMessage = "User profile not found";
          _isLoading = false;
        });
        return;
      }

      final regNo = userDoc.data()?['reg_no'];
      if (regNo == null) {
        setState(() {
          _errorMessage = "Registration number not found";
          _isLoading = false;
        });
        return;
      }

      // Get laboratory findings using the registration number
      final labDoc = await FirebaseFirestore.instance
          .collection("laboratory_findings")
          .doc(regNo)
          .get();

      if (!labDoc.exists) {
        setState(() {
          _errorMessage = "Laboratory report not found";
          _isLoading = false;
        });
        return;
      }

      setState(() {
        _labData = labDoc.data();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Laboratory Results'),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Laboratory Results'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  color: Colors.red[700],
                  size: 60,
                ),
                const SizedBox(height: 16),
                Text(
                  'Error',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.red[700],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _errorMessage!,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Please contact support if this issue persists.',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (_labData == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Laboratory Results'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.info_outline,
                  color: Colors.amber[700],
                  size: 60,
                ),
                const SizedBox(height: 16),
                Text(
                  'No Data Available',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.amber[700],
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'We couldn\'t find any laboratory results for your account. If you believe this is an error, please contact your healthcare provider.',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Format date
    String dateStr = "Not available";
    if (_labData!['timestamp'] != null) {
      try {
        final Timestamp timestamp = _labData!['timestamp'];
        dateStr = DateFormat('MMM d, yyyy').format(timestamp.toDate());
      } catch (e) {
        // Keep default value if date parsing fails
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Laboratory Report'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildReportHeader(dateStr),
              const SizedBox(height: 16),
              _buildCategorySection(
                'Blood Tests',
                Icons.bloodtype,
                Colors.red,
                ['blood_rbs', 'blood_urea', 'blood_tc', 'blood_hiv', 'blood_rh_type'],
              ),
              const SizedBox(height: 16),
              _buildCategorySection(
                'Thyroid Function Tests',
                Icons.monitor_heart,
                Colors.purple,
                ['tft_t3', 'tft_t4', 'tft_t3t4'],
              ),
              const SizedBox(height: 16),
              _buildCategorySection(
                'Urine Tests',
                Icons.opacity,
                Colors.amber,
                ['urine_albumin', 'urine_sugar', 'urine_microscopic'],
              ),
              const SizedBox(height: 16),
              _buildCategorySection(
                'Stool Tests',
                Icons.science,
                Colors.brown,
                ['stool_ova', 'stool_cyst'],
              ),
              const SizedBox(height: 24),
              _buildUnderstandingResultsCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReportHeader(String dateStr) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.blue[50],
          border: Border.all(color: Colors.blue[100]!),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Report Summary',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                Text(
                  'Date: $dateStr',
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Academic Year: ${_labData!['selected_year'] ?? 'Not specified'}',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategorySection(
      String title,
      IconData icon,
      Color iconColor,
      List<String> testKeys,
      ) {
    // Filter out any null values
    final tests = testKeys.where((key) => _labData![key] != null).toList();

    if (tests.isEmpty) {
      return Container(); // Don't show the section if no tests are available
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: iconColor, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...tests.map((test) => _buildTestItem(test)),
          ],
        ),
      ),
    );
  }

  Widget _buildTestItem(String test) {
    final value = _labData![test];
    if (value == null) return Container();

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _getTestDisplayName(test),
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: _getStatusColor(test, value),
                  ),
                ),
              ],
            ),
            if (_getInterpretation(test, value).isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text(
                  _getInterpretation(test, value),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildUnderstandingResultsCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.blue[50],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Understanding Your Results',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'This report provides a summary of your laboratory tests. Results in green are within normal ranges. '
                  'Yellow indicates values that may need monitoring, while red indicates values outside normal ranges that may '
                  'require attention. For any concerns about your results, please consult with your healthcare provider.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getTestDisplayName(String test) {
    switch (test) {
      case 'blood_rbs':
        return 'Blood Sugar';
      case 'blood_urea':
        return 'Blood Urea';
      case 'blood_tc':
        return 'White Blood Cell Count';
      case 'blood_hiv':
        return 'HIV Status';
      case 'blood_rh_type':
        return 'Blood Rh Factor';
      case 'tft_t3':
        return 'T3 Level';
      case 'tft_t4':
        return 'T4 Level';
      case 'tft_t3t4':
        return 'Thyroid Status';
      case 'urine_albumin':
        return 'Protein in Urine';
      case 'urine_sugar':
        return 'Sugar in Urine';
      case 'urine_microscopic':
        return 'Microscopic\nExamination';
      case 'stool_ova':
        return 'Parasite Eggs';
      case 'stool_cyst':
        return 'Parasite Cysts';
      default:
        return test
            .split('_')
            .map((word) => word[0].toUpperCase() + word.substring(1))
            .join(' ');
    }
  }

  Color _getStatusColor(String test, String value) {
    if (test == 'blood_rbs') {
      final numValue = double.tryParse(value.split(' ')[0]);
      if (numValue != null) {
        if (numValue < 70) return Colors.red;
        if (numValue > 140) return Colors.red;
        return Colors.green;
      }
    }

    if (test == 'blood_urea') {
      final numValue = double.tryParse(value.split(' ')[0]);
      if (numValue != null && numValue > 40) return Colors.red;
      return Colors.green;
    }

    if (test == 'tft_t3') {
      final numValue = double.tryParse(value.split(' ')[0]);
      if (numValue != null && (numValue < 0.8 || numValue > 2.0)) return Colors.red;
      return Colors.green;
    }

    if (test == 'tft_t4') {
      final numValue = double.tryParse(value.split(' ')[0]);
      if (numValue != null && (numValue < 5.1 || numValue > 14.1)) return Colors.red;
      return Colors.green;
    }

    if (test == 'urine_albumin' && value != 'Negative' && value != 'Absent') {
      return Colors.amber;
    }

    if (test == 'urine_sugar' && value != 'Negative') {
      return Colors.red;
    }

    // Default colors for positive/negative tests
    if (value == 'Negative' || value == 'Absent' || value == 'Normal' || value == 'No abnormalities') {
      return Colors.green;
    }

    return Colors.black87;
  }

  String _getInterpretation(String test, String value) {
    if (test == 'blood_rbs') {
      final numValue = double.tryParse(value.split(' ')[0]);
      if (numValue != null) {
        if (numValue < 70) return 'Low blood sugar (hypoglycemia)';
        if (numValue > 140) return 'Elevated blood sugar';
        return 'Normal range';
      }
    }

    if (test == 'blood_urea') {
      final numValue = double.tryParse(value.split(' ')[0]);
      if (numValue != null && numValue > 40) return 'Elevated - may indicate kidney issues';
      return 'Normal range';
    }

    if (test == 'blood_tc') {
      final numValue = double.tryParse(value.split(' ')[0]);
      if (numValue != null) {
        if (numValue < 4000) return 'Low white blood cell count';
        if (numValue > 11000) return 'Elevated white blood cell count';
        return 'Normal range';
      }
    }

    if (test == 'tft_t3t4') {
      return value == 'Normal' ? 'Thyroid function normal' : 'Thyroid function abnormal';
    }

    if (test == 'blood_hiv') {
      return value == 'Negative' ? 'No HIV infection detected' : 'Follow up required';
    }

    if (test == 'blood_rh_type') {
      return 'Rh ${value} blood type';
    }

    if (test == 'urine_albumin') {
      if (value == 'Trace') return 'Minor amount detected - monitor';
      if (value == 'Negative' || value == 'Absent') return 'Normal';
      return 'Protein in urine detected';
    }

    return '';
  }
}