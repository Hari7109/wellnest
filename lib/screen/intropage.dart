import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Albertian WellNest',
      theme: ThemeData(
        primarySwatch: Colors.blue, // Customize your theme if needed
        fontFamily: 'Lexend Deca', // Set default font family
      ),
      home: const IntroWidget(),
    );
  }
}

class IntroWidget extends StatefulWidget {
  const IntroWidget({super.key});

  @override
  State<IntroWidget> createState() => _IntroWidgetState();
}

class _IntroWidgetState extends State<IntroWidget> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        top: true,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(0.0, 50.0, 0.0, 0.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Image.asset(
                  'assets/images/albertslogo.png',
                  width: 548.0,
                  height: 392.0,
                  fit: BoxFit.cover,
                  alignment: Alignment.center, // Changed to center alignment for better fit.
                  errorBuilder: (context, object, stackTrace) {
                    print('Error loading logo: $object');
                    return const Icon(Icons.error);
                  },
                ),
              ),
            ),
            Align(
              alignment: AlignmentDirectional.bottomCenter, // Align text to the bottom center
              child: Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 50.0),
                child: Text(
                  'Albertian WellNest',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'Lexend Deca',
                    fontSize: 16.0,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
            Padding( // Added padding for the button
              padding: const EdgeInsets.only(bottom: 35.0), // Adjust as needed
              child: ElevatedButton( // Replaced FFButtonWidget with ElevatedButton
                onPressed: () {
                  print('Button pressed ...');
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 30.0),
                  backgroundColor: const Color(0xFF63B6EA), // Background color
                  textStyle: const TextStyle(
                    fontFamily: 'Inter Tight',
                    color: Colors.white,
                  ),
                  elevation: 10.0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                child: const Text('Get Started ➔'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}