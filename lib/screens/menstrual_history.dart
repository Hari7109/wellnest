import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MenstrualHistoryPage(),
    );
  }
}

class MenstrualHistoryPage extends StatefulWidget {
  const MenstrualHistoryPage({super.key});

  @override
  _MenstrualHistoryPageState createState() => _MenstrualHistoryPageState();
}

class _MenstrualHistoryPageState extends State<MenstrualHistoryPage> {
  bool isRegularCycle = true;
  List<String> symptoms = [];
  bool showOtherSymptoms = false;
  TextEditingController otherSymptomsController = TextEditingController();
  TextEditingController menarcheController = TextEditingController();

  void _toggleSymptom(String symptom) {
    setState(() {
      if (symptoms.contains(symptom)) {
        symptoms.remove(symptom);
      } else {
        symptoms.add(symptom);
      }
      showOtherSymptoms = symptoms.contains("Any other");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1976D2),
        title: const Text("Menstrual History"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Menarche attended", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              TextField(
                controller: menarcheController,
                decoration: const InputDecoration(hintText: "Enter age"),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 20),
              const Text("Menstrual Cycle", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Row(
                children: [
                  ChoiceChip(
                    label: const Text("Regular"),
                    selected: isRegularCycle,
                    onSelected: (selected) {
                      setState(() {
                        isRegularCycle = true;
                      });
                    },
                  ),
                  const SizedBox(width: 10),
                  ChoiceChip(
                    label: const Text("Irregular"),
                    selected: !isRegularCycle,
                    onSelected: (selected) {
                      setState(() {
                        isRegularCycle = false;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text("Associated Symptoms", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Wrap(
                spacing: 10,
                children: [
                  "Dysmenorrhea", "Vomiting", "Back Pain", "Any other"
                ].map((symptom) {
                  return ChoiceChip(
                    label: Text(symptom),
                    selected: symptoms.contains(symptom),
                    onSelected: (selected) => _toggleSymptom(symptom),
                  );
                }).toList(),
              ),
              if (showOtherSymptoms)
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: TextField(
                    controller: otherSymptomsController,
                    decoration: const InputDecoration(hintText: "Specify other symptoms"),
                  ),
                ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Navigate to the next page
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1976D2),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    textStyle: const TextStyle(fontSize: 18),
                  ),
                  child: const Text("Next"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
