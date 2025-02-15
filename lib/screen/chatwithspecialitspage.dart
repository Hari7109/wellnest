import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Specialists Page',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Inter Tight',
      ),
      home: const SpecialistspageWidget(),
    );
  }
}

class SpecialistspageWidget extends StatefulWidget {
  const SpecialistspageWidget({super.key});

  @override
  State<SpecialistspageWidget> createState() => _SpecialistspageWidgetState();
}

class _SpecialistspageWidgetState extends State<SpecialistspageWidget> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          color: Colors.white,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Talk with Specialists',
          style: TextStyle(
            fontFamily: 'Inter Tight',
            color: Colors.white,
            fontSize: 22.0,
          ),
        ),
        centerTitle: false,
        elevation: 2.0,
      ),
      body: SafeArea(
        top: true,
        child: SingleChildScrollView(
          child: Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.only(top: 20.0),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _buildSpecialistCard(context, "Dietitian"),
                  _buildSpecialistCard(context, "Psychologist"),
                  _buildSpecialistCard(context, "Physiotherapist"),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSpecialistCard(BuildContext context, String specialistType) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
      child: Container(
        width: double.infinity,
        height: 124.0,
        decoration: BoxDecoration(
          color: const Color(0xFFBFC3C3),
          borderRadius: BorderRadius.circular(22.0),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.only(left: 15.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Chat with Inhouse',
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 20.0,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      specialistType,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 20.0,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.only(right: 15.0),
                  child: ElevatedButton(
                    onPressed: () {
                      print('Chat with $specialistType pressed ...');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20.0, vertical: 10.0),
                      textStyle: const TextStyle(
                        fontFamily: 'Inter Tight',
                        color: Colors.white,
                      ),
                      elevation: 0.0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24.0),
                      ),
                    ),
                    child: const Text(
                      'Chat',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}