import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LaboratoryFindingsView extends StatefulWidget {
  final Map<String, dynamic> studentData;
  const LaboratoryFindingsView({Key? key, required this.studentData}) : super(key: key);

  @override
  _LaboratoryFindingsViewState createState() => _LaboratoryFindingsViewState();
}

class _LaboratoryFindingsViewState extends State<LaboratoryFindingsView> {
  String _selectedYear = 'Not specified';
  bool _isLoading = true;
  bool _hasData = false;

  // Blood Test Data
  String _bloodHb = 'Not recorded';
  String _bloodTC = 'Not recorded';
  String _bloodDC = 'Not recorded';
  String _bloodESR = 'Not recorded';

  // Urine Test Data
  String _urineAlbumin = 'Not recorded';
  String _urineSugar = 'Not recorded';
  String _urineMicroscopic = 'Not recorded';

  // Stool Test Data
  String _stoolOva = 'Not recorded';
  String _stoolCyst = 'Not recorded';

  // Blood Group Test Data
  String _bloodGrouping = 'Not recorded';
  String _bloodRhType = 'Not recorded';
  String _bloodRBS = 'Not recorded';
  String _bloodUrea = 'Not recorded';
  String _bloodHBsAg = 'Not recorded';
  String _bloodHIV = 'Not recorded';
  String _bloodHCV = 'Not recorded';

  // TFT Test Data
  String _tftT3 = 'Not recorded';
  String _tftT4 = 'Not recorded';
  String _tftT3T4 = 'Not recorded';

  @override
  void initState() {
    super.initState();
    _fetchLaboratoryFindings();
  }

  Future<void> _fetchLaboratoryFindings() async {
    try {
      String regNo = widget.studentData['reg_no'];
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('laboratory_findings')
          .doc(regNo)
          .get();

      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

        setState(() {
          _selectedYear = data['selected_year'] ?? 'Not specified';

          // Blood Test Data
          _bloodHb = data['blood_hb'] ?? 'Not recorded';
          _bloodTC = data['blood_tc'] ?? 'Not recorded';
          _bloodDC = data['blood_dc'] ?? 'Not recorded';
          _bloodESR = data['blood_esr'] ?? 'Not recorded';

          // Urine Test Data
          _urineAlbumin = data['urine_albumin'] ?? 'Not recorded';
          _urineSugar = data['urine_sugar'] ?? 'Not recorded';
          _urineMicroscopic = data['urine_microscopic'] ?? 'Not recorded';

          // Stool Test Data
          _stoolOva = data['stool_ova'] ?? 'Not recorded';
          _stoolCyst = data['stool_cyst'] ?? 'Not recorded';

          // Blood Group Test Data
          _bloodGrouping = data['blood_grouping'] ?? 'Not recorded';
          _bloodRhType = data['blood_rh_type'] ?? 'Not recorded';
          _bloodRBS = data['blood_rbs'] ?? 'Not recorded';
          _bloodUrea = data['blood_urea'] ?? 'Not recorded';
          _bloodHBsAg = data['blood_hbsag'] ?? 'Not recorded';
          _bloodHIV = data['blood_hiv'] ?? 'Not recorded';
          _bloodHCV = data['blood_hcv'] ?? 'Not recorded';

          // TFT Test Data
          _tftT3 = data['tft_t3'] ?? 'Not recorded';
          _tftT4 = data['tft_t4'] ?? 'Not recorded';
          _tftT3T4 = data['tft_t3t4'] ?? 'Not recorded';

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
      backgroundColor: Colors.indigo[50],
      appBar: AppBar(
        title: const Text('Laboratory Findings'),
        backgroundColor: Colors.indigo[700],
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
                  'No laboratory findings available',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[600],
                  ),
                ),
              ),
            if (_hasData) ...[
              // Year Display
              _buildInfoCard(
                title: 'Academic Year',
                value: _selectedYear,
                icon: Icons.calendar_today,
                color: Colors.indigo,
              ),
              const SizedBox(height: 16),

              // Blood Test Section
              _buildSectionTitle('Blood Test'),
              _buildInfoCard(
                title: 'Hemoglobin (Hb)',
                value: _bloodHb,
                icon: Icons.bloodtype,
                color: Colors.red,
              ),
              _buildInfoCard(
                title: 'TC',
                value: _bloodTC,
                icon: Icons.science,
                color: Colors.blue,
              ),
              _buildInfoCard(
                title: 'DC',
                value: _bloodDC,
                icon: Icons.science,
                color: Colors.green,
              ),
              _buildInfoCard(
                title: 'ESR',
                value: _bloodESR,
                icon: Icons.science,
                color: Colors.orange,
              ),

              // Urine Test Section
              _buildSectionTitle('Urine Test'),
              _buildInfoCard(
                title: 'Albumin',
                value: _urineAlbumin,
                icon: Icons.water_drop,
                color: Colors.purple,
              ),
              _buildInfoCard(
                title: 'Sugar',
                value: _urineSugar,
                icon: Icons.water_drop,
                color: Colors.pink,
              ),
              _buildInfoCard(
                title: 'Microscopic',
                value: _urineMicroscopic,
                icon: Icons.remove_red_eye,
                color: Colors.teal,
              ),

              // Stool Test Section
              _buildSectionTitle('Stool Test'),
              _buildInfoCard(
                title: 'Ova',
                value: _stoolOva,
                icon: Icons.bug_report,
                color: Colors.brown,
              ),
              _buildInfoCard(
                title: 'Cyst',
                value: _stoolCyst,
                icon: Icons.bubble_chart,
                color: Colors.deepOrange,
              ),

              // Blood Group Test Section
              _buildSectionTitle('Blood Group Test'),
              _buildInfoCard(
                title: 'Grouping',
                value: _bloodGrouping,
                icon: Icons.group,
                color: Colors.blue,
              ),
              _buildInfoCard(
                title: 'Rh-Type',
                value: _bloodRhType,
                icon: Icons.add,
                color: Colors.indigo,
              ),
              _buildInfoCard(
                title: 'RBS',
                value: _bloodRBS,
                icon: Icons.bloodtype,
                color: Colors.red,
              ),
              _buildInfoCard(
                title: 'Blood Urea',
                value: _bloodUrea,
                icon: Icons.water,
                color: Colors.green,
              ),
              _buildInfoCard(
                title: 'HBs.Ag',
                value: _bloodHBsAg,
                icon: Icons.science,
                color: Colors.amber,
              ),
              _buildInfoCard(
                title: 'HIV',
                value: _bloodHIV,
                icon: Icons.medical_services,
                color: Colors.red,
              ),
              _buildInfoCard(
                title: 'HCV',
                value: _bloodHCV,
                icon: Icons.medical_services,
                color: Colors.purple,
              ),

              // TFT Test Section
              _buildSectionTitle('TFT Test'),
              _buildInfoCard(
                title: 'T3',
                value: _tftT3,
                icon: Icons.science,
                color: Colors.cyan,
              ),
              _buildInfoCard(
                title: 'T4',
                value: _tftT4,
                icon: Icons.science,
                color: Colors.lime,
              ),
              _buildInfoCard(
                title: 'T3/4',
                value: _tftT3T4,
                icon: Icons.science,
                color: Colors.deepPurple,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.indigo[700],
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[700],
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
}