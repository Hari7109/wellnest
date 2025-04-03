import 'package:albertian_wellnest/screens/studentprofile.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import 'chatwithspecialistspage.dart';
import 'home.dart';

// Enhanced ChatMessage model with reply functionality
class ChatMessage {
  final String id;
  final String senderId;
  final String senderName;
  final String text;
  final DateTime timestamp;
  final bool isEdited;
  final String? repostFrom;
  final String? repostFromName;
  final String? replyTo;
  final String? replyToName;
  final String? replyText;

  ChatMessage({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.text,
    required this.timestamp,
    this.isEdited = false,
    this.repostFrom,
    this.repostFromName,
    this.replyTo,
    this.replyToName,
    this.replyText,
  });

  factory ChatMessage.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    return ChatMessage(
      id: snapshot.id,
      senderId: data['senderId'],
      senderName: data['senderName'],
      text: data['text'],
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      isEdited: data['isEdited'] ?? false,
      repostFrom: data['repostFrom'],
      repostFromName: data['repostFromName'],
      replyTo: data['replyTo'],
      replyToName: data['replyToName'],
      replyText: data['replyText'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'senderName': senderName,
      'text': text,
      'timestamp': Timestamp.fromDate(timestamp),
      'isEdited': isEdited,
      'repostFrom': repostFrom,
      'repostFromName': repostFromName,
      'replyTo': replyTo,
      'replyToName': replyToName,
      'replyText': replyText,
    };
  }
}

