import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class HealthArticlesPage extends StatefulWidget {
  const HealthArticlesPage({Key? key}) : super(key: key);

  @override
  _HealthArticlesPageState createState() => _HealthArticlesPageState();
}

class _HealthArticlesPageState extends State<HealthArticlesPage> {
  final List<String> _categories = [
    'All', 'Mental Health', 'Nutrition', 'Fitness', 'Lifestyle',
    'Preventive Care', 'General Wellness', 'Chronic Conditions',
    "Womens Health", 'Mens Health', 'Child Health'
  ];
  String _selectedCategory = 'All';
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  Widget _buildCategoryChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: _categories.map((category) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: ChoiceChip(
              label: Text(category),
              selected: _selectedCategory == category,
              onSelected: (bool selected) {
                setState(() {
                  _selectedCategory = category;
                });
              },
              selectedColor: Colors.teal[100],
              backgroundColor: Colors.teal[50],
              labelStyle: TextStyle(
                color: _selectedCategory == category ? Colors.teal[800] : Colors.teal[700],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search health articles...',
          prefixIcon: Icon(Icons.search, color: Colors.teal[700]),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
            icon: Icon(Icons.clear, color: Colors.teal[700]),
            onPressed: () {
              _searchController.clear();
              setState(() {
                _searchQuery = '';
              });
            },
          )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.teal[200]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.teal[500]!, width: 2),
          ),
        ),
        onChanged: (value) {
          setState(() {
            _searchQuery = value.toLowerCase();
          });
        },
      ),
    );
  }

  Widget _buildArticleCard(DocumentSnapshot article) {
    final data = article.data() as Map<String, dynamic>;
    final Timestamp? createdAt = data['createdAt'] as Timestamp?;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.teal[50],
      child: ListTile(
        title: Text(
          data['title'] ?? 'Untitled Article',
          style: TextStyle(color: Colors.teal[800], fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              data['summary'] ?? 'No summary available',
              style: TextStyle(color: Colors.teal[700]),
            ),
            if (createdAt != null)
              Text(
                DateFormat('MMM dd, yyyy - hh:mm a').format(createdAt.toDate()),
                style: TextStyle(
                  color: Colors.teal[600],
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
              ),
          ],
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => HealthArticleDetailPage(article: article),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Health Articles'),
        backgroundColor: Colors.teal[600],
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildCategoryChips(),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('health_articles').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error: ${snapshot.error}',
                      style: TextStyle(color: Colors.teal[800]),
                    ),
                  );
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.teal[600]!),
                    ),
                  );
                }
                final filteredArticles = snapshot.data!.docs.where((article) {
                  final data = article.data() as Map<String, dynamic>;
                  bool categoryMatch = _selectedCategory == 'All' || data['category'] == _selectedCategory;
                  bool searchMatch = _searchQuery.isEmpty || data['title'].toLowerCase().contains(_searchQuery);
                  return categoryMatch && searchMatch;
                }).toList();

                if (filteredArticles.isEmpty) {
                  return Center(
                    child: Text(
                      'No articles found',
                      style: TextStyle(color: Colors.teal[800]),
                    ),
                  );
                }
                return ListView.builder(
                  itemCount: filteredArticles.length,
                  itemBuilder: (context, index) => _buildArticleCard(filteredArticles[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class HealthArticleDetailPage extends StatelessWidget {
  final DocumentSnapshot article;
  const HealthArticleDetailPage({Key? key, required this.article}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final data = article.data() as Map<String, dynamic>;
    final Timestamp? createdAt = data['createdAt'] as Timestamp?;

    return Scaffold(
      appBar: AppBar(
        title: Text(data['title'] ?? 'Article Details'),
        backgroundColor: Colors.teal[600],
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                data['title'] ?? 'Untitled',
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal[800]
                ),
              ),
              if (createdAt != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    'Published on: ${DateFormat('MMMM dd, yyyy - hh:mm a').format(createdAt.toDate())}',
                    style: TextStyle(
                      color: Colors.teal[600],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              Text(
                data['content'] ?? 'No content available',
                style: TextStyle(
                    fontSize: 16,
                    color: Colors.teal[900]
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}