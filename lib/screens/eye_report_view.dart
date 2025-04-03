import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class VisionExaminationPage extends StatefulWidget {
  const VisionExaminationPage({Key? key}) : super(key: key);

  @override
  State<VisionExaminationPage> createState() => _VisionExaminationPageState();
}

class _VisionExaminationPageState extends State<VisionExaminationPage> {
  bool _isLoading = true;
  String? _errorMessage;
  Map<String, dynamic>? _visionData;

  @override
  void initState() {
    super.initState();
    _fetchVisionData();
  }

  Future<void> _fetchVisionData() async {
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

      // Get vision examination data using the registration number
      // Assuming it's in a collection called "vision_examination"
      final visionDoc = await FirebaseFirestore.instance
          .collection("eye_examinations")
          .doc(regNo)
          .get();

      if (!visionDoc.exists) {
        setState(() {
          _errorMessage = "Vision examination report not found";
          _isLoading = false;
        });
        return;
      }

      setState(() {
        _visionData = visionDoc.data();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  // Visual acuity interpretation
  String _interpretVisualAcuity(String acuity) {
    // Split the value (e.g., "20/20")
    if (!acuity.contains('/')) return 'No interpretation available';

    final parts = acuity.split('/');
    if (parts.length != 2) return 'No interpretation available';

    final numerator = int.tryParse(parts[0]);
    final denominator = int.tryParse(parts[1]);

    if (numerator == null || denominator == null) {
      return 'No interpretation available';
    }

    // Interpret based on standard vision scales
    if (numerator <= 20 && denominator <= 20) {
      return 'Normal vision (20/20 or better)';
    } else if (numerator <= 20 && denominator <= 40) {
      return 'Near normal vision';
    } else if (numerator <= 20 && denominator <= 60) {
      return 'Mild vision impairment';
    } else if (numerator <= 20 && denominator <= 200) {
      return 'Moderate vision impairment';
    } else {
      return 'Severe vision impairment';
    }
  }

  // Get status color for visual acuity
  Color _getVisionStatusColor(String acuity) {
    if (!acuity.contains('/')) return Colors.grey;

    final parts = acuity.split('/');
    if (parts.length != 2) return Colors.grey;

    final numerator = int.tryParse(parts[0]);
    final denominator = int.tryParse(parts[1]);

    if (numerator == null || denominator == null) {
      return Colors.grey;
    }

    if (numerator <= 20 && denominator <= 20) {
      return Colors.green;
    } else if (numerator <= 20 && denominator <= 40) {
      return Colors.green[700]!;
    } else if (numerator <= 20 && denominator <= 60) {
      return Colors.amber;
    } else if (numerator <= 20 && denominator <= 200) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Vision Examination'),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Vision Examination'),
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

    if (_visionData == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Vision Examination'),
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
                  'We couldn\'t find any vision examination results for your account. If you believe this is an error, please contact your healthcare provider.',
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
    if (_visionData!['timestamp'] != null) {
      try {
        final Timestamp timestamp = _visionData!['timestamp'];
        dateStr = DateFormat('MMM d, yyyy').format(timestamp.toDate());
      } catch (e) {
        // Keep default value if date parsing fails
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Vision Examination'),
        backgroundColor: Colors.indigo,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildReportHeader(dateStr),
              const SizedBox(height: 16),
              _buildVisionCard(),
              const SizedBox(height: 16),
              _buildPupilResponseCard(),
              const SizedBox(height: 16),
              _buildRemarksCard(),
              const SizedBox(height: 24),
              _buildInformationCard(),
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
          color: Colors.indigo[50],
          border: Border.all(color: Colors.indigo[100]!),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Vision Examination Report',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.indigo,
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
      ),
    );
  }

  Widget _buildVisionCard() {
    final rightVision = _visionData!['right_vision'] ?? 'Not tested';
    final leftVision = _visionData!['left_vision'] ?? 'Not tested';

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
              children: const [
                Icon(Icons.remove_red_eye, color: Colors.indigo, size: 20),
                SizedBox(width: 8),
                Text(
                  'Visual Acuity',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            IntrinsicHeight(
              child: Row(
                children: [
                  Expanded(
                    child: _buildEyeVisualAcuity('Right Eye', rightVision),
                  ),
                  const VerticalDivider(
                    color: Colors.grey,
                    thickness: 1,
                  ),
                  Expanded(
                    child: _buildEyeVisualAcuity('Left Eye', leftVision),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEyeVisualAcuity(String eyeName, String acuity) {
    return Column(
      children: [
        Text(
          eyeName,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          acuity,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: _getVisionStatusColor(acuity),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _interpretVisualAcuity(acuity),
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildPupilResponseCard() {
    final pupilReaction = _visionData!['pupil_reaction'] ?? 'Not tested';

    // Determine color based on the result
    Color statusColor = Colors.grey;
    if (pupilReaction.toLowerCase().contains('normal') ||
        pupilReaction.toLowerCase().contains('reactive')) {
      statusColor = Colors.green;
    } else if (pupilReaction.toLowerCase().contains('sluggish')) {
      statusColor = Colors.amber;
    } else if (pupilReaction.toLowerCase().contains('non') ||
        pupilReaction.toLowerCase().contains('unreactive')) {
      statusColor = Colors.red;
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
              children: const [
                Icon(Icons.brightness_5, color: Colors.amber, size: 20),
                SizedBox(width: 8),
                Text(
                  'Pupil Response',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    pupilReaction,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: statusColor,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    pupilReaction.toLowerCase().contains('normal') ?
                    'Normal pupillary response indicates healthy neurological function' :
                    'Pupillary response is an important indicator of neurological health',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
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

  Widget _buildRemarksCard() {
    final remarks = _visionData!['remarks'] ?? 'No remarks provided.';

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
              children: const [
                Icon(Icons.comment, color: Colors.teal, size: 20),
                SizedBox(width: 8),
                Text(
                  'Examiner\'s Remarks',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.teal.withOpacity(0.3)),
              ),
              child: Text(
                remarks,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInformationCard() {
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
          color: Colors.indigo[50],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Understanding Visual Acuity',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.indigo,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Visual acuity is typically measured using a Snellen chart. The standard notation (e.g., 20/20) '
                  'represents your vision compared to what a person with normal vision can see from the same distance. '
                  'For example, 20/40 means you can see at 20 feet what a person with normal vision can see at 40 feet. '
                  'If you have concerns about your vision, please consult with an eye care professional.',
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
}