// Chat Room Selection Page
class ChatRoomSelectionPage extends StatelessWidget {
  final List<Map<String, dynamic>> chatRooms = [
    {'id': 'general', 'name': 'General Discussion', 'icon': Icons.public, 'color': Colors.blue},
    //{'id': 'homework', 'name': 'Homework Help', 'icon': Icons.school, 'color': Colors.green},
    {'id': 'events', 'name': 'Events & Activities', 'icon': Icons.event, 'color': Colors.purple},
    {'id': 'resources', 'name': 'Study Resources', 'icon': Icons.book, 'color': Colors.orange},
   // {'id': 'tech', 'name': 'Technology', 'icon': Icons.computer, 'color': Colors.teal},
    {'id': 'career', 'name': 'Career Advice', 'icon': Icons.work, 'color': Colors.brown},
    {'id': 'sports', 'name': 'Sports', 'icon': Icons.sports_soccer, 'color': Colors.red},
   // {'id': 'arts', 'name': 'Arts & Culture', 'icon': Icons.palette, 'color': Colors.pink},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Chat Room'),
      ),
      body: GridView.builder(
        padding: EdgeInsets.all(16),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.2,
        ),
        itemCount: chatRooms.length,
        itemBuilder: (context, index) {
          final room = chatRooms[index];
          return _buildChatRoomCard(context, room);
        },
      ),
    );
  }

  Widget _buildChatRoomCard(BuildContext context, Map<String, dynamic> room) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CommunityChat(chatRoomId: room['id']),
          ),
        );
      },
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: room['color'].withOpacity(0.2),
              child: Icon(
                room['icon'],
                size: 30,
                color: room['color'],
              ),
            ),
            SizedBox(height: 12),
            Text(
              room['name'],
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// Updated Community Chat
class CommunityChat extends StatefulWidget {
  final String chatRoomId;

  const CommunityChat({Key? key, required this.chatRoomId}) : super(key: key);

  @override
  _CommunityChatState createState() => _CommunityChatState();
}

class _CommunityChatState extends State<CommunityChat> {
  final TextEditingController _messageController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? _editingMessageId;
  String? _currentUserId;
  String? _currentUserName;

  // For reply functionality
  String? _replyToId;
  String? _replyToName;
  String? _replyText;

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
  }

  void _getCurrentUser() async {
    final user = _auth.currentUser;
    if (user != null) {
      // Set a default username immediately
      setState(() {
        _currentUserId = user.uid;
        _currentUserName = user.displayName ?? user.email?.split('@')[0] ?? 'User';
      });

      try {
        // Then try to get the custom name from Firestore
        final userDoc = await _firestore.collection('users').doc(user.uid).get();
        if (userDoc.exists && userDoc.data()?['name'] != null) {
          setState(() {
            _currentUserName = userDoc.data()?['name'];
          });
        } else {
          // If document doesn't exist or doesn't have a name field, create it
          await _firestore.collection('users').doc(user.uid).set({
            'name': _currentUserName,
            'email': user.email,
            'lastActive': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
        }
      } catch (e) {
        print('Error getting user data: $e');
        // No need to update UI as we already set a default name
      }
    }
  }

  void _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    if (_editingMessageId != null) {
      // Update existing message
      await _firestore
          .collection('chatRooms')
          .doc(widget.chatRoomId)
          .collection('messages')
          .doc(_editingMessageId)
          .update({
        'text': _messageController.text.trim(),
        'isEdited': true,
      });
      setState(() {
        _editingMessageId = null;
      });
    } else {
      // Send new message
      final message = ChatMessage(
        id: '',
        senderId: _currentUserId!,
        senderName: _currentUserName!,
        text: _messageController.text.trim(),
        timestamp: DateTime.now(),
        replyTo: _replyToId,
        replyToName: _replyToName,
        replyText: _replyText,
      );

      await _firestore
          .collection('chatRooms')
          .doc(widget.chatRoomId)
          .collection('messages')
          .add(message.toMap());

      // Clear reply data
      setState(() {
        _replyToId = null;
        _replyToName = null;
        _replyText = null;
      });
    }

    _messageController.clear();
  }

  void _repostMessage(ChatMessage message) async {
    // Show dialog to add an optional comment for the repost
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Repost Message'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Original message by ${message.senderName}:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(message.text),
            ),
            SizedBox(height: 8),
            TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Add your comment (optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _messageController.clear();
            },
            child: Text('CANCEL'),
          ),
          TextButton(
            onPressed: () async {
              String repostComment = _messageController.text.trim();
              _messageController.clear();
              Navigator.pop(context);

              final repost = ChatMessage(
                id: '',
                senderId: _currentUserId!,
                senderName: _currentUserName!,
                text: repostComment.isEmpty ? "Reposted" : repostComment,
                timestamp: DateTime.now(),
                repostFrom: message.senderId,
                repostFromName: message.senderName,
                replyText: message.text,
              );

              await _firestore
                  .collection('chatRooms')
                  .doc(widget.chatRoomId)
                  .collection('messages')
                  .add(repost.toMap());

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Message reposted')),
              );
            },
            child: Text('REPOST'),
          ),
        ],
      ),
    );
  }

  void _replyToMessage(ChatMessage message) {
    setState(() {
      _replyToId = message.senderId;
      _replyToName = message.senderName;
      _replyText = message.text;
    });

    // Focus the message input field
    FocusScope.of(context).requestFocus(FocusNode());
  }

  void _cancelReply() {
    setState(() {
      _replyToId = null;
      _replyToName = null;
      _replyText = null;
    });
  }

  void _deleteMessage(String messageId) async {
    await _firestore
        .collection('chatRooms')
        .doc(widget.chatRoomId)
        .collection('messages')
        .doc(messageId)
        .delete();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Message deleted')),
    );
  }

  void _editMessage(ChatMessage message) {
    setState(() {
      _editingMessageId = message.id;
      _messageController.text = message.text;
    });
    FocusScope.of(context).requestFocus(FocusNode());
  }

  void _cancelEdit() {
    setState(() {
      _editingMessageId = null;
      _messageController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
        title: Text(widget.chatRoomId.toUpperCase() + ' Chat'),
    actions: [
    IconButton(
    icon: Icon(Icons.people),
    onPressed: () {
    // Show chat room members or other options
    },
    ),
    ],
    ),
    body: Column(
    children: [
    Expanded(
    child: StreamBuilder<QuerySnapshot>(
    stream: _firestore
        .collection('chatRooms')
        .doc(widget.chatRoomId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots(),
    builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
    return Center(child: CircularProgressIndicator());
    }

    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
    return Center(child: Text('No messages yet'));
    }

    final messages = snapshot.data!.docs
        .map((doc) => ChatMessage.fromSnapshot(doc))
        .toList();

    return ListView.builder(
    reverse: true,
    itemCount: messages.length,
    itemBuilder: (context, index) {
    final message = messages[index];
    final isCurrentUser = message.senderId == _currentUserId;

    return Slidable(
    enabled: isCurrentUser,
    endActionPane: ActionPane(
    motion: const ScrollMotion(),
    children: [
    SlidableAction(
    onPressed: (_) => _editMessage(message),
    backgroundColor: Colors.blue,
    foregroundColor: Colors.white,
    icon: Icons.edit,
    label: 'Edit',
    ),
    SlidableAction(
    onPressed: (_) => _deleteMessage(message.id),
    backgroundColor: Colors.red,
    foregroundColor: Colors.white,
    icon: Icons.delete,
    label: 'Delete',
    ),
    ],
    ),
    startActionPane: ActionPane(
    motion: const ScrollMotion(),
    children: [
    SlidableAction(
    onPressed: (_) => _replyToMessage(message),
    backgroundColor: Colors.green,
    foregroundColor: Colors.white,
    icon: Icons.reply,
    label: 'Reply',
    ),
    SlidableAction(
    onPressed: (_) => _repostMessage(message),
    backgroundColor: Colors.orange,
    foregroundColor: Colors.white,
    icon: Icons.repeat,
    label: 'Repost',
    ),
    ],
    ),
    child: GestureDetector(
    onLongPress: () => _showMessageOptions(message, isCurrentUser),
    child: Container(
    margin: EdgeInsets.symmetric(
    horizontal: 8,
    vertical: 4,
    ),
    padding: EdgeInsets.all(12),
    decoration: BoxDecoration(
    color: isCurrentUser
    ? Colors.blue.shade100
        : Colors.grey.shade200,
    borderRadius: BorderRadius.circular(12),
    ),
    child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
    // Header: username and timestamp
    Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
    Text(
    isCurrentUser ? 'You' : message.senderName,
    style: TextStyle(
    fontWeight: FontWeight.bold,
    color: Colors.black87,
    ),
    ),
    Text(
    DateFormat('HH:mm').format(message.timestamp),
    style: TextStyle(
    fontSize: 12,
    color: Colors.black54,
    ),
    ),
    ],
    ),
      // Reply section (if this is a reply to someone)
      if (message.replyTo != null) ...[
        SizedBox(height: 4),
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Colors.grey.shade400,
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Reply to ${message.replyToName}',
                style: TextStyle(
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                  color: Colors.black54,
                ),
              ),
              SizedBox(height: 4),
              Text(
                message.replyText ?? '',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.black87,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],

      // Repost section
      if (message.repostFrom != null) ...[
        SizedBox(height: 8),
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Colors.grey.shade400,
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.repeat, size: 16, color: Colors.black54),
                  SizedBox(width: 4),
                  Text(
                    'Reposted from ${message.repostFromName}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 6),
              Text(
                message.replyText ?? '',  // We're using replyText to store the original message
                style: TextStyle(fontSize: 14),
              ),
            ],
          ),
        ),
        SizedBox(height: 8),
        // Only show the repost comment if it's not just "Reposted"
        if (message.text != "Reposted")
          Text(message.text),
      ] else ...[
        SizedBox(height: 8),
        Text(message.text),
      ],

      if (message.isEdited) ...[
        SizedBox(height: 4),
        Text(
          '(edited)',
          style: TextStyle(
            fontSize: 12,
            fontStyle: FontStyle.italic,
            color: Colors.black54,
          ),
        ),
      ],
    ],
    ),
    ),
    ),
    );
    },
    );
    },
    ),
    ),
      // Reply indicator
      if (_replyToId != null)
        Container(
          color: Colors.grey.shade200,
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Icon(Icons.reply, size: 16, color: Colors.grey.shade700),
              SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Replying to ${_replyToName}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      _replyText ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(Icons.close, size: 16),
                padding: EdgeInsets.all(4),
                constraints: BoxConstraints(),
                onPressed: _cancelReply,
              ),
            ],
          ),
        ),
      // Edit indicator
      if (_editingMessageId != null)
        Container(
          color: Colors.amber.shade100,
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Editing message...',
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),
              ),
              IconButton(
                icon: Icon(Icons.close),
                onPressed: _cancelEdit,
              ),
            ],
          ),
        ),
      // Message input
      Container(
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              offset: Offset(0, -1),
              blurRadius: 4,
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _messageController,
                decoration: InputDecoration(
                  hintText: 'Type a message',
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade200,
                ),
                textCapitalization: TextCapitalization.sentences,
                maxLines: null,
              ),
            ),
            SizedBox(width: 8),
            CircleAvatar(
              backgroundColor: Theme.of(context).primaryColor,
              child: IconButton(
                icon: Icon(
                  _editingMessageId != null ? Icons.check : Icons.send,
                  color: Colors.white,
                ),
                onPressed: _sendMessage,
              ),
            ),
          ],
        ),
      ),
    ],
    ),
    );
  }

  void _showMessageOptions(ChatMessage message, bool isCurrentUser) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.reply),
                title: Text('Reply to Message'),
                onTap: () {
                  Navigator.pop(context);
                  _replyToMessage(message);
                },
              ),
              ListTile(
                leading: Icon(Icons.repeat),
                title: Text('Repost Message'),
                onTap: () {
                  Navigator.pop(context);
                  _repostMessage(message);
                },
              ),
              if (isCurrentUser) ...[
                ListTile(
                  leading: Icon(Icons.edit),
                  title: Text('Edit Message'),
                  onTap: () {
                    Navigator.pop(context);
                    _editMessage(message);
                  },
                ),
                ListTile(
                  leading: Icon(Icons.delete),
                  title: Text('Delete Message'),
                  onTap: () {
                    Navigator.pop(context);
                    _deleteMessage(message.id);
                  },
                ),
              ],
              ListTile(
                leading: Icon(Icons.cancel),
                title: Text('Cancel'),
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      },
    );
  }
}

