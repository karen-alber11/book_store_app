import 'package:badges/badges.dart' as badges;
import '../data/json.dart';
import '../theme/colors.dart';
import '../widgets/widgets.dart';
import '../data/DBHelper.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../pages/cart_page.dart';

class BookPage extends StatefulWidget {
  const BookPage({Key? key}) : super(key: key);

  @override
  _BookPageState createState() => _BookPageState();
}

class _BookPageState extends State<BookPage> {
  List<Map<String, dynamic>> popularBooks = [];
  List<Map<String, dynamic>> latestBooks = [];
  List<Map<String, dynamic>> books = [];

  @override
  void initState() {
    super.initState();
    loadBooks();
  }

  Future<void> loadBooks() async {
    // Fetch popular and latest books from the database
    popularBooks = await BookDatabaseHelper().getPopularBooks();
    latestBooks = await BookDatabaseHelper().getLatestBooks();

    print('Popular books: $popularBooks');
    print('Latest books: $latestBooks');

    setState(() {});
  }


  @override
  Widget build(BuildContext context) {
    return body();
  }

  Widget body() {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: appBgColor,
          elevation: 0,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Container(
                  alignment: Alignment.centerLeft,
                  child: Icon(
                    Icons.vertical_distribute_rounded,
                    color: primary,
                  ),
                ),
              ),
              Icon(
                Icons.search_rounded,
                color: primary,
              ),
              SizedBox(width: 15),
              badges.Badge(
                position: badges.BadgePosition.topEnd(top: -10, end: -10),
                badgeContent: Text(
                  '',
                  style: TextStyle(color: Colors.white),
                ),
                child: GestureDetector(
                  child: Icon(
                    Icons.shopping_bag_rounded,
                    color: primary,
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => CartPage()),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        body: Column(
          children: [
            Container(
              margin: EdgeInsets.only(left: 15, right: 15, top: 10, bottom: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.grey.shade200,
                boxShadow: [
                  BoxShadow(
                    color: shadowColor.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 1,
                    offset: Offset(1, 1),
                  ),
                ],
              ),
              child: TabBar(
                indicatorColor: primary,
                indicator: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: primary,
                ),
                labelPadding: EdgeInsets.only(top: 8, bottom: 8),
                unselectedLabelColor: primary,
                indicatorSize: TabBarIndicatorSize.tab,
                tabs: [
                  Text(
                    "New Books",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  Text(
                    "Popular Books",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  ListView(
                    scrollDirection: Axis.vertical,
                    padding: EdgeInsets.only(left: 15, right: 15),
                    children: getLatestBooks(),
                  ),
                  ListView(
                    scrollDirection: Axis.vertical,
                    padding: EdgeInsets.only(left: 15, right: 15),
                    children: getPopularBooks(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> getPopularBooks() {
    return popularBooks.map((book) => BookItem(
      book: book,
      onAddToCart: () => addToCart(book['id']), // Add this callback
    )).toList();
  }

  List<Widget> getLatestBooks() {
    return latestBooks.map((book) => BookItem(
      book: book,
      onAddToCart: () => addToCart(book['id']), // Add this callback
    )).toList();
  }

  Future<void> addToCart(int bookId) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('currentUserId');

    if (userId == null) {
      showSnackBar("User not logged in. Please log in to add items to the cart.");
      return;
    }

    String? bids = prefs.getString('bids');
    List<int> bidsList = bids != null ? List<int>.from(bids.split(',').map((e) => int.parse(e))) : [];

    if (!bidsList.contains(bookId)) {
      bidsList.add(bookId);
      await prefs.setString('bids', bidsList.join(','));
      showSnackBar("Book added to cart.");
    } else {
      showSnackBar("Book is already in the cart.");
    }
  }

  void showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
}
