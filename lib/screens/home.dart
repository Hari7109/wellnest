import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:albertian_wellnest/screens/bmi.dart';
import 'package:intl/intl.dart';
import 'chatwithspecialistspage.dart';
import 'communitypage.dart';
import 'studentprofile.dart';
import 'quiz.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF6750A4),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6750A4),
          secondary: const Color(0xFF03DAC6),
        ),
        textTheme: const TextTheme(
          headlineMedium: TextStyle(fontWeight: FontWeight.bold),
          titleLarge: TextStyle(fontWeight: FontWeight.w600),
          titleMedium: TextStyle(fontWeight: FontWeight.w500),
          bodyLarge: TextStyle(fontSize: 16),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 2,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
        ),
        cardTheme: CardTheme(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          clipBehavior: Clip.antiAlias,
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
          backgroundColor: Color(0xFF6750A4),
          foregroundColor: Colors.white,
        ),
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  final List<Widget> _pages = [
    HomePageContent(),
    ChatWithSpecialistsPage(),
    ChatRoomSelectionPage(),
    StudentProfile(),
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
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          child: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            selectedItemColor: Theme.of(context).colorScheme.primary,
            unselectedItemColor: Colors.grey,
            showUnselectedLabels: true,
            elevation: 8,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_rounded),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.chat_bubble_outline_rounded),
                label: 'Specialists',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.forum_rounded),
                label: 'Community',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline_rounded),
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HomePageContent extends StatefulWidget {
  const HomePageContent({super.key});

  @override
  _HomePageContentState createState() => _HomePageContentState();
}

class _HomePageContentState extends State<HomePageContent> {
  String userName = ""; // Default name
  int? _score = 0; // Store quiz score
  double? _starRating = 0.0; // Store calculated star rating

  String _bmi = "";
  String _category = "";
  int _height = 0;
  int _weight = 0;
  DateTime _lastUpdated = DateTime.now();

  // Getters for accessing data globally
  String get bmi => _bmi;
  String get category => _category;
  int get height => _height;
  int get weight => _weight;
  String get lastUpdated => DateFormat.yMMMd().format(_lastUpdated);

  List<Map<String, dynamic>> specialists = [
    {"name": "Nutrition Specialist", "icon": "🥗", "color": Colors.green.shade100},
    {"name": "Physiotherapist", "icon": "🏋️", "color": Colors.orange.shade100},
    {"name": "Psychologist", "icon": "🧠", "color": Colors.purple.shade100},
    {"name": "Yoga Instructor", "icon": "🧘", "color": Colors.blue.shade100},
  ];

  List<Map<String, String>> tasks = [];

  // Sample images
  List<Map<String, dynamic>> wellnessPhotos = [
    {
      "image": "assets/images/wellness1.jpg",
      "title": "Health Session",
      "description": "Weekly wellness session"
    },
    {
      "image": "assets/images/wellness2.jpg",
      "title": "Blood Donation",
      "description": "Mental peace activities"
    },
    {
      "image": "assets/images/wellness3.jpg",
      "title": "Dite Workshop",
      "description": "fitness program"
    },
  ];

  @override
  void initState() {
    super.initState();
    fetchUserName();
    fetchbmi();
    _fetchLastQuizScore();
  }

