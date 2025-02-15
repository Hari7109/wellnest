import 'package:flutter/material.dart';
import 'doctor_dashboard.dart';
import 'medical_history.dart';
import 'chat_page.dart';
import 'broadcast_page.dart';

void main() {
  runApp(const DoctorModuleApp());
}

class DoctorModuleApp extends StatelessWidget {
  const DoctorModuleApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: DoctorMainPage(),
    );
  }
}

class DoctorMainPage extends StatefulWidget {
  @override
  _DoctorMainPageState createState() => _DoctorMainPageState();
}

class _DoctorMainPageState extends State<DoctorMainPage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    DoctorDashboard(),
    MedicalHistoryPage(),
    ChatPage(),
    BroadcastPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        backgroundColor: Colors.blue,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: "Dashboard"),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: "History"),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: "Chat"),
          BottomNavigationBarItem(icon: Icon(Icons.campaign), label: "Broadcast"),
        ],
      ),
    );
  }
}
