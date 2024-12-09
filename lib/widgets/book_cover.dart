import 'dart:math';
import '../theme/colors.dart';
import 'package:flutter/material.dart';
import 'avatar_image.dart';

class BookCover extends StatelessWidget {
  BookCover({Key? key, required this.book}) : super(key: key);
  final Map<String, dynamic> book;

  @override
  Widget build(BuildContext context) {
    double _width = 75, _height = 95;

    return Container(
      margin: EdgeInsets.only(right: 15),
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                padding: EdgeInsets.only(bottom: 50, right: 40),
                width: _width,
                height: _height,
                decoration: BoxDecoration(
                  color: primary,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: shadowColor.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 1,
                      offset: Offset(1, 1), // changes position of shadow
                    ),
                  ],
                ),
                child: Container(
                  width: _width / 2,
                  height: _height / 2,
                  decoration: BoxDecoration(
                    color: Color(Random().nextInt(0xffffffff)).withAlpha(0xff),
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(15)),
                  ),
                ),
              ),
              Container(
                width: _width,
                height: _height,
                padding: EdgeInsets.all(8),
                child: AvatarImage(
                  book["bimg"] ?? "assets/placeholder.png", // Corrected to use `bimg`
                  isSVG: false,
                  radius: 8,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            book["btitle"] ?? "Unknown Title", // Corrected to use `btitle`
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 4),
          Text(
            book["bprice"] != null
                ? "\$${book["bprice"].toStringAsFixed(2)}"
                : "Price Unavailable", // Corrected to use `bprice`
            style: TextStyle(fontWeight: FontWeight.w500, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
