import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:albertian_wellnest/screens/specialist/update_health_details.dart';

class BodyCompositionFormPage extends StatefulWidget {
  final Map<String, dynamic> studentData; // Accept student data


  const BodyCompositionFormPage({Key? key, required this.studentData}) : super(key: key);

  @override
  _BodyCompositionFormPageState createState() => _BodyCompositionFormPageState();
}

class _BodyCompositionFormPageState extends State<BodyCompositionFormPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _bmiController = TextEditingController();
  final TextEditingController _fatPercentageController = TextEditingController();
  final TextEditingController _muscleMassController = TextEditingController();
  final TextEditingController _visceralFatController = TextEditingController();
  final TextEditingController _waistCircumferenceController = TextEditingController();
  final TextEditingController _waistToHipRatioController = TextEditingController();
  final TextEditingController _bmrController = TextEditingController();
  final TextEditingController _tdeeController = TextEditingController();

  // Medical theme colors
  final Color _primaryColor = Color(0xFF1E88E5); // Blue
  final Color _accentColor = Color(0xFF26A69A);  // Teal
  final Color _backgroundColor = Color(0xFFF5F5F7); // Light Gray
  final Color _cardColor = Colors.white;
  final Color _textColor = Color(0xFF37474F); // Dark Blue Gray

  bool _isLoading = true;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _dateController.text = DateFormat('yyyy-MM-dd').format(_selectedDate);
    print("Received student data: ${widget.studentData}");


    _fetchBodyCompositionData();
  }

  @override
  void dispose() {
    _dateController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _bmiController.dispose();
    _fatPercentageController.dispose();
    _muscleMassController.dispose();
    _visceralFatController.dispose();
    _waistCircumferenceController.dispose();
    _waistToHipRatioController.dispose();
    _bmrController.dispose();
    _tdeeController.dispose();
    super.dispose();
  }

  void _fetchBodyCompositionData() async {
    setState(() => _isLoading = true);
    try {
      var regNo = widget.studentData['reg_no'];
      print("Received student data in reg: ${regNo}");

      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('bodyComposition')
          .doc(regNo)
          .get();

      if (doc.exists && doc.data() != null) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

        setState(() {
          _heightController.text = data['height']?.toString() ?? '0.0';
          _weightController.text = data['weight']?.toString() ?? '0.0';
          _bmiController.text = data['bmi']?.toString() ?? '0.0';
          _fatPercentageController.text = data['fatPercentage']?.toString() ?? '0.0';
          _muscleMassController.text = data['muscleMass']?.toString() ?? '0.0';
          _visceralFatController.text = data['visceralFat']?.toString() ?? '0.0';
          _waistCircumferenceController.text = data['waistCircumference']?.toString() ?? '0.0';
          _waistToHipRatioController.text = data['waistToHipRatio']?.toString() ?? '0.0';
          _bmrController.text = data['bmr']?.toString() ?? '0.0';
          _tdeeController.text = data['tdee']?.toString() ?? '0.0';

          // If there's a date in the data, use it
          if (data['date'] != null) {
            _dateController.text = data['date'];
            _selectedDate = DateFormat('yyyy-MM-dd').parse(data['date']);
          }
        });
      }
    } catch (e) {
      print("Error fetching body composition data: $e");
      _showErrorSnackBar("Failed to load data. Please try again.");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _calculateBMI() {
    // Only calculate if both height and weight are available
    if (_heightController.text.isNotEmpty && _weightController.text.isNotEmpty) {
      double height = double.tryParse(_heightController.text) ?? 0;
      double weight = double.tryParse(_weightController.text) ?? 0;

      if (height > 0 && weight > 0) {
        // Convert height from cm to meters
        double heightInMeters = height / 100;
        // Calculate BMI
        double bmi = weight / (heightInMeters * heightInMeters);
        _bmiController.text = bmi.toStringAsFixed(1);
      }
    }
  }

  void _saveBodyCompositionData() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        var regNo = widget.studentData['reg_no'];

        await FirebaseFirestore.instance.collection('bodyComposition').doc(regNo).set({
          'date': _dateController.text,
          'height': double.tryParse(_heightController.text) ?? 0.0,
          'weight': double.tryParse(_weightController.text) ?? 0.0,
          'bmi': double.tryParse(_bmiController.text) ?? 0.0,
          'fatPercentage': double.tryParse(_fatPercentageController.text) ?? 0.0,
          'muscleMass': double.tryParse(_muscleMassController.text) ?? 0.0,
          'visceralFat': double.tryParse(_visceralFatController.text) ?? 0.0,
          'waistCircumference': double.tryParse(_waistCircumferenceController.text) ?? 0.0,
          'waistToHipRatio': double.tryParse(_waistToHipRatioController.text) ?? 0.0,
          'bmr': double.tryParse(_bmrController.text) ?? 0.0,
          'tdee': double.tryParse(_tdeeController.text) ?? 0.0,
        });
        _showSuccessSnackBar('Body composition data saved successfully');
      } catch (e) {
        print("Error saving body composition data: $e");
        _showErrorSnackBar("Failed to save data. Please try again.");
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: _accentColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: _primaryColor,
              onPrimary: Colors.white,
              surface: _cardColor,
              onSurface: _textColor,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = DateFormat('yyyy-MM-dd').format(_selectedDate);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        title: const Text('Body Composition Assessment',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: _primaryColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.white),
            onPressed: _fetchBodyCompositionData,
            tooltip: 'Refresh Data',
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: _primaryColor))
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildHeader("Patient Health Assessment"),
              _buildDateField(),
              const SizedBox(height: 16),

              _buildSectionHeader("Body Measurements"),
              _buildNumberFieldRow('Height (cm)', _heightController, 'Weight (kg)', _weightController),
              _buildCalculateButton(),
              _buildNumberFieldWithInfo('BMI', _bmiController, _getBMIInfo()),
              _buildNumberField('Fat Percentage (%)', _fatPercentageController),
              _buildNumberField('Muscle Mass (%)', _muscleMassController),
              _buildNumberField('Visceral Fat Level', _visceralFatController),

              const SizedBox(height: 16),
              _buildSectionHeader("Additional Measurements"),
              _buildNumberField('Waist Circumference (cm)', _waistCircumferenceController),
              _buildNumberField('Waist-to-Hip Ratio', _waistToHipRatioController),
              _buildNumberField('BMR (calories)', _bmrController),
              _buildNumberField('TDEE (calories)', _tdeeController),

              const SizedBox(height: 24),
              _buildSaveButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(String title) {
    return Container(
      margin: EdgeInsets.only(bottom: 20),
      padding: EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: _primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          title,
          style: TextStyle(
            color: _primaryColor,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: _primaryColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Divider(color: _primaryColor.withOpacity(0.3), thickness: 1),
        ],
      ),
    );
  }

  Widget _buildDateField() {
    return Card(
      elevation: 2,
      margin: EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: TextFormField(
          controller: _dateController,
          decoration: InputDecoration(
            labelText: 'Date',
            labelStyle: TextStyle(color: _textColor),
            border: InputBorder.none,
            prefixIcon: Icon(Icons.calendar_today, color: _primaryColor),
            suffixIcon: IconButton(
              icon: Icon(Icons.edit, color: _accentColor),
              onPressed: () => _selectDate(context),
            ),
          ),
          readOnly: true,
          onTap: () => _selectDate(context),
        ),
      ),
    );
  }

  Widget _buildNumberField(String label, TextEditingController controller) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: TextFormField(
          controller: controller,
          keyboardType: TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            labelText: label,
            labelStyle: TextStyle(color: _textColor),
            border: InputBorder.none,
            prefixIcon: Icon(_getIconForField(label), color: _primaryColor),
          ),
          validator: (value) => value!.isEmpty ? 'Enter $label' : null,
        ),
      ),
    );
  }

  Widget _buildNumberFieldWithInfo(String label, TextEditingController controller, Widget infoWidget) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
              controller: controller,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: label,
                labelStyle: TextStyle(color: _textColor),
                border: InputBorder.none,
                prefixIcon: Icon(_getIconForField(label), color: _primaryColor),
              ),
              validator: (value) => value!.isEmpty ? 'Enter $label' : null,
            ),
          ),
          infoWidget,
        ],
      ),
    );
  }

  Widget _buildNumberFieldRow(String label1, TextEditingController controller1,
      String label2, TextEditingController controller2) {
    return Row(
      children: [
        Expanded(
          child: Card(
            elevation: 2,
            margin: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                controller: controller1,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: label1,
                  labelStyle: TextStyle(color: _textColor),
                  border: InputBorder.none,
                  prefixIcon: Icon(_getIconForField(label1), color: _primaryColor),
                ),
                validator: (value) => value!.isEmpty ? 'Required' : null,
                onChanged: (_) => _calculateBMI(),
              ),
            ),
          ),
        ),
        Expanded(
          child: Card(
            elevation: 2,
            margin: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                controller: controller2,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: label2,
                  labelStyle: TextStyle(color: _textColor),
                  border: InputBorder.none,
                  prefixIcon: Icon(_getIconForField(label2), color: _primaryColor),
                ),
                validator: (value) => value!.isEmpty ? 'Required' : null,
                onChanged: (_) => _calculateBMI(),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCalculateButton() {
    return Container(
      margin: EdgeInsets.only(top: 4, bottom: 12),
      alignment: Alignment.centerRight,
      child: TextButton.icon(
        icon: Icon(Icons.calculate, size: 18, color: _accentColor),
        label: Text('Calculate BMI', style: TextStyle(color: _accentColor)),
        onPressed: _calculateBMI,
      ),
    );
  }

  Widget _getBMIInfo() {
    double? bmi = double.tryParse(_bmiController.text);
    if (bmi == null) return SizedBox.shrink();

    String classification;
    Color color;

    if (bmi < 18.5) {
      classification = 'Underweight';
      color = Colors.blue;
    } else if (bmi < 25) {
      classification = 'Normal weight';
      color = Colors.green;
    } else if (bmi < 30) {
      classification = 'Overweight';
      color = Colors.orange;
    } else {
      classification = 'Obesity';
      color = Colors.red;
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(12),
          bottomRight: Radius.circular(12),
        ),
      ),
      child: Text(
        classification,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return ElevatedButton(
      onPressed: _saveBodyCompositionData,
      style: ElevatedButton.styleFrom(
        backgroundColor: _accentColor,
        padding: EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Text(
        'SAVE ASSESSMENT',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }

  IconData _getIconForField(String fieldName) {
    if (fieldName.contains('Height')) return Icons.height;
    if (fieldName.contains('Weight')) return Icons.monitor_weight;
    if (fieldName.contains('BMI')) return Icons.assessment;
    if (fieldName.contains('Fat')) return Icons.analytics;
    if (fieldName.contains('Muscle')) return Icons.fitness_center;
    if (fieldName.contains('Waist')) return Icons.straighten;
    if (fieldName.contains('Hip')) return Icons.accessibility_new;
    if (fieldName.contains('BMR') || fieldName.contains('TDEE')) return Icons.local_fire_department;
    return Icons.medical_information;
  }
}