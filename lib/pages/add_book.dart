import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../data/DBHelper.dart';

class AddBookPage extends StatefulWidget {
  @override
  _AddBookPageState createState() => _AddBookPageState();
}

class _AddBookPageState extends State<AddBookPage> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController originalPriceController = TextEditingController();
  final TextEditingController imageLinkController = TextEditingController();
  int isLatest = 1;
  int isPopular = 1;
  final BookDatabaseHelper _bookDbHelper = BookDatabaseHelper();

  void _addBook() async {
    if (titleController.text.isEmpty ||
        priceController.text.isEmpty ||
        originalPriceController.text.isEmpty) {
      _showSnackBar("Please fill all fields");
      return;
    }

    final book = {
      BookDatabaseHelper.colBtitle: titleController.text,
      BookDatabaseHelper.colBprice: double.tryParse(priceController.text) ?? 0.0,
      BookDatabaseHelper.colBoriginalPrice:
      double.tryParse(originalPriceController.text) ?? 0.0,
      BookDatabaseHelper.colBimg: imageLinkController.text,
      BookDatabaseHelper.colIsPopular: isPopular,
      BookDatabaseHelper.colIsLatest: isLatest,
    };

    await _bookDbHelper.insertBook(book);
    Navigator.pop(context);
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_sharp),
          color: secondary,
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: primary,
        title: Text(
          "Add Book",
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                labelText: "Book Title",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: priceController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Book Price",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: originalPriceController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Book Original Price",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: imageLinkController,
              decoration: InputDecoration(
                labelText: "Book Image Link",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<int>(
                    value: isLatest,
                    decoration: InputDecoration(
                      labelText: "Is Latest",
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      DropdownMenuItem(value: 1, child: Text("Yes")),
                      DropdownMenuItem(value: 0, child: Text("No")),
                    ],
                    onChanged: (value) {
                      setState(() {
                        isLatest = value!;
                      });
                    },
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<int>(
                    value: isPopular,
                    decoration: InputDecoration(
                      labelText: "Is Popular",
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      DropdownMenuItem(value: 1, child: Text("Yes")),
                      DropdownMenuItem(value: 0, child: Text("No")),
                    ],
                    onChanged: (value) {
                      setState(() {
                        isPopular = value!;
                      });
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 24),
            Center(
              child: ElevatedButton(
                onPressed: _addBook,
                child: Text("Add"),
                style: ElevatedButton.styleFrom(
                  padding:
                  EdgeInsets.symmetric(horizontal: 50, vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
