import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'biodata.dart';
import 'change_password.dart';
import 'personal_history.dart';
import 'menstrual_history.dart';
import 'immunization.dart';

class StudentAccountPage extends StatefulWidget {
  const StudentAccountPage({super.key});

  @override
  _StudentAccountPageState createState() => _StudentAccountPageState();
}

class _StudentAccountPageState extends State<StudentAccountPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late Future<Map<String, dynamic>?> _userData;

  @override
  void initState() {
    super.initState();
    _userData = getUserData();
  }

  Future<Map<String, dynamic>?> getUserData() async {
    User? user = _auth.currentUser;
    if (user == null) return null;

    DocumentSnapshot doc = await _firestore.collection('bioData').doc(user.uid).get();
    if (doc.exists) {
      return doc.data() as Map<String, dynamic>;
    } else {
      return null;
    }
  }

  // Get avatar color based on name
  Color getAvatarColor(String name) {
    final List<Color> colors = [
      Colors.blue,
      Colors.purple,
      Colors.teal,
      Colors.indigo,
      Colors.pink,
      Colors.orange,
      Colors.green,
      Colors.deepPurple,
    ];

    // Simple hash function to get consistent color for the same name
    int hash = name.isEmpty ? 0 : name.codeUnitAt(0) % colors.length;
    return colors[hash];
  }

  // Get initials from full name
  String getInitials(String fullName) {
    if (fullName.isEmpty) return "?";

    List<String> nameParts = fullName.trim().split(" ");
    if (nameParts.length == 1) {
      return nameParts[0][0].toUpperCase();
    }

    // Get first letter of first name and first letter of last name
    String firstInitial = nameParts.first.isNotEmpty ? nameParts.first[0].toUpperCase() : "";
    String lastInitial = nameParts.last.isNotEmpty ? nameParts.last[0].toUpperCase() : "";

    return "$firstInitial$lastInitial";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "Student Account",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        // actions: [
        //   IconButton(
        //     icon: const Icon(Icons.settings_outlined, color: Colors.white),
        //     onPressed: () {
        //       // Settings action
        //     },
        //   ),
        // ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFF2A73D5),
              const Color(0xFF3E8AE6),
              Colors.blue.shade300,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: FutureBuilder<Map<String, dynamic>?>(
          future: _userData,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                ),
              );
            }
            if (snapshot.hasError || snapshot.data == null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 60, color: Colors.white.withOpacity(0.8)),
                    const SizedBox(height: 16),
                    Text(
                      "Failed to load profile data",
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _userData = getUserData();
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.blue,
                      ),
                      child: const Text("Retry"),
                    ),
                  ],
                ),
              );
            }

            var data = snapshot.data!;
            String name = data['name'] ?? "No Name";
            String email = _auth.currentUser?.email ?? "No Email";
            String sex = data['sex']?.toLowerCase() ?? "unknown";

            // Get initials from name
            String avatarText = getInitials(name);
            Color avatarColor = getAvatarColor(name);

            return SafeArea(
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 10),
                          // Profile card
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(3),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: LinearGradient(
                                      colors: [
                                        avatarColor.withOpacity(0.7),
                                        avatarColor,
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                  ),
                                  child: CircleAvatar(
                                    radius: 40,
                                    backgroundColor: Colors.white,
                                    child: CircleAvatar(
                                      radius: 38,
                                      backgroundColor: avatarColor,
                                      child: Text(
                                        avatarText,
                                        style: GoogleFonts.poppins(
                                          fontSize: avatarText.length > 1 ? 24 : 28,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 20),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        name,
                                        style: GoogleFonts.poppins(
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        email,
                                        style: GoogleFonts.poppins(
                                          fontSize: 14,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.blue.shade50,
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: Text(
                                              sex.capitalize(),
                                              style: GoogleFonts.poppins(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500,
                                                color: Colors.blue.shade700,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.blue.shade50,
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: Text(
                                              "Student",
                                              style: GoogleFonts.poppins(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500,
                                                color: Colors.blue.shade700,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 30),

                          // Section header
                          Padding(
                            padding: const EdgeInsets.only(left: 10),
                            child: Text(
                              "Health Information",
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),

                  // Grid items
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    sliver: SliverGrid(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 15,
                        mainAxisSpacing: 15,
                        childAspectRatio: 0.9,
                      ),
                      delegate: SliverChildListDelegate([
                        _buildOptionCard(
                          context,
                          "Biodata",
                          "Personal information and contact details",
                          Icons.person_outline,
                          Colors.indigo,
                              () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const BioDataProfilePage(),
                            ),
                          ),
                        ),
                        _buildOptionCard(
                          context,
                          "Personal History",
                          "Medical and health history records",
                          Icons.history,
                          Colors.teal,
                              () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const PersonalHistoryPage(),
                            ),
                          ),
                        ),
                        if (sex.trim().toLowerCase() == "female")
                          _buildOptionCard(
                            context,
                            "Menstrual History",
                            "Track your menstrual cycle",
                            Icons.calendar_today,
                            Colors.pink,
                                () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const MenstrualHistoryPage(),
                              ),
                            ),
                          ),
                        _buildOptionCard(
                          context,
                          "Immunization",
                          "Vaccination records and schedule",
                          Icons.health_and_safety_outlined,
                          Colors.green,
                              () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ImmunizationPage(),
                            ),
                          ),
                        ),
                        _buildOptionCard(
                          context,
                          "Change Password",
                          "Strong passwords, strong security",
                          Icons.password_sharp,
                          Colors.red,
                              () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ChangePasswordPage(),
                            ),
                          ),
                        ),

                      ]),
                    ),
                  ),

                  // Bottom padding
                  const SliverPadding(
                    padding: EdgeInsets.only(bottom: 40),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildOptionCard(
      BuildContext context,
      String title,
      String subtitle,
      IconData icon,
      Color color,
      VoidCallback onTap,
      ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 30,
                color: color,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                subtitle,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Extension method to capitalize the first letter of a string
extension StringExtension on String {
  String capitalize() {
    return isNotEmpty ? '${this[0].toUpperCase()}${substring(1)}' : '';
  }
}