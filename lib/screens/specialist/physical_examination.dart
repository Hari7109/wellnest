import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_svg/flutter_svg.dart';

class PhysicalExaminationPage extends StatefulWidget {
  final Map<String, dynamic> studentData; // Accept student data

  const PhysicalExaminationPage({Key? key, required this.studentData}) : super(key: key);

  @override
  _PhysicalExaminationPageState createState() => _PhysicalExaminationPageState();
}

class _PhysicalExaminationPageState extends State<PhysicalExaminationPage> {
  final Map<String, TextEditingController> _controllers = {};
  final List<String> _categories = [
    'General', 'Appearance', 'Vital Signs', 'Temperature', 'Pulse',
    'Respiration', 'BP', 'Weight', 'Height', 'Integumentary System',
    'Neck', 'Cardiovascular System', 'Respiratory System',
    'Gastrointestinal System', 'Genitourinary System',
    'Musculoskeletal System', 'Central Nervous System', 'ECG', 'X-Ray'
  ];
  String _selectedYear = 'First Year';
  final List<String> _years = ['First Year', 'Second Year', 'Third Year', 'Fourth Year'];
  final TextEditingController _remarksController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    for (var category in _categories) {
      _controllers[category] = TextEditingController();
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    _remarksController.dispose();
    super.dispose();
  }

  Future<void> _saveData() async {
    if (_validateForm()) {
      setState(() {
        _isLoading = true;
      });

      try {

        String regNo = widget.studentData['reg_no'];
        
        Map<String, dynamic> data = {
          'year': _selectedYear,
          'date': DateTime.now().toIso8601String(),
          'remarks': _remarksController.text,
        };

        _controllers.forEach((key, controller) {
          data[key.toLowerCase().replaceAll(' ', '_')] = controller.text;
        });

        await FirebaseFirestore.instance.collection('physical_examinations').doc(regNo).set(data);

        _showSuccessDialog();
      } catch (e) {
        _showErrorDialog(e.toString());
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  bool _validateForm() {
    bool isValid = true;
    _controllers.forEach((key, controller) {
      if (controller.text.isEmpty) {
        isValid = false;
      }
    });

    if (!isValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please fill in all fields'),
          backgroundColor: Colors.red,
        ),
      );
    }

    return isValid;
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Success', style: TextStyle(color: Colors.green)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              'assets/success_icon.svg',
              height: 100,
              width: 100,
            ),
            SizedBox(height: 16),
            Text('Physical Examination data saved successfully!'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String error) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Error', style: TextStyle(color: Colors.red)),
        content: Text(error),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Close'),
          ),
        ],
      ),
    );
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
                  _buildYearSelector(),
                  SizedBox(height: 20),
                  _buildExaminationTable(),
                  SizedBox(height: 20),
                  _buildRemarksField(),
                  SizedBox(height: 20),
                  _buildSaveButton(),
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

  Widget _buildYearSelector() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.blue[50],
      ),
      child: DropdownButtonFormField<String>(
        value: _selectedYear,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          labelText: 'Select Year',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
        ),
        items: _years.map((year) {
          return DropdownMenuItem(
            value: year,
            child: Text(year, style: TextStyle(color: Colors.blue[800])),
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            _selectedYear = value.toString();
          });
        },
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
                      child: TextField(
                        controller: _controllers[category],
                        decoration: InputDecoration(
                          hintText: 'Enter $category',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
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

  Widget _buildRemarksField() {
    return TextField(
      controller: _remarksController,
      maxLines: 3,
      decoration: InputDecoration(
        labelText: 'Additional Remarks',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        filled: true,
        fillColor: Colors.blue[50],
      ),
    );
  }

  Widget _buildSaveButton() {
    return ElevatedButton(
      onPressed: _isLoading ? null : _saveData,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue[700],
        padding: EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: Text(
        'Save Examination Data',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}