import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EyeExaminationForm extends StatefulWidget {
  const EyeExaminationForm({Key? key}) : super(key: key);

  @override
  _EyeExaminationFormState createState() => _EyeExaminationFormState();
}

class _EyeExaminationFormState extends State<EyeExaminationForm> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final TextEditingController _rightVisionController = TextEditingController();
  final TextEditingController _leftVisionController = TextEditingController();
  final TextEditingController _reactionController = TextEditingController();
  final TextEditingController _remarksController = TextEditingController();

  @override
  void dispose() {
    // Dispose controllers
    _rightVisionController.dispose();
    _leftVisionController.dispose();
    _reactionController.dispose();
    _remarksController.dispose();
    super.dispose();
  }

  Future<void> _saveEyeExamination() async {
    if (_formKey.currentState!.validate()) {
      try {
        // Prepare examination data
        Map<String, dynamic> eyeExamData = {
          'right_vision': _rightVisionController.text,
          'left_vision': _leftVisionController.text,
          'pupil_reaction': _reactionController.text,
          'remarks': _remarksController.text,
          'timestamp': FieldValue.serverTimestamp(),
        };

        // Save to Firestore
        await FirebaseFirestore.instance
            .collection('eye_examinations')
            .add(eyeExamData);

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
          'Eye examination data has been successfully recorded.',
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
          'Failed to save eye examination: $error',
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
      backgroundColor: Colors.teal[50],
      appBar: AppBar(
        title: const Text('Eye Examination'),
        backgroundColor: Colors.teal[700],
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Right Vision Input
              _buildColorfulTextField(
                controller: _rightVisionController,
                labelText: 'Right Eye Vision',
                iconColor: Colors.blue,
                icon: Icons.remove_red_eye_outlined,
                keyboardType: TextInputType.number,
                validator: (value) =>
                value == null || value.isEmpty ? 'Right vision is required' : null,
              ),
              const SizedBox(height: 16),

              // Left Vision Input
              _buildColorfulTextField(
                controller: _leftVisionController,
                labelText: 'Left Eye Vision',
                iconColor: Colors.green,
                icon: Icons.remove_red_eye,
                keyboardType: TextInputType.number,
                validator: (value) =>
                value == null || value.isEmpty ? 'Left vision is required' : null,
              ),
              const SizedBox(height: 16),

              // Pupil Reaction Input
              _buildColorfulTextField(
                controller: _reactionController,
                labelText: 'Pupil Reaction',
                iconColor: Colors.orange,
                icon: Icons.remove_circle_outline,
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
                onPressed: _saveEyeExamination,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal[700],
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Save Eye Examination',
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
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
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