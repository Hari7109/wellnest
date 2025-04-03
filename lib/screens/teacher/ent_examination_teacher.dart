import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ENTExaminationView extends StatefulWidget {
  final Map<String, dynamic> studentData;
  const ENTExaminationView({Key? key, required this.studentData}) : super(key: key);

  @override
  _ENTExaminationViewState createState() => _ENTExaminationViewState();
}

class _ENTExaminationViewState extends State<ENTExaminationView> {
  String _earExam = 'Not recorded';
  String _noseExam = 'Not recorded';
  String _sinusesExam = 'Not recorded';
  String _throatExam = 'Not recorded';
  String _remarks = 'No remarks';
  bool _isLoading = true;
  bool _hasData = false;
  String regNo = "";

  @override
  void initState() {
    super.initState();
    regNo = widget.studentData['reg_no'];
    _fetchENTExamination();
  }

  Future<void> _fetchENTExamination() async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('ent_examinations')
          .doc(regNo)
          .get();

      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        setState(() {
          _earExam = data['ear_examination'] ?? 'Not recorded';
          _noseExam = data['nose_examination'] ?? 'Not recorded';
          _sinusesExam = data['sinuses_examination'] ?? 'Not recorded';
          _throatExam = data['throat_examination'] ?? 'Not recorded';
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
      backgroundColor: Colors.blue[50],
      appBar: AppBar(
        title: const Text('ENT Examination Record'),
        backgroundColor: Colors.deepPurple,
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
                  'No ENT examination data available',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[600],
                  ),
                ),
              ),
            if (_hasData) ...[
              _buildExamCard(
                title: 'Ear Examination',
                value: _earExam,
                icon: Icons.hearing,
                color: Colors.blue,
              ),
              const SizedBox(height: 16),
              _buildExamCard(
                title: 'Nose Examination',
                value: _noseExam,
                icon: Icons.panorama_wide_angle,
                color: Colors.green,
              ),
              const SizedBox(height: 16),
              _buildExamCard(
                title: 'Sinuses Examination',
                value: _sinusesExam,
                icon: Icons.landscape,
                color: Colors.orange,
              ),
              const SizedBox(height: 16),
              _buildExamCard(
                title: 'Throat Examination',
                value: _throatExam,
                icon: Icons.mic,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              _buildExamCard(
                title: 'Remarks',
                value: _remarks,
                icon: Icons.notes,
                color: Colors.purple,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildExamCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
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
                Icon(icon, color: color),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color,
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