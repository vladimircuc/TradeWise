// ignore_for_file: no_leading_underscores_for_local_identifiers

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:software_engineering_project/components/charts/chart.dart';
import 'package:software_engineering_project/components/charts/chart_button_group.dart';

class ChartDisplay extends StatefulWidget {
  final String stockTicker;

  const ChartDisplay({super.key, required this.stockTicker});

  @override
  State<ChartDisplay> createState() => _ChartDisplayState();
}

class _ChartDisplayState extends State<ChartDisplay> {
  String selectedRange = "mo";

  void _handleRangeUpdate(int selectedValue) {
    setState(() {
      selectedRange = ["wk", "mo", "yr"][selectedValue];
    });
  }

  @override
  Widget build(BuildContext context) {
    String _stockTicker = widget.stockTicker;
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: const EdgeInsets.all(20.0), // Adjust margin as needed
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  blurRadius: 5.0,
                  spreadRadius: 2.0,
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.only(
                left: 25.0,
                right: 25.0,
                bottom: 10.0,
              ),
              child: Center(
                child: Column(
                  children: [
                    AppBar(
                      titleSpacing: 0,
                      title: Text(
                        'Stock Prices ($_stockTicker)',
                        style: GoogleFonts.playfairDisplay(
                          color: const Color.fromARGB(255, 59, 59, 61),
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const Divider(
                      height: 2, // Adjust height as needed
                      thickness: 2, // Adjust thickness as needed
                      color: Colors.black,
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      child: Text(
                        "Closing Prices",
                        style: GoogleFonts.playfairDisplay(
                          color: const Color.fromARGB(255, 59, 59, 61),
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Flexible(
                      flex: 1,
                      child: Chart(
                          stockTicker: _stockTicker, timeFrame: selectedRange),
                    ),
                    ChartButtonGroup(onChanged: _handleRangeUpdate),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
