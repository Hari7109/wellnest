import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DietitianChatPage extends StatefulWidget {
  const DietitianChatPage({super.key});

  @override
  _DietitianChatPageState createState() => _DietitianChatPageState();
}

class _DietitianChatPageState extends State<DietitianChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user ID
  String get _userId => _auth.currentUser?.uid ?? '';
  String get _userName => _auth.currentUser?.displayName ?? 'Student';

  // Conversation ID (will be generated on init)
  String _conversationId = '';
  String _doctorId = ''; // Will store dietitian's ID

  @override
  void initState() {
    super.initState();
    _initializeChat();
  }

  Future<void> _initializeChat() async {
    // Find dietitian user
    final dietitianQuery = await _firestore
        .collection('users')
        .where('role', isEqualTo: 'dietitian')
        .limit(1)
        .get();

    if (dietitianQuery.docs.isEmpty) {
      // Handle case with no dietitian
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No dietitian available at the moment')));
      return;
    }

    _doctorId = dietitianQuery.docs.first.id;

    // Check if conversation already exists
    final existingConversationQuery = await _firestore
        .collection('conversations')
        .where('participants', arrayContains: _userId)
        .where('doctorType', isEqualTo: 'dietitian')
        .limit(1)
        .get();

    if (existingConversationQuery.docs.isNotEmpty) {
      // Use existing conversation
      _conversationId = existingConversationQuery.docs.first.id;
    } else {
      // Create new conversation
      DocumentReference newConversationRef =
          await _firestore.collection('conversations').add({
        'participants': [_userId, _doctorId],
        'doctorType': 'dietitian',
        'lastMessage': '',
        'lastMessageTimestamp': FieldValue.serverTimestamp(),
        'lastMessageSenderId': '',
        'createdAt': FieldValue.serverTimestamp()
      });

      _conversationId = newConversationRef.id;
    }

    // Mark existing messages as read
    _markMessagesAsRead();
  }

  void _markMessagesAsRead() {
    _firestore
        .collection('messages')
        .where('conversationId', isEqualTo: _conversationId)
        .where('receiverId', isEqualTo: _userId)
        .where('isRead', isEqualTo: false)
        .get()
        .then((snapshot) {
      for (var doc in snapshot.docs) {
        doc.reference.update({'isRead': true});
      }
    });
  }

  void _sendMessage() async {
    if (_messageController.text.trim().isEmpty || _conversationId.isEmpty) {
      return;
    }

    final messageText = _messageController.text.trim();
    _messageController.clear();

    // Add message to Firestore
    await _firestore.collection('messages').add({
      'conversationId': _conversationId,
      'senderId': _userId,
      'senderName': _userName,
      'receiverId': _doctorId,
      'content': messageText,
      'timestamp': FieldValue.serverTimestamp(),
      'isRead': false
    });

    // Update conversation with last message
    await _firestore.collection('conversations').doc(_conversationId).update({
      'lastMessage': messageText,
      'lastMessageTimestamp': FieldValue.serverTimestamp(),
      'lastMessageSenderId': _userId
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1976D2),
        title: const Text("Chat with Inhouse Dietitian",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
      ),
      body: Column(
        children: [
          Expanded(
            child: _conversationId.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : StreamBuilder<QuerySnapshot>(
                    stream: _firestore
                        .collection('messages')
                        .where('conversationId', isEqualTo: _conversationId)
                        .orderBy('timestamp', descending: true)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (snapshot.hasError) {
                        return const Center(child: Text('Error loading messages'));
                      }

                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return const Center(
                          child:
                              Text('No messages yet. Start the conversation!'),
                        );
                      }

                      final messages = snapshot.data!.docs;

                      return ListView.builder(
                        reverse: true,
                        padding: const EdgeInsets.all(10.0),
                        itemCount: messages.length,
                        itemBuilder: (context, index) {
                          final message =
                              messages[index].data() as Map<String, dynamic>;
                          final isUser = message['senderId'] == _userId;

                          return Align(
                            alignment: isUser
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: Container(
                              padding: const EdgeInsets.all(10.0),
                              margin: const EdgeInsets.symmetric(
                                  vertical: 5.0, horizontal: 10.0),
                              decoration: BoxDecoration(
                                color: isUser ? Colors.blue : Colors.grey[300],
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (!isUser)
                                    const Text(
                                      'Dietitian',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                          color: Colors.black54),
                                    ),
                                  Text(
                                    message['content'] ?? '',
                                    style: TextStyle(
                                        color: isUser
                                            ? Colors.white
                                            : Colors.black,
                                        fontSize: 16),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: "Type your message...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.blue),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
