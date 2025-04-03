import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'screens/home.dart';
import 'package:albertian_wellnest/screens/admin/admin_dashboard.dart';
import 'package:albertian_wellnest/screens/teacher/teacher_dashboard.dart';
import 'package:albertian_wellnest/screens/specialist/specialist_dashboard.dart';
import 'package:albertian_wellnest/screens/auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AuthCheck(), // Check user authentication state
    );
  }
}

class AuthCheck extends StatelessWidget {
  const AuthCheck({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        if (snapshot.hasData) {
          final String uid = snapshot.data!.uid;
          return FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance.collection('users').doc(uid).get(),
            builder: (context, userSnapshot) {
              if (userSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(body: Center(child: CircularProgressIndicator()));
              }

              if (userSnapshot.hasError) {
                return ErrorScreen(message: "Error loading user data");
              }

              if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
                return ErrorScreen(message: "User profile not found");
              }

              final data = userSnapshot.data!.data() as Map<String, dynamic>;
              final String role = data['role'] ?? 'user';

              // Redirecting after build
              return RedirectBasedOnRole(role: role);
            },
          );
        } else {
          return const LoginPage();
        }
      },
    );
  }
}

class RedirectBasedOnRole extends StatefulWidget {
  final String role;
  const RedirectBasedOnRole({super.key, required this.role});

  @override
  State<RedirectBasedOnRole> createState() => _RedirectBasedOnRoleState();
}

class _RedirectBasedOnRoleState extends State<RedirectBasedOnRole> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      if (widget.role == "admin") {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const AdminDashboard()));
      } else if (widget.role == "teacher") {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const TeacherDashboard()));
      } else if (widget.role == "specialist") {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const SpecialistDashboard()));
      } else {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomePage()));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}

class ErrorScreen extends StatelessWidget {
  final String message;
  const ErrorScreen({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(message),
            ElevatedButton(
              onPressed: () => FirebaseAuth.instance.signOut(),
              child: const Text("Sign Out"),
            ),
          ],
        ),
      ),
    );
  }
}
