import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../service/controller.dart'; // Confirm this import path is correct

class TradingPage extends StatefulWidget {
  final String stockCode;
  final String userId;
  final double price;

  const TradingPage({
    Key? key,
    required this.stockCode,
    required this.userId,
    required this.price,
  }) : super(key: key);

  @override
  State<TradingPage> createState() => _TradingPageState();
}

class _TradingPageState extends State<TradingPage> {
  final DataBase_Controller databaseController = DataBase_Controller();
  double balance = 0.0; // Initial balance
  TextEditingController balanceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchBalance();
  }

  void fetchBalance() async {
    double userBalance = await databaseController.getUserBalance(widget.userId);
    setState(() => balance = userBalance);
  }

  void depositMoney() async {
    final newBalance = balance + 5000;
    await databaseController.updateUserBalance(widget.userId, newBalance);
    setState(() => balance = newBalance);
  }

  void placeTrade() async {
    final dollarAmount = double.parse(balanceController.text);
    final amountOfStock = dollarAmount / widget.price;

    if (dollarAmount > balance) {
      _showAlertDialogError("Not enough balance");
    } else {
      await databaseController.addTrans(widget.userId, widget.stockCode,
          widget.price, dollarAmount, amountOfStock);
      _showAlertDialogTrans(
          "You bought ${amountOfStock.toStringAsFixed(2)} worth of ${widget.stockCode}");
      await databaseController.updateUserBalance(
          widget.userId, balance - dollarAmount);
      setState(() => balance -= dollarAmount);
    }
    balanceController.clear();
  }

  void _showAlertDialogTrans(String message) {
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
          style: TextStyle(fontSize: 15),
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

  void _showAlertDialogError(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Error',
          style: TextStyle(color: Colors.red, fontSize: 35),
        ), // Adds a title to the AlertDialog
        content: Text(
          message,
          style: TextStyle(fontSize: 15),
        ), // The main message text
        shape: RoundedRectangleBorder(
            side: BorderSide(color: Colors.red, width: 3),
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
              iconColor: Colors.blue, // Text color
              shape: RoundedRectangleBorder(
                side: BorderSide(
                    color: Colors.blue, width: 2), // Border color and width
                borderRadius: BorderRadius.circular(16.0), // Border radius
              ),
              padding: EdgeInsets.symmetric(
                  horizontal: 20, vertical: 10), // Button padding
            ),
            child: Text(
              'OK',
              style: TextStyle(color: Colors.blue),
            ), // Text for the button
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Trading Page"),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/background.png'),
            fit: BoxFit.cover,
          ),
        ),
        padding: EdgeInsets.all(16),
        alignment: Alignment.center,
        child: Column(
          children: [
            SizedBox(height: 20),
            Text(
              "Balance: \$${balance.toStringAsFixed(2)}",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                foregroundColor: Color.fromARGB(198, 192, 162, 14),
                backgroundColor: Colors.white,
                side: BorderSide(
                    color: Color.fromARGB(198, 192, 162, 14), width: 3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                "Deposit 5k dollars",
                style: TextStyle(
                    color: const Color.fromARGB(198, 192, 162, 14),
                    fontWeight: FontWeight.bold),
              ),
              onPressed: depositMoney,
            ),
            SizedBox(height: 20),
            Text(
              "Current price of ${widget.stockCode} is \$${widget.price}",
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
            ),
            SizedBox(height: 20),
            TextField(
              controller: balanceController,
              decoration: InputDecoration(
                labelText: 'Amount to Invest',
                labelStyle: TextStyle(color: Colors.black),
                enabledBorder: const OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.black, width: 2),
                ),
                suffixIcon: Icon(
                  Icons.attach_money,
                  color: Colors.black,
                ),
              ),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}'))
              ],
            ),
            SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                foregroundColor: Color.fromARGB(198, 192, 162, 14),
                backgroundColor: Colors.white,
                side: BorderSide(
                    color: Color.fromARGB(198, 192, 162, 14), width: 3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                "Place Trade",
                style: TextStyle(
                    color: const Color.fromARGB(198, 192, 162, 14),
                    fontWeight: FontWeight.bold),
              ),
              onPressed: placeTrade,
            ),
          ],
        ),
      ),
    );
  }
}
