import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/colors.dart';
import 'avatar_image.dart';
import '../data/DBHelper.dart';
import 'dart:convert';

class BookItem extends StatefulWidget {
  final Map<String, dynamic> book;
  final bool isInCartPage;
  final VoidCallback? onRemoveFromCart;
  final VoidCallback? onAddToCart;

  const BookItem({
    Key? key,
    required this.book,
    this.isInCartPage = false, // Default to false for general use
    this.onRemoveFromCart,
    this.onAddToCart,
  }) : super(key: key);

  @override
  _BookItemState createState() => _BookItemState();
}

class _BookItemState extends State<BookItem> {
  bool isInCart = false; // Tracks if the book is in the cart

  @override
  void initState() {
    super.initState();
    _checkIfInCart();
  }

  Future<void> _checkIfInCart() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? userId = prefs.getInt('currentUserId');

    if (userId != null) {
      final dbHelper = UserDatabaseHelper();
      final user = await dbHelper.getUserById(userId);
      if (user != null && user.containsKey('bids')) {
        List<int> bids = List<int>.from(jsonDecode(user['bids'] ?? '[]'));
        setState(() {
          isInCart = bids.contains(widget.book['bid']);
        });
      }
    }
  }

  Future<void> _toggleCartStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? userId = prefs.getInt('currentUserId');

    if (userId == null) {
      print('Error: No user ID found in SharedPreferences.');
      return;
    }

    int? bookId = widget.book['bid'];
    if (bookId == null) {
      print('Error: Book ID is null or not an integer.');
      return;
    }

    final dbHelper = UserDatabaseHelper();
    if (widget.isInCartPage) {
      // If in the cart page, always remove the book
      await dbHelper.removeBookFromCart(userId, bookId);
      setState(() {
        isInCart = false;
      });
      widget.onRemoveFromCart?.call(); // Call the remove callback if provided
    } else {
      // Normal add/remove logic
      if (isInCart) {
        await dbHelper.removeBookFromCart(userId, bookId);
        setState(() {
          isInCart = false;
        });
        widget.onRemoveFromCart?.call();
      } else {
        final success = await dbHelper.addBookToCart(userId, bookId);
        if (success) {
          setState(() {
            isInCart = true;
          });
          widget.onRemoveFromCart?.call();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    String bookTitle = widget.book["btitle"] ?? 'No Title';
    String bookImage = widget.book["bimg"] ?? 'path/to/default/image.png';
    String bookPrice = widget.book["bprice"]?.toString() ?? 'N/A';
    String originalPrice = widget.book["boriginal_price"]?.toString() ?? 'N/A';

    return Container(
      margin: EdgeInsets.only(bottom: 10),
      padding: EdgeInsets.only(top: 15),
      child: Row(
        children: [
          // Book image
          Stack(
            children: [
              Container(
                padding: EdgeInsets.only(bottom: 50, right: 40),
                width: 80,
                height: 100,
                decoration: BoxDecoration(
                  color: primary,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: shadowColor.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 1,
                      offset: Offset(1, 1),
                    ),
                  ],
                ),
                child: Container(
                  width: 80 / 2,
                  height: 100 / 2,
                  decoration: BoxDecoration(
                    color: Color(Random().nextInt(0xffffffff)).withAlpha(0xff),
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(15)),
                  ),
                ),
              ),
              Container(
                width: 80,
                height: 100,
                padding: EdgeInsets.all(8),
                child: AvatarImage(
                  bookImage,
                  isSVG: false,
                  radius: 8,
                ),
              ),
            ],
          ),
          SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  bookTitle,
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 12),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: bookPrice,
                        style: TextStyle(
                          fontSize: 16,
                          color: primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      TextSpan(text: "   "),
                      TextSpan(
                        text: originalPrice,
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 16,
                          decoration: TextDecoration.lineThrough,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 10),
          Align(
            alignment: Alignment.bottomCenter,
            child: IconButton(
              icon: Icon(
                widget.isInCartPage ? Icons.remove_shopping_cart : isInCart ? Icons.remove_shopping_cart : Icons.add_shopping_cart,
                color: isInCart || widget.isInCartPage ? Colors.black : Colors.black, // Visual feedback
              ),
              onPressed: _toggleCartStatus,
            ),
          ),
        ],
      ),
    );
  }
}


