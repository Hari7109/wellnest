import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart'; // Import Firebase Core
import 'package:albertian_wellnest/screens/home.dart';

// Initialize Firebase in main()
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: BioDataPage(),
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

  final TextEditingController nameController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController sexController = TextEditingController();
  final TextEditingController dobController = TextEditingController();
  final TextEditingController bloodGroupController = TextEditingController();
  final TextEditingController religionController = TextEditingController();
  final TextEditingController idMarkController = TextEditingController();
  final TextEditingController courseNameController = TextEditingController();
  final TextEditingController admissionDateController = TextEditingController();
  final TextEditingController courseDurationController =
      TextEditingController();
  final TextEditingController completionDateController =
      TextEditingController();
  final TextEditingController guardianController = TextEditingController();
  final TextEditingController permanentAddressController =
      TextEditingController();
  final TextEditingController residentialAddressController =
      TextEditingController();

  final TextEditingController fatherNameController = TextEditingController();
  final TextEditingController fatherEducationController =
      TextEditingController();
  final TextEditingController fatherOccupationController =
      TextEditingController();
  final TextEditingController fatherIncomeController = TextEditingController();

  final TextEditingController motherNameController = TextEditingController();
  final TextEditingController motherEducationController =
      TextEditingController();
  final TextEditingController motherOccupationController =
      TextEditingController();
  final TextEditingController motherIncomeController = TextEditingController();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _submitData() async {
    print("pressed");
    //_formKey.currentState!.validate()
    if (true) {
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
          const SnackBar(content: Text('Data submitted successfully!')),
        );
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const NextPage()),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error submitting data: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D47A1),
        title: const Text("Add to your Profile",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Bio Data",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              buildInputRow("Name", nameController),
              buildInputRow("Age", ageController),
              buildInputRow("Sex", sexController),
              buildInputRow("Date of Birth", dobController),
              buildInputRow("Blood Group", bloodGroupController),
              buildInputRow("Religion", religionController),
              buildInputRow("Identification Mark", idMarkController),
              buildInputRow("Name of the Course", courseNameController),
              buildInputRow("Date of Admission", admissionDateController),
              buildInputRow("Duration of the Course", courseDurationController),
              buildInputRow("Date of Completion", completionDateController),
              buildInputRow("Local Guardian (if any)", guardianController),
              const SizedBox(height: 10),
              const Text("Permanent Address",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              buildTextArea(permanentAddressController),
              const SizedBox(height: 10),
              const Text("Residential Address",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              buildTextArea(residentialAddressController),
              const SizedBox(height: 10),
              const Text("Father's Details",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              buildInputRow("Name", fatherNameController),
              buildInputRow("Education", fatherEducationController),
              buildInputRow("Occupation", fatherOccupationController),
              buildInputRow("Income", fatherIncomeController),
              const SizedBox(height: 10),
              const Text("Mother's Details",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              buildInputRow("Name", motherNameController),
              buildInputRow("Education", motherEducationController),
              buildInputRow("Occupation", motherOccupationController),
              buildInputRow("Income", motherIncomeController),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: _submitData,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0D47A1),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        vertical: 14, horizontal: 40),
                    textStyle: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  child: const Text("Submit"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildInputRow(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          SizedBox(
              width: 150,
              child: Text(label,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold))),
          Expanded(
            child: TextFormField(
              controller: controller,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Enter $label';
                }
                return null;
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget buildTextArea(TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: TextFormField(
        controller: controller,
        maxLines: 3,
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          contentPadding: EdgeInsets.all(10),
        ),
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
        title: const Text('Ready to Go'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'OK, Done, Ready to Go!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Add your navigation logic here
                // For example, navigate back to the previous screen
                Navigator.pop(context);

                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const HomePage()),
                );
              },
              child: const Text('Proceed'),
            ),
          ],
        ),
      ),
    );
  }
}
