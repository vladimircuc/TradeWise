import 'dart:convert';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fuzzy/fuzzy.dart';

import '../components/charts/chart_display.dart';
import '../components/fav_cards.dart';
import '../components/my_card.dart';
import '../models/stock_model.dart';
import '../service/controller.dart';
import '../service/nav_bar.dart';
import '../service/notification_service.dart';

class FavoritePage extends StatefulWidget {
  const FavoritePage({super.key});

  @override
  State<FavoritePage> createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {
  // Variables to manage user data, stocks, and notifications
  String userId = "";
  List _prices = [];
  List<Stock> _stocks = [];
  bool _notificationsAllowed = false;

  // Variables for browsing functionality
  List _browsingStocks = [];
  final List<String> _matches = [];
  final List<String> _matchedCodes = [];
  final TextEditingController _queryController = TextEditingController();
  bool _isBrowsing = false;
  final List<bool> _favs = [];

  @override
  void initState() {
    super.initState();
    readJson(); // Load stock prices from JSON
    _initializeUser(); // Fetch current user and set up user ID
    _checkNotificationPermission(); // Check notification settings on first load
  }

  // Initialize user details and fetch user-specific data
  void _initializeUser() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        userId = user.uid;
      });
      getUsers(); // Fetch the user's saved stocks if logged in
    }
  }

  // Check for notification permission and request if necessary
  Future<void> _checkNotificationPermission() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool notificationsAllowed = prefs.getBool('notifications_allowed') ?? false;
    setState(() {
      _notificationsAllowed = notificationsAllowed;
    });

    if (!_notificationsAllowed) {
      _showNotificationPermissionDialog(); // Show permission dialog if not allowed
    } else {
      NotificationService
          .initializeNotification(); // Initialize notifications if allowed
    }
  }

  // Toggle notification permission and update the preference
  Future<void> _toggleNotificationPermission(bool allow) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_allowed', allow);
    setState(() {
      _notificationsAllowed = allow;
    });
  }

  // Display a dialog to request notification permission from the user
  void _showNotificationPermissionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Allow Notifications"),
          content: const Text("Our app would like to send you notifications"),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                _toggleNotificationPermission(false);
                Navigator.pop(context);
              },
              child: const Text('Don\'t Allow',
                  style: TextStyle(color: Colors.grey, fontSize: 18)),
            ),
            TextButton(
              onPressed: () {
                _toggleNotificationPermission(true);
                AwesomeNotifications()
                    .requestPermissionToSendNotifications()
                    .then((_) {
                  Navigator.pop(context);
                  NotificationService.initializeNotification();
                  _createAutomaticSchedule(); // Create notification schedule if allowed
                });
              },
              child: const Text('Allow',
                  style: TextStyle(
                      color: Colors.teal,
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  // Schedule automatic notifications based on the time of day
  Future<void> _createAutomaticSchedule() async {
    final time = DateTime.now();
    String title;
    String body;

    if (time.hour < 10) {
      title =
          "${Emojis.money_money_bag + Emojis.time_ten_o_clock} Time to Trade!";
      body = "The stock market is about to open! Hop on to trading.";
    } else {
      title = "${Emojis.smile_money_mouth_face} Time to check on your stocks!";
      body =
          "The stock market is about to close! Come check out your profits of the day";
    }

    await NotificationService.showNotification(
      title: title,
      body: body,
      category: NotificationCategory.Recommendation,
      scheduled: true,
      interval: _getInterval(),
    );
  }

  // Helper function to calculate the interval for scheduling notifications
  int _getInterval() {
    final time = DateTime.now();
    DateTime nextTime = time.hour < 9
        ? _getNextWeekdayTime(time, 9, 50)
        : _getNextWeekdayTime(time, 16, 20); // Using 16:20 for 4:20 PM
    return nextTime.difference(time).inSeconds;
  }

  // Function to find the next weekday at a specific time
  DateTime _getNextWeekdayTime(DateTime now, int hour, int minute) {
    DateTime nextTime = DateTime(now.year, now.month, now.day, hour, minute);
    while (nextTime.weekday == 6 || nextTime.weekday == 7) {
      // Skip weekends
      nextTime = nextTime.add(const Duration(days: 1));
    }
    return nextTime;
  }

  // Add a stock to the favorites list if it doesn't already exist
  void addToFavourites(String stockName, String stockCode) {
    setState(() {
      if (!_stocks.any((stock) => stock.code == stockCode)) {
        // Avoid duplicates
        _stocks.add(Stock(name: stockName, code: stockCode));
        _isBrowsing = false;
        _queryController.clear();
      }
    });
  }

  // Load stocks from JSON file to populate browsing options
  Future<void> loadStocks() async {
    final String response =
        await rootBundle.loadString('assets/data/stocks.json');
    final data = await json.decode(response);

    setState(() {
      _browsingStocks = data["stocks"];
      for (var stock in _browsingStocks) {
        stock['isFav'] = _stocks.any(
            (favStock) => favStock.code == stock['code']); // Mark favorites
      }
    });
  }

  // Handle changes to the search query and trigger a fuzzy search
  void onQueryChanged(String newQuery) {
    loadStocks();
    List<String> stockNames = [];
    setState(() {
      for (var stock in _browsingStocks) {
        stockNames.add(stock['name']);
        _matches.add(stock['name']);
      }
      _isBrowsing = true;
      fuzzySearch(stockNames, newQuery);
    });
  }

  // Perform a fuzzy search on the list of stocks
  void fuzzySearch(List stocks, String query) {
    if (query.isEmpty) {
      _isBrowsing = false;
      _matches.clear();
      _matchedCodes.clear();
      _favs.clear();
      return;
    }

    double threshold = query.length == 1
        ? .99
        : query.length < 4
            ? .2
            : 0.01;
    final fuzzy = Fuzzy(stocks,
        options: FuzzyOptions(
            isCaseSensitive: false,
            findAllMatches: true,
            threshold: threshold));
    final result = fuzzy.search(query);

    _matches.clear();
    _matchedCodes.clear();
    _favs.clear();

    for (var item in result) {
      if (item.score <= threshold) {
        _matches.add(item.item);
        for (var stock in _browsingStocks) {
          if (_matches.contains(stock['name']) &&
              !_matchedCodes.contains(stock['code'])) {
            _matchedCodes.add(stock['code']);
            _favs.add(stock['isFav']);
          }
        }
      }
    }
  }

  // Read JSON data to initialize stock prices
  Future<void> readJson() async {
    final String response =
        await rootBundle.loadString('assets/data/prices.json');
    final data = await json.decode(response);
    setState(() {
      _prices = data["prices"];
    });
  }

  // Fetch price information for a given stock code
  String getPriceByCode(String stockCode) {
    var priceInfo = _prices.firstWhere((price) => price['code'] == stockCode,
        orElse: () => null);
    return priceInfo != null ? priceInfo['price'] : 'Not Found';
  }

  // Sign the user out and navigate to the landing page
  void signUserOut(BuildContext context) {
    FirebaseAuth.instance.signOut();
    Navigator.pushReplacementNamed(context, '/landing');
  }

  // Fetch the user's favorite stocks from the database
  final databaseController = DataBase_Controller();
  void getUsers() async {
    if (userId.isNotEmpty) {
      _stocks = await databaseController.getUserStocksByCustomId(userId);
      setState(() {}); // Refresh the UI with updated stock data
    }
  }

  // Remove a stock from the favorites list
  void onUnFav(String stockCode) {
    setState(() {
      _stocks.removeWhere((stock) => stock.code == stockCode);
    });
  }

  // Display stock details in a modal sheet
  void onOpenStock(String stockCode) async {
    await showMaterialModalBottomSheet(
      context: context,
      expand: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ChartDisplay(stockTicker: stockCode),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/background.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            SizedBox(height: 50),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: TextField(
                controller: _queryController,
                onChanged: onQueryChanged,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color.fromARGB(255, 255, 255, 255),
                  hintText: 'Browse stocks...',
                  hintStyle: const TextStyle(
                      color: Color.fromARGB(255, 0, 0, 0),
                      fontWeight: FontWeight.w400),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: const BorderSide(
                        color: Color.fromARGB(255, 225, 177, 35), width: 2),
                  ),
                  suffixIcon: const Icon(Icons.search,
                      color: Color.fromARGB(255, 225, 177, 35)),
                ),
              ),
            ),
            _isBrowsing == false
                ? _stocks.isEmpty
                    ? const Center(
                        child: Text(
                          'No saved quotes. Add some in the Browsing Page',
                          style: TextStyle(
                              color: Colors.black, fontFamily: 'serif'),
                        ),
                      )
                    : Expanded(
                        child: ListView.builder(
                          itemCount: _stocks.length,
                          itemBuilder: (context, index) {
                            return MyFavCard(
                              stockCode: _stocks[index].code,
                              userId: userId,
                              onUnFav: () => setState(() {
                                onUnFav(_stocks[index].code);
                              }),
                              onOpenChart: () => setState(() {
                                onOpenStock(_stocks[index].code);
                              }),
                              navigatorKey: navigatorKey,
                            );
                          },
                        ),
                      )
                : Expanded(
                    child: ListView.builder(
                      itemCount: _matches.length,
                      itemBuilder: (context, index) {
                        return MyCard(
                          addToFavourites: () => setState(() {
                            addToFavourites(
                                _matches[index], _matchedCodes[index]);
                          }),
                          isFav: _favs[index],
                          userID: userId,
                          stockName: _matches[index],
                          stockCode: _matchedCodes[index],
                        );
                      },
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
