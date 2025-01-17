import 'package:flutter/material.dart';
import '../services/db_helper.dart';

class BusinessListingScreen extends StatefulWidget {
  final int subCategoryId;
  final String subCategoryName;

  const BusinessListingScreen({
    Key? key,
    required this.subCategoryId,
    required this.subCategoryName,
  }) : super(key: key);

  @override
  _BusinessListingScreenState createState() => _BusinessListingScreenState();
}

class _BusinessListingScreenState extends State<BusinessListingScreen> {
  List<Map<String, dynamic>> _businesses = [];

  @override
  void initState() {
    super.initState();
    _loadBusinesses();
  }

  Future<void> _loadBusinesses() async {
    final db = await DBHelper.instance.database;
    final result = await db.query(
      'businesses',
      where: 'sub_category_id = ?',
      whereArgs: [widget.subCategoryId],
    );
    setState(() {
      _businesses = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.subCategoryName),
      ),
      body: _businesses.isEmpty
          ? Center(child: Text('No businesses found.'))
          : ListView.builder(
        itemCount: _businesses.length,
        itemBuilder: (context, index) {
          final business = _businesses[index];
          return Card(
            margin: EdgeInsets.all(8),
            child: ListTile(
              leading: Text(
                business['thumbnail'],
                style: TextStyle(fontSize: 40),
              ),
              title: Text(business['name']),
              subtitle: Text(business['description']),
              trailing: Text(business['price_range'] ?? 'N/A'),
            ),
          );
        },
      ),
    );
  }
}

void showReviewDialog(BuildContext context, int businessId, int userId) {
  final _reviewController = TextEditingController();
  int _rating = 5;

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text('Submit Review'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<int>(
              value: _rating,
              items: List.generate(
                5,
                    (index) => DropdownMenuItem(
                  value: index + 1,
                  child: Text('${index + 1} Stars'),
                ),
              ),
              onChanged: (value) {
                _rating = value ?? 5;
              },
              decoration: InputDecoration(labelText: 'Rating'),
            ),
            TextField(
              controller: _reviewController,
              decoration: InputDecoration(labelText: 'Review'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (_reviewController.text.trim().isNotEmpty) {
                await DBHelper.instance.addReview(
                  businessId: businessId,
                  userId: userId,
                  rating: _rating,
                  review: _reviewController.text.trim(),
                );
                Navigator.pop(context); // Close dialog
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Review added successfully!')),
                );
              }
            },
            child: Text('Submit'),
          ),
        ],
      );
    },
  );
}
