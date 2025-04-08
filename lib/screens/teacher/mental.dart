import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MentalHealthView extends StatefulWidget {
  final Map<String, dynamic> studentData;
  const MentalHealthView({Key? key, required this.studentData}) : super(key: key);

  @override
  _MentalHealthViewState createState() => _MentalHealthViewState();
}

class _MentalHealthViewState extends State<MentalHealthView> {
  Map<String, dynamic>? mentalHealthData;
  bool _isLoading = true;
  bool _hasData = false;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    String regNo = widget.studentData['reg_no'];

    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('quiz_results')
          .doc(regNo)
          .get();

      if (doc.exists) {
        setState(() {
          mentalHealthData = doc.data() as Map<String, dynamic>;
          _hasData = true;
        });
      }
    } catch (e) {
      print('Error fetching mental health data: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal[50],
      appBar: AppBar(
        title: const Text('Mental Health Record'),
        backgroundColor: Colors.teal[700],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: _hasData ? _buildDataView() : Center(
          child: Text(
            'No Mental Health Data Available',
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
        ),
      ),
    );
  }

  Widget _buildDataView() {
    final responses = mentalHealthData!['responses'] as Map<String, dynamic>;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildInfoCard(
          title: 'Rating',
          value: mentalHealthData!['rating'].toString(),
          icon: Icons.star_rate,
          iconColor: Colors.amber,
        ),
        const SizedBox(height: 16),
        _buildInfoCard(
          title: 'Score',
          value: mentalHealthData!['score'].toString(),
          icon: Icons.score,
          iconColor: Colors.green,
        ),
        // const SizedBox(height: 16),
        // _buildInfoCard(
        //   title: 'Timestamp',
        //   value: mentalHealthData!['timestamp'],
        //   icon: Icons.access_time,
        //   iconColor: Colors.blue,
        // ),
        const SizedBox(height: 16),
        Text(
          'Responses:',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ...responses.entries.map((e) => _buildResponseTile(e.key, e.value)),
      ],
    );
  }

  Widget _buildInfoCard({
    required String title,
    required String value,
    required IconData icon,
    required Color iconColor,
  }) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(icon, color: iconColor),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '$title : $value',
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResponseTile(String question, String answer) {
    return Card(
      child: ListTile(
        title: Text(question),
        subtitle: Text(answer),
      ),
    );
  }
}
