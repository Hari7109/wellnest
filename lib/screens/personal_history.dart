import 'package:flutter/material.dart';
import 'immunization.dart';

class PersonalHistoryPage extends StatefulWidget {
  const PersonalHistoryPage({super.key});

  @override
  _PersonalHistoryPageState createState() => _PersonalHistoryPageState();
}

class _PersonalHistoryPageState extends State<PersonalHistoryPage> {
  String? dietaryPattern, sleep, bowelHabit, bladderHabit, hospitalization;
  String? hobbies, areaOfInterest, hospitalizationReason;
  bool showOtherHobbyField = false;
  bool showOtherInterestField = false;
  bool showHospitalizationReason = false;
  TextEditingController otherHobbyController = TextEditingController();
  TextEditingController otherInterestController = TextEditingController();
  TextEditingController hospitalizationController = TextEditingController();
  TextEditingController surgeriesController = TextEditingController();
  TextEditingController bloodTransfusionController = TextEditingController();
  TextEditingController allergyController = TextEditingController();

  List<String> communicableDiseases = [
    "Chickenpox", "Measles", "Mumps", "Jaundice", "TB", "Typhoid", "Malaria", "Dengue", "Chikungunya", "Pertussis"
  ];
  List<String> nonCommunicableDiseases = [
    "Congenital Heart Disease", "Asthma", "Hypertension", "Diabetes (DM)", "Cancer", "Pneumonia"
  ];

  Set<String> selectedCommunicable = {};
  Set<String> selectedNonCommunicable = {};

  bool get _isFormComplete {
    return dietaryPattern != null &&
        sleep != null &&
        bowelHabit != null &&
        bladderHabit != null &&
        hospitalization != null &&
        hobbies != null &&
        areaOfInterest != null &&
        (!showOtherHobbyField || otherHobbyController.text.isNotEmpty) &&
        (!showOtherInterestField || otherInterestController.text.isNotEmpty) &&
        (!showHospitalizationReason || hospitalizationController.text.isNotEmpty);
  }

  void _navigateToImmunizationPage() {
    if (_isFormComplete) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ImmunizationPage()),
      );
    }
  }

  Widget _buildCategory(String title, List<String> options, ValueChanged<String?> onChanged, String? selectedValue) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        Wrap(
          spacing: 8.0,
          children: options.map((option) {
            return ChoiceChip(
              label: Text(option),
              selected: selectedValue == option,
              onSelected: (selected) {
                setState(() {
                  onChanged(selected ? option : null);
                });
              },
              selectedColor: Colors.blue,
              backgroundColor: Colors.grey[300],
              labelStyle: TextStyle(color: selectedValue == option ? Colors.white : Colors.black),
            );
          }).toList(),
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _buildCheckboxGroup(String title, List<String> options, Set<String> selectedOptions) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        Wrap(
          spacing: 8.0,
          children: options.map((option) {
            return FilterChip(
              label: Text(option),
              selected: selectedOptions.contains(option),
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    selectedOptions.add(option);
                  } else {
                    selectedOptions.remove(option);
                  }
                });
              },
              selectedColor: Colors.blue,
              backgroundColor: Colors.grey[300],
              labelStyle: TextStyle(color: selectedOptions.contains(option) ? Colors.white : Colors.black),
            );
          }).toList(),
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _buildTextArea(String title, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        TextField(
          controller: controller,
          maxLines: 3,
          decoration: const InputDecoration(border: OutlineInputBorder(), hintText: "Enter details..."),
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Personal History")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCategory("Dietary Pattern", ["Vegetarian", "Non Vegetarian"], (val) => setState(() => dietaryPattern = val), dietaryPattern),
              _buildCategory("Sleep", ["Adequate", "Inadequate"], (val) => setState(() => sleep = val), sleep),
              _buildCategory("Bowel Habit", ["Regular", "Irregular"], (val) => setState(() => bowelHabit = val), bowelHabit),
              _buildCategory("Bladder Habit", ["Normal", "Abnormal"], (val) => setState(() => bladderHabit = val), bladderHabit),

              _buildCategory("Hobbies", ["Reading", "Stamp Collection", "Gardening", "Any other"], (val) {
                setState(() {
                  hobbies = val;
                  showOtherHobbyField = val == "Any other";
                });
              }, hobbies),
              if (showOtherHobbyField) _buildTextArea("Specify Hobby", otherHobbyController),

              _buildCategory("Area of Interest", ["Music", "Dance", "Sports", "Literature", "Any other"], (val) {
                setState(() {
                  areaOfInterest = val;
                  showOtherInterestField = val == "Any other";
                });
              }, areaOfInterest),
              if (showOtherInterestField) _buildTextArea("Specify Interest", otherInterestController),

              _buildCheckboxGroup("Communicable Diseases", communicableDiseases, selectedCommunicable),
              _buildCheckboxGroup("Non-Communicable Diseases", nonCommunicableDiseases, selectedNonCommunicable),

              _buildTextArea("Surgeries (if any)", surgeriesController),
              _buildTextArea("Blood Transfusion", bloodTransfusionController),
              _buildTextArea("Allergic to Medication/Other Items", allergyController),

              _buildCategory("Hospitalization", ["Yes", "No"], (val) {
                setState(() {
                  hospitalization = val;
                  showHospitalizationReason = val == "Yes";
                });
              }, hospitalization),
              if (showHospitalizationReason) _buildTextArea("Reason for hospitalization", hospitalizationController),

              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isFormComplete ? _navigateToImmunizationPage : null,
                  style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12), textStyle: const TextStyle(fontSize: 18)),
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
