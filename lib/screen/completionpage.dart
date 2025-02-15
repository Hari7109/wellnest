import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Completion Page',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Inter Tight',
      ),
      home: const CompletionpageWidget(),
    );
  }
}

class CompletionpageWidget extends StatefulWidget {
  const CompletionpageWidget({super.key});

  @override
  State<CompletionpageWidget> createState() => _CompletionpageWidgetState();
}

class _CompletionpageWidgetState extends State<CompletionpageWidget> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: const BoxDecoration(
          image: DecorationImage(
            fit: BoxFit.cover,
            image: AssetImage('assets/images/completion.jpg'),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              'Great!!',
              style: const TextStyle(
                fontFamily: 'Inter Tight',
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0A2646),
              ),
            ),
            Text(
              'Everything is in its Place..',
              style: const TextStyle(
                fontFamily: 'Inter Tight',
                fontSize: 16,
                color: Color(0xFF0A2646),
              ),
            ),
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(0.0, 200.0, 0.0, 40.0),
              child: ElevatedButton(
                onPressed: () {
                  print('Button pressed ...');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0A2646),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20.0, vertical: 12.0), // Adjust padding
                  minimumSize: const Size(200.0, 40.0), // Set minimum size
                  textStyle: const TextStyle(
                    fontFamily: 'Inter Tight',
                    color: Colors.white,
                  ),
                  elevation: 0.0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                child: const Text('Continue'), // The text is here!
              ),
            ),
          ],
        ),
      ),
    );
  }
}