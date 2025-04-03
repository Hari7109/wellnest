import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EyeExaminationView extends StatefulWidget {
  final Map<String, dynamic> studentData;
  const EyeExaminationView({Key? key, required this.studentData}) : super(key: key);

  @override
  _EyeExaminationViewState createState() => _EyeExaminationViewState();
}

class _EyeExaminationViewState extends State<EyeExaminationView> {
  String _rightVision = 'Not recorded';
  String _leftVision = 'Not recorded';
  String _pupilReaction = 'Not recorded';
  String _remarks = 'No remarks';
  bool _isLoading = true;
  bool _hasData = false;

  @override
  void initState() {
    super.initState();
    _fetchExistingData();
  }

  Future<void> _fetchExistingData() async {
    String regNo = widget.studentData['reg_no'];

    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('eye_examinations')
          .doc(regNo)
          .get();

      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

        setState(() {
          _rightVision = data['right_vision'] ?? 'Not recorded';
          _leftVision = data['left_vision'] ?? 'Not recorded';
          _pupilReaction = data['pupil_reaction'] ?? 'Not recorded';
          _remarks = data['remarks'] ?? 'No remarks';
          _hasData = true;
        });
      }
    } catch (e) {
      print('Error fetching data: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal[50],
      appBar: AppBar(
        title: const Text('Eye Examination Record'),
        backgroundColor: Colors.teal[700],
        elevation: 0,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (!_hasData)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20.0),
                child: Text(
                  'No eye examination data available',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[600],
                  ),
                ),
              ),
            if (_hasData) ...[
              _buildInfoCard(
                title: 'Right Eye Vision',
                value: _rightVision,
                icon: Icons.remove_red_eye_outlined,
                iconColor: Colors.blue,
              ),
              const SizedBox(height: 16),
              _buildInfoCard(
                title: 'Left Eye Vision',
                value: _leftVision,
                icon: Icons.remove_red_eye,
                iconColor: Colors.green,
              ),
              const SizedBox(height: 16),
              _buildInfoCard(
                title: 'Pupil Reaction',
                value: _pupilReaction,
                icon: Icons.remove_circle_outline,
                iconColor: Colors.orange,
              ),
              const SizedBox(height: 16),
              _buildInfoCard(
                title: 'Remarks',
                value: _remarks,
                icon: Icons.notes,
                iconColor: Colors.purple,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required String value,
    required IconData icon,
    required Color iconColor,
  }) {
    return Card(
      elevation: 3,
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
                Icon(icon, color: iconColor),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: iconColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.only(left: 32.0),
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey[700],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}