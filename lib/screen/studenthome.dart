import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Swasthi App',
      theme: ThemeData(
        primarySwatch: Colors.blue, // You can customize the theme
        fontFamily: 'Inter', // Default font family
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        top: true,
        child: Container(
          decoration: const BoxDecoration(),
          child: Stack(
            children: [
              Image.asset(
                'assets/images/homebg.jpg',
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, object, stackTrace) {
                  print('Error loading background image: $object');
                  return const Icon(Icons.error);
                },
              ),
              Align(
                alignment: const AlignmentDirectional(0.02, 0.0),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(
                          0.0, 80.0, 0.0, 0.0),
                      child: Container(
                        width: 362.0,
                        height: 277.0,
                        decoration: BoxDecoration(
                          color: const Color(0xFF1072B1),
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsetsDirectional.fromSTEB(
                                  10.0, 10.0, 0.0, 0.0),
                              child: Text(
                                'Welcome to Swasthi',
                                style: const TextStyle( // Use TextStyle directly
                                  fontFamily: 'Inter Tight',
                                  color: Colors.white,
                                  fontSize: 24, // Example size
                                  fontWeight: FontWeight.bold, // Example weight
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsetsDirectional.fromSTEB(
                                  10.0, 0.0, 0.0, 0.0),
                              child: Text(
                                'Your Wellness Management App',
                                style: const TextStyle( // Use TextStyle directly
                                  fontFamily: 'Inter',
                                  color: Colors.white,
                                  fontSize: 16, // Example size
                                ),
                              ),
                            ),
                            Expanded(
                              child: Align(
                                alignment: AlignmentDirectional.bottomEnd,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8.0),
                                  child: Image.asset(
                                    'assets/images/doctor.png',
                                    width: 237.0,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, object, stackTrace) {
                                      print(
                                          'Error loading doctors image: $object');
                                      return const Icon(Icons.error);
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
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
}