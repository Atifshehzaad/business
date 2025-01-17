import 'package:flutter/material.dart';
import '../services/db_helper.dart';
import 'business_listing_screen.dart';

class SubCategoryScreen extends StatefulWidget {
  final int categoryId;
  final String categoryName;

  const SubCategoryScreen({
    Key? key,
    required this.categoryId,
    required this.categoryName,
  }) : super(key: key);

  @override
  _SubCategoryScreenState createState() => _SubCategoryScreenState();
}

class _SubCategoryScreenState extends State<SubCategoryScreen> {
  List<Map<String, dynamic>> _subCategories = [];

  @override
  void initState() {
    super.initState();
    _loadSubCategories();
  }

  Future<void> _loadSubCategories() async {
    final db = await DBHelper.instance.database;
    final result = await db.query(
      'sub_categories',
      where: 'category_id = ?',
      whereArgs: [widget.categoryId],
    );
    setState(() {
      _subCategories = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.categoryName),
      ),
      body: _subCategories.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: _subCategories.length,
        itemBuilder: (context, index) {
          final subCategory = _subCategories[index];
          return Card(
            margin: EdgeInsets.all(8),
            child: ListTile(
              title: Text(subCategory['name']),
              trailing: Icon(Icons.arrow_forward),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BusinessListingScreen(
                      subCategoryId: subCategory['id'],
                      subCategoryName: subCategory['name'],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
