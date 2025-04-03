import 'convert_to_pdf.dart';
import 'laboratory_findings_page_teacher.dart';
import 'package:flutter/material.dart';
import 'physical_examination_teacher.dart';
import 'eye_examination_teacher.dart';
import 'ent_examination_teacher.dart';
import 'body_composition_page_teacher.dart';

class FormsPage extends StatelessWidget {
  final Map<String, dynamic> studentData;

  FormsPage({required this.studentData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Forms for ${studentData['name']}')),
      body: ListView(
        padding: EdgeInsets.all(16.0),
        children: [
          ListTile(
            title: Text('Physical Examination'),
            trailing: Icon(Icons.arrow_forward),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => PhysicalExaminationPage(studentData: studentData)),
              );
            },
          ),
          ListTile(
            title: Text('Eye Examination'),
            trailing: Icon(Icons.arrow_forward),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => EyeExaminationView(studentData: studentData)),
              );
            },
          ),
          ListTile(
            title: Text('ENT Examination'),
            trailing: Icon(Icons.arrow_forward),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ENTExaminationView(studentData: studentData)),
              );
            },
          ),
          ListTile(
            title: Text('Laboratory Findings'),
            trailing: Icon(Icons.arrow_forward),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => LaboratoryFindingsView(studentData: studentData)),
              );
            },
          ),
          ListTile(
            title: Text('Body Composition'),
            trailing: Icon(Icons.arrow_forward),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => BodyCompositionViewPage(studentData: studentData)),
              );
            },
          ),
          ListTile(
            title: Text('Convert to PDF'),
            trailing: Icon(Icons.arrow_forward),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ExaminationResultsPage(studentData: studentData)),
              );
            },
          ),
          // Add more forms here as needed
        ],
      ),
    );
  }
}