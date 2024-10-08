import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';
import '../models/profit_at_time.dart';
import '../service/controller.dart';
import 'user_portofolio.dart';

class PortfolioPage extends StatefulWidget {
  final String userId;
  final Map<String, double> dataMap;
  final List<ProfitInTime> chartData;
  final bool areThereStocks;
  final GlobalKey<NavigatorState> navigatorKey;

  const PortfolioPage({
    super.key,
    required this.userId,
    required this.dataMap,
    required this.chartData,
    required this.areThereStocks,
    required this.navigatorKey,
  });

  @override
  State<PortfolioPage> createState() => _PortfolioPageState();
}

class _PortfolioPageState extends State<PortfolioPage> {
  final databaseController = DataBase_Controller();
  double aTProfit = 0.0;
  double unrealisedProfit = 0.0;
  String bestStock = "";
  double bestPercentage = 0.0;
  String worstStock = "";
  double worstPercentage = 0.0;
  Map<String, double> adjustedDataMap = {};
  TextEditingController nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    getAllTimeProfit(); // Fetch all-time profit
    getUnrealisedProfit(); // Fetch unrealised profit

    // Fetch stock information if available, else set default values
    if (widget.areThereStocks) {
      getStockInfo();
    } else {
      worstStock = "No Stock";
      bestStock = "No Stock";
    }
    adjustedDataMap =
        adjustDataMap(widget.dataMap); // Adjust data map for pie chart
  }

  // Adjust the data map to combine small values into an "Others" category
  Map<String, double> adjustDataMap(Map<String, double> originalDataMap) {
    final double totalValue =
        originalDataMap.values.fold(0, (sum, e) => sum + e);
    final Map<String, double> adjustedDataMap = {};
    double othersValue = 0.0;

    originalDataMap.forEach((key, value) {
      final double percentage = (value / totalValue) * 100;
      if (percentage < 5) {
        othersValue += value; // Aggregate small values into "Others"
      } else {
        adjustedDataMap[key] = value; // Retain larger values
      }
    });

    if (othersValue > 0) {
      adjustedDataMap['Others'] =
          othersValue; // Add "Others" category if needed
    }

    return adjustedDataMap;
  }

  // Fetch the user's all-time profit from the database
  void getAllTimeProfit() async {
    aTProfit = await databaseController.getAllTimeProfit(widget.userId);
    setState(() {}); // Update the UI with the new profit value
  }

  // Fetch the user's unrealised profit from the database
  void getUnrealisedProfit() async {
    unrealisedProfit =
        await databaseController.getUnrealisedProfit(widget.userId);
    setState(() {}); // Update the UI with the new unrealised profit value
  }

  // Fetch best and worst stock performers from the database
  void getStockInfo() async {
    Map<String, double> stocks =
        await databaseController.getSTocksForPerformers(widget.userId);
    bestStock = stocks.keys.first;
    bestPercentage = stocks[bestStock]!;
    worstStock = stocks.keys.first;
    worstPercentage = stocks[worstStock]!;

    // Determine the best and worst performers
    stocks.forEach((key, value) {
      if (value < worstPercentage) {
        worstStock = key;
        worstPercentage = value;
      }
      if (value > bestPercentage) {
        bestPercentage = value;
        bestStock = key;
      }
    });

    setState(() {}); // Refresh the UI with the updated stock information
  }

  // Display an error dialog with a custom message
  void _showAlertDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Error',
          style: TextStyle(color: Colors.red, fontSize: 35),
        ),
        content: Text(
          message,
          style: const TextStyle(fontSize: 15),
        ),
        shape: RoundedRectangleBorder(
            side: const BorderSide(color: Colors.red, width: 3),
            borderRadius: BorderRadius.circular(15.0)),
        backgroundColor: Colors.white,
        elevation: 24.0,
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
            },
            style: TextButton.styleFrom(
              shape: RoundedRectangleBorder(
                side: const BorderSide(color: Colors.blue, width: 2),
                borderRadius: BorderRadius.circular(16.0),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            child: const Text(
              'OK',
              style: TextStyle(color: Colors.blue),
            ),
          ),
        ],
      ),
    );
  }

  // Search for another user and navigate to their portfolio
  void searchUser() async {
    String searchedUserId =
        await databaseController.getUserIdByName(nameController.text);

    if (searchedUserId.isEmpty) {
      _showAlertDialog("There is no user named ${nameController.text}");
    } else {
      Map<String, double> newDataMap =
          await databaseController.getDataForChart(searchedUserId);
      bool newAreThereStocks = newDataMap.isNotEmpty;

      if (!newAreThereStocks) {
        newDataMap["no stocks :(("] = 0;
      }

      List<ProfitInTime> newChartData =
          await databaseController.getProfits(searchedUserId);

      widget.navigatorKey.currentState?.push(MaterialPageRoute(
          builder: (context) => UserPortfolioPage(
                userId: searchedUserId,
                chartData: newChartData,
                dataMap: newDataMap,
                areThereStocks: newAreThereStocks,
              )));
    }
    nameController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Portfolio"),
          centerTitle: true,
          backgroundColor: Colors.white,
        ),
        body: Container(
          padding: const EdgeInsets.all(10),
          alignment: Alignment.center,
          child: Column(
            children: [
              _buildUserSearchRow(),
              _buildPieChart(),
              _buildProfitCards(),
              _buildStockPerformanceCards(),
              const SizedBox(height: 10),
              _buildProfitLineChart(),
            ],
          ),
        ));
  }

  // Build the user search row
  Widget _buildUserSearchRow() {
    return Expanded(
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Search for another user',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.name),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 1,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
              child: const Text("Search"),
              onPressed: searchUser,
            ),
          ),
        ],
      ),
    );
  }

  // Build the pie chart displaying stock distribution
  Widget _buildPieChart() {
    return Expanded(
      flex: 2,
      child: PieChart(
        dataMap: adjustedDataMap,
        chartValuesOptions: const ChartValuesOptions(
          showChartValueBackground: true,
          showChartValues: true,
          showChartValuesInPercentage: true,
          decimalPlaces: 1,
        ),
      ),
    );
  }

  // Build the profit cards displaying all-time profit and unrealised profit
  Widget _buildProfitCards() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildCard("All time profit", aTProfit),
        _buildCard("Unrealised Profit", unrealisedProfit),
      ],
    );
  }

  // Build individual stock performance cards
  Widget _buildStockPerformanceCards() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildStockCard("Best Performer", bestStock, bestPercentage),
        _buildStockCard("Worst Performer", worstStock, worstPercentage),
      ],
    );
  }

  // Build individual card displaying stock information or profits
  Widget _buildCard(String title, double value) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8.0),
      elevation: 5.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: SizedBox(
          width: 130,
          height: 50,
          child: Column(
            children: [
              Center(child: Text(title)),
              Center(
                child: Text(
                  "${value.toStringAsFixed(2)}\$",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: value > 0
                        ? Colors.blue
                        : value < 0
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

  // Build individual stock performance card (Best and Worst)
  Widget _buildStockCard(String title, String stock, double percentage) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8.0),
      elevation: 5.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: SizedBox(
          width: 130,
          height: 50,
          child: Column(
            children: [
              Center(child: Text(title)),
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      stock,
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      percentage > 0
                          ? " ↑${percentage.toStringAsFixed(2)}%"
                          : percentage < 0
                              ? " ↓${percentage.toStringAsFixed(2)}%"
                              : " ${percentage.toStringAsFixed(2)}%",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: percentage > 0
                            ? Colors.blue
                            : percentage < 0
                                ? Colors.red
                                : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Build a line chart showing profit over time
  Widget _buildProfitLineChart() {
    return Expanded(
      flex: 2,
      child: SfCartesianChart(
        primaryXAxis: DateTimeAxis(dateFormat: DateFormat('MM/dd')),
        primaryYAxis: NumericAxis(title: AxisTitle(text: 'Profit (%)')),
        series: <CartesianSeries>[
          LineSeries<ProfitInTime, DateTime>(
            dataSource: widget.chartData,
            xValueMapper: (ProfitInTime profit, _) => profit.day,
            yValueMapper: (ProfitInTime profit, _) => profit.profit,
          ),
        ],
      ),
    );
  }
}
