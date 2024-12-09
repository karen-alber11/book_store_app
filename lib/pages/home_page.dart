import 'package:flutter/material.dart';
import '../data/DBHelper.dart';
import '../widgets/widgets.dart';
import '../theme/colors.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> popularBooks = [];
  List<Map<String, dynamic>> latestBooks = [];
  List<Map<String, dynamic>> books = [];

  @override
  void initState() {
    super.initState();
    loadBooks();
  }

  void loadBooks() async {
    final allBooks = await BookDatabaseHelper().fetchBooks();

    // Debugging: Print all books fetched
    print('All books fetched: $allBooks');

    setState(() {
      popularBooks = allBooks.where((book) => book['isPopular'] == 1).toList();
      latestBooks = allBooks.where((book) => book['isLatest'] == 1).toList();
    });

    // Debugging: Print filtered books
    print('Popular books: $popularBooks');
    print('Latest books: $latestBooks');
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: primary,
        elevation: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Container(
                alignment: Alignment.centerLeft,
                child: Icon(Icons.vertical_distribute_rounded),
              ),
            ),
            Icon(Icons.search_rounded, color: Colors.white),
            SizedBox(width: 15),
            Icon(Icons.person, color: Colors.white),
          ],
        ),
      ),
      body: getStackBody(),
    );
  }

  Widget getStackBody() {
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  child: getTopBlock(),
                ),
                Positioned(
                  top: 140,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 260,
                    child: getPopularBooks(),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.only(left: 15, right: 15, top: 10),
                child: Text(
                  "Latest Books",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ),
              SizedBox(height: 15),
              Container(
                margin: EdgeInsets.only(left: 15),
                child: getLatestBooks(),
              ),
              SizedBox(height: 25),
            ],
          ),
        ],
      ),
    );
  }

  Widget getTopBlock() {
    return Column(
      children: [
        Container(
          width: double.infinity,
          height: 250,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(bottomLeft: Radius.circular(100)),
            color: primary,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 10),
              Container(
                margin: EdgeInsets.only(left: 35, right: 15),
                child: Text(
                  "Hi,",
                  style: TextStyle(
                      color: secondary,
                      fontSize: 23,
                      fontWeight: FontWeight.w600),
                ),
              ),
              SizedBox(height: 10),
              Container(
                margin: EdgeInsets.only(left: 35, right: 15),
                child: Text(
                  "Welcome to our Book Store App!",
                  style: TextStyle(
                      color: secondary,
                      fontSize: 15,
                      fontWeight: FontWeight.w500),
                ),
              ),
              SizedBox(height: 35),
              Container(
                padding: EdgeInsets.only(left: 15, right: 15),
                child: Text(
                  "Popular Books",
                  style: TextStyle(
                      color: secondary,
                      fontSize: 18,
                      fontWeight: FontWeight.w600),
                ),
              ),
              SizedBox(height: 15),
            ],
          ),
        ),
        Container(
          height: 150,
          color: primary,
          child: Container(
            decoration: BoxDecoration(
              color: appBgColor,
              borderRadius: BorderRadius.only(topRight: Radius.circular(100)),
            ),
          ),
        )
      ],
    );
  }

  Widget getPopularBooks() {
    return SingleChildScrollView(
      padding: EdgeInsets.only(bottom: 5, left: 15),
      scrollDirection: Axis.horizontal,
      child: Row(
        children: popularBooks.map((book) => BookCard(book: book)).toList(),
      ),
    );
  }

  Widget getLatestBooks() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: latestBooks.map((book) {
          return BookCover(book: book);
        }).toList(),
      ),
    );
  }

}
