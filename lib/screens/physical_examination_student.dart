import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';

import '../services/user_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MedicalApp());
}

class MedicalApp extends StatelessWidget {
  const MedicalApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Medical Records',
      theme: ThemeData(
        primaryColor: const Color(0xFF56A4DA),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF56A4DA),
          primary: const Color(0xFF56A4DA),
          secondary: const Color(0xFF03DAC6),
          background: Colors.white,
          surface: Colors.white,
        ),
        scaffoldBackgroundColor: const Color(0xFFF5F5F7),
        textTheme: GoogleFonts.poppinsTextTheme(),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 0,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        cardTheme: CardTheme(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          color: Colors.white,
        ),
      ),
      darkTheme: ThemeData.dark().copyWith(
        primaryColor: const Color(0xFF56A4DA),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF56A4DA),
          primary: const Color(0xFF56A4DA),
          secondary: const Color(0xFF03DAC6),
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF121212),
        textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme),
        cardTheme: CardTheme(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          color: const Color(0xFF1E1E1E),
        ),
      ),
      themeMode: ThemeMode.system,
      home: const MedicalDataScreen(),
    );
  }
}

class MedicalDataScreen extends StatefulWidget {
  const MedicalDataScreen({Key? key}) : super(key: key);

  @override
  _MedicalDataScreenState createState() => _MedicalDataScreenState();
}

class _MedicalDataScreenState extends State<MedicalDataScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Map<String, dynamic>? studentData;
  String? userId;
  bool _isLoading = true;
  Map<String, dynamic>? _physicalExaminationData;

  @override
  void initState() {
    super.initState();
    fetchAndLoadData();
  }

  Future<void> fetchAndLoadData() async {
    setState(() => _isLoading = true);
    try {
      await fetchStudentData();
      await _fetchPhysicalExamination();
    } catch (e) {
      print("Error in fetching data: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> fetchStudentData() async {
    User? user = _auth.currentUser;
    if (user != null) {
      userId = user.uid;
      try {
        Map<String, dynamic>? data = await _firestoreService.getStudentData(userId!);
        if (data != null) {
          setState(() {
            studentData = data;
          });
          print("Student Data: $studentData");
        } else {
          print("Failed to fetch student data.");
        }
      } catch (e) {
        print("Error fetching student data: $e");
      }
    } else {
      print("No user is logged in");
    }
  }

  Future<void> _fetchPhysicalExamination() async {
    if (studentData == null) {
      print("Student data is null, can't fetch physical examination");
      return;
    }

    try {
      var regNo = studentData!['reg_no'];
      print("Fetching physical examination data for reg no: $regNo");

      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('physical_examinations')
          .doc(regNo)
          .get();

      if (doc.exists && doc.data() != null) {
        setState(() {
          _physicalExaminationData = doc.data() as Map<String, dynamic>;
        });
        print("Physical examination data retrieved: $_physicalExaminationData");
      } else {
        print("No physical examination data found for reg no: $regNo");
      }
    } catch (e) {
      print("Error fetching physical examination data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Medical Records',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: fetchAndLoadData,
          ),
          // IconButton(
          //   icon: const Icon(Icons.arrow_back),
          //   onPressed: () {
          //     // Show profile or account information
          //     // Navigator.pop(context);
          //   },
          // ),
        ],
      ),
      body: _isLoading
          ? const Center(
        child: CircularProgressIndicator(),
      )
          : _buildBody(),
    );
  }

  Widget _buildBody() {
    // Check if we have physical examination data
    if (_physicalExaminationData != null) {
      // If we have the student-specific data, show it
      return _buildStudentDataView();
    } else {
      // If no student-specific data, use the general collection as fallback
      return _buildGeneralDataFallback();
    }
  }

  Widget _buildStudentDataView() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Theme.of(context).colorScheme.primary.withOpacity(0.05),
            Theme.of(context).colorScheme.background,
          ],
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStudentInfoCard(),
              const SizedBox(height: 16),
              MedicalDataCard(data: _physicalExaminationData!),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStudentInfoCard() {
    if (studentData == null) return const SizedBox.shrink();

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 32,
              backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
              child: Text(
                studentData!['name']?.substring(0, 1).toUpperCase() ?? 'S',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    studentData!['name'] ?? 'Student Name',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Reg No: ${studentData!['reg_no'] ?? 'N/A'}',
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
                    ),
                  ),
                  if (studentData!['program'] != null)
                    Text(
                      studentData!['program'],
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
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

  Widget _buildGeneralDataFallback() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Theme.of(context).colorScheme.primary.withOpacity(0.05),
            Theme.of(context).colorScheme.background,
          ],
        ),
      ),
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('medical_records').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 48,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading data',
                    style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.data == null || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.medical_services_outlined,
                    size: 64,
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No medical records found',
                    style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: fetchAndLoadData,
                    child: const Text('Refresh'),
                  ),
                ],
              ),
            );
          }

          final data = snapshot.data!.docs[0].data() as Map<String, dynamic>;
          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: MedicalDataCard(data: data),
            ),
          );
        },
      ),
    );
  }
}

class MedicalDataCard extends StatelessWidget {
  final Map<String, dynamic> data;

