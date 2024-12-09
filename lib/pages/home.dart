import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../pages/book_page.dart';
import '../pages/search_page.dart';
import '../pages/all_books_page.dart';
import '../theme/colors.dart';
import '../widgets/bottombar_item.dart';
import '../pages/settings_page.dart';
import 'home_page.dart';
import '../data/DBHelper.dart'; // Ensure this import is available for database helper

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int activeTab = 0;
  String userType = ""; // Variable to hold the user type

  @override
  void initState() {
    super.initState();
    _getUserType();
  }

  Future<void> _getUserType() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('currentUserId');

    if (userId != null) {
      final userDbHelper = UserDatabaseHelper();
      final db = await userDbHelper.database;
      final user = await db.query(
        UserDatabaseHelper.userTable,
        where: '${UserDatabaseHelper.colUid} = ?',
        whereArgs: [userId],
      );

      if (user.isNotEmpty) {
        setState(() {
          userType = (user.first[UserDatabaseHelper.colUtype] as String?) ?? '';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appBgColor,
      bottomNavigationBar: getBottomBar(),
      body: getPage(),
    );
  }

  Widget getBottomBar() {
    return Container(
      height: 65,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(topLeft: Radius.circular(100)),
        color: bottomBarColor,
      ),
      child: Padding(
        padding: const EdgeInsets.only(left: 25, right: 25, top: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            GestureDetector(
              onTap: () => setState(() => activeTab = 0),
              child: BottomBarItem(
                Icons.home,
                "",
                isActive: activeTab == 0,
                activeColor: secondary,
              ),
            ),
            GestureDetector(
              onTap: () => setState(() => activeTab = 1),
              child: BottomBarItem(
                Icons.my_library_books_rounded,
                "",
                isActive: activeTab == 1,
                activeColor: secondary,
              ),
            ),
            GestureDetector(
              onTap: () => setState(() => activeTab = 2),
              child: BottomBarItem(
                Icons.settings,
                "",
                isActive: activeTab == 2,
                activeColor: secondary,
              ),
            ),
            // Conditional icon based on user type
            GestureDetector(
              onTap: () => setState(() => activeTab = 3),
              child: BottomBarItem(
                userType == 'User' ? Icons.search_rounded : Icons.add_circle_outline_rounded,
                "",
                isActive: activeTab == 3,
                activeColor: secondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget getPage() {
    return Container(
      decoration: BoxDecoration(color: bottomBarColor),
      child: Container(
        decoration: BoxDecoration(
          color: appBgColor,
          borderRadius: BorderRadius.only(bottomRight: Radius.circular(80)),
        ),
        child: IndexedStack(
          index: activeTab,
          children: <Widget>[
            HomePage(),
            BookPage(),
            UserSettingsScreen(),
            // Add a placeholder for the new page
            userType == 'User' ? SearchPage() : AllBooksPage(),
          ],
        ),
      ),
    );
  }
}
