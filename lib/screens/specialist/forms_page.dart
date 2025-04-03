import 'package:albertian_wellnest/screens/specialist/laboratory_findings_page.dart';
import 'package:flutter/material.dart';
import 'physical_examination.dart';
import 'eye_examination.dart';
import 'ent_examination.dart';
import 'body_composition_page.dart';

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
                MaterialPageRoute(builder: (context) => EyeExaminationForm()),
              );
            },
          ),
          ListTile(
            title: Text('ENT Examination'),
            trailing: Icon(Icons.arrow_forward),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ENTExaminationForm()),
              );
            },
          ),
          ListTile(
            title: Text('Laboratory Findings'),
            trailing: Icon(Icons.arrow_forward),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => LaboratoryFindingsForm()),
              );
            },
          ),
          ListTile(
            title: Text('Body Composition'),
            trailing: Icon(Icons.arrow_forward),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => BodyCompositionFormPage(studentData: studentData)),
              );
            },
          ),
          // Add more forms here as needed
        ],
      ),
    );
  }
}