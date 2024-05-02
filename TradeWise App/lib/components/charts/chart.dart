import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:software_engineering_project/service/api_manipulation.dart';

class StockDataPoint {
  int date;
  double closePrice;

  StockDataPoint(this.date, this.closePrice);
}

String intToBusinessDateString(int businessDays) {
  int counter = 0;
  DateTime date = DateTime.now();

  while (counter < businessDays) {
    date = date.subtract(const Duration(days: 1));
    if (date.weekday != DateTime.saturday && date.weekday != DateTime.sunday) {
      counter++;
    }
  }

  // Format the output (using date)
  return "${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}";
}

List<StockDataPoint> assignDates(List<double> closePrices) {
  final List<StockDataPoint> dataPoints = [];
  int businessDays = 0;

  for (int i = 0; i < closePrices.length; i++) {
    businessDays++;

    dataPoints.add(StockDataPoint(businessDays, closePrices[i]));
  }

  return dataPoints; // Reverse the order
}

List<FlSpot> stockDataPointToFLSpot(List<StockDataPoint> stockDataPoints) {
  final List<FlSpot> flSpots = [];
  for (var dataPoint in stockDataPoints) {
    double close = dataPoint.closePrice;
    int date = dataPoint.date;
    flSpots.add(FlSpot(date.toDouble(), close));
  }

  return flSpots;
}

class Chart extends StatefulWidget {
  final String stockTicker;
  final String timeFrame;

  const Chart({super.key, required this.stockTicker, required this.timeFrame});

  @override
  State<Chart> createState() => _ChartState();
}

class _ChartState extends State<Chart> {
  List<FlSpot> _stockPrices = [];
  bool _isLoading = true;
  double minY = 100000.0;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  @override
  void didUpdateWidget(covariant Chart oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Check if the timeFrame has actually changed
    if (oldWidget.timeFrame != widget.timeFrame) {
      _isLoading = true; // Show loading state while fetching
      setState(() {}); // Update the UI to show loading if needed
      _fetchData();
    }
  }

  void _fetchData() async {
    List<FlSpot> stockPrices = [];
    try {
      final apiManipulation = APIManipulation();
      List<dynamic> apiStockPrices = [];

      if (widget.timeFrame == "mo") {
        apiStockPrices =
            await apiManipulation.getOneMonthJson(widget.stockTicker);
      }
      if (widget.timeFrame == "wk") {
        apiStockPrices =
            await apiManipulation.getOneWeekJson(widget.stockTicker);
      }
      if (widget.timeFrame == "yr") {
        apiStockPrices =
            await apiManipulation.getOneYearJson(widget.stockTicker);
      }
      final List<double> closePrices = [];

      List<StockDataPoint> dataPoints = [];

      var maxY = 0.0;
      var maxX = 0.0;

      for (var record in apiStockPrices) {
        double close = record['Close'].toDouble();
        if (close > maxY) {
          maxY = close;
        }
        if (close < minY) {
          minY = close;
        }

        closePrices.add(close);
      }

      dataPoints = assignDates(closePrices);
      stockPrices = stockDataPointToFLSpot(dataPoints);
      for (var stock in stockPrices) {
        if (stock.x > maxX) {
          maxX = stock.x;
        }
      }

      stockPrices.add(FlSpot.nullSpot);
      stockPrices.add(FlSpot(maxX, maxY * 1.02));

      _stockPrices = stockPrices;
    } catch (error) {
      print('Error updating chart: $error');
    } finally {
      setState(
        () {
          _stockPrices = stockPrices;
          _isLoading = false;
        },
      );
    }
  }

  List<LineTooltipItem> getCustomTooltipItems(FlSpot touchedSpot) {
    return [
      LineTooltipItem(
        'Closing: ${touchedSpot.y.toStringAsFixed(2)} Date: ${intToBusinessDateString(touchedSpot.x.toInt())}',
        const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLoading) {
      return Scaffold(
        body: SizedBox(
          height: 800.0,
          child: LineChart(
            LineChartData(
              clipData: const FlClipData.all(),
              lineTouchData: LineTouchData(
                touchCallback:
                    (FlTouchEvent event, LineTouchResponse? touchResponse) {},
                touchTooltipData: LineTouchTooltipData(
                  tooltipBgColor: Colors.blueGrey,
                  getTooltipItems: (spots) =>
                      getCustomTooltipItems(spots.first),
                ),
              ),
              gridData: const FlGridData(
                drawVerticalLine: false,
              ),
              //clipData: FlClipData(
              //top: false, bottom: false, left: true, right: false),
              lineBarsData: [
                LineChartBarData(
                  shadow: const Shadow(blurRadius: 5),
                  preventCurveOverShooting: true,
                  spots: _stockPrices,
                  dotData: const FlDotData(show: false),
                  isCurved: true, // Set to true for a curved line graph

                  //color: Colors.green[900],
                  gradient: const LinearGradient(
                      //begin: Alignment(300, 300),
                      transform: GradientRotation(1.57079633),
                      colors: [
                        Color.fromRGBO(255, 241, 118, 1),
                        Color.fromRGBO(63, 159, 255, 1),
                      ]),
                  barWidth: 3, // Adjust bar width as needed
                  belowBarData: BarAreaData(
                    // Optional for filling below the line
                    show: true,
                    color: Colors.blue[900]?.withOpacity(0.3),
                  ),
                ),
              ],
              borderData: FlBorderData(
                show: true,
              ),
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    //interval: 10.0,
                    getTitlesWidget: (value, titleConfig) => value ==
                            _stockPrices.elementAt(0).x
                        ? const Text('')
                        : Text(
                            value.isNaN
                                ? 'N/A'
                                : intToBusinessDateString(
                                    value.toInt()), // Your original logic */
                            style: const TextStyle(
                                color: Colors.black, fontSize: 12),
                          ),
                  ),
                ),
                leftTitles: const AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: false,
                    reservedSize: 30, // Adjust reserved space for titles
                  ),
                ),
                rightTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 45.0,
                    //interval: 2.0,
                    getTitlesWidget: (value, titleConfig) =>
                        value == _stockPrices.last.y || value == minY
                            ? const Text('')
                            : // Anonymous function
                            Text(
                                // Check for NaN and display "N/A"
                                value.isNaN
                                    ? 'N/A'
                                    : value.toStringAsFixed(
                                        2), // Adjust for data type if needed
                              ),
                  ),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
            ),
          ),
        ),
      );
    } else {
      return Center(
        child: _isLoading
            ? const CircularProgressIndicator(
                color: Color.fromARGB(255, 21, 101, 192),
              )
            : Container(height: 200, width: 200, color: Colors.blue),
      );
    }
  }
}