// Modified version of _HomePageState to include the button for ChatRoomSelectionPage
// class _HomePageState extends State<HomePage> {
//   int _selectedIndex = 0;
//   final List<Widget> _pages = [
//     HomePageContent(),
//     ChatWithSpecialistsPage(),
//     CommunityEntryPage(), // Changed from direct CommunityChat to entry page
//     StudentProfile(),
//   ];
//
//   void _onItemTapped(int index) {
//     setState(() {
//       _selectedIndex = index;
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: _pages[_selectedIndex],
//       bottomNavigationBar: BottomNavigationBar(
//         type: BottomNavigationBarType.fixed,
//         currentIndex: _selectedIndex,
//         onTap: _onItemTapped,
//         items: [
//           BottomNavigationBarItem(
//             icon: Icon(Icons.home),
//             label: 'Home',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.chat),
//             label: 'Specialists',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.forum),
//             label: 'Community',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.person),
//             label: 'Profile',
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// // New entry page for Community section that has button to select chat rooms
// class CommunityEntryPage extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Community'),
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Image.asset(
//               'assets/community_icon.png', // Replace with your asset
//               height: 150,
//               width: 150,
//               fit: BoxFit.contain,
//               errorBuilder: (context, error, stackTrace) => Icon(
//                 Icons.forum,
//                 size: 150,
//                 color: Colors.grey,
//               ),
//             ),
//             SizedBox(height: 24),
//             Text(
//               'Join the Conversation',
//               style: TextStyle(
//                 fontSize: 24,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             SizedBox(height: 8),
//             Text(
//               'Connect with other students in different chat rooms',
//               textAlign: TextAlign.center,
//               style: TextStyle(
//                 fontSize: 16,
//                 color: Colors.grey.shade700,
//               ),
//             ),
//             SizedBox(height: 40),
//             ElevatedButton.icon(
//               onPressed: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) => ChatRoomSelectionPage(),
//                   ),
//                 );
//               },
//               icon: Icon(Icons.forum),
//               label: Text('Browse Chat Rooms'),
//               style: ElevatedButton.styleFrom(
//                 padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
//                 textStyle: TextStyle(fontSize: 18),
//               ),
//             ),
//             SizedBox(height: 16),
//             OutlinedButton.icon(
//               onPressed: () {
//                 // Direct entry to general chat
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) => CommunityChat(chatRoomId: 'general'),
//                   ),
//                 );
//               },
//               icon: Icon(Icons.arrow_forward),
//               label: Text('Go to General Chat'),
//               style: OutlinedButton.styleFrom(
//                 padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
//                 textStyle: TextStyle(fontSize: 16),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }