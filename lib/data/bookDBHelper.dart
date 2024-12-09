import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../data/DBHelper.dart';

class BookDatabaseHelper {
  static const String dbName = 'bookstore.db';
  static const String bookTable = 'books';

  // Book table columns
  static const String colBid = 'bid';
  static const String colBtitle = 'btitle';
  static const String colBimg = 'bimg';
  static const String colBprice = 'bprice';
  static const String colBoriginalPrice = 'boriginal_price';
  static const String colUids = 'uids'; // JSON list of user IDs in the book's history
  static const String colIsPopular = 'isPopular';
  static const String colIsLatest = 'isLatest';

  static final BookDatabaseHelper _instance = BookDatabaseHelper._internal();

  BookDatabaseHelper._internal();

  factory BookDatabaseHelper() => _instance;

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
      version: 3, // Incremented version to 3
      onCreate: (db, version) async {
        await db.execute(''' 
        CREATE TABLE $bookTable (
          $colBid INTEGER PRIMARY KEY AUTOINCREMENT,
          $colBtitle TEXT NOT NULL,
          $colBimg TEXT,
          $colBprice REAL NOT NULL,
          $colBoriginalPrice REAL NOT NULL,
          $colUids TEXT NOT NULL DEFAULT '[]',
          $colIsPopular INTEGER NOT NULL DEFAULT 0, -- 0 for false, 1 for true
          $colIsLatest INTEGER NOT NULL DEFAULT 0  -- 0 for false, 1 for true
        )
      ''');
        print('Book database created');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        print('Upgrading database from version $oldVersion to $newVersion...');
        if (oldVersion < 3) {
          await _dropAndRecreateTable(db);
        }
      },
    );
  }

  Future<void> _dropAndRecreateTable(Database db) async {
    print('Dropping and recreating table $bookTable');
    await db.execute('DROP TABLE IF EXISTS $bookTable');
    await db.execute(''' 
    CREATE TABLE $bookTable (
      $colBid INTEGER PRIMARY KEY AUTOINCREMENT,
      $colBtitle TEXT NOT NULL,
      $colBimg TEXT,
      $colBprice REAL NOT NULL,
      $colBoriginalPrice REAL NOT NULL,
      $colUids TEXT NOT NULL DEFAULT '[]',
      $colIsPopular INTEGER NOT NULL DEFAULT 0,
      $colIsLatest INTEGER NOT NULL DEFAULT 0
    )
    ''');
    print('Table $bookTable recreated');
  }

  // Insert a new book
  Future<int> insertBook(Map<String, dynamic> book) async {
    final db = await database;
    book[colUids] = jsonEncode(book[colUids] ?? []);
    book[colIsPopular] = book[colIsPopular] ?? 0;
    book[colIsLatest] = book[colIsLatest] ?? 0;
    return await db.insert(bookTable, book);
  }

  Future<List<Map<String, dynamic>>> fetchBooks() async {
    final db = await database;
    final books = await db.query(bookTable);

    // Debugging: Print fetched books
    print('Raw books from database: $books');

    // Decode uids and return books as a list of maps
    return books.map((book) {
      Map<String, dynamic> mutableBook = Map.from(book);

      // Decode JSON list for uids column
      if (mutableBook[colUids] is String) {
        mutableBook[colUids] = jsonDecode(mutableBook[colUids]);
      } else {
        mutableBook[colUids] = [];
      }

      print('Processed book: $mutableBook');
      return mutableBook;
    }).toList();
  }


  Future<int> deleteAllBooks() async {
    final db = await database;
    return await db.delete(bookTable);
  }

  Future<int> deleteBook(int bookId) async {
    final db = await database;
    return await db.delete(
      bookTable,
      where: '$colBid = ?',
      whereArgs: [bookId],
    );
  }

  Future<void> printBooks() async {
    final db = await database;
    final List<Map<String, dynamic>> books = await db.query(bookTable);
    for (var book in books) {
      print('Book: $book');
    }
  }

  Future<void> closeDatabase() async {
    final db = await _database;
    db?.close();
  }

  Future<int> updateBookStatus(int bookId, bool isPopular, bool isLatest) async {
    final db = await database;
    return await db.update(
      bookTable,
      {
        colIsPopular: isPopular ? 1 : 0,
        colIsLatest: isLatest ? 1 : 0,
      },
      where: '$colBid = ?',
      whereArgs: [bookId],
    );
  }

  Future<List<Map<String, dynamic>>> getPopularBooks() async {
    final db = await database;
    final popularBooks = await db.query(
      bookTable,
      where: '$colIsPopular = ?',
      whereArgs: [1],
    );
    print('Popular books fetched: ${popularBooks.length}');
    return _decodeUidsInBooks(popularBooks);
  }

  Future<List<Map<String, dynamic>>> getLatestBooks() async {
    final db = await database;
    final latestBooks = await db.query(
      bookTable,
      where: '$colIsLatest = ?',
      whereArgs: [1],
    );

    print('Latest books fetched: ${latestBooks.length}');
    return _decodeUidsInBooks(latestBooks);
  }

  List<Map<String, dynamic>> _decodeUidsInBooks(List<Map<String, dynamic>> books) {
    return books.map((book) {
      Map<String, dynamic> mutableBook = Map.from(book);
      var uids = mutableBook[colUids];
      if (uids is String) {
        mutableBook[colUids] = jsonDecode(uids);
      } else if (uids == null) {
        mutableBook[colUids] = [];
      } else {
        throw FormatException("Unexpected format for $colUids column");
      }
      return mutableBook;
    }).toList();
  }

  Future<void> addBookToCart(int userId, int bookId) async {
    final db = await database;
    await UserDatabaseHelper().updateUserCart(userId, [bookId]);
  }

}
