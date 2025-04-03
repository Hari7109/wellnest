import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LaboratoryFindingsForm extends StatefulWidget {
  const LaboratoryFindingsForm({Key? key}) : super(key: key);

  @override
  _LaboratoryFindingsFormState createState() => _LaboratoryFindingsFormState();
}

class _LaboratoryFindingsFormState extends State<LaboratoryFindingsForm> {
  final _formKey = GlobalKey<FormState>();

  // Year selection
  final List<String> _years = ['First Year', 'Second Year', 'Third Year', 'Fourth Year'];
  String? _selectedYear;

  // Blood Test Controllers
  final TextEditingController _bloodHbController = TextEditingController();
  final TextEditingController _bloodTCController = TextEditingController();
  final TextEditingController _bloodDCController = TextEditingController();
  final TextEditingController _bloodESRController = TextEditingController();

  // Urine Test Controllers
  final TextEditingController _urineAlbuminController = TextEditingController();
  final TextEditingController _urineSugarController = TextEditingController();
  final TextEditingController _urineMicroscopicController = TextEditingController();

  // Stool Test Controllers
  final TextEditingController _stoolOvaController = TextEditingController();
  final TextEditingController _stoolCystController = TextEditingController();

  // Blood Group Test Controllers
  final TextEditingController _bloodGroupingController = TextEditingController();
  final TextEditingController _bloodRhTypeController = TextEditingController();
  final TextEditingController _bloodRBSController = TextEditingController();
  final TextEditingController _bloodUreaController = TextEditingController();
  final TextEditingController _bloodHBsAgController = TextEditingController();
  final TextEditingController _bloodHIVController = TextEditingController();
  final TextEditingController _bloodHCVController = TextEditingController();

  // TFT Test Controllers
  final TextEditingController _tftT3Controller = TextEditingController();
  final TextEditingController _tftT4Controller = TextEditingController();
  final TextEditingController _tftT3T4Controller = TextEditingController();

  @override
  void dispose() {
    // Dispose all controllers
    _bloodHbController.dispose();
    _bloodTCController.dispose();
    _bloodDCController.dispose();
    _bloodESRController.dispose();
    _urineAlbuminController.dispose();
    _urineSugarController.dispose();
    _urineMicroscopicController.dispose();
    _stoolOvaController.dispose();
    _stoolCystController.dispose();
    _bloodGroupingController.dispose();
    _bloodRhTypeController.dispose();
    _bloodRBSController.dispose();
    _bloodUreaController.dispose();
    _bloodHBsAgController.dispose();
    _bloodHIVController.dispose();
    _bloodHCVController.dispose();
    _tftT3Controller.dispose();
    _tftT4Controller.dispose();
    _tftT3T4Controller.dispose();
    super.dispose();
  }

