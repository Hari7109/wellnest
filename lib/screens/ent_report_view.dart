import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class ENTExaminationReportPage extends StatefulWidget {
  const ENTExaminationReportPage({Key? key}) : super(key: key);

  @override
  _ENTExaminationReportPageState createState() => _ENTExaminationReportPageState();
}

class _ENTExaminationReportPageState extends State<ENTExaminationReportPage> {
  bool _isLoading = true;
  Map<String, dynamic>? _examData;
  Map<String, dynamic>? _userData;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchExaminationData();
  }

  Future<void> _fetchExaminationData() async {
    try {
      // Get current user
      final User? currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser == null) {
        setState(() {
          _errorMessage = "You need to be logged in to view your reports";
          _isLoading = false;
        });
        return;
      }

      // Fetch user data
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();

      if (!userDoc.exists) {
        setState(() {
          _errorMessage = "User profile not found";
          _isLoading = false;
        });
        return;
      }

      _userData = userDoc.data();
      String regNo = _userData?['reg_no'];

      if (regNo == null) {
        setState(() {
          _errorMessage = "Registration number not found in your profile";
          _isLoading = false;
        });
        return;
      }

      // Fetch examination data using registration number
      final examDoc = await FirebaseFirestore.instance
          .collection('ent_examinations')
          .doc(regNo)
          .get();

      if (!examDoc.exists) {
        setState(() {
          _errorMessage = "No ENT examination record found";
          _isLoading = false;
        });
        return;
      }

      setState(() {
        _examData = examDoc.data();
        _isLoading = false;
      });

    } catch (e) {
      setState(() {
        _errorMessage = "Error fetching data: ${e.toString()}";
        _isLoading = false;
      });
    }
  }

  String _formatTimestamp(dynamic timestamp) {
    if (timestamp == null) return "Date not available";

    if (timestamp is Timestamp) {
      return DateFormat('MMMM d, yyyy • h:mm a').format(timestamp.toDate());
    } else if (timestamp is String) {
      try {
        return timestamp; // Return as is if already formatted
      } catch (e) {
        return "Date format error";
      }
    }

    return "Date not available";
  }

  Widget _buildExamCard(String title, String content, IconData icon, Color color) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    content,
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey[800],
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

  Widget _buildSummarySection() {
    // Check if findings are normal based on the remarks
    String remarks = _examData?['remarks'] ?? "No remarks available";
    bool isNormal = remarks.toLowerCase().contains("normal");

    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isNormal ? Colors.green.shade50 : Colors.amber.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isNormal ? Colors.green.shade200 : Colors.amber.shade200,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isNormal ? Icons.check_circle : Icons.info,
                color: isNormal ? Colors.green : Colors.amber,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                "Summary",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: isNormal ? Colors.green.shade800 : Colors.amber.shade800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            remarks,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("ENT Examination Report"),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 60, color: Colors.red[300]),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _fetchExaminationData,
                child: const Text("Try Again"),
              ),
            ],
          ),
        ),
      )
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Timestamp display
            if (_examData?['timestamp'] != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(
                  _formatTimestamp(_examData!['timestamp']),
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ),

            // Summary section with overall diagnosis
            _buildSummarySection(),

            // Detailed examination results
            _buildExamCard(
              "Ear Examination",
              _examData?['ear_examination'] ?? "Not available",
              Icons.hearing,
              Colors.blue,
            ),

            _buildExamCard(
              "Nose Examination",
              _examData?['nose_examination'] ?? "Not available",
              Icons.air,
              Colors.purple,
            ),

            _buildExamCard(
              "Throat Examination",
              _examData?['throat_examination'] ?? "Not available",
              Icons.emoji_people,
              Colors.orange,
            ),

            _buildExamCard(
              "Sinuses Examination",
              _examData?['sinuses_examination'] ?? "Not available",
              Icons.face,
              Colors.teal,
            ),

            // What next section
            const SizedBox(height: 16),
            Card(
              elevation: 1,
              margin: const EdgeInsets.only(top: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "What's Next?",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.indigo.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(Icons.help_outline, color: Colors.indigo),
                      ),
                      title: const Text("Have questions?"),
                      subtitle: const Text("Contact your doctor for clarification"),
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(Icons.calendar_today, color: Colors.green),
                      ),
                      title: const Text("Follow-up appointment"),
                      subtitle: const Text("Schedule your next visit if needed"),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}