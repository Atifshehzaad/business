import 'package:flutter/material.dart';
import '../services/db_helper.dart';

class AdvancedSearchScreen extends StatefulWidget {
  @override
  _AdvancedSearchScreenState createState() => _AdvancedSearchScreenState();
}

class _AdvancedSearchScreenState extends State<AdvancedSearchScreen> {
  final TextEditingController _nameController = TextEditingController();
  String? _selectedCategory;
  String? _selectedSubCategory;
  int? _minPopularity;
  int? _minPrice;
  int? _maxPrice;

  List<Map<String, dynamic>> _searchResults = [];

  final List<String> _categories = ['Food', 'Healthcare', 'Hotels', 'Education'];
  final Map<String, List<String>> _subCategories = {
    'Food': ['Fast Food', 'Restaurants', 'Cafes'],
    'Healthcare': ['Hospitals', 'Clinics', 'Pharmacies'],
    'Hotels': ['Luxury', 'Budget', 'Hostels'],
    'Education': ['Schools', 'Colleges', 'Universities'],
  };

  Future<void> _performSearch() async {
    final results = await DBHelper.instance.advancedSearch(
      name: _nameController.text,
      category: _selectedCategory,
      subCategory: _selectedSubCategory,
      minPopularity: _minPopularity,
      minPrice: _minPrice,
      maxPrice: _maxPrice,
    );
    setState(() {
      _searchResults = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Advanced Search'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Business Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              items: _categories
                  .map((category) => DropdownMenuItem(
                value: category,
                child: Text(category),
              ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value;
                  _selectedSubCategory = null; // Reset sub-category
                });
              },
              decoration: const InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedSubCategory,
              items: (_subCategories[_selectedCategory] ?? [])
                  .map((subCategory) => DropdownMenuItem(
                value: subCategory,
                child: Text(subCategory),
              ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedSubCategory = value;
                });
              },
              decoration: const InputDecoration(
                labelText: 'Sub-Category',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      labelText: 'Min Price',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      _minPrice = int.tryParse(value);
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      labelText: 'Max Price',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      _maxPrice = int.tryParse(value);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Minimum Popularity',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                _minPopularity = int.tryParse(value);
              },
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _performSearch,
              child: const Text('Search'),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: _searchResults.length,
                itemBuilder: (context, index) {
                  final business = _searchResults[index];
                  return ListTile(
                    title: Text(business['name']),
                    subtitle: Text('${business['category']} - ${business['sub_category']}'),
                    trailing: Text('\$${business['price_range']}'),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
