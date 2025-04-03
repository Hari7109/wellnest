import 'package:albertian_wellnest/screens/teacher/manage_student.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:albertian_wellnest/screens/auth.dart';
import 'package:albertian_wellnest/screens/communitypage.dart';
import 'health_article_page.dart'; // Import the HealthArticlePage
import 'notifications_page.dart';
import 'add_student.dart';
import 'view_events_page.dart'; // Import the ViewEventsPage

class TeacherDashboard extends StatefulWidget {
  const TeacherDashboard({super.key});

  @override
  _TeacherDashboardState createState() => _TeacherDashboardState();
}

class _TeacherDashboardState extends State<TeacherDashboard> {
  String teacherName = "Loading...";
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchTeacherName();
  }

  void _fetchTeacherName() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc =
      await FirebaseFirestore.instance.collection('users').doc(user.uid).get();

      if (userDoc.exists) {
        setState(() {
          teacherName = userDoc['name'] ?? "Teacher";
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void _logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  void _navigateToCommunityChat() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CommunityChat(chatRoomId: 'general')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Teacher Dashboard'),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ViewNotificationsPage()),
              );
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Modern Greeting Card
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              color: Colors.blue.shade700,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.white,
                      child: Text(
                        teacherName.isNotEmpty ? teacherName[0].toUpperCase() : "T",
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Welcome Back,',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          teacherName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Quick Actions Grid
            const Text(
              'Quick Actions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                children: [
                  _buildActionCard(
                    'Add Student',
                    Icons.person_add_outlined,
                    Colors.indigo,
                        () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const TeacherAddUser()),
                      );
                    },
                  ),
                  _buildActionCard(
                    'Manage Students',
                    Icons.group_outlined,
                    Colors.green,
                        () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const TeacherManageUsersPage()),
                      );
                    },
                  ),
                  _buildActionCard(
                    'Community Chat',
                    Icons.chat_bubble_outline,
                    Colors.amber,
                    _navigateToCommunityChat,
                  ),
                  _buildActionCard(
                    'Student Health',
                    Icons.medical_services_outlined,
                    Colors.red,
                        () {}, // Add navigation when needed
                  ),
                  _buildActionCard(
                    'Department Health',
                    Icons.analytics_outlined,
                    Colors.purple,
                        () {}, // Add navigation when needed
                  ),
                  _buildActionCard(
                    'Events',
                    Icons.event,
                    Colors.orange,
                        () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ViewEventsPage()),
                      );
                    },
                  ),
                  _buildActionCard(
                    'Health Articles', // New Health Articles Card
                    Icons.article_outlined,
                    Colors.teal,
                        () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const HealthArticlesPage()),
                      );
                    },
                  ),
                  _buildActionCard(
                    'Log Out',
                    Icons.logout,
                    Colors.grey,
                    _logout,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(
      String title, IconData icon, Color color, VoidCallback onTap) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 25,
              backgroundColor: color.withOpacity(0.1),
              child: Icon(icon, color: color),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}