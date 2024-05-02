import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../service/controller.dart';

class TransactionCard extends StatefulWidget {
  final String stockCode;
  final String userId;
  final double priceBought;
  final double amountStock;
  final double amountDollar;
  final double profitClosed;
  final bool open;
  final String transId;
  final VoidCallback onClose;

  TransactionCard(
      {super.key,
      required this.stockCode,
      required this.userId,
      required this.priceBought,
      required this.amountDollar,
      required this.amountStock,
      required this.open,
      required this.profitClosed,
      required this.transId,
      required this.onClose});

  @override
  State<TransactionCard> createState() => _TransactionCardState();
}

class _TransactionCardState extends State<TransactionCard> {
  final databaseController = DataBase_Controller();
  String currentPrice = "0";
  double profitOpen = 0;

  @override
  void initState() {
    super.initState();
    getPrice(); // Fetch the price when the widget is first created
  }

  void getPrice() async {
    var stockCode1 = widget.stockCode;
    try {
      var resp = await http
          .get(Uri.parse('http://10.0.2.2:5000/stock/$stockCode1/time/1d'));
      var jsonData = jsonDecode(resp.body);
      double price = jsonData[0]['Close'];
      String string = price.toStringAsFixed(2);
      double pripeRound = double.parse(string);
      double profit1 = widget.amountStock * (pripeRound - widget.priceBought);

      setState(() {
        currentPrice = string;
        profitOpen = profit1;
      });
    } catch (e) {
      print(e);
    }
  }

  void closeTrade() async {
    double baalce = await databaseController.getUserBalance(widget.userId);
    await databaseController.updateUserBalance(
        widget.userId, baalce + widget.amountDollar + profitOpen);
    await databaseController.closeTransaction(
        widget.userId, profitOpen, widget.transId); // Make sure this is awaited
    widget.onClose(); // Call this after the above operations are complete
    _showAlertDialogClose(
        "You closed ${widget.amountStock.toStringAsFixed(2)} worth of ${widget.stockCode}\nPorfit: ${profitOpen.toStringAsFixed(2)}\$");
  }

  void _showAlertDialogClose(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Success',
          style:
              TextStyle(color: Color.fromARGB(255, 13, 1, 140), fontSize: 35),
        ), // Adds a title to the AlertDialog
        content: Text(
          message,
          style: TextStyle(fontSize: 17),
        ), // The main message text
        shape: RoundedRectangleBorder(
            side: BorderSide(color: Color.fromARGB(255, 13, 1, 140), width: 3),
            borderRadius: BorderRadius.circular(
                15.0)), // Rounds the corners of the AlertDialog
        backgroundColor: Colors.white, // Sets a custom background color
        elevation: 24.0, // Shadow elevation for 3D effect
        actions: <Widget>[
          // Actions are typically buttons at the bottom of the dialog
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Closes the dialog
            },
            style: TextButton.styleFrom(
              iconColor: Color.fromARGB(255, 13, 1, 140), // Text color
              shape: RoundedRectangleBorder(
                side: BorderSide(
                    color: Color.fromARGB(255, 13, 1, 140),
                    width: 2), // Border color and width
                borderRadius: BorderRadius.circular(16.0), // Border radius
              ),
              padding: EdgeInsets.symmetric(
                  horizontal: 20, vertical: 10), // Button padding
            ),
            child: Text(
              'OK',
              style: TextStyle(color: Color.fromARGB(255, 13, 1, 140)),
            ), // Text for the button
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
      elevation: 5.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      child: Padding(
        padding: EdgeInsets.all(15.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              flex: 3,
              child: Text(
                widget.stockCode,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(width: 10),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Amount',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.normal,
                      color: Colors.grey),
                ),
                SizedBox(
                  width: 50,
                  child: Text(
                    '${widget.amountStock.toStringAsFixed(2)}',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                  ),
                ),
              ],
            ),
            SizedBox(width: 10),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Profit',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.normal,
                      color: Colors.grey),
                ),
                widget.open
                    ? SizedBox(
                        width: 80,
                        child: Text(
                          '${profitOpen.toStringAsFixed(2)}',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: profitOpen == 0.0
                                ? Colors.grey
                                : (profitOpen < 0 ? Colors.red : Colors.blue),
                          ),
                        ),
                      )
                    : SizedBox(
                        width: 80,
                        child: Text(
                          '${widget.profitClosed.toStringAsFixed(2)}',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: widget.profitClosed == 0.0
                                ? Colors.grey
                                : (widget.profitClosed < 0
                                    ? Colors.red
                                    : Colors.blue),
                          ),
                        ),
                      )
              ],
            ),
            widget.open
                ? ElevatedButton(
                    onPressed: closeTrade,
                    child: Text(
                      "CLOSE",
                      style: TextStyle(
                          color: Colors.red, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.red,
                      backgroundColor: Colors.white,
                      side: BorderSide(color: Colors.red, width: 3),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  )
                : SizedBox(
                    width: 100,
                    child: Text(
                      'CLOSED',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
