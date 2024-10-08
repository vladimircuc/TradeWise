import 'package:flutter/material.dart';
import '../components/transactionCard.dart';
import '../models/transaction_model.dart';
import '../service/controller.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  // Variables to store user details, transactions, and financial data
  String userId = "";
  List _prices = [];
  double balance = 0.0;
  double unrealized = 0.0;

  // Initialize the page state, fetch user details, and load financial data
  @override
  void initState() {
    super.initState();
    _initializeUser(); // Set up user ID if logged in
    getTransactions(); // Fetch user's transaction history
    getBalance(); // Get user's balance
    getUnrealizedProfit(); // Calculate unrealized profit
  }

  // Retrieve the current user and assign their UID if logged in
  void _initializeUser() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        userId = user.uid;
      });
    }
  }

  // Function to get the price of a stock by its code
  String getPriceByCode(String stockCode) {
    var priceInfo = _prices.firstWhere(
      (price) => price['code'] == stockCode,
      orElse: () => null,
    );
    return priceInfo != null
        ? priceInfo['price']
        : 'Not Found'; // Return price or 'Not Found'
  }

  // Refresh the transaction list and update balance and unrealized profit
  void onClose() {
    getTransactions();
    setState(() {
      getBalance();
      getUnrealizedProfit();
    });
  }

  // Fetch the user's balance from the database
  void getBalance() async {
    balance = await databaseController.getUserBalance(userId);
    setState(() {}); // Refresh the UI with the updated balance
  }

  // Fetch the user's unrealized profit from the database and format it
  void getUnrealizedProfit() async {
    unrealized = await databaseController.getUnrealisedProfit(userId);
    unrealized = double.parse(
        unrealized.toStringAsFixed(2)); // Format to two decimal places
    setState(() {}); // Refresh the UI with the updated unrealized profit
  }

  final databaseController = DataBase_Controller();
  List<Trans> _transactions = [];

  // Fetch the user's transactions and update the UI
  void getTransactions() async {
    if (userId.isNotEmpty) {
      var updatedTransactions =
          await databaseController.getTransactions(userId);
      setState(() {
        _transactions =
            updatedTransactions; // Refresh the UI with the updated list
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Trades"),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/background.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            // Display user's balance and unrealized profit in cards
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildBalanceCard(),
                _buildUnrealizedProfitCard(),
              ],
            ),
            // Display user's transaction history or a message if there are no transactions
            _transactions.isEmpty
                ? Center(
                    child: Text(
                      'No transactions',
                      style:
                          TextStyle(color: Colors.black, fontFamily: 'serif'),
                    ),
                  )
                : Expanded(
                    child: ListView.builder(
                      itemCount: _transactions.length,
                      itemBuilder: (context, index) {
                        return _buildTransactionCard(index);
                      },
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  // Widget to display the user's balance in a card
  Widget _buildBalanceCard() {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 15.0, vertical: 8.0),
      elevation: 5.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: SizedBox(
          width: 130,
          height: 50,
          child: Column(
            children: [
              Center(child: Text("Balance")),
              Center(
                child: Text(
                  "${balance.toStringAsFixed(2)}",
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget to display the user's unrealized profit in a card
  Widget _buildUnrealizedProfitCard() {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 15.0, vertical: 8.0),
      elevation: 5.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: SizedBox(
          width: 130,
          height: 50,
          child: Column(
            children: [
              Center(child: Text("Unrealized Profit")),
              Center(
                child: Text(
                  "${unrealized.toStringAsFixed(2)}",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: unrealized > 0
                        ? Colors.blue
                        : unrealized < 0
                            ? Colors.red
                            : Colors.grey,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to build each transaction card
  Widget _buildTransactionCard(int index) {
    return Column(
      children: [
        TransactionCard(
          key: ValueKey(_transactions[index].ID),
          onClose: onClose,
          open: _transactions[index].open,
          profitClosed: _transactions[index].profit,
          priceBought: _transactions[index].priceBought,
          stockCode: _transactions[index].code,
          userId: userId,
          amountDollar: _transactions[index].dollarAmount,
          amountStock: _transactions[index].stockAmount,
          transId: _transactions[index].ID,
        ),
      ],
    );
  }
}
