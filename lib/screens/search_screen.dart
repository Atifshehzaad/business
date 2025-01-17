import 'package:flutter/material.dart';
import '../services/db_helper.dart';
import 'advance_search_screen.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _searchResults = [];

  Future<void> _performSearch(String query) async {
    final results = await DBHelper.instance.searchBusinesses(query);
    setState(() {
      _searchResults = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Search Businesses')),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AdvancedSearchScreen()),
              );
            },
            child: const Text('Advanced Search'),
          ),
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search by name or category',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
            onChanged: (value) => _performSearch(value),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _searchResults.length,
              itemBuilder: (context, index) {
                final business = _searchResults[index];
                return ListTile(
                  title: Text(business['name']),
                  subtitle: Text(business['address']),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
