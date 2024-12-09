import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/DBHelper.dart';
import '../theme/colors.dart';
import 'dart:math';
import '../widgets/avatar_image.dart';

class AllBooksTile extends StatelessWidget {
  final Map<String, dynamic> book;

  const AllBooksTile({
    Key? key,
    required this.book,
  }) : super(key: key);

  void showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _deleteBook(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('currentUserId');

    if (userId == null) {
      showSnackBar(context, "User not logged in.");
      return;
    }

    final dbHelper = UserDatabaseHelper();
    final userDb = await dbHelper.database;
    final user = await userDb.query(
      UserDatabaseHelper.userTable,
      where: '${UserDatabaseHelper.colUid} = ?',
      whereArgs: [userId],
    );

    if (user.isNotEmpty) {
      final userType = user.first[UserDatabaseHelper.colUtype];

      if (userType == 'Admin') {
        // Delete the book
        final bookDbHelper = BookDatabaseHelper();
        final rowsDeleted = await bookDbHelper.deleteBook(book['bid']);
        if (rowsDeleted > 0) {
          showSnackBar(context, "Book deleted successfully.");
        } else {
          showSnackBar(context, "Failed to delete the book.");
        }
      } else {
        showSnackBar(context, "Only Admins can delete books.");
      }
    } else {
      showSnackBar(context, "User not found.");
    }
  }

  @override
  Widget build(BuildContext context) {
    String bookTitle = book["btitle"] ?? 'No Title';
    String bookImage = book["bimg"] ?? 'path/to/default/image.png';
    String bookPrice = book["bprice"]?.toString() ?? 'N/A';
    String originalPrice = book["boriginal_price"]?.toString() ?? 'N/A';

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
                  color: secondary,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 1,
                      offset: Offset(1, 1),
                    ),
                  ],
                ),
                child: Container(
                  width: 40,
                  height: 50,
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
                Icons.delete,
                color: primary,
              ),
              onPressed: () => _deleteBook(context),
            ),
          ),
        ],
      ),
    );
  }
}
