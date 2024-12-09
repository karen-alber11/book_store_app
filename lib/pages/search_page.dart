import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../theme/colors.dart';
import '../data/DBHelper.dart';
import '../widgets/book_item.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _searchResults = [];
  bool _isSearching = false;
  bool _noMatchFound = false;

  Future<void> _searchBooks() async {
    final String query = _searchController.text.trim();

    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _noMatchFound = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _noMatchFound = false;
    });

    final dbHelper = BookDatabaseHelper();
    List<Map<String, dynamic>> books = await dbHelper.fetchBooks();

    final results = books.where((book) {
      final title = book['btitle']?.toLowerCase() ?? '';
      return title.contains(query.toLowerCase());
    }).toList();

    setState(() {
      _isSearching = false;
      _searchResults = results;
      _noMatchFound = results.isEmpty;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primary,
        title: Text(
          "Search Books",
          style: TextStyle(
            color: secondary,
            fontSize: 23,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search by title...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12.0),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.search),
                  onPressed: _searchBooks,
                ),
              ],
            ),
            SizedBox(height: 16.0),
            if (_isSearching)
              Center(child: CircularProgressIndicator())
            else if (_noMatchFound)
              Text(
                'No match found!',
                style: TextStyle(
                  color: primary,
                  fontSize: 16.0,
                ),
              )
            else if (_searchResults.isNotEmpty)
                Expanded(
                  child: ListView.builder(
                    itemCount: _searchResults.length,
                    itemBuilder: (context, index) {
                      final book = _searchResults[index];
                      return BookItem(
                        book: book,
                        onAddToCart: () => print('${book["btitle"]} added to cart'),
                        onRemoveFromCart: () => print('${book["btitle"]} removed from cart'),
                      );
                    },
                  ),
                )
              else
                SizedBox.shrink(),
          ],
        ),
      ),
    );
  }
}
