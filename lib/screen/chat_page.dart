import 'package:flutter/material.dart';

class ChatPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text("Doctor Chat"),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: 10, // Sample messages
              itemBuilder: (context, index) {
                return ListTile(
                  leading: const Icon(Icons.person),
                  title: Text("Student ${index + 1}"),
                  subtitle: Text("Hello Doctor, I have a query."),
                  trailing: IconButton(
                    icon: const Icon(Icons.chat, color: Colors.blue),
                    onPressed: () {
                      // Open chat window
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
