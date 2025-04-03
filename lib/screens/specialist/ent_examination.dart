import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ENTExaminationForm extends StatefulWidget {
  const ENTExaminationForm({Key? key}) : super(key: key);

  @override
  _ENTExaminationFormState createState() => _ENTExaminationFormState();
}

class _ENTExaminationFormState extends State<ENTExaminationForm> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final TextEditingController _earController = TextEditingController();
  final TextEditingController _noseController = TextEditingController();
  final TextEditingController _sinusesController = TextEditingController();
  final TextEditingController _throatController = TextEditingController();
  final TextEditingController _remarksController = TextEditingController();

  @override
  void dispose() {
    // Dispose controllers
    _earController.dispose();
    _noseController.dispose();
    _sinusesController.dispose();
    _throatController.dispose();
    _remarksController.dispose();
    super.dispose();
  }

  Future<void> _saveENTExamination() async {
    if (_formKey.currentState!.validate()) {
      try {
        // Prepare examination data
        Map<String, dynamic> entExamData = {
          'ear_examination': _earController.text,
          'nose_examination': _noseController.text,
          'sinuses_examination': _sinusesController.text,
          'throat_examination': _throatController.text,
          'remarks': _remarksController.text,
          'timestamp': FieldValue.serverTimestamp(),
        };

        // Save to Firestore
        await FirebaseFirestore.instance
            .collection('ent_examinations')
            .add(entExamData);

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
          'Examination Saved',
          style: TextStyle(color: Colors.green[800], fontWeight: FontWeight.bold),
        ),
        content: Text(
          'ENT examination data has been successfully recorded.',
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
          'Failed to save ENT examination: $error',
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
      backgroundColor: Colors.blue[50],
      appBar: AppBar(
        title: const Text('ENT Examination'),
        backgroundColor: Colors.deepPurple,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Ear Examination Input
              _buildColorfulTextField(
                controller: _earController,
                labelText: 'Ear Examination',
                iconColor: Colors.blue,
                icon: Icons.hearing,
              ),
              const SizedBox(height: 16),

              // Nose Examination Input
              _buildColorfulTextField(
                controller: _noseController,
                labelText: 'Nose Examination',
                iconColor: Colors.green,
                icon: Icons.panorama_wide_angle,
              ),
              const SizedBox(height: 16),

              // Sinuses Examination Input
              _buildColorfulTextField(
                controller: _sinusesController,
                labelText: 'Sinuses Examination',
                iconColor: Colors.orange,
                icon: Icons.landscape,
              ),
              const SizedBox(height: 16),

              // Throat Examination Input
              _buildColorfulTextField(
                controller: _throatController,
                labelText: 'Throat Examination',
                iconColor: Colors.red,
                icon: Icons.mic,
              ),
              const SizedBox(height: 16),

              // Remarks Input
              _buildColorfulTextField(
                controller: _remarksController,
                labelText: 'Additional Remarks',
                iconColor: Colors.purple,
                icon: Icons.notes,
                maxLines: 3,
              ),
              const SizedBox(height: 24),

              // Save Button
              ElevatedButton(
                onPressed: _saveENTExamination,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Save ENT Examination',
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

  // Custom method to create colorful text fields
  Widget _buildColorfulTextField({
    required TextEditingController controller,
    required String labelText,
    required Color iconColor,
    required IconData icon,
    int maxLines = 2,
  }) {
    return TextFormField(
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
    );
  }
}