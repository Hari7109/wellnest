import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminFeedbackPage extends StatelessWidget {
  const AdminFeedbackPage({super.key});

  void _respondToFeedback(String docId, BuildContext context) {
    TextEditingController responseController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Respond to Feedback"),
        content: TextField(
          controller: responseController,
          decoration: const InputDecoration(hintText: "Enter response..."),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context, rootNavigator: true).pop(); // Close dialog
            },
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              if (responseController.text.isNotEmpty) {
                await FirebaseFirestore.instance
                    .collection('feedback')
                    .doc(docId)
                    .update({'adminResponse': responseController.text}); // Store response in 'adminResponse'

                Navigator.of(context, rootNavigator: true).pop(); // Close dialog

                // Show success message
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Response sent successfully!")),
                );
              }
            },
            child: const Text("Send"),
          ),
        ],
      ),
    );
  }

  Future<String> _getUserName(String studentId) async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('biodata')
          .doc(studentId) // Match with studentId
          .get();
      if (doc.exists) {
        return doc['name'] ?? 'Unknown'; // Fetch name from biodata
      }
    } catch (e) {
      print("Error fetching name: $e");
    }
    return "Unknown"; // Default if no data found
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Student Feedbacks")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('feedback')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No feedback available."));
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: snapshot.data!.docs.map((doc) {
              Map<String, dynamic> feedback =
              doc.data() as Map<String, dynamic>;

              String studentId = feedback['studentId'] ?? 'Unknown';
              String feedbackText = feedback['feedbackText'] ?? "No message";

              return FutureBuilder<String>(
                future: _getUserName(studentId),
                builder: (context, nameSnapshot) {
                  String userName = nameSnapshot.data ?? "Fetching...";

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "From: $userName", // Shows the student's name
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            feedbackText,
                            style: const TextStyle(fontSize: 16),
                          ),
                          const Divider(),
                          feedback['adminResponse'] != null
                              ? Text(
                            "Admin Response: ${feedback['adminResponse']}",
                            style: const TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold),
                          )
                              : ElevatedButton(
                            onPressed: () =>
                                _respondToFeedback(doc.id, context),
                            child: const Text("Respond"),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
