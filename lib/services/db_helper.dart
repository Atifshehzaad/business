import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DBHelper {
  static final DBHelper instance = DBHelper._init();
  static Database? _database;

  DBHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('business_info.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 3, // Increment version when schema changes
      onCreate: _createDB,
      onUpgrade: _onUpgradeDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    // Create users table
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL,
        city TEXT
      )
    ''');

    // Create categories table
    await db.execute('''
      CREATE TABLE categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        icon TEXT NOT NULL
      )
    ''');

    // Create sub_categories table
    await db.execute('''
      CREATE TABLE sub_categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        category_id INTEGER NOT NULL,
        name TEXT NOT NULL,
        FOREIGN KEY (category_id) REFERENCES categories (id)
      )
    ''');

    // Create businesses table
    await db.execute('''
      CREATE TABLE businesses (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        sub_category_id INTEGER NOT NULL,
        name TEXT NOT NULL,
        description TEXT NOT NULL,
        price_range TEXT,
        thumbnail TEXT,
        address TEXT,
        contact TEXT,
        services TEXT,
        FOREIGN KEY (sub_category_id) REFERENCES sub_categories (id)
      )
    ''');
    // Alter businesses table
    await db.execute('''
      ALTER TABLE businesses ADD COLUMN image_path TEXT
    ''');
    // Create reviews table
    await db.execute('''
    CREATE TABLE reviews (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      business_id INTEGER NOT NULL,
      user_id INTEGER NOT NULL,
      rating INTEGER NOT NULL,
      review TEXT,
      FOREIGN KEY (business_id) REFERENCES businesses (id),
      FOREIGN KEY (user_id) REFERENCES users (id)
    )
  ''');


  }
  Future<void> addReview({
    required int businessId,
    required int userId,
    required int rating,
    required String review,
  }) async {
    final db = await instance.database;
    await db.insert('reviews', {
      'business_id': businessId,
      'user_id': userId,
      'rating': rating,
      'review': review,
    });
  }

  Future<List<Map<String, dynamic>>> getReviewsByBusinessId(int businessId) async {
    final db = await instance.database;
    return await db.query(
      'reviews',
      where: 'business_id = ?',
      whereArgs: [businessId],
    );
  }

  Future<double?> getAverageRating(int businessId) async {
    final db = await instance.database;
    final result = await db.rawQuery('''
    SELECT AVG(rating) as avg_rating FROM reviews WHERE business_id = ?
  ''', [businessId]);

    if (result.isNotEmpty && result.first['avg_rating'] != null) {
      return result.first['avg_rating'] as double;
    }
    return null;
  }

  Future<List<Map<String, dynamic>>> searchBusinesses(String query) async {
    final db = await instance.database;

    // Query to search businesses by name or category
    return await db.rawQuery('''
    SELECT b.*, c.name AS category_name
    FROM businesses b
    JOIN sub_categories sc ON b.sub_category_id = sc.id
    JOIN categories c ON sc.category_id = c.id
    WHERE b.name LIKE ? OR c.name LIKE ?
  ''', ['%$query%', '%$query%']);
  }



  Future<void> _onUpgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 3) {
      await db.execute('''
        CREATE TABLE businesses (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          sub_category_id INTEGER NOT NULL,
          name TEXT NOT NULL,
          description TEXT NOT NULL,
          price_range TEXT,
          thumbnail TEXT,
          address TEXT,
          contact TEXT,
          services TEXT,
          FOREIGN KEY (sub_category_id) REFERENCES sub_categories (id)
        )
      ''');

    }
  }

  Future<void> populateCategories() async {
    final db = await instance.database;

    // Check if categories table already has data
    final categoryCount = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM categories'),
    );
    if (categoryCount != 0) return; // Data already exists

    // Insert main categories
    await db.insert('categories', {'name': 'Food', 'icon': '🍔'});
    await db.insert('categories', {'name': 'Healthcare', 'icon': '🏥'});
    await db.insert('categories', {'name': 'Hotels', 'icon': '🏨'});
    await db.insert('categories', {'name': 'Education', 'icon': '📚'});
    await db.insert('categories', {'name': 'Entertainment', 'icon': Icons.movie});
    await db.insert('categories', {'name': 'Shopping', 'icon': Icons.shopping_cart});
    await db.insert('categories', {'name': 'Fitness', 'icon': Icons.fitness_center});
    await db.insert('categories', {'name': 'Travel', 'icon': Icons.directions_car});
    await db.insert('categories', {'name': 'Other', 'icon': Icons.star});

    // Insert sub-categories
    await db.insert('sub_categories', {'category_id': 1, 'name': 'Restaurants'});
    await db.insert('sub_categories', {'category_id': 1, 'name': 'Cafes'});
    await db.insert('sub_categories', {'category_id': 2, 'name': 'Hospitals'});
    await db.insert('sub_categories', {'category_id': 2, 'name': 'Clinics'});
    await db.insert('sub_categories', {'category_id': 3, 'name': 'Hotels'});
    await db.insert('sub_categories', {'category_id': 3, 'name': 'Motels'});
    await db.insert('sub_categories', {'category_id': 4, 'name': 'Schools'});
    await db.insert('sub_categories', {'category_id': 4, 'name': 'Colleges'});
    await db.insert('sub_categories', {'category_id': 5, 'name': 'Movies'});
    await db.insert('sub_categories', {'category_id': 5, 'name': 'Theater'});
    await db.insert('sub_categories', {'category_id': 6, 'name': 'Mall'});
    await db.insert('sub_categories', {'category_id': 6, 'name': 'Online Shopping'});
    await db.insert('sub_categories', {'category_id': 7, 'name': 'Gim'});
    await db.insert('sub_categories', {'category_id': 7, 'name': 'Club'});
    await db.insert('sub_categories', {'category_id': 8, 'name': 'Travel Agency'});
    await db.insert('sub_categories', {'category_id': 8, 'name': 'Uber'});
    await db.insert('sub_categories', {'category_id': 9, 'name': 'Any Other'});
    await db.insert('sub_categories', {'category_id': 9, 'name': 'Others'});
  }

  Future<void> populateBusinesses() async {
    final db = await instance.database;

    // Check if businesses table already has data
    final businessCount = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM businesses'),
    );
    if (businessCount != 0) return; // Data already exists

    // Insert dummy businesses
    await db.insert('businesses', {
      'sub_category_id': 1, // Restaurants
      'name': 'Pizza Palace',
      'description': 'Delicious pizzas with fresh ingredients.',
      'price_range': '\$10 - \$30',
      'thumbnail': '🍕',
      'address': '123 Pizza St, Food City',
      'contact': '+1234567890',
      'services': '[{"name": "Pepperoni Pizza", "price": "\$12"}, {"name": "Veggie Pizza", "price": "\$10"}]',
    });

    await db.insert('businesses', {
      'sub_category_id': 2, // Cafes
      'name': 'Cozy Coffee Shop',
      'description': 'A perfect place for coffee and snacks.',
      'price_range': '\$5 - \$15',
      'thumbnail': '☕',
      'address': '456 Coffee Lane, Brew Town',
      'contact': '+0987654321',
      'services': '[{"name": "Latte", "price": "\$5"}, {"name": "Cappuccino", "price": "\$6"}]',
    });
  }

  Future<void> insertUser(Map<String, dynamic> user) async {
    final db = await instance.database;
    await db.insert('users', user);
  }


  Future<void> printTables() async {
    final db = await instance.database;
    final tables = await db.rawQuery("SELECT name FROM sqlite_master WHERE type='table';");
    for (var table in tables) {
      print('Table: ${table['name']}');
    }
  }

  Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    final db = await instance.database;
    final result = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );
    return result.isNotEmpty ? result.first : null;
  }

  Future<List<Map<String, dynamic>>> advancedSearch({
    String? name,
    String? category,
    String? subCategory,
    int? minPopularity,
    int? minPrice,
    int? maxPrice,
  }) async {
    final db = await database;

    String whereClause = '1=1'; // Always true for appending conditions
    List<dynamic> whereArgs = [];

    if (name != null && name.isNotEmpty) {
      whereClause += ' AND name LIKE ?';
      whereArgs.add('%$name%');
    }
    if (category != null && category.isNotEmpty) {
      whereClause += ' AND category = ?';
      whereArgs.add(category);
    }
    if (subCategory != null && subCategory.isNotEmpty) {
      whereClause += ' AND sub_category = ?';
      whereArgs.add(subCategory);
    }
    if (minPopularity != null) {
      whereClause += ' AND popularity >= ?';
      whereArgs.add(minPopularity);
    }
    if (minPrice != null) {
      whereClause += ' AND price_range >= ?';
      whereArgs.add(minPrice);
    }
    if (maxPrice != null) {
      whereClause += ' AND price_range <= ?';
      whereArgs.add(maxPrice);
    }

    return await db.query('businesses', where: whereClause, whereArgs: whereArgs);
  }


  Future<void> printTableData(String tableName) async {
    final db = await instance.database;
    final data = await db.query(tableName);
    for (var row in data) {
      print('Row: $row');
    }
  }



  Future<void> deleteDatabaseFile() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'business_info.db');
    await deleteDatabase(path);
    print('Database deleted successfully.');
  }

  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }

  getUserById(int userId) {}

  updateUserProfile(int userId, String trim, String trim2) {}

  insertBusiness(Map<String, String?> business) {}
}
