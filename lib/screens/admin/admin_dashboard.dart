import 'package:albertian_wellnest/screens/admin/admin_send_notification.dart';
import 'package:albertian_wellnest/screens/admin/manage_user.dart';
import 'package:albertian_wellnest/screens/admin/view_feedback.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'admin_add_user.dart';
import '../auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'upload_event.dart';
import 'student_health.dart';
import 'package:albertian_wellnest/screens/communitypage.dart';
import 'department_health.dart';
import 'view_feedback.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  // Store counts from Firestore
  int userCount = 0;
  int eventCount = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchCounts();
  }

  // Fetch collection counts from Firestore
  Future<void> _fetchCounts() async {
    setState(() {
      isLoading = true;
    });

    try {
      // Get users count
      final QuerySnapshot usersSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .get();

      // Get events count
      final QuerySnapshot eventsSnapshot = await FirebaseFirestore.instance
          .collection('events')
          .get();

      setState(() {
        userCount = usersSnapshot.size;
        eventCount = eventsSnapshot.size;
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching data: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Define theme colors for consistency
    final Color primaryColor = Theme.of(context).primaryColor;
    final Color secondaryColor = Colors.grey.shade200;

    // Get device size for responsive layouts
    final Size screenSize = MediaQuery.of(context).size;
    final double cardAspectRatio = screenSize.width > 600 ? 2.0 : 1.8;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Albertian Wellnest"),
        elevation: 0,

        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: primaryColor,
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.admin_panel_settings, size: 40, color: Colors.blueGrey),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Admin Panel",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.dashboard),
              title: const Text("Dashboard"),
              selected: true,
              onTap: () {
                Navigator.pop(context);
              },
            ),

            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text("Logout", style: TextStyle(color: Colors.red)),
              onTap: () async {
                // Sign out from Firebase
                await FirebaseAuth.instance.signOut();

                // Navigate to login page and remove all previous routes
                if (context.mounted) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                        (route) => false, // This removes all previous routes
                  );
                }
              },
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome header with animation
              TweenAnimationBuilder(
                tween: Tween<double>(begin: 0, end: 1),
                duration: const Duration(milliseconds: 800),
                builder: (context, value, child) {
                  return Opacity(
                    opacity: value,
                    child: Transform.translate(
                      offset: Offset(0, 20 * (1 - value)),
                      child: child,
                    ),
                  );
                },
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.admin_panel_settings, color: primaryColor, size: 36),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Welcome, Admin",
                            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            "What would you like to do today?",
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // Quick stats with real data from Firestore
              Row(
                children: [
                  _buildStatCard(
                    context,
                    "Users",
                    isLoading ? "..." : userCount.toString(),
                    Icons.people,
                    Colors.blue,
                    onTap: () => _fetchCounts(),
                  ),
                  const SizedBox(width: 12),
                  _buildStatCard(
                    context,
                    "Events",
                    isLoading ? "..." : eventCount.toString(),
                    Icons.event,
                    Colors.orange,
                    onTap: () => _fetchCounts(),
                  ),
                  const SizedBox(width: 12),
                  _buildStatCard(
                    context,
                    "Refresh Data",
                    "",
                    isLoading ? Icons.hourglass_empty : Icons.refresh,
                    Colors.green,
                    onTap: () => _fetchCounts(),
                  ),
                ],
              ),

              const SizedBox(height: 30),
              const Text(
                "Management",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              // Management options with UPDATED grid layout
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  childAspectRatio: cardAspectRatio, // UPDATED to use responsive ratio
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  padding: const EdgeInsets.only(bottom: 16), // Add padding at bottom
                  children: [
                    _buildDashboardCard(
                      context,
                      "Add Users",
                      Icons.person_add,
                      Colors.indigo,
                          () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const AdminAddUser()),
                        );
                      },
                    ),
                    _buildDashboardCard(
                      context,
                      "Manage Users",
                      Icons.people,
                      Colors.teal,
                          () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const ManageUsersPage()),
                        );
                      },
                    ),
                    _buildDashboardCard(
                      context,
                      "Community Chat",
                      Icons.chat,
                      Colors.deepPurple,
                          () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const CommunityChat(chatRoomId: 'general')),
                            );
                      },
                    ),
                    _buildDashboardCard(
                      context,
                      "Upload Event",
                      Icons.event_available,
                      Colors.amber.shade700,
                          () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const UploadEventPage()),
                        );
                      },
                    ),
                    _buildDashboardCard(
                      context,
                      "Student Health",
                      Icons.healing,
                      Colors.red,
                          () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const StudentHealthPage()),
                        );
                      },
                    ),
                    _buildDashboardCard(
                      context,
                      "Department Health",
                      Icons.analytics,
                      Colors.green,
                          () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const DepartmentHealthPage()),
                        );
                      },
                    ),
                    _buildDashboardCard(
                      context,
                      "Feedback",
                      Icons.feedback,
                      Colors.purple,
                          () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const AdminFeedbackPage()),
                        );
                      },
                    ),
                    _buildDashboardCard(
                      context,
                      "Notification",
                      Icons.notification_add,
                      Colors.orange.shade700,
                          () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const AdminSendNotificationPage()),
                        );
                      },
                    ),

                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(
      BuildContext context,
      String title,
      String value,
      IconData icon,
      Color color,
      {VoidCallback? onTap}
      ) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.3), width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(height: 8),
              Text(
                value,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDashboardCard(BuildContext context, String title, IconData icon, Color color, VoidCallback onTap) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(12), // Reduced padding from 16 to 12
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withOpacity(0.9),
                color,
              ],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 28), // Reduced from 32 to 28
              const SizedBox(height: 6), // Reduced from 8 to 6
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14, // Reduced from 16 to 14
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}