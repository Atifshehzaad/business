import 'package:flutter/material.dart';
import '../services/db_helper.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key, required int userId}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  int? _userId; // Replace with your user authentication logic to get logged-in user ID

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    // Replace 1 with the logged-in user's ID
    _userId = 1; // Mocked for demonstration purposes
    final profile = await DBHelper.instance.getUserProfile(_userId!);

    if (profile != null) {
      setState(() {
        _nameController.text = profile['name'] ?? '';
        _emailController.text = profile['email'] ?? '';
        _cityController.text = profile['city'] ?? '';
      });
    }
  }

  Future<void> _saveProfileData() async {
    if (_userId == null) return;

    final updatedProfile = {
      'id': _userId,
      'name': _nameController.text,
      'email': _emailController.text,
      'city': _cityController.text,
    };

    await DBHelper.instance.updateUserProfile(updatedProfile);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile updated successfully!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _cityController,
              decoration: const InputDecoration(
                labelText: 'City',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _saveProfileData,
              child: const Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }
}
