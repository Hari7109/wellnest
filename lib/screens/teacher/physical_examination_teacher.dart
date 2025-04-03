import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_svg/flutter_svg.dart';

class PhysicalExaminationPage extends StatefulWidget {
  final Map<String, dynamic> studentData;

  const PhysicalExaminationPage({Key? key, required this.studentData}) : super(key: key);

  @override
  _PhysicalExaminationPageState createState() => _PhysicalExaminationPageState();
}

class _PhysicalExaminationPageState extends State<PhysicalExaminationPage> {
  final Map<String, String> _examinationData = {};
  final List<String> _categories = [
    'General', 'Appearance', 'Vital Signs', 'Temperature', 'Pulse',
    'Respiration', 'BP', 'Weight', 'Height', 'Integumentary System',
    'Neck', 'Cardiovascular System', 'Respiratory System',
    'Gastrointestinal System', 'Genitourinary System',
    'Musculoskeletal System', 'Central Nervous System', 'ECG', 'X-Ray'
  ];
  String _selectedYear = 'First Year';
  final List<String> _years = ['First Year', 'Second Year', 'Third Year', 'Fourth Year'];
  String _remarks = '';
  bool _isLoading = true;
  bool _hasData = false;

  @override
  void initState() {
    super.initState();
    _fetchExistingData();
  }

  Future<void> _fetchExistingData() async {
    try {
      String regNo = widget.studentData['reg_no'];
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('physical_examinations')
          .doc(regNo)
          .get();

      if (snapshot.exists) {
        Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;

        setState(() {
          _selectedYear = data['year'] ?? 'First Year';
          _remarks = data['remarks'] ?? '';
          for (var category in _categories) {
            _examinationData[category] = data[category.toLowerCase().replaceAll(' ', '_')] ?? 'N/A';
          }
          _hasData = true;
        });
      }
    } catch (e) {
      print("Error fetching data: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Physical Examination', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.blue[700],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildYearDisplay(),
                  SizedBox(height: 20),
                  _buildExaminationTable(),
                  SizedBox(height: 20),
                  _buildRemarksDisplay(),
                ],
              ),
            ),
          ),
          if (_isLoading)
            Positioned.fill(
              child: Container(
                color: Colors.black54,
                child: Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildYearDisplay() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.blue[50],
      ),
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Text('Year: ', style: TextStyle(fontWeight: FontWeight.bold)),
          Text(_selectedYear, style: TextStyle(color: Colors.blue[800])),
        ],
      ),
    );
  }

  Widget _buildExaminationTable() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Examination Details',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue[800],
              ),
            ),
            SizedBox(height: 16),
            if (!_hasData && !_isLoading)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20.0),
                child: Text(
                  'No examination data available',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            if (_hasData)
              ListView.separated(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: _categories.length,
                separatorBuilder: (context, index) => Divider(color: Colors.grey[300]),
                itemBuilder: (context, index) {
                  final category = _categories[index];
                  return Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(
                          category,
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Text(
                            _examinationData[category] ?? 'N/A',
                            style: TextStyle(color: Colors.grey[700]),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildRemarksDisplay() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Remarks',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.blue[800],
              ),
            ),
            SizedBox(height: 8),
            Text(
              _remarks.isNotEmpty ? _remarks : 'No remarks available',
              style: TextStyle(color: Colors.grey[700]),
            ),
          ],
        ),
      ),
    );
  }
}