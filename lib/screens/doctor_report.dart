import 'package:flutter/material.dart';
import 'package:albertian_wellnest/screens/specialist/laboratory_findings_page.dart';

import 'Lab_report_view.dart';
import 'body_composition.dart';
import 'ent_report_view.dart';
import 'eye_report_view.dart';
import 'physical_examination_student.dart';

class StudentFormsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Define report items with icons and colors
    final reportItems = [
      {
        'title': 'Physical Examination',
        'icon': Icons.medical_services,
        'color': Colors.blue,
        'page': MedicalApp(),
      },
      {
        'title': 'Eye Examination',
        'icon': Icons.visibility,
        'color': Colors.purple,
        'page': VisionExaminationPage(),
      },
      {
        'title': 'ENT Examination',
        'icon': Icons.hearing,
        'color': Colors.orange,
        'page': ENTExaminationReportPage(),
      },
      {
        'title': 'Laboratory Findings',
        'icon': Icons.science,
        'color': Colors.green,
        'page': LaboratoryReportPage(),
      },
      {
        'title': 'Body Composition',
        'icon': Icons.accessibility_new,
        'color': Colors.red,
        'page': BodyCompositionDisplayPage(),
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Doctor Report'),
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).primaryColor.withOpacity(0.1),
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Medical Reports',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Select a medical report to view details',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 1.1,
                    ),
                    itemCount: reportItems.length,
                    itemBuilder: (context, index) {
                      final item = reportItems[index];
                      return _buildReportCard(
                        context,
                        title: item['title'] as String,
                        icon: item['icon'] as IconData,
                        color: item['color'] as Color,
                        page: item['page'] as Widget,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReportCard(
      BuildContext context, {
        required String title,
        required IconData icon,
        required Color color,
        required Widget page,
      }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => page),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(1.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 48,
                color: color,
              ),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}