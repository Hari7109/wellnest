import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

import 'chat_screen.dart';
import 'main.dart';

class StudentView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Choose a Specialist to Chat With:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .where('userType', isEqualTo: 'specialist')
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Center(child: Text("No specialists available"));
              }

              return ListView.builder(
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  final specialistDoc = snapshot.data!.docs[index];
                  final data = specialistDoc.data() as Map<String, dynamic>;

                  return ListTile(
                    leading: CircleAvatar(
                      child: Icon(Icons.person),
                    ),
                    title: Text(data['displayName'] ?? 'Unnamed Specialist'),
                    subtitle: Text(data['expertise'] ?? 'General Specialist'),
                    onTap: () => _startOrOpenChat(context, specialistDoc.id, data['displayName']),
                  );
                },
              );
            },
          ),
        ),

        Divider(),

        Expanded(
          child: _buildExistingChats(context),
        ),
      ],
    );
  }

  Widget _buildExistingChats(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Your Ongoing Chats:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('chats')
                .where('studentId', isEqualTo: userProvider.user!.uid)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Center(child: Text("No active chats"));
              }

              return ListView.builder(
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  final chatDoc = snapshot.data!.docs[index];
                  final data = chatDoc.data() as Map<String, dynamic>;

                  return ListTile(
                    title: Text(data['specialistName'] ?? 'Unknown Specialist'),
                    subtitle: Text(data['lastMessage'] ?? 'Start conversation'),
                    trailing: data['unreadStudent'] > 0
                        ? CircleAvatar(
                      radius: 10,
                      backgroundColor: Colors.red,
                      child: Text(
                        data['unreadStudent'].toString(),
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
                            otherUserName: data['specialistName'],
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Future<void> _startOrOpenChat(BuildContext context, String specialistId, String specialistName) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final studentId = userProvider.user!.uid;
    final studentName = userProvider.displayName;

    // Check if a chat already exists between these users
    final existingChatQuery = await FirebaseFirestore.instance
        .collection('chats')
        .where('specialistId', isEqualTo: specialistId)
        .where('studentId', isEqualTo: studentId)
        .limit(1)
        .get();

    String chatId;

    if (existingChatQuery.docs.isNotEmpty) {
      // Chat exists, use its ID
      chatId = existingChatQuery.docs.first.id;
    } else {
      // Create a new chat
      DocumentReference chatRef = await FirebaseFirestore.instance.collection('chats').add({
        'specialistId': specialistId,
        'studentId': studentId,
        'specialistName': specialistName,
        'studentName': studentName,
        'createdAt': FieldValue.serverTimestamp(),
        'lastMessage': 'New conversation',
        'lastMessageTime': FieldValue.serverTimestamp(),
        'unreadSpecialist': 1,
        'unreadStudent': 0,
      });

      chatId = chatRef.id;

      // Add a system message to start the conversation
      await FirebaseFirestore.instance.collection('chats').doc(chatId).collection('messages').add({
        'text': 'Chat started with $specialistName',
        'senderId': 'system',
        'senderName': 'System',
        'timestamp': FieldValue.serverTimestamp(),
        'type': 'system'
      });
    }

    // Navigate to chat screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(
          chatId: chatId,
          otherUserName: specialistName,
        ),
      ),
    );
  }
}
