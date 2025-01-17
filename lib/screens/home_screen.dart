import 'package:business_info_app/screens/search_screen.dart';
import 'package:flutter/material.dart';
import '../services/db_helper.dart';
import 'login_screen.dart';
import 'sub_category_screen.dart';

class HomeScreen extends StatefulWidget {
  final int loggedInUserId;

  const HomeScreen({Key? key, required this.loggedInUserId}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> _categories = [];

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final db = await DBHelper.instance.database;
    final result = await db.query('categories');
    setState(() {
      _categories = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Business Categories'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              // Navigate back to Login Screen
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SearchScreen()),
              );
            },
          ),
        ],
      ),

      body:

      _categories.isEmpty
          ? Center(child: CircularProgressIndicator())
          : GridView.builder(
        padding: EdgeInsets.all(16),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SubCategoryScreen(
                    categoryId: category['id'],
                    categoryName: category['name'],
                  ),
                ),
              );
            },
            child: Card(
              elevation: 4,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      category['icon'],
                      style: TextStyle(fontSize: 40),
                    ),
                    SizedBox(height: 10),
                    Text(
                      category['name'],
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                  ],
                ),
              ),
            ),
          );
        },
      ),

    );
  }
}
