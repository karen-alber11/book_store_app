import 'dart:math';
import '../theme/colors.dart';
import 'package:flutter/material.dart';
import 'avatar_image.dart';

class BookCard extends StatelessWidget {
  BookCard({ Key? key, required this.book }) : super(key: key);
  final Map<String, dynamic> book;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      height: 260,
      margin: EdgeInsets.only(right: 25),
      padding: EdgeInsets.only(left: 10, right: 10, top: 14, bottom: 25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: shadowColor.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 1,
            offset: Offset(1, 1), // changes position of shadow
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.only(left: 5),
            decoration: BoxDecoration(
              color: Color(Random().nextInt(0xffffffff)).withAlpha(0xff),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: primary,
                borderRadius: BorderRadius.circular(6),
              ),
              child:
              // Image.network(
              //   book["bimg"] ?? "assets/placeholder.png", // Placeholder if image is not found
              //   width: 80,
              //   height: 100,
              //   fit: BoxFit.cover,
              //   loadingBuilder: (context, child, loadingProgress) {
              //     if (loadingProgress == null) {
              //       return child;
              //     } else {
              //       return Center(
              //         child: CircularProgressIndicator(),
              //       );
              //     }
              //   },
              //   errorBuilder: (context, error, stackTrace) {
              //     return Center(
              //       child: Icon(Icons.broken_image, size: 40, color: Colors.grey),
              //     );
              //   },
              // ),
              AvatarImage(
                book["bimg"] ?? "assets/placeholder.png", // Corrected to use `bimg`
                isSVG: false,
                radius: 8,
                height: 110,
              ),
            ),
          ),
          SizedBox(height: 15),
          Text(
            book["btitle"] ?? "Unknown Title", // Ensure correct column name
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8),
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              children: [
                TextSpan(
                  text: book["bprice"] != null ? "\$${book["bprice"]}" : "N/A", // Ensure price formatting
                  style: TextStyle(
                    fontSize: 16,
                    color: primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                TextSpan(text: "   "),
                TextSpan(
                  text: book["boriginal_price"] != null ? "\$${book["boriginal_price"]}" : "",
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
    );
  }
}
