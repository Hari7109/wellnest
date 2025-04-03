import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'view_events_page.dart'; // Import the new page

class UploadEventPage extends StatefulWidget {
  const UploadEventPage({super.key});

  @override
  _UploadEventPageState createState() => _UploadEventPageState();
}

class _UploadEventPageState extends State<UploadEventPage> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  DateTime? selectedDate;
  File? _image;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<String?> _uploadImage() async {
    if (_image == null) return null;
    try {
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      Reference ref = _storage.ref().child('event_images/$fileName');
      UploadTask uploadTask = ref.putFile(_image!);
      TaskSnapshot snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      return null;
    }
  }

  Future<void> _uploadEvent() async {
    if (titleController.text.isEmpty || descriptionController.text.isEmpty || selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields"), backgroundColor: Colors.red),
      );
      return;
    }

    String? imageUrl = await _uploadImage();

    await _firestore.collection('events').add({
      'title': titleController.text,
      'description': descriptionController.text,
      'date': selectedDate?.toIso8601String(),
      'imageUrl': imageUrl,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Event uploaded successfully!"), backgroundColor: Colors.green),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Upload Event")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(controller: titleController, decoration: const InputDecoration(labelText: "Title")),
            TextField(controller: descriptionController, decoration: const InputDecoration(labelText: "Description")),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () async {
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2101),
                );
                if (pickedDate != null) {
                  setState(() {
                    selectedDate = pickedDate;
                  });
                }
              },
              child: Text(selectedDate == null ? "Select Date" : selectedDate!.toLocal().toString().split(' ')[0]),
            ),
            const SizedBox(height: 10),
            //ElevatedButton(onPressed: _pickImage, child: const Text("Pick Image")),
            //const SizedBox(height: 20),
            ElevatedButton(onPressed: _uploadEvent, child: const Text("Upload Event")),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ViewEventsPage()), // Admin Mode
                );
              },
              child: const Text("View & Manage Events"),
            ),
          ],
        ),
      ),
    );
  }
}
