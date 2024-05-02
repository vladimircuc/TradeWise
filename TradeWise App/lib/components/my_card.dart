import 'package:flutter/material.dart';
import '../service/controller.dart';

/// MyCard is a StatefulWidget that displays stock information and allows the user to add the stock to favorites.
class MyCard extends StatefulWidget {
  final VoidCallback
      addToFavourites; // Callback function when a stock is added to favorites
  final bool isFav; // State to track if the stock is already a favorite
  final String userID; // ID of the user for whom the stock might be favorited
  final String stockName; // Display name of the stock
  final String stockCode; // Code of the stock

  const MyCard({
    super.key,
    required this.addToFavourites,
    required this.isFav,
    required this.userID,
    required this.stockName,
    required this.stockCode,
  });

  @override
  State<MyCard> createState() => _MyCardState();
}

class _MyCardState extends State<MyCard> {
  final db = DataBase_Controller(); // Controller for database operations

  /// Adds the stock to the user's favorites list and updates UI state.
  void addToFavourites(String stockName, String stockCode) async {
    if (widget.userID.isNotEmpty) {
      await db.addAStock(
          widget.userID, stockName, stockCode); // Adds stock to the database
      widget
          .addToFavourites(); // Calls the callback after adding to update UI or perform other actions
    }
    setState(() {
      // Optionally update local state or trigger UI refresh if needed
      if (!widget.isFav) {
        widget.addToFavourites();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 5),
      elevation: 5.0, // Defines shadow cast by the card
      shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(8.0)), // Rounded corners for the card
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Row(
          textDirection: TextDirection.ltr,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(widget.stockName,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                )),
            Text(widget.stockCode),
            IconButton(
              onPressed: () =>
                  addToFavourites(widget.stockName, widget.stockCode),
              icon: widget.isFav
                  ? const Icon(Icons
                      .favorite) // Shows filled heart if stock is a favorite
                  : const Icon(Icons
                      .favorite_border_outlined), // Shows outlined heart if not a favorite
              color: const Color.fromARGB(255, 225, 177, 35),
            )
          ],
        ),
      ),
    );
  }
}
