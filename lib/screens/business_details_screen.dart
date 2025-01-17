import 'dart:convert';
import 'package:flutter/material.dart';
import '../services/db_helper.dart';

class BusinessDetailScreen extends StatefulWidget {
  final int businessId;

  const BusinessDetailScreen({Key? key, required this.businessId}) : super(key: key);

  @override
  _BusinessDetailScreenState createState() => _BusinessDetailScreenState();
}

class _BusinessDetailScreenState extends State<BusinessDetailScreen> {
  Map<String, dynamic>? _business;
  Future<List<Map<String, dynamic>>>? _reviewsFuture;
  double? _averageRating;

  @override
  void initState() {
    super.initState();
    _loadBusinessDetails();
    _loadReviews();
  }

  Future<void> _loadBusinessDetails() async {
    try {
      final db = await DBHelper.instance.database;
      final result = await db.query(
        'businesses',
        where: 'id = ?',
        whereArgs: [widget.businessId],
      );
      if (result.isNotEmpty) {
        setState(() {
          _business = result.first;
        });
      }
    } catch (e) {
      print('Error loading business details: $e');
    }
  }

  Future<void> _loadReviews() async {
    try {
      final reviews = DBHelper.instance.getReviewsByBusinessId(widget.businessId);
      final avgRating = await DBHelper.instance.getAverageRating(widget.businessId);
      setState(() {
        _reviewsFuture = reviews;
        _averageRating = avgRating;
      });
    } catch (e) {
      print('Error loading reviews: $e');
    }
  }

  void showReviewDialog(BuildContext context) {
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
                    businessId: widget.businessId,
                    userId: 1, // Replace with logged-in user's ID
                    rating: _rating,
                    review: _reviewController.text.trim(),
                  );
                  Navigator.pop(context); // Close dialog
                  _loadReviews(); // Reload reviews
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

  @override
  Widget build(BuildContext context) {
    if (_business == null) {
      return Scaffold(
        appBar: AppBar(title: Text('Business Details')),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Decode services JSON string
    final services = json.decode(_business!['services']) as List<dynamic>;

    return Scaffold(
      appBar: AppBar(
        title: Text(_business!['name']),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Business Thumbnail and Description
            Row(
              children: [
                Text(
                  _business!['thumbnail'] ?? '📍',
                  style: TextStyle(fontSize: 60),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Text(
                    _business!['description'],
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),

            // Address
            Row(
              children: [
                Icon(Icons.location_on, color: Colors.blue),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _business!['address'],
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),

            // Contact
            Row(
              children: [
                Icon(Icons.phone, color: Colors.blue),
                SizedBox(width: 8),
                Text(
                  _business!['contact'],
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
            SizedBox(height: 16),

            // Services and Prices
            Text(
              'Services',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: services.length,
              itemBuilder: (context, index) {
                final service = services[index];
                return ListTile(
                  title: Text(service['name']),
                  trailing: Text(service['price']),
                );
              },
            ),
            SizedBox(height: 16),

            // Average Rating
            if (_averageRating != null)
              Text(
                'Average Rating: ${_averageRating!.toStringAsFixed(1)}',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),

            // Submit Review Button
            ElevatedButton(
              onPressed: () => showReviewDialog(context),
              child: Text('Submit a Review'),
            ),

            SizedBox(height: 16),

            // Reviews List
            FutureBuilder<List<Map<String, dynamic>>>(
              future: _reviewsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Text('Error loading reviews');
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Text('No reviews yet.');
                }

                final reviews = snapshot.data!;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: reviews.map((review) {
                    return ListTile(
                      leading: CircleAvatar(
                        child: Text('${review['rating']}'),
                      ),
                      title: Text(review['review'] ?? ''),
                      subtitle: Text('User ID: ${review['user_id']}'),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
