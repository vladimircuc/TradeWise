import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../pages/trading_page.dart';
import '../service/controller.dart';

/// MyFavCard is a StatefulWidget that displays a card for a stock,
/// including actions to view details, trade, and unfavorite.
class MyFavCard extends StatefulWidget {
  final String stockCode;
  final String userId;
  final VoidCallback onUnFav;
  final VoidCallback onOpenChart;
  final GlobalKey<NavigatorState> navigatorKey;

  MyFavCard({
    super.key,
    required this.stockCode,
    required this.userId,
    required this.onUnFav,
    required this.onOpenChart,
    required this.navigatorKey,
  });

  @override
  State<MyFavCard> createState() => _MyFavCardState();
}

class _MyFavCardState extends State<MyFavCard> {
  final databaseController = DataBase_Controller();
  String price = "0";

  @override
  void initState() {
    super.initState();
    getPrice(); // Fetch the stock price on widget initialization
  }

  /// Fetches the stock price from a backend service using the stock code.
  void getPrice() async {
    try {
      var response = await http.get(
          Uri.parse('http://10.0.2.2:5000/stock/${widget.stockCode}/time/1d'));
      var jsonData = jsonDecode(response.body);
      String priceFetched = jsonData[0]['Close'].toStringAsFixed(2);
      setState(() {
        price = priceFetched;
      });
    } catch (e) {
      print("Failed to fetch stock price: $e");
    }
  }

  /// Opens a chart for the current stock.
  void openChart() {
    widget.onOpenChart();
  }

  /// Initiates trading for the current stock.
  void trade() {
    widget.navigatorKey.currentState?.push(MaterialPageRoute(
      builder: (context) => TradingPage(
        stockCode: widget.stockCode,
        userId: widget.userId,
        price: double.parse(price),
      ),
    ));
  }

  /// Removes the stock from the user's favorites and triggers the callback.
  void unFav() async {
    if (widget.userId.isNotEmpty) {
      await databaseController.deleteStock(widget.userId, widget.stockCode);
      widget.onUnFav();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
      elevation: 5.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(widget.stockCode,
                  style: const TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  )),
            ),
            Expanded(
              child: Text('\$$price',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  )),
            ),
            IconButton(
              onPressed: openChart,
              icon: const Icon(Icons.add_chart),
              iconSize: 30,
              color: const Color.fromARGB(255, 9, 158, 148),
            ),
            IconButton(
              onPressed: trade,
              icon: const Icon(Icons.account_balance_wallet),
              iconSize: 30,
              color: const Color.fromARGB(255, 203, 133, 2),
            ),
            IconButton(
              onPressed: unFav,
              icon: const Icon(Icons.heart_broken),
              iconSize: 30,
              color: const Color.fromARGB(255, 222, 18, 18),
            ),
          ],
        ),
      ),
    );
  }
}
