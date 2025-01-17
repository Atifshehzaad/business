import 'db_helper.dart'; // Import the database helper
import 'dart:convert';  // For encoding passwords
import 'package:crypto/crypto.dart'; // For hashing passwords

class AuthService {
  final DBHelper _dbHelper = DBHelper.instance; // Database helper instance

  // Hashes the password using SHA-256
  String _hashPassword(String password) {
    return sha256.convert(utf8.encode(password)).toString();
  }

  // Registers a new user
  Future<String?> registerUser(String username, String email, String password) async {
    try {
      final user = {
        'username': username,
        'email': email,
        'password': _hashPassword(password), // Hash the password
      };
      await _dbHelper.insertUser(user); // Insert user into the database
      return null; // Registration successful
    } catch (e) {
      return 'User already exists or an error occurred: $e';
    }
  }

  // Logs in a user
  Future<String?> loginUser(String email, String password) async {
    try {
      final user = await _dbHelper.getUserByEmail(email); // Fetch user by email
      if (user == null) {
        return 'No user found with this email.';
      }

      final hashedPassword = _hashPassword(password);
      if (user['password'] != hashedPassword) {
        return 'Invalid password.';
      }

      return null; // Login successful
    } catch (e) {
      return 'An error occurred during login: $e';
    }
  }
}
