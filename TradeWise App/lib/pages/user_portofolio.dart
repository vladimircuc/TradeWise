import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';
import '../models/profit_at_time.dart';
import '../service/controller.dart';

class UserPortfolioPage extends StatefulWidget {
  final String userId;
  final Map<String, double> dataMap;
  final List<ProfitInTime> chartData;
  final bool areThereStocks;

  const UserPortfolioPage(
      {super.key,
      required this.userId,
      required this.dataMap,
      required this.chartData,
      required this.areThereStocks});

  @override
  State<UserPortfolioPage> createState() => _UserPortfolioPageState();
}

class _UserPortfolioPageState extends State<UserPortfolioPage> {
  final databaseController = DataBase_Controller();
  double aTProfit = 0.0;
  double unrealisedProfit = 0.0;
  String bestStock = "";
  double bestPercentage = 0.0;
  String worstStock = "";
  double worstPercentage = 0.0;
  Map<String, double> adjustedDataMap = {};
  TextEditingController balanceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    getAllTimeProfit();
    getUnrealisedProfit();

    if (widget.areThereStocks) {
      getStockInfo();
    } else {
      worstStock = "No Stock";
      bestStock = "No Stock";
    }
    adjustedDataMap = adjustDataMap(widget.dataMap);
  }

  Map<String, double> adjustDataMap(Map<String, double> originalDataMap) {
    final double totalValue =
        originalDataMap.values.fold(0, (sum, e) => sum + e);
    final Map<String, double> adjustedDataMap = {};
    double othersValue = 0.0;

    originalDataMap.forEach((key, value) {
      final double percentage = (value / totalValue) * 100;
      if (percentage < 5) {
        // Aggregate into "Others"
        othersValue += value;
      } else {
        // Keep as is
        adjustedDataMap[key] = value;
      }
    });

    if (othersValue > 0) {
      // Add the "Others" category if necessary
      adjustedDataMap['Others'] = othersValue;
    }

    return adjustedDataMap;
  }

  void getAllTimeProfit() async {
    aTProfit = await databaseController.getAllTimeProfit(widget.userId);
    setState(() {});
  }

  void getUnrealisedProfit() async {
    unrealisedProfit =
        await databaseController.getUnrealisedProfit(widget.userId);
    setState(() {});
  }

  void getStockInfo() async {
    Map<String, double> stocks =
        await databaseController.getSTocksForPerformers(widget.userId);

    bestStock = stocks.keys.first;
    bestPercentage = stocks[bestStock]!;
    worstStock = stocks.keys.first;
    worstPercentage = stocks[worstStock]!;

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

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Portfolio"),
          centerTitle: true,
          backgroundColor: Colors.white,
        ),
        body: Container(
          padding: EdgeInsets.all(10),
          alignment: Alignment.center,
          child: Column(
            children: [
              Expanded(
                // Makes the chart flexible
                flex: 2, // Adjust the flex factor as needed to allocate space
                child: PieChart(
                  dataMap: adjustedDataMap,
                  chartValuesOptions: ChartValuesOptions(
                    showChartValueBackground: true,
                    showChartValues: true,
                    showChartValuesInPercentage: true,
                    showChartValuesOutside: false,
                    decimalPlaces: 1,
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Card(
                    margin:
                        EdgeInsets.symmetric(horizontal: 15.0, vertical: 8.0),
                    elevation: 5.0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0)),
                    child: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: SizedBox(
                          width: 130, // Set your desired width
                          height: 50,
                          child: Column(
                            children: [
                              Center(child: Text("All time profit")),
                              Center(
                                child: Text(
                                  "${aTProfit.toStringAsFixed(2)}\$",
                                  style: TextStyle(
                                      fontSize: 20, // Size of the text
                                      fontWeight:
                                          FontWeight.bold, // Make text bold
                                      color: aTProfit > 0
                                          ? Colors.blue
                                          : aTProfit < 0
                                              ? Colors.red
                                              : Colors.grey),
                                ),
                              )
                            ],
                          )),
                    ),
                  ),
                  Card(
                    margin:
                        EdgeInsets.symmetric(horizontal: 15.0, vertical: 8.0),
                    elevation: 5.0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0)),
                    child: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: SizedBox(
                          width: 130, // Set your desired width
                          height: 50,
                          child: Center(
                              child: Column(
                            children: [
                              Text("Unrealised Profit"),
                              Center(
                                child: Text(
                                  "${unrealisedProfit.toStringAsFixed(2)}\$",
                                  style: TextStyle(
                                      fontSize: 20, // Size of the text
                                      fontWeight:
                                          FontWeight.bold, // Make text bold
                                      color: unrealisedProfit > 0
                                          ? Colors.blue
                                          : unrealisedProfit < 0
                                              ? Colors.red
                                              : Colors.grey),
                                ),
                              )
                            ],
                          ))),
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Card(
                    margin:
                        EdgeInsets.symmetric(horizontal: 15.0, vertical: 8.0),
                    elevation: 5.0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0)),
                    child: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: SizedBox(
                          width: 130, // Set your desired width
                          height: 50,
                          child: Center(
                              child: Column(
                            children: [
                              Text("Best Performer"),
                              Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Center(
                                      child: Text(
                                        bestStock,
                                        style: TextStyle(
                                          fontSize: 20, // Size of the text
                                          fontWeight:
                                              FontWeight.bold, // Make text bold
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                    Center(
                                        child: widget.areThereStocks
                                            ? Text(
                                                bestPercentage > 0
                                                    ? " ↑${bestPercentage.toStringAsFixed(2)}%"
                                                    : bestPercentage < 0
                                                        ? " ↓${bestPercentage.toStringAsFixed(2)}%"
                                                        : " ${bestPercentage.toStringAsFixed(2)}%",
                                                style: TextStyle(
                                                    fontSize:
                                                        15, // Size of the text
                                                    fontWeight: FontWeight
                                                        .bold, // Make text bold
                                                    color: bestPercentage > 0
                                                        ? Colors.blue
                                                        : bestPercentage < 0
                                                            ? Colors.red
                                                            : Colors.grey))
                                            : const Text("")),
                                  ],
                                ),
                              )
                            ],
                          ))),
                    ),
                  ),
                  Card(
                    margin:
                        EdgeInsets.symmetric(horizontal: 15.0, vertical: 8.0),
                    elevation: 5.0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0)),
                    child: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: SizedBox(
                          width: 130, // Set your desired width
                          height: 50,
                          child: Center(
                              child: Column(
                            children: [
                              Text("Worst Performer"),
                              Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      worstStock,
                                      style: TextStyle(
                                        fontSize: 20, // Size of the text
                                        fontWeight:
                                            FontWeight.bold, // Make text bold
                                        color: Colors.black,
                                      ),
                                    ),
                                    Center(
                                      child: widget.areThereStocks
                                          ? Text(
                                              worstPercentage > 0
                                                  ? " ↑${worstPercentage.toStringAsFixed(2)}%"
                                                  : worstPercentage < 0
                                                      ? " ↓${worstPercentage.toStringAsFixed(2)}%"
                                                      : " ${worstPercentage.toStringAsFixed(2)}%",
                                              style: TextStyle(
                                                  fontSize:
                                                      15, // Size of the text
                                                  fontWeight: FontWeight
                                                      .bold, // Make text bold
                                                  color: worstPercentage > 0
                                                      ? Colors.blue
                                                      : worstPercentage < 0
                                                          ? Colors.red
                                                          : Colors.grey))
                                          : const Text(""),
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ))),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 10,
              ),
              Expanded(
                  flex: 2,
                  child: Container(
                      child: SfCartesianChart(
                          // Chart Title
                          primaryXAxis: DateTimeAxis(
                            dateFormat: DateFormat(
                                'MM/dd'), // Format the date as you want
                            // X Axis Title
                          ),
                          primaryYAxis: NumericAxis(
                            //numberFormat: NumberFormat
                            //.percentPattern(), // Format the number with a percentage sign
                            title:
                                AxisTitle(text: 'Profit (%)'), // Y Axis Title
                          ),
                          series: <CartesianSeries>[
                        // Renders line chart
                        LineSeries<ProfitInTime, DateTime>(
                          dataSource: widget.chartData,
                          xValueMapper: (ProfitInTime profit, _) => profit.day,
                          yValueMapper: (ProfitInTime profit, _) =>
                              profit.profit,
                          //dataLabelSettings: DataLabelSettings(
                          //isVisible: true), // Show data labels
                          //name:
                          //'Profit' // Name of the series, shows in legend
                        )
                      ])))
            ],
          ),
        ));
  }
}
