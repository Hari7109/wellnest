import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:albertian_wellnest/screens/home.dart';
import 'package:intl/intl.dart'; // Add this for date formatting

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        primaryColor: const Color(0xFF0D47A1),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFF0D47A1), width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0D47A1),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 40),
            textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
      ),
      home: const BioDataPage(),
    );
  }
}

class BioDataPage extends StatefulWidget {
  const BioDataPage({super.key});

  @override
  _BioDataPageState createState() => _BioDataPageState();
}

class _BioDataPageState extends State<BioDataPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController sexController = TextEditingController();
  final TextEditingController dobController = TextEditingController();
  final TextEditingController bloodGroupController = TextEditingController();
  final TextEditingController religionController = TextEditingController();
  final TextEditingController idMarkController = TextEditingController();
  final TextEditingController courseNameController = TextEditingController();
  final TextEditingController admissionDateController = TextEditingController();
  final TextEditingController courseDurationController = TextEditingController();
  final TextEditingController completionDateController = TextEditingController();
  final TextEditingController guardianController = TextEditingController();
  final TextEditingController permanentAddressController = TextEditingController();
  final TextEditingController residentialAddressController = TextEditingController();

  final TextEditingController fatherNameController = TextEditingController();
  final TextEditingController fatherEducationController = TextEditingController();
  final TextEditingController fatherOccupationController = TextEditingController();
  final TextEditingController fatherIncomeController = TextEditingController();

  final TextEditingController motherNameController = TextEditingController();
  final TextEditingController motherEducationController = TextEditingController();
  final TextEditingController motherOccupationController = TextEditingController();
  final TextEditingController motherIncomeController = TextEditingController();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _selectDate(BuildContext context, TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF0D47A1),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        controller.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  Future<void> _submitData() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        User? user = FirebaseAuth.instance.currentUser;

        await _firestore.collection('bioData').doc(user?.uid).set({
          'name': nameController.text,
          'age': ageController.text,
          'sex': sexController.text,
          'dob': dobController.text,
          'bloodGroup': bloodGroupController.text,
          'religion': religionController.text,
          'idMark': idMarkController.text,
          'courseName': courseNameController.text,
          'admissionDate': admissionDateController.text,
          'courseDuration': courseDurationController.text,
          'completionDate': completionDateController.text,
          'guardian': guardianController.text,
          'permanentAddress': permanentAddressController.text,
          'residentialAddress': residentialAddressController.text,
          'fatherName': fatherNameController.text,
          'fatherEducation': fatherEducationController.text,
          'fatherOccupation': fatherOccupationController.text,
          'fatherIncome': fatherIncomeController.text,
          'motherName': motherNameController.text,
          'motherEducation': motherEducationController.text,
          'motherOccupation': motherOccupationController.text,
          'motherIncome': motherIncomeController.text,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Data submitted successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const NextPage()),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error submitting data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all required fields'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D47A1),
        title: const Text("Add to your Profile",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0D47A1), Color(0xFFFFFFFF)],
            stops: [0.0, 0.3],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SectionTitle(title: "Bio Data"),
                    buildInputRow("Name", nameController, Icons.person),
                    buildInputRow("Age", ageController, Icons.calendar_today, isNumeric: true),
                    buildDropdownRow("Sex", sexController, ["Male", "Female", "Other"], Icons.people),
                    buildDatePickerRow("Date of Birth", dobController, Icons.cake),
                    buildDropdownRow("Blood Group", bloodGroupController,
                        ["A+", "A-", "B+", "B-", "AB+", "AB-", "O+", "O-"], Icons.bloodtype),
                    buildInputRow("Religion", religionController, Icons.church),
                    buildInputRow("Identification Mark", idMarkController, Icons.fingerprint),
                    buildInputRow("Name of the Course", courseNameController, Icons.school),
                    buildDatePickerRow("Date of Admission", admissionDateController, Icons.date_range),
                    buildInputRow("Duration of the Course", courseDurationController, Icons.timer),
                    buildDatePickerRow("Date of Completion", completionDateController, Icons.event_available),
                    buildInputRow("Local Guardian (if any)", guardianController, Icons.person_outline),

                    const SectionTitle(title: "Permanent Address"),
                    buildTextArea(permanentAddressController, Icons.home),

                    const SectionTitle(title: "Residential Address"),
                    buildTextArea(residentialAddressController, Icons.location_city),

                    const SectionTitle(title: "Father's Details"),
                    buildInputRow("Name", fatherNameController, Icons.person),
                    buildInputRow("Education", fatherEducationController, Icons.school),
                    buildInputRow("Occupation", fatherOccupationController, Icons.work),
                    buildInputRow("Income", fatherIncomeController, Icons.attach_money, isNumeric: true),

                    const SectionTitle(title: "Mother's Details"),
                    buildInputRow("Name", motherNameController, Icons.person),
                    buildInputRow("Education", motherEducationController, Icons.school),
                    buildInputRow("Occupation", motherOccupationController, Icons.work),
                    buildInputRow("Income", motherIncomeController, Icons.attach_money, isNumeric: true),

                    const SizedBox(height: 30),
                    Center(
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Color(0xFF0D47A1))
                          : ElevatedButton.icon(
                        onPressed: _submitData,
                        icon: const Icon(Icons.check_circle),
                        label: const Text("Submit Profile"),
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildInputRow(String label, TextEditingController controller, IconData icon, {bool isNumeric = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: const Color(0xFF0D47A1)),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter $label';
          }
          return null;
        },
      ),
    );
  }

  Widget buildDropdownRow(String label, TextEditingController controller, List<String> options, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: const Color(0xFF0D47A1)),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
        value: controller.text.isNotEmpty ? controller.text : null,
        items: options.map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
        onChanged: (String? newValue) {
          if (newValue != null) {
            setState(() {
              controller.text = newValue;
            });
          }
        },
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please select $label';
          }
          return null;
        },
      ),
    );
  }

  Widget buildDatePickerRow(String label, TextEditingController controller, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        readOnly: true,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: const Color(0xFF0D47A1)),
          suffixIcon: IconButton(
            icon: const Icon(Icons.calendar_month, color: Color(0xFF0D47A1)),
            onPressed: () => _selectDate(context, controller),
          ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
        onTap: () => _selectDate(context, controller),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter $label';
          }
          return null;
        },
      ),
    );
  }

  Widget buildTextArea(TextEditingController controller, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        maxLines: 3,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: const Color(0xFF0D47A1)),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter address';
          }
          return null;
        },
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String title;

  const SectionTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF0D47A1)),
          ),
          const Divider(thickness: 2, color: Color(0xFF0D47A1)),
        ],
      ),
    );
  }
}

class NextPage extends StatelessWidget {
  const NextPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        primaryColor: const Color(0xFF0D47A1),
      ),
      home: const OkDoneReadyToGoPage(),
    );
  }
}

class OkDoneReadyToGoPage extends StatelessWidget {
  const OkDoneReadyToGoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D47A1),
        title: const Text('Ready to Go'),
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0D47A1), Color(0xFFFFFFFF)],
            stops: [0.0, 0.3],
          ),
        ),
        child: Center(
          child: Card(
            margin: const EdgeInsets.all(20),
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: Padding(
              padding: const EdgeInsets.all(30.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Icon(
                    Icons.check_circle,
                    color: Color(0xFF0D47A1),
                    size: 80,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Profile Created Successfully!',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0D47A1),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Your profile has been created successfully. You can now proceed to your dashboard.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const HomePage()),
                      );
                    },
                    icon: const Icon(Icons.arrow_forward),
                    label: const Text('Go to Dashboard'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}