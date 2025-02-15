import 'package:flutter/material.dart';

class MedicalHistoryPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text("Medical History"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Select a Student", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: 5, // Sample list
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text("Student ${index + 1}"),
                    subtitle: Text("Roll No: 20${index + 10}"),
                    trailing: IconButton(
                      icon: const Icon(Icons.upload_file, color: Colors.blue),
                      onPressed: () {
                        // Upload logic
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