  const MedicalDataCard({Key? key, required this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.zero,
      child: Column(
        children: [
          _buildHeader(context),
          const Divider(height: 1, thickness: 1),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildVitalSigns(context),
                _buildSystemExamination(context),
                _buildDiagnostics(context),
                _buildAdditionalNotes(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    String dateStr = 'N/A';
    if (data.containsKey('date') && data['date'] != null) {
      final dateParts = data['date'].toString().split('T');
      dateStr = dateParts.isNotEmpty ? dateParts[0] : 'N/A';
    }

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        children: [
          Text(
            'Medical Examination Report',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.calendar_today,
                size: 16,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 0),
              Text(
                'Date: $dateStr',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              if (data.containsKey('year') && data['year'] != null) ...[
                const SizedBox(width: 3 ),
                Icon(
                  Icons.school,
                  size: 16,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 4),
                Text(
                  'Year: ${data['year']}',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVitalSigns(BuildContext context) {
    List<DataItem> vitalSigns = [];

    // Check if each field exists before adding
    if (data.containsKey('height')) vitalSigns.add(DataItem('Height', data['height']));
    if (data.containsKey('weight')) vitalSigns.add(DataItem('Weight', data['weight']));
    if (data.containsKey('bp')) vitalSigns.add(DataItem('BP', data['bp']));
    if (data.containsKey('temperature')) vitalSigns.add(DataItem('Temperature', data['temperature']));
    if (data.containsKey('pulse')) vitalSigns.add(DataItem('Pulse', data['pulse']));
    if (data.containsKey('respiration')) vitalSigns.add(DataItem('Respiration', data['respiration']));
    if (data.containsKey('vital_signs')) vitalSigns.add(DataItem('Other Vital Signs', data['vital_signs']));

    if (vitalSigns.isEmpty) return const SizedBox.shrink();

    return _buildSection(context, 'Vital Signs', Icons.favorite, vitalSigns);
  }

  Widget _buildSystemExamination(BuildContext context) {
    List<DataItem> examItems = [];

    // Check if each field exists before adding
    if (data.containsKey('general')) examItems.add(DataItem('General', data['general']));
    if (data.containsKey('appearance')) examItems.add(DataItem('Appearance', data['appearance']));
    if (data.containsKey('neck')) examItems.add(DataItem('Neck', data['neck']));
    if (data.containsKey('cardiovascular_system'))
      examItems.add(DataItem('Cardiovascular System', data['cardiovascular_system']));
    if (data.containsKey('respiratory_system'))
      examItems.add(DataItem('Respiratory System', data['respiratory_system']));
    if (data.containsKey('central_nervous_system'))
      examItems.add(DataItem('Central Nervous System', data['central_nervous_system']));
    if (data.containsKey('gastrointestinal_system'))
      examItems.add(DataItem('Gastrointestinal System', data['gastrointestinal_system']));
    if (data.containsKey('genitourinary_system'))
      examItems.add(DataItem('Genitourinary System', data['genitourinary_system']));
    if (data.containsKey('integumentary_system'))
      examItems.add(DataItem('Integumentary System', data['integumentary_system']));
    if (data.containsKey('musculoskeletal_system'))
      examItems.add(DataItem('Musculoskeletal System', data['musculoskeletal_system']));

    if (examItems.isEmpty) return const SizedBox.shrink();

    return _buildSection(context, 'System Examination', Icons.medical_services, examItems);
  }

  Widget _buildDiagnostics(BuildContext context) {
    List<DataItem> diagnostics = [];

    // Check if each field exists before adding
    if (data.containsKey('ecg')) diagnostics.add(DataItem('ECG', data['ecg']));
    if (data.containsKey('x-ray')) diagnostics.add(DataItem('X-Ray', data['x-ray']));

    if (diagnostics.isEmpty) return const SizedBox.shrink();

    return _buildSection(context, 'Diagnostics', Icons.assessment, diagnostics);
  }

  Widget _buildAdditionalNotes(BuildContext context) {
    if (!data.containsKey('remarks') || data['remarks'] == null)
      return const SizedBox.shrink();

    return _buildSection(context, 'Additional Notes', Icons.note, [
      DataItem('Remarks', data['remarks']),
    ]);
  }

  Widget _buildSection(BuildContext context, String title, IconData icon, List<DataItem> items) {
    if (items.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 16, bottom: 0),
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(8),
              topRight: Radius.circular(8),
            ),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: Colors.white,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(8),
              bottomRight: Radius.circular(8),
            ),
            border: Border.all(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Column(
            children: items.asMap().entries.map((entry) {
              int idx = entry.key;
              DataItem item = entry.value;
              bool isLast = idx == items.length - 1;

              return Column(
                children: [
                  _buildDataRow(context, item.label, item.value),
                  if (!isLast)
                    Divider(
                      height: 1,
                      thickness: 1,
                      indent: 0,
                      endIndent: 0,
                      color: Theme.of(context).dividerColor.withOpacity(0.3),
                    ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildDataRow(BuildContext context, String label, dynamic value) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Label column
          Container(
            width: 150,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.05),
              border: Border(
                right: BorderSide(
                  color: Theme.of(context).dividerColor.withOpacity(0.3),
                  width: 1,
                ),
              ),
            ),
            alignment: Alignment.centerLeft,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.primary.withOpacity(0.8),
                fontSize: 14,
              ),
            ),
          ),
          // Value column
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
              child: Text(
                value?.toString() ?? 'N/A',
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DataItem {
  final String label;
  final dynamic value;
  DataItem(this.label, this.value);
}