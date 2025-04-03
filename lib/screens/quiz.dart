// quiz.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class QuizPage extends StatefulWidget {
  const QuizPage({super.key});

  @override
  _QuizPageState createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  final List<Map<String, dynamic>> _questions = [
    {
      "question": "Been able to concentrate well on what you're doing?",
      "options": ["Always", "Frequently", "Sometimes", "Never"]
    },
    {
      "question": "Felt you were playing a useful part in things?",
      "options": ["Always", "Frequently", "Sometimes", "Never"]
    },
    {
      "question": "Felt capable of making decisions about things?",
      "options": ["Always", "Frequently", "Sometimes", "Never"]
    },
    {
      "question": "Been able to enjoy your normal day to day activities?",
      "options": ["Always", "Frequently", "Sometimes", "Never"]
    },
    {
      "question": "Been able to face up to your problems?",
      "options": ["Always", "Frequently", "Sometimes", "Never"]
    },
    {
      "question": "Been feeling reasonably happy, all things considered?",
      "options": ["Always", "Frequently", "Sometimes", "Never"]
    },
    {
      "question": "Lost much sleep over worry?",
      "options": ["Never", "Sometimes", "Frequently", "Always"]
    },
    {
      "question": "Felt constantly under strain?",
      "options": ["Never", "Sometimes", "Frequently", "Always"]
    },
    {
      "question": "Felt you couldn't overcome your difficulties?",
      "options": ["Never", "Sometimes", "Frequently", "Always"]
    },
    {
      "question": "Been feeling unhappy and depressed?",
      "options": ["Never", "Sometimes", "Frequently", "Always"]
    },
    {
      "question": "Been losing confidence in yourself?",
      "options": ["Never", "Sometimes", "Frequently", "Always"]
    },
    {
      "question": "Been thinking of yourself as a worthless person?",
      "options": ["Never", "Sometimes", "Frequently", "Always"]
    },
  ];

  final Map<int, int> _answers = {};

  int calculateScore() {
    int score = 0;
    for (int i = 0; i < _questions.length; i++) {
      if (_answers[i] != null) {
        score += (_answers[i]! >= 2) ? 1 : 0;
      }
    }
    return score;
  }

  Future<void> _saveQuizResult(int score, double rating) async {
    String userId = FirebaseAuth.instance.currentUser?.uid ?? "guest";
    await FirebaseFirestore.instance.collection("quiz_results").doc(userId).set({
      // "userId": userId,
      "score": score,
      "rating": rating,
      "timestamp": FieldValue.serverTimestamp(),
      "responses": _answers.map((key, value) =>
          MapEntry(_questions[key]["question"], _questions[key]["options"][value])),
    });
  }

  void _submitQuiz() async {
    int totalScore = _answers.values.where((v) => v >= 2).length;
    double rating = 5.0 - (totalScore / 3.0);

    await _saveQuizResult(totalScore, rating);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Quiz Result"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Your Score: $totalScore"),
            RatingBarIndicator(
              rating: rating,
              itemBuilder: (context, index) => const Icon(Icons.star, color: Colors.amber),
              itemCount: 5,
              itemSize: 30.0,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            const Text("Mental Health Quiz", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            const Text("Please answer the following questions honestly.",
                style: TextStyle(fontSize: 16)),
            const SizedBox(height: 20),
            Expanded(
              child: ListView(
                children: _questions.asMap().entries.map((entry) {
                  int index = entry.key;
                  var question = entry.value;
                  return Card(
                    elevation: 3,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(question["question"],
                              style: const TextStyle(fontWeight: FontWeight.bold)),
                          ...List.generate(question["options"].length, (i) {
                            return RadioListTile(
                              title: Text(question["options"][i]),
                              value: i,
                              groupValue: _answers[index],
                              onChanged: (value) {
                                setState(() => _answers[index] = value as int);
                              },
                            );
                          }),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            Center(
              child: ElevatedButton(
                onPressed: _submitQuiz,
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  textStyle:
                      const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                child: const Text("Submit Quiz"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
