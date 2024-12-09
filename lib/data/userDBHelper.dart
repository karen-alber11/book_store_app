import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../data/DBHelper.dart';

class UserDatabaseHelper {
  static const String dbName = 'bookstore.db';
  static const String userTable = 'users';

  // User table columns
  static const String colUid = 'uid';
  static const String colUname = 'uname';
  static const String colUemail = 'uemail';
  static const String colUpass = 'upass';
  static const String colUtype = 'utype';
  static const String colBids = 'bids'; // JSON list of book IDs in the user's cart

  static final UserDatabaseHelper _instance = UserDatabaseHelper._internal();

  UserDatabaseHelper._internal();

  factory UserDatabaseHelper() => _instance;

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), dbName);
    return await openDatabase(
      path,
      version: 3,
      readOnly: false,
      onCreate: (db, version) async {
        await db.execute(''' 
        CREATE TABLE $userTable (
          $colUid INTEGER PRIMARY KEY AUTOINCREMENT,
          $colUname TEXT NOT NULL,
          $colUemail TEXT UNIQUE NOT NULL,
          $colUpass TEXT NOT NULL,
          $colUtype TEXT NOT NULL,
          $colBids TEXT NOT NULL DEFAULT '[]'
        )
      ''');

        print('Database created with initial schema');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          // Example migration logic: Add a new column if it does not exist
          await db.execute(''' 
          ALTER TABLE $userTable ADD COLUMN newColumn TEXT DEFAULT NULL
        ''');

          print('Database upgraded to version 2');
        }
        // Handle more version upgrade cases as needed
      },
    ).then((db) {
      print('Database initialized');
      return db;
    });
  }

  // Insert a new user
  Future<int> insertUser(Map<String, dynamic> user) async {
    final db = await database;
    user[colBids] = jsonEncode(user[colBids] ?? []);
    try {
      return await db.insert(userTable, user);
    } on DatabaseException catch (e) {
      print('Error inserting user: $e');
      throw e;
    }
  }

  Future<void> printUsers() async {
    final db = await database;
    final List<Map<String, dynamic>> users = await db.query(userTable);
    for (var user in users) {
      print('User: $user');
    }
  }

  // Fetch all users
  Future<List<Map<String, dynamic>>> fetchUsers() async {
    final db = await database;
    final users = await db.query(userTable);

    return users.map((user) {
      var bids = user[colBids];
      if (bids is String) {
        user[colBids] = jsonDecode(bids);
      } else if (bids == null) {
        user[colBids] = [];
      } else {
        throw FormatException("Unexpected format for $colBids column");
      }
      return user;
    }).toList();
  }

  // This method updates the user's cart in the database.
  Future<void> updateUserCart(int userId, List<int> bids) async {
    final db = await database;
    await db.update(
      userTable,
      {colBids: jsonEncode(bids)},
      where: '$colUid = ?',
      whereArgs: [userId],
    );
  }


  // Delete a user
  Future<int> deleteUser(int userId) async {
    final db = await database;
    return await db.delete(
      userTable,
      where: '$colUid = ?',
      whereArgs: [userId],
    );
  }

  // Close the database
  Future<void> closeDatabase() async {
    final db = await _database;
    db?.close();
  }

  // Add a book to the user's cart in the database
  Future<bool> addBookToCart(int userId, int bookId) async {
    final db = await database;
    final user = await db.query(
      userTable,
      where: '$colUid = ?',
      whereArgs: [userId],
    );

    if (user.isNotEmpty) {
      var bidsData = user.first[colBids];
      List<int> bids;

      if (bidsData != null && bidsData is String) {
        bids = List<int>.from(jsonDecode(bidsData));
      } else {
        bids = []; // Handle cases where bidsData is null or not a valid JSON string
      }

      if (!bids.contains(bookId)) {
        bids.add(bookId);
        await updateUserCart(userId, bids);
        print('Book added to cart!');
        return true;
      } else {
        print('Book is already in the cart.');
        return false;
      }
    } else {
      print('Error: User not found in the database.');
      return false;
    }
  }

  // Fetch a user by ID
  Future<Map<String, dynamic>?> getUserById(int userId) async {
    final db = await database;

    // Query the user by their ID
    final user = await db.query(
      userTable,
      where: '$colUid = ?',
      whereArgs: [userId],
    );

    if (user.isNotEmpty) {
      // Decode the 'bids' column to ensure it returns as a List<int>
      var userData = user.first;
      var bidsData = userData[colBids];

      if (bidsData is String) {
        userData[colBids] = jsonDecode(bidsData);
      } else if (bidsData == null) {
        userData[colBids] = [];
      } else {
        throw FormatException("Unexpected format for $colBids column");
      }

      return userData;
    }

    // Return null if the user is not found
    return null;
  }

  // Remove a book from the user's cart in the database
  Future<bool> removeBookFromCart(int userId, int bookId) async {
    final db = await database;

    // Query the user by their ID
    final user = await db.query(
      userTable,
      where: '$colUid = ?',
      whereArgs: [userId],
    );

    if (user.isNotEmpty) {
      // Get the current 'bids' and decode it
      var bidsData = user.first[colBids];
      List<int> bids;

      if (bidsData != null && bidsData is String) {
        bids = List<int>.from(jsonDecode(bidsData));
      } else {
        bids = [];
      }

      // Check if the book is in the cart and remove it
      if (bids.contains(bookId)) {
        bids.remove(bookId);
        await updateUserCart(userId, bids);
        print('Book removed from cart!');
        return true;
      } else {
        print('Book not found in the cart.');
        return false;
      }
    } else {
      print('Error: User not found in the database.');
      return false;
    }
  }


}
