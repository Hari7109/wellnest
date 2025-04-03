import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ImmunizationPage extends StatefulWidget {
  const ImmunizationPage({super.key});

  @override
  _ImmunizationPageState createState() => _ImmunizationPageState();
}

class _ImmunizationPageState extends State<ImmunizationPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Map<String, dynamic>> vaccines = [
    {"name": "Hepatitis B", "firstDose": null, "secondDose": null, "thirdDose": null},
    {"name": "Rubella", "firstDose": null, "secondDose": null, "thirdDose": null},
  ];
  bool showOtherVaccineField = false;
  TextEditingController otherVaccineController = TextEditingController();
  List<Map<String, dynamic>> otherVaccines = [];

  @override
  void initState() {
    super.initState();
    _loadImmunizationData();
  }

  Future<void> _loadImmunizationData() async {
    User? user = _auth.currentUser;
    if (user == null) return;

    DocumentSnapshot doc = await _firestore.collection('immunization').doc(user.uid).get();

    if (doc.exists) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

      setState(() {
        vaccines = [
          {"name": "Hepatitis B", "firstDose": data["hepatitisB"]["firstDose"], "secondDose": data["hepatitisB"]["secondDose"], "thirdDose": data["hepatitisB"]["thirdDose"]},
          {"name": "Rubella", "firstDose": data["rubella"]["firstDose"], "secondDose": data["rubella"]["secondDose"], "thirdDose": data["rubella"]["thirdDose"]}
        ];

        if (data.containsKey("otherVaccines")) {
          otherVaccines = List<Map<String, dynamic>>.from(data["otherVaccines"]);
          showOtherVaccineField = otherVaccines.isNotEmpty;
        }
      });
    }
  }

  Future<void> _submitForm() async {
    User? user = _auth.currentUser;
    if (user == null) return;

    Map<String, dynamic> dataToSave = {
      "hepatitisB": {
        "firstDose": vaccines[0]["firstDose"],
        "secondDose": vaccines[0]["secondDose"],
        "thirdDose": vaccines[0]["thirdDose"],
      },
      "rubella": {
        "firstDose": vaccines[1]["firstDose"],
        "secondDose": vaccines[1]["secondDose"],
        "thirdDose": vaccines[1]["thirdDose"],
      },
      "otherVaccines": otherVaccines,
      "updatedAt": FieldValue.serverTimestamp(),
    };

    await _firestore.collection('immunization').doc(user.uid).set(dataToSave, SetOptions(merge: true));

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Immunization details updated!")));
  }

  Widget _buildVaccineCard(Map<String, dynamic> vaccine, {VoidCallback? onDelete}) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text(vaccine["name"], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
                if (onDelete != null)
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: onDelete,
                  ),
              ],
            ),
            const SizedBox(height: 10),
            _buildDoseSelector("First Dose", (value) => setState(() => vaccine["firstDose"] = value), vaccine["firstDose"]),
            _buildDoseSelector("Second Dose", (value) => setState(() => vaccine["secondDose"] = value), vaccine["secondDose"]),
            _buildDoseSelector("Third Dose", (value) => setState(() => vaccine["thirdDose"] = value), vaccine["thirdDose"]),
          ],
        ),
      ),
    );
  }

  Widget _buildDoseSelector(String title, ValueChanged<bool?> onChanged, bool? selectedValue) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 16)),
          Row(
            children: [
              _buildToggleButton("✔", true, selectedValue, onChanged),
              const SizedBox(width: 10),
              _buildToggleButton("✘", false, selectedValue, onChanged),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildToggleButton(String label, bool value, bool? groupValue, ValueChanged<bool?> onChanged) {
    return GestureDetector(
      onTap: () => onChanged(value),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color: groupValue == value ? Colors.blueAccent : Colors.grey[300],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: groupValue == value ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }

  void _addOtherVaccine() {
    if (otherVaccineController.text.isNotEmpty) {
      setState(() {
        otherVaccines.add({
          "name": otherVaccineController.text,
          "firstDose": null,
          "secondDose": null,
          "thirdDose": null,
        });
        otherVaccineController.clear();
      });
    }
  }

  void _removeOtherVaccine(int index) {
    setState(() {
      otherVaccines.removeAt(index);
      if (otherVaccines.isEmpty) showOtherVaccineField = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Immunization")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ...vaccines.map((vaccine) => _buildVaccineCard(vaccine)),

              GestureDetector(
                onTap: () => setState(() => showOtherVaccineField = !showOtherVaccineField),
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Text("+ Add Another Vaccine", style: TextStyle(fontSize: 16, color: Colors.blueAccent, fontWeight: FontWeight.bold)),
                ),
              ),

              if (showOtherVaccineField)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: otherVaccineController,
                      decoration: const InputDecoration(labelText: "Enter Vaccine Name"),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: _addOtherVaccine,
                      child: const Text("Add Vaccine"),
                    ),
                  ],
                ),

              ...otherVaccines.asMap().entries.map((entry) {
                int index = entry.key;
                Map<String, dynamic> vaccine = entry.value;
                return _buildVaccineCard(vaccine, onDelete: () => _removeOtherVaccine(index));
              }),

              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitForm,
                  child: const Text("Save & Update"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