  Future<void> _fetchLastQuizScore() async {
    try {
      String uid = FirebaseAuth.instance.currentUser!.uid;
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('quiz_results')
          .doc(uid)
          .get();

      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

        setState(() {
          _score = data['score'] ?? 0;
          _starRating = (data['rating'] as num?)?.toDouble() ?? 0.0;
        });
      }
    } catch (e) {
      print("Error fetching quiz score: $e");
    }
  }

  Future<void> fetchUserName() async {
    try {
      String userId = FirebaseAuth.instance.currentUser!.uid;
      DocumentSnapshot docSnapshot = await FirebaseFirestore.instance
          .collection('bioData')
          .doc(userId)
          .get();

      if (docSnapshot.exists) {
        setState(() {
          userName = docSnapshot['name'];
        });
      }
    } catch (e) {
      print('Error fetching user name: $e');
    }
  }

  Future<void> fetchbmi() async {
    try {
      String userId = FirebaseAuth.instance.currentUser!.uid;
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('bmi_data')
          .doc(userId)
          .get();

      if (snapshot.exists) {
        Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;

        _bmi = data['bmi'] ?? "N/A";
        _category = data['category'] ?? "N/A";
        _height = (data['height'] as num?)?.toInt() ?? 0;
        _weight = (data['weight'] as num?)?.toInt() ?? 0;
        if ((data['last_updated'] is Timestamp)) {
          _lastUpdated = (data['last_updated'] as Timestamp).toDate();
        } else {
          _lastUpdated = DateTime.now();
        }

        setState(() {});
      }
    } catch (e) {
      print('Error fetching BMI data: $e');
    }
  }

  void _addTask() {
    TextEditingController taskController = TextEditingController();
    DateTime? selectedDate;
    TimeOfDay? selectedTime;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Add Reminder"),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: taskController,
                decoration: const InputDecoration(
                  labelText: "Task Name",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.task_alt),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2101),
                          builder: (context, child) {
                            return Theme(
                              data: Theme.of(context).copyWith(
                                colorScheme: ColorScheme.light(
                                  primary: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                              child: child!,
                            );
                          },
                        );
                        if (pickedDate != null) {
                          setState(() => selectedDate = pickedDate);
                        }
                      },
                      icon: const Icon(Icons.calendar_today),
                      label: const Text("Date"),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        TimeOfDay? pickedTime = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now(),
                          builder: (context, child) {
                            return Theme(
                              data: Theme.of(context).copyWith(
                                colorScheme: ColorScheme.light(
                                  primary: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                              child: child!,
                            );
                          },
                        );
                        if (pickedTime != null) {
                          setState(() => selectedTime = pickedTime);
                        }
                      },
                      icon: const Icon(Icons.access_time),
                      label: const Text("Time"),
                    ),
                  ),
                ],
              ),
              if (selectedDate != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Chip(
                    avatar: const Icon(Icons.calendar_today, size: 16),
                    label: Text(DateFormat.yMMMd().format(selectedDate!)),
                    backgroundColor: Colors.purple.shade100,
                  ),
                ),
              if (selectedTime != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Chip(
                    avatar: const Icon(Icons.access_time, size: 16),
                    label: Text(selectedTime!.format(context)),
                    backgroundColor: Colors.blue.shade100,
                  ),
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                if (taskController.text.isNotEmpty &&
                    selectedDate != null &&
                    selectedTime != null) {
                  setState(() {
                    tasks.add({
                      "task": taskController.text,
                      "date": DateFormat('yyyy-MM-dd').format(selectedDate!),
                      "time": selectedTime!.format(context),
                    });
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text("Add"),
            ),
          ],
        );
      },
    );
  }

  void _deleteTask(int index) {
    setState(() {
      tasks.removeAt(index);
    });
  }

  String _getBmiStatusColor() {
    if (_category.toLowerCase().contains("normal")) {
      return "healthy";
    } else if (_category.toLowerCase().contains("under")) {
      return "underweight";
    } else {
      return "overweight";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.spa, size: 24),
            SizedBox(width: 8),
            Text(
              "Albertian Wellnest",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        // actions: [
        //   IconButton(
        //     icon: const Icon(Icons.notifications_none_rounded),
        //     onPressed: () {},
        //   ),
        // ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await fetchUserName();
          await fetchbmi();
          await _fetchLastQuizScore();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                // Welcome Card
                Container(
                  width: double.infinity,
                  height: 170,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).colorScheme.primary,
                        Theme.of(context).colorScheme.primary.withOpacity(0.7),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        bottom: -15,
                        right: -15,
                        child: Icon(
                          Icons.spa,
                          size: 120,
                          color: Colors.white.withOpacity(0.2),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 26,
                                  backgroundColor: Colors.white,
                                  child: Text(
                                    userName.isNotEmpty ? userName[0].toUpperCase() : "A",
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context).colorScheme.primary,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Hi, $userName",
                                      style: const TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const Text(
                                      "Welcome back!",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              "Nourish your Mind, Body & Soul",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Health Status Card
                Card(
                  elevation: 4,
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(16),
                            topRight: Radius.circular(16),
                          ),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.health_and_safety_outlined, color: Colors.white),
                            SizedBox(width: 8),
                            Text(
                              "Health Status",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                _healthInfoItem(Icons.height, "Height", "$height cm"),
                                _healthInfoItem(Icons.monitor_weight_outlined, "Weight", "$weight kg"),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                _healthInfoItem(Icons.calculate_outlined, "BMI", bmi),
                                _healthInfoItem(
                                    _getBmiStatusColor() == "healthy" ? Icons.check_circle_outline :
                                    (_getBmiStatusColor() == "underweight" ? Icons.arrow_downward : Icons.arrow_upward),
                                    "Status",
                                    category,
                                    color: _getBmiStatusColor() == "healthy" ? Colors.green :
                                    (_getBmiStatusColor() == "underweight" ? Colors.orange : Colors.red)
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Last updated: $lastUpdated",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => const HealthInfoPage()),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Theme.of(context).colorScheme.primary,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    minimumSize: const Size(0, 36),
                                  ),
                                  child: const Text("Update"),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Specialists Section
                _sectionHeader("Inhouse Specialists", Icons.people_alt_outlined),
                const SizedBox(height: 12),
                Container(
                  height: 120,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: specialists.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 16),
                        child: _specialistCard(
                          specialists[index]["icon"]!,
                          specialists[index]["name"]!,
                          specialists[index]["color"]!,
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 24),

                // Mental Health Assessment
                _sectionHeader("Mental Health Assessment", Icons.psychology_outlined),
                const SizedBox(height: 12),
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primaryContainer,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.quiz_outlined,
                                color: Theme.of(context).colorScheme.primary,
                                size: 32,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text("Mental Wellness Quiz",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      )),
                                  const SizedBox(height: 4),
                                  Text(
                                    "Understand your mental health status",
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        if (_score != null && _score! > 0)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Column(
                              children: [
                                Text(
                                  "Your Score: $_score / 12",
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  "Less the better",
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w100,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                _buildStarRating(_starRating!),
                              ],
                            ),
                          ),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const QuizPage()),
                              );

                              if (result != null) {
                                setState(() {
                                  _score = result['score'];
                                  _starRating = ((result['score'] ?? 0).toDouble() /
                                      (result['total'] ?? 1).toDouble()) * 5;
                                });
                              }
                            },
                            icon: const Icon(Icons.psychology),
                            label: Text(_score != null && _score! > 0 ? "Retake Quiz" : "Take Quiz"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).colorScheme.primary,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Tasks/Reminders Section
                _sectionHeader("Your Wellness Reminders", Icons.notifications_active_outlined),
                const SizedBox(height: 12),
                Card(
                  elevation: 2,
                  child: Column(
                    children: [
                      if (tasks.isEmpty)
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Center(
                            child: Column(
                              children: [
                                Icon(
                                  Icons.schedule,
                                  size: 48,
                                  color: Colors.grey.shade400,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  "No reminders set",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      if (tasks.isNotEmpty)
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: tasks.length,
                          separatorBuilder: (context, index) => Divider(height: 1, color: Colors.grey.shade300),
                          itemBuilder: (context, index) {
                            return Dismissible(
                              key: Key(tasks[index]["task"]! + index.toString()),
                              background: Container(
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.only(right: 20),
                                color: Colors.red,
                                child: const Icon(Icons.delete, color: Colors.white),
                              ),
                              direction: DismissDirection.endToStart,
                              onDismissed: (direction) => _deleteTask(index),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
                                  child: const Icon(Icons.task_alt),
                                ),
                                title: Text(
                                  tasks[index]["task"]!,
                                  style: const TextStyle(fontWeight: FontWeight.w500),
                                ),
                                subtitle: Row(
                                  children: [
                                    const Icon(Icons.calendar_today, size: 12),
                                    const SizedBox(width: 4),
                                    Text(tasks[index]["date"]!),
                                    const SizedBox(width: 12),
                                    const Icon(Icons.access_time, size: 12),
                                    const SizedBox(width: 4),
                                    Text(tasks[index]["time"]!),
                                  ],
                                ),
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                                  onPressed: () => _deleteTask(index),
                                ),
                              ),
                            );
                          },
                        ),
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _addTask,
                            icon: const Icon(Icons.add),
                            label: const Text("Add Reminder"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).colorScheme.primary,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Wellness Activities
                _sectionHeader("Wellness Centre Activities", Icons.local_activity_outlined),
                const SizedBox(height: 12),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: wellnessPhotos.length,
                  itemBuilder: (context, index) {
                    return Container(
                      height: 200,
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Stack(
                        children: [
                          Card(
                            margin: EdgeInsets.zero,
                            child: Container(
                              width: double.infinity,
                              height: 200,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Image.asset(
                                  wellnessPhotos[index]["image"]!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => Container(
                                    alignment: Alignment.center,
                                    color: Colors.grey.shade300,
                                    child: const Icon(Icons.broken_image, size: 64, color: Colors.grey),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                borderRadius: const BorderRadius.only(
                                  bottomLeft: Radius.circular(16),
                                  bottomRight: Radius.circular(16),
                                ),
                                gradient: LinearGradient(
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                  colors: [
                                    Colors.black.withOpacity(0.8),
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    wellnessPhotos[index]["title"]!,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    wellnessPhotos[index]["description"]!,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.white70,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addTask,
        child: const Icon(Icons.add),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
    );
  }
  Widget _healthInfoItem(IconData icon, String label, String value, {Color? color}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: color ?? Theme.of(context).colorScheme.primary),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget _sectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  // Widget _healthInfoItem(IconData icon, String label, String value, {Color? color}) {
  //   return Expanded(
  //     child: Container(
  //       padding: const EdgeInsets.all(12),
  //       decoration: BoxDecoration(
  //         color: Colors.grey.shade100,
  //         borderRadius: BorderRadius.circular(12),
  //       ),
  //       child: Row(
  //         children: [
  //           Icon(icon, color: color ?? Theme.of(context).colorScheme.primary),
  //           const SizedBox(width: 8),
  //           Expanded(
  //             child: Column(
  //               crossAxisAlignment: CrossAxisAlignment.start,
  //               children: [
  //                 Text(
  //                   label,
  //                   style: TextStyle(
  //                     fontSize: 14,
  //                     color: Colors.grey.shade700,
  //                   ),
  //                 ),
  //                 const SizedBox(height: 4),
  //                 Text(
  //                   value,
  //                   style: const TextStyle(
  //                     fontSize: 16,
  //                     fontWeight: FontWeight.bold,
  //                   ),
  //                   overflow: TextOverflow.ellipsis,
  //                 ),
  //               ],
  //             ),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  Widget _specialistCard(String emoji, String name, Color color) {
    return Container(
      width: 100,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            emoji,
            style: const TextStyle(fontSize: 32),
          ),
          const SizedBox(height: 8),
          Text(
            name,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildStarRating(double rating) {
    List<Widget> stars = [];

    for (int i = 1; i <= 5; i++) {
      if (i <= rating) {
        // Full star
        stars.add(const Icon(Icons.star, color: Colors.amber, size: 24));
      } else if (i - 0.5 <= rating && rating < i) {
        // Half star
        stars.add(const Icon(Icons.star_half, color: Colors.amber, size: 24));
      } else {
        // Empty star
        stars.add(const Icon(Icons.star_border, color: Colors.amber, size: 24));
      }
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: stars,
    );
  }
}

// BMI Calculator Page
class HealthInfoPage extends StatefulWidget {
  const HealthInfoPage({super.key});

  @override
  _HealthInfoPageState createState() => _HealthInfoPageState();
}

class _HealthInfoPageState extends State<HealthInfoPage> {
  final _formKey = GlobalKey<FormState>();
  int _height = 0;
  int _weight = 0;
  String _bmi = "";
  String _category = "";
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadExistingData();
  }

  Future<void> _loadExistingData() async {
    setState(() => _isLoading = true);

    try {
      String userId = FirebaseAuth.instance.currentUser!.uid;
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('bmi_data')
          .doc(userId)
          .get();

      if (snapshot.exists) {
        Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
        setState(() {
          _height = (data['height'] as num?)?.toInt() ?? 0;
          _weight = (data['weight'] as num?)?.toInt() ?? 0;
          _bmi = data['bmi'] ?? "";
          _category = data['category'] ?? "";
        });
      }
    } catch (e) {
      print('Error loading BMI data: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _calculateBMI() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // Calculate BMI
      double heightInMeters = _height / 100;
      double calculatedBMI = _weight / (heightInMeters * heightInMeters);

      // Determine category
      String category;
      if (calculatedBMI < 18.5) {
        category = "Underweight";
      } else if (calculatedBMI < 25) {
        category = "Normal weight";
      } else if (calculatedBMI < 30) {
        category = "Overweight";
      } else {
        category = "Obese";
      }

      setState(() {
        _bmi = calculatedBMI.toStringAsFixed(1);
        _category = category;
      });

      // Save to Firestore
      try {
        setState(() => _isLoading = true);
        String userId = FirebaseAuth.instance.currentUser!.uid;

        await FirebaseFirestore.instance.collection('bmi_data').doc(userId).set({
          'height': _height,
          'weight': _weight,
          'bmi': _bmi,
          'category': _category,
          'last_updated': Timestamp.now(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('BMI data saved successfully')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving BMI data: $e')),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BMI Calculator'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Enter your height and weight',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        initialValue: _height > 0 ? _height.toString() : '',
                        decoration: const InputDecoration(
                          labelText: 'Height (cm)',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.height),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your height';
                          }
                          if (int.tryParse(value) == null || int.parse(value) <= 0) {
                            return 'Please enter a valid height';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _height = int.parse(value!);
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        initialValue: _weight > 0 ? _weight.toString() : '',
                        decoration: const InputDecoration(
                          labelText: 'Weight (kg)',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.monitor_weight_outlined),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your weight';
                          }
                          if (int.tryParse(value) == null || int.parse(value) <= 0) {
                            return 'Please enter a valid weight';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _weight = int.parse(value!);
                        },
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _calculateBMI,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: const Text('Calculate BMI'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            if (_bmi.isNotEmpty)
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        'Your BMI Result',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _getBMIColor(_category),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            _bmi,
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _category,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: _getBMIColor(_category),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildBMIDescription(_category),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 24),
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'BMI Categories',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _categoryItem('Underweight', 'Less than 18.5', Colors.orange),
                    const SizedBox(height: 8),
                    _categoryItem('Normal weight', '18.5 - 24.9', Colors.green),
                    const SizedBox(height: 8),
                    _categoryItem('Overweight', '25 - 29.9', Colors.orange),
                    const SizedBox(height: 8),
                    _categoryItem('Obesity', '30 or greater', Colors.red),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _categoryItem(String name, String range, Color color) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          name,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const Spacer(),
        Text(
          range,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey.shade700,
          ),
        ),
      ],
    );
  }

  Color _getBMIColor(String category) {
    if (category.toLowerCase().contains('normal')) {
      return Colors.green;
    } else if (category.toLowerCase().contains('under')) {
      return Colors.orange;
    } else if (category.toLowerCase().contains('over')) {
      return Colors.orange.shade700;
    } else {
      return Colors.red;
    }
  }

  Widget _buildBMIDescription(String category) {
    String description;

    if (category.toLowerCase().contains('under')) {
      description = 'You are underweight. Consider consulting with a nutritionist for a healthy weight gain plan.';
    } else if (category.toLowerCase().contains('normal')) {
      description = 'Your BMI is within a healthy range. Keep up the good work!';
    } else if (category.toLowerCase().contains('over')) {
      description = 'You are overweight. Consider adopting a healthier diet and increasing physical activity.';
    } else {
      description = 'You are in the obese category. It\'s recommended to consult with a healthcare professional.';
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        description,
        style: const TextStyle(fontSize: 16),
      ),
    );
  }
}