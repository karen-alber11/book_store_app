import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../data/DBHelper.dart';
import '../widgets/widgets.dart';
import '../widgets/all_books_tile.dart';
import '../pages/add_book.dart';

class AllBooksPage extends StatefulWidget {
  @override
  _AllBooksPageState createState() => _AllBooksPageState();
}

class _AllBooksPageState extends State<AllBooksPage> {
  List<Map<String, dynamic>> allBooks = [];
  final BookDatabaseHelper _bookDbHelper = BookDatabaseHelper();

  @override
  void initState() {
    super.initState();
    _loadBooks();
  }

  Future<void> _loadBooks() async {
    // Fetch books from the database
    allBooks = await _bookDbHelper.fetchBooks();

    print('Books in database: $allBooks');
    setState(() {});
  }

  Future<void> _refreshBooks() async {
    // Refresh the books list
    await _loadBooks();
  }

  void _navigateToAddBook() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddBookPage()),
    ).then((_) {
      // Reload books after returning from AddBook
      _refreshBooks();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primary,
        title: Text(
          "All Books Page",
          style: TextStyle(
            color: secondary,
            fontSize: 23,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshBooks,
        child: allBooks.isEmpty
            ? Center(
          child: Text(
            "No books available!",
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
        )
            : Padding(
          padding: const EdgeInsets.all(12.0),
          child: ListView.builder(
            itemCount: allBooks.length,
            itemBuilder: (context, index) {
              return AllBooksTile(book: allBooks[index]);
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddBook,
        backgroundColor: primary,
        child: Icon(Icons.add, color: secondary),
      ),
    );
  }
}