  Future<void> _saveLaboratoryFindings() async {
    if (_formKey.currentState!.validate()) {
      try {
        // Prepare laboratory findings data
        Map<String, dynamic> labFindingsData = {
          'selected_year': _selectedYear,

          // Blood Test Data
          'blood_hb': _bloodHbController.text,
          'blood_tc': _bloodTCController.text,
          'blood_dc': _bloodDCController.text,
          'blood_esr': _bloodESRController.text,

          // Urine Test Data
          'urine_albumin': _urineAlbuminController.text,
          'urine_sugar': _urineSugarController.text,
          'urine_microscopic': _urineMicroscopicController.text,

          // Stool Test Data
          'stool_ova': _stoolOvaController.text,
          'stool_cyst': _stoolCystController.text,

          // Blood Group Test Data
          'blood_grouping': _bloodGroupingController.text,
          'blood_rh_type': _bloodRhTypeController.text,
          'blood_rbs': _bloodRBSController.text,
          'blood_urea': _bloodUreaController.text,
          'blood_hbsag': _bloodHBsAgController.text,
          'blood_hiv': _bloodHIVController.text,
          'blood_hcv': _bloodHCVController.text,

          // TFT Test Data
          'tft_t3': _tftT3Controller.text,
          'tft_t4': _tftT4Controller.text,
          'tft_t3t4': _tftT3T4Controller.text,

          'timestamp': FieldValue.serverTimestamp(),
        };

        // Save to Firestore
        await FirebaseFirestore.instance
            .collection('laboratory_findings')
            .add(labFindingsData);

        // Show success dialog
        _showSuccessDialog();
      } catch (e) {
        // Show error dialog
        _showErrorDialog(e.toString());
      }
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.green[50],
        title: Text(
          'Laboratory Findings Saved',
          style: TextStyle(color: Colors.green[800], fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Laboratory findings for $_selectedYear have been successfully recorded.',
          style: TextStyle(color: Colors.green[700]),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK', style: TextStyle(color: Colors.green[800])),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String error) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.red[50],
        title: Text(
          'Error',
          style: TextStyle(color: Colors.red[800], fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Failed to save laboratory findings: $error',
          style: TextStyle(color: Colors.red[700]),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Close', style: TextStyle(color: Colors.red[800])),
          ),
        ],
      ),
    );
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Year Selection Dropdown
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Select Year',
                    prefixIcon: Icon(Icons.calendar_today, color: Colors.indigo[700]),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  value: _selectedYear,
                  items: _years.map((year) =>
                      DropdownMenuItem(
                        value: year,
                        child: Text(year),
                      )
                  ).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedYear = value;
                    });
                  },
                  validator: (value) =>
                  value == null ? 'Please select a year' : null,
                ),
              ),

              // Blood Test Section
              _buildSectionTitle('Blood Test'),
              _buildColorfulTextField(
                controller: _bloodHbController,
                labelText: 'Hemoglobin (Hb)',
                iconColor: Colors.red,
                icon: Icons.bloodtype,
              ),
              _buildColorfulTextField(
                controller: _bloodTCController,
                labelText: 'TC',
                iconColor: Colors.blue,
                icon: Icons.science,
              ),
              _buildColorfulTextField(
                controller: _bloodDCController,
                labelText: 'DC',
                iconColor: Colors.green,
                icon: Icons.science,
              ),
              _buildColorfulTextField(
                controller: _bloodESRController,
                labelText: 'ESR',
                iconColor: Colors.orange,
                icon: Icons.science,
              ),

              // Urine Test Section
              _buildSectionTitle('Urine Test'),
              _buildColorfulTextField(
                controller: _urineAlbuminController,
                labelText: 'Albumin',
                iconColor: Colors.purple,
                icon: Icons.water_drop,
              ),
              _buildColorfulTextField(
                controller: _urineSugarController,
                labelText: 'Sugar',
                iconColor: Colors.pink,
                icon: Icons.water_drop,
              ),
              _buildColorfulTextField(
                controller: _urineMicroscopicController,
                labelText: 'Microscopic',
                iconColor: Colors.teal,
                icon: Icons.remove_red_eye,
              ),

              // Stool Test Section
              _buildSectionTitle('Stool Test'),
              _buildColorfulTextField(
                controller: _stoolOvaController,
                labelText: 'Ova',
                iconColor: Colors.brown,
                icon: Icons.bug_report,
              ),
              _buildColorfulTextField(
                controller: _stoolCystController,
                labelText: 'Cyst',
                iconColor: Colors.deepOrange,
                icon: Icons.bubble_chart,
              ),

              // Blood Group Test Section
              _buildSectionTitle('Blood Group Test'),
              _buildColorfulTextField(
                controller: _bloodGroupingController,
                labelText: 'Grouping',
                iconColor: Colors.blue,
                icon: Icons.group,
              ),
              _buildColorfulTextField(
                controller: _bloodRhTypeController,
                labelText: 'Rh-Type',
                iconColor: Colors.indigo,
                icon: Icons.add,
              ),
              _buildColorfulTextField(
                controller: _bloodRBSController,
                labelText: 'RBS',
                iconColor: Colors.red,
                icon: Icons.bloodtype,
              ),
              _buildColorfulTextField(
                controller: _bloodUreaController,
                labelText: 'Blood Urea',
                iconColor: Colors.green,
                icon: Icons.water,
              ),
              _buildColorfulTextField(
                controller: _bloodHBsAgController,
                labelText: 'HBs.Ag',
                iconColor: Colors.amber,
                icon: Icons.science,
              ),
              _buildColorfulTextField(
                controller: _bloodHIVController,
                labelText: 'HIV',
                iconColor: Colors.red,
                icon: Icons.medical_services,
              ),
              _buildColorfulTextField(
                controller: _bloodHCVController,
                labelText: 'HCV',
                iconColor: Colors.purple,
                icon: Icons.medical_services,
              ),

              // TFT Test Section
              _buildSectionTitle('TFT Test'),
              _buildColorfulTextField(
                controller: _tftT3Controller,
                labelText: 'T3',
                iconColor: Colors.cyan,
                icon: Icons.science,
              ),
              _buildColorfulTextField(
                controller: _tftT4Controller,
                labelText: 'T4',
                iconColor: Colors.lime,
                icon: Icons.science,
              ),
              _buildColorfulTextField(
                controller: _tftT3T4Controller,
                labelText: 'T3/4',
                iconColor: Colors.deepPurple,
                icon: Icons.science,
              ),

              const SizedBox(height: 24),

              // Save Button
              ElevatedButton(
                onPressed: _saveLaboratoryFindings,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo[700],
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Save Laboratory Findings',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Section Title Widget
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
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

  // Custom method to create colorful text fields
  Widget _buildColorfulTextField({
    required TextEditingController controller,
    required String labelText,
    required Color iconColor,
    required IconData icon,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: labelText,
          prefixIcon: Icon(icon, color: iconColor),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: iconColor, width: 2),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: iconColor.withOpacity(0.5), width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: iconColor, width: 2),
          ),
          labelStyle: TextStyle(color: iconColor),
        ),
      ),
    );
  }
}