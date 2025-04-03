import 'package:albertian_wellnest/screens/chat/student_view.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

import 'chat_screen.dart';
import 'main.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Chat Dashboard'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
            },
          )
        ],
      ),
      body: userProvider.userType == 'specialist'
          ? SpecialistView()
          : StudentView(),
    );
  }
}

// specialist_view.dart
class SpecialistView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('chats')
          .where('specialistId', isEqualTo: userProvider.user!.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text("No active chats yet"));
        }

        return ListView.builder(
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final chatDoc = snapshot.data!.docs[index];
            final data = chatDoc.data() as Map<String, dynamic>;

            return ListTile(
              title: Text(data['studentName'] ?? 'Unknown Student'),
              subtitle: Text(data['lastMessage'] ?? 'Start conversation'),
              trailing: data['unreadSpecialist'] > 0
                  ? CircleAvatar(
                radius: 10,
                backgroundColor: Colors.red,
                child: Text(
                  data['unreadSpecialist'].toString(),
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              )
                  : null,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatScreen(
                      chatId: chatDoc.id,
                      otherUserName: data['studentName'],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
