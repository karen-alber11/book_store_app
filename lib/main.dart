import 'package:flutter/material.dart';
import '../theme/colors.dart';
import 'pages/login_page.dart';
import 'pages/home.dart';
import '../data/DBHelper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Future.delayed(Duration.zero); // Optional: delay to ensure database initialization is completed
  runApp(MyApp());
}
// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   final bookDbHelper = BookDatabaseHelper();
//   // Drop and recreate the database
//   final db = await bookDbHelper.database;
//   await bookDbHelper.deleteAllBooks(); // Optional: To clear the table
//   await insertBooks(bookDbHelper); // Insert new books
//   runApp(MyApp());
// }


class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Book Store',
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: primary,
      ),
      home: LoginPage(),
    );
  }
}

// Function to insert books
// Future<void> insertBooks(BookDatabaseHelper bookDbHelper) async {
//   var latestBooks = [
//     {
//       "title" : "The Creative Ideas",
//       "image" : "https://d1csarkz8obe9u.cloudfront.net/posterpreviews/how-to-creative-ideas-book-cover-design-template-52f7ec58f53452b9b46a351cea1bd9a1_screen.jpg",
//       "price" : "\$58.99",
//       "ori_price" : "\$120.50",
//       'isPopular': 0,
//       'isLatest': 1,
//     },
//     {
//       "title" : "Follow Me to Ground",
//       "image" : "https://s26162.pcdn.co/wp-content/uploads/2019/12/46301955-668x1024.jpg",
//       "price" : "\$19.99",
//       "ori_price" : "\$120.50",
//       'isPopular': 0,
//       'isLatest': 1,
//     },
//     {
//       "title" : "Snow at Sunset",
//       "image" : "https://wepik.com/storage/previews/1853935/conversions/minimalist-snow-winter-book-cover-r-908311156page1-thumb.jpg",
//       "price" : "\$29.90",
//       "ori_price" : "\$120.50",
//       'isPopular': 0,
//       'isLatest': 1,
//     },
//     {
//       "title" : "The Prince of Thorns",
//       "image" : "https://www.thecreativepenn.com/wp-content/uploads/2018/04/image1.jpeg",
//       "price" : "\$9.99",
//       "ori_price" : "\$120.50",
//       'isPopular': 0,
//       'isLatest': 1,
//     },
//     {
//       "title" : "The Last Breath",
//       "image" : "https://i.pinimg.com/originals/fc/52/3f/fc523fab7bcc161d8cca966ee974be64.png",
//       "price" : "\$93.90",
//       "ori_price" : "\$120.50",
//       'isPopular': 0,
//       'isLatest': 1,
//     },
//     {
//       "title" : "The Secrets",
//       "image" : "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSwf6U8c_AwOwZvz9CjfMEzikpESGwcNqSuxQ&usqp=CAU",
//       "price" : "\$45.50",
//       "ori_price" : "\$120.50",
//       'isPopular': 0,
//       'isLatest': 1,
//     }
//   ];
//
//   var popularBooks = [
//     {
//       "title" : "The Way of the Nameless",
//       "image" : "https://d1csarkz8obe9u.cloudfront.net/posterpreviews/teal-and-orange-fantasy-book-cover-design-template-056106feb952bdfb7bfd16b4f9325c11.jpg",
//       "price" : "\$19.99",
//       "ori_price" : "\$40.00",
//       'isPopular': 1,
//       'isLatest': 0,
//     },
//     {
//       "title" : "The Power of You",
//       "image" : "https://i.pinimg.com/originals/97/c4/99/97c499de2581f8cca7f415b4d85870a5.jpg",
//       "price" : "\$9.99",
//       "ori_price" : "\$23.50",
//       'isPopular': 1,
//       'isLatest': 0,
//     },
//     {
//       "title" : "The Glow",
//       "image" : "https://i.pinimg.com/736x/4f/59/aa/4f59aaa78f898054f949351515875b3c--book-cover-design-book-design.jpg",
//       "price" : "\$26.50",
//       "ori_price" : "\$120.50",
//       'isPopular': 1,
//       'isLatest': 0,
//     },
//     {
//       "title" : "The Happy Morning",
//       "image" : "https://pro2-bar-s3-cdn-cf6.myportfolio.com/4573a45834d27f53b119f41019fcc904/a7c97b6f-b81e-4cc5-a59e-c9bdf1b3c746_rw_1200.jpg",
//       "price" : "\$14.99",
//       "ori_price" : "\$120.50",
//       'isPopular': 1,
//       'isLatest': 0,
//     },
//     {
//       "title" : "Undersea World",
//       "image" : "https://www.edrawsoft.com/templates/images/seaworld-children-book-cover.png",
//       "price" : "\$29.99",
//       "ori_price" : "\$60.50",
//       'isPopular': 1,
//       'isLatest': 0,
//     },
//     {
//       "title" : "The Last Breath",
//       "image" : "https://www.ingramspark.com/hubfs/Book-Cover-Design-Pillar/32.png",
//       "price" : "\$9.99",
//       "ori_price" : "\$120.50",
//       'isPopular': 1,
//       'isLatest': 0,
//     }
//   ];
// // Combine all books into one list
//   var allBooks = [...latestBooks, ...popularBooks];
//
//   for (var book in allBooks) {
//     try {
//       await bookDbHelper.insertBook({
//         'btitle': book['title'],
//         'bimg': book['image'],
//         'bprice': double.tryParse((book['price'] as String?)?.replaceAll('\$', '') ?? "0") ?? 0,
//         'boriginal_price': double.tryParse((book['ori_price'] as String?)?.replaceAll('\$', '') ?? "0") ?? 0,
//         'uids': [], // Default to an empty history
//         'isPopular': book['isPopular'] ?? 0,
//         'isLatest': book['isLatest'] ?? 0,
//       });
//     } catch (e) {
//       print("Failed to insert book '${book['title']}': $e");
//     }
//   }
//
//   print("Books have been inserted successfully!");
//
// }
