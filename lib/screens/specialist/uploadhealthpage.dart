import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UploadHealthArticlePage extends StatefulWidget {
  const UploadHealthArticlePage({Key? key}) : super(key: key);

  @override
  _UploadHealthArticlePageState createState() => _UploadHealthArticlePageState();
}

class _UploadHealthArticlePageState extends State<UploadHealthArticlePage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for text fields
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _summaryController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();

  // Dropdown for health categories
  final List<String> _healthCategories = [
    'Mental Health',
    'Nutrition',
    'Fitness',
    'Lifestyle',
    'Preventive Care',
    'General Wellness',
    'Chronic Conditions',
    'Women\'s Health',
    'Men\'s Health',
    'Child Health'
  ];

  String _selectedCategory = 'General Wellness';
  bool _isLoading = false;

  void _uploadArticle() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Get current user
        User? currentUser = FirebaseAuth.instance.currentUser;
        if (currentUser == null) {
          _showErrorDialog('Please log in to upload an article');
          return;
        }

        // Prepare article data
        Map<String, dynamic> articleData = {
          'title': _titleController.text.trim(),
          'summary': _summaryController.text.trim(),
          'content': _contentController.text.trim(),
          'category': _selectedCategory,
          'authorId': currentUser.uid,
          'authorName': currentUser.displayName ?? 'Anonymous Specialist',
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
          'status': 'draft', // Can be changed to 'published' if auto-approved
        };

        // Upload to Firestore
        await FirebaseFirestore.instance.collection('health_articles').add(articleData);

        // Show success dialog
        _showSuccessDialog();

        // Clear form
        _clearForm();
      } catch (e) {
        _showErrorDialog('Failed to upload article: ${e.toString()}');
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Article Uploaded'),
        content: const Text('Your health article has been submitted successfully.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Upload Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _clearForm() {
    _titleController.clear();
    _summaryController.clear();
    _contentController.clear();
    setState(() {
      _selectedCategory = 'General Wellness';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Health Article'),
        backgroundColor: Colors.blue[600],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Title Input
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Article Title',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an article title';
                  }
                  if (value.length < 10) {
                    return 'Title must be at least 10 characters long';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Category Dropdown
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: InputDecoration(
                  labelText: 'Health Category',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: _healthCategories.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value!;
                  });
                },
              ),
              const SizedBox(height: 20),

              // Summary Input
              TextFormField(
                controller: _summaryController,
                decoration: InputDecoration(
                  labelText: 'Article Summary',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please provide a brief summary';
                  }
                  if (value.length < 50) {
                    return 'Summary must be at least 50 characters long';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Content Input
              TextFormField(
                controller: _contentController,
                decoration: InputDecoration(
                  labelText: 'Article Content',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                maxLines: 10,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter article content';
                  }
                  if (value.length < 200) {
                    return 'Content must be at least 200 characters long';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 30),

              // Submit Button
              ElevatedButton(
                onPressed: _uploadArticle,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[600],
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Upload Article',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    // Dispose controllers to prevent memory leaks
    _titleController.dispose();
    _summaryController.dispose();
    _contentController.dispose();
    super.dispose();
  }
}