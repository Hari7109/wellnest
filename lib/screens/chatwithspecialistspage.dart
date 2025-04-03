import 'package:flutter/material.dart';
import 'DietitianChatPage.dart';
import 'PsychologistChatPage.dart';
import 'PhysiotherapistChatPage.dart';

class ChatWithSpecialistsPage extends StatelessWidget {
  const ChatWithSpecialistsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1976D2),
        title: const Text(
          "Talk with Specialists",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildSpecialistCard(
              context,
              "Inhouse Dietitian",
              const DietitianChatPage(),
            ),
            _buildSpecialistCard(
              context,
              "Inhouse Psychologist",
              const PsychologistChatPage(),
            ),
            _buildSpecialistCard(
              context,
              "Inhouse Physiotherapist",
              const PhysiotherapistChatPage(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpecialistCard(
      BuildContext context, String title, Widget chatPage) {
    return Card(
      color: Colors.grey[300],
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        title: Text.rich(
          TextSpan(
            text: "Chat with ",
            children: [
              TextSpan(
                text: title,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        trailing: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => chatPage),
            );
          },
          child: const Text("Chat"),
        ),
      ),
    );
  }
}

//
// import 'package:flutter/material.dart';
// import 'package:albertian_wellnest/screens/chat/chat_screen.dart';
//
// class ChatWithSpecialistsPage extends StatelessWidget {
//   final List<Map<String, String>> doctors = [
//     {'id': 'doctor1', 'name': 'Dr. John Doe'},
//     {'id': 'doctor2', 'name': 'Dr. Jane Smith'},
//     {'id': 'doctor3', 'name': 'Dr. Alice Johnson'},
//   ];
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Select a Doctor'),
//       ),
//       body: ListView.builder(
//         itemCount: doctors.length,
//         itemBuilder: (context, index) {
//           final doctor = doctors[index];
//           return ListTile(
//             title: Text(doctor['name']!),
//             onTap: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (context) => ChatScreen(
//                     chatId:
//                         'user1_${doctor['id']}', // Replace 'user1' with the logged-in user's ID
//                     recipientName: doctor['name']!,
//                   ),
//                 ),
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
// }
