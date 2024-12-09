import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../theme/colors.dart';
import '../data/DBHelper.dart';
import '../widgets/widgets.dart';

class CartPage extends StatefulWidget {
  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  List<BookItem> _cartBooks = [];
  final BookDatabaseHelper _bookDbHelper = BookDatabaseHelper();
  final UserDatabaseHelper _userDbHelper = UserDatabaseHelper();

  @override
  void initState() {
    super.initState();
    _loadCartBooks();
  }

  Future<void> _loadCartBooks() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('currentUserId');

    if (userId != null) {
      final db = await _userDbHelper.database;
      final user = await db.query(
        UserDatabaseHelper.userTable,
        where: '${UserDatabaseHelper.colUid} = ?',
        whereArgs: [userId],
      );

      if (user.isNotEmpty) {
        var bidsData = user.first[UserDatabaseHelper.colBids];
        List<int> bids;

        if (bidsData != null && bidsData is String) {
          bids = List<int>.from(jsonDecode(bidsData));
        } else {
          bids = [];
        }

        final allBooks = await _bookDbHelper.fetchBooks();
        final cartBooks = allBooks.where((book) => bids.contains(book['bid'])).toList();

        setState(() {
          _cartBooks = cartBooks.map((book) => BookItem(book: book, isInCartPage: true, onRemoveFromCart: _loadCartBooks)).toList();
        });
      } else {
        setState(() {
          _cartBooks = [];
        });
      }
    } else {
      setState(() {
        _cartBooks = [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_sharp),
          color: secondary,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: primary,
        title: Text(
          "Cart",
          style: TextStyle(
            color: secondary,
            fontSize: 23,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Column(
        children: [
          _cartBooks.isEmpty
              ? Center(
            child: Text(
              "Your cart is empty!",
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          )
              : Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: ListView.builder(
                itemCount: _cartBooks.length,
                itemBuilder: (context, index) {
                  return _cartBooks[index];
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextButton(
              onPressed: () {
                // Add functionality for purchase button here if needed
              },
              child: Text("Purchase", style: TextStyle(color: secondary,)),
              style: TextButton.styleFrom(
                backgroundColor: primary, // Customize the background color if needed
                padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
                textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
            ),
          ),
        ],
      ),
    );
  }

}

