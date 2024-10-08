import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../service/controller.dart';

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
  double balance = 0.0; // User's current balance
  TextEditingController balanceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchBalance(); // Fetch user's balance when the page is initialized
  }

  // Fetch the user's balance from the database
  void fetchBalance() async {
    double userBalance = await databaseController.getUserBalance(widget.userId);
    setState(
        () => balance = userBalance); // Update balance state with fetched value
  }

  // Deposit a fixed amount of $5000 to the user's balance
  void depositMoney() async {
    final newBalance = balance + 5000;
    await databaseController.updateUserBalance(widget.userId, newBalance);
    setState(
        () => balance = newBalance); // Update balance state with the new amount
  }

  // Place a trade by deducting the investment amount from the balance and updating the transaction history
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
      setState(() =>
          balance -= dollarAmount); // Update balance after placing the trade
    }
    balanceController.clear(); // Clear the input field after the transaction
  }

  // Show a success dialog after placing a trade
  void _showAlertDialogTrans(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Success',
            style: TextStyle(
                color: Color.fromARGB(255, 13, 1, 140), fontSize: 35)),
        content: Text(message, style: const TextStyle(fontSize: 15)),
        shape: RoundedRectangleBorder(
          side: const BorderSide(
              color: Color.fromARGB(255, 13, 1, 140), width: 3),
          borderRadius: BorderRadius.circular(15.0),
        ),
        backgroundColor: Colors.white,
        elevation: 24.0,
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(), // Close the dialog
            style: TextButton.styleFrom(
              iconColor: const Color.fromARGB(255, 13, 1, 140),
              shape: RoundedRectangleBorder(
                side: const BorderSide(
                    color: Color.fromARGB(255, 13, 1, 140), width: 2),
                borderRadius: BorderRadius.circular(16.0),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            child: const Text('OK',
                style: TextStyle(color: Color.fromARGB(255, 13, 1, 140))),
          ),
        ],
      ),
    );
  }

  // Show an error dialog if there's not enough balance to place a trade
  void _showAlertDialogError(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error',
            style: TextStyle(color: Colors.red, fontSize: 35)),
        content: Text(message, style: const TextStyle(fontSize: 15)),
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: Colors.red, width: 3),
          borderRadius: BorderRadius.circular(15.0),
        ),
        backgroundColor: Colors.white,
        elevation: 24.0,
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(), // Close the dialog
            style: TextButton.styleFrom(
              iconColor: Colors.blue,
              shape: RoundedRectangleBorder(
                side: const BorderSide(color: Colors.blue, width: 2),
                borderRadius: BorderRadius.circular(16.0),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            child: const Text('OK', style: TextStyle(color: Colors.blue)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Trading Page"),
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
        padding: const EdgeInsets.all(16),
        alignment: Alignment.center,
        child: Column(
          children: [
            const SizedBox(height: 20),
            Text(
              "Balance: \$${balance.toStringAsFixed(2)}",
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                foregroundColor: const Color.fromARGB(198, 192, 162, 14),
                backgroundColor: Colors.white,
                side: const BorderSide(
                    color: Color.fromARGB(198, 192, 162, 14), width: 3),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text(
                "Deposit 5k dollars",
                style: TextStyle(
                    color: Color.fromARGB(198, 192, 162, 14),
                    fontWeight: FontWeight.bold),
              ),
              onPressed: depositMoney,
            ),
            const SizedBox(height: 20),
            Text(
              "Current price of ${widget.stockCode} is \$${widget.price}",
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
            ),
            const SizedBox(height: 20),
            _buildInvestmentTextField(),
            const SizedBox(height: 20),
            _buildPlaceTradeButton(),
          ],
        ),
      ),
    );
  }

  // Build the text field for entering the amount to invest
  Widget _buildInvestmentTextField() {
    return TextField(
      controller: balanceController,
      decoration: const InputDecoration(
        labelText: 'Amount to Invest',
        labelStyle: TextStyle(color: Colors.black),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.black, width: 2),
        ),
        suffixIcon: Icon(Icons.attach_money, color: Colors.black),
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}'))
      ],
    );
  }

  // Build the button to place a trade
  Widget _buildPlaceTradeButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        foregroundColor: const Color.fromARGB(198, 192, 162, 14),
        backgroundColor: Colors.white,
        side: const BorderSide(
            color: Color.fromARGB(198, 192, 162, 14), width: 3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: const Text(
        "Place Trade",
        style: TextStyle(
            color: Color.fromARGB(198, 192, 162, 14),
            fontWeight: FontWeight.bold),
      ),
      onPressed: placeTrade,
    );
  }
}
