import 'package:albertian_wellnest/screens/specialist/specialist_dashboard.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:albertian_wellnest/screens/change_password.dart';
import 'package:albertian_wellnest/screens/bio_data_form.dart';
import 'package:albertian_wellnest/screens/home.dart';
import 'package:albertian_wellnest/screens/teacher/teacher_dashboard.dart';

import 'admin/admin_dashboard.dart';


final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
final FirebaseFirestore _firestore = FirebaseFirestore.instance;

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool _obscureText = true;

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      try {
        final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
        );

        String uid = userCredential.user!.uid;

        // Fetch user data from Firestore
        DocumentSnapshot userDoc = await _firestore.collection('users').doc(uid).get();

        if (userDoc.exists && userDoc.data() != null) {
          Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
          String role = userData['role'] ?? 'user';
          bool isFirstLogin = userData['first_login'] ?? true;

          debugPrint("User Role: $role"); // Debugging output
          debugPrint("First Login: $isFirstLogin");

          if (isFirstLogin) {
            Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => ChangePasswordPage()),
            );

            // Update first_login status after password change
            await _firestore.collection('users').doc(uid).update({
              'first_login': false,
            });
          } else {
            // Navigate based on role
            switch (role) {
              case "admin":
                Navigator.pushReplacement(
                  context, MaterialPageRoute(builder: (context) => const AdminDashboard()),
                );
                break;
              case "teacher":
                Navigator.pushReplacement(
                  context, MaterialPageRoute(builder: (context) => const TeacherDashboard()),
                );
                break;
              case "specialist":
                Navigator.pushReplacement(
                  context, MaterialPageRoute(builder: (context) => const SpecialistDashboard()),
                );
                break;
              default:
                Navigator.pushReplacement(
                  context, MaterialPageRoute(builder: (context) => const HomePage()),
                );
                break;
            }
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("User data not found. Contact admin.")),
          );
        }
      } on FirebaseAuthException catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.message ?? 'Authentication failed')),
        );
      } catch (e) {
        debugPrint("Error: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("An error occurred. Try again.")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Image.asset('assets/images/loginlogo.png', height: 250),
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    'FOR TRUTH AND SERVICE',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Welcome To',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const Text(
                  'Albertian Wellnest',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty || !value.contains('@')) {
                      return 'Please enter a valid email address';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: passwordController,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(_obscureText ? Icons.visibility_off : Icons.visibility),
                      onPressed: () {
                        setState(() {
                          _obscureText = !_obscureText;
                        });
                      },
                    ),
                  ),
                  obscureText: _obscureText,
                  validator: (value) {
                    if (value == null || value.trim().length < 6) {
                      return 'Password must be at least 6 characters long';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    backgroundColor: const Color(0xFF303F9F),
                  ),
                  child: const Text(
                    'Sign In',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
