import 'package:flutter/material.dart';
import '../pages/favorite_page.dart';
import '../pages/history_page.dart';
import '../pages/learn_page.dart';
import '../pages/news_page.dart';
import '../pages/settings_page.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class NavBar extends StatefulWidget {
  const NavBar({super.key});

  @override
  NavBarState createState() => NavBarState();
}

class NavBarState extends State<NavBar> {
  int _selectedIndex = 0;

  List<Widget> _buildScreens() {
    return [
      FavoritePage(),
      HistoryPage(),
      NewsPage(),
      LearnPage(),
      SettingsPage()
    ];
  }

  void _onItemTapped(int index) {
    if (_selectedIndex == index) {
      // If the same tab is tapped and we're not on the first route, pop to the first route
      navigatorKey.currentState?.popUntil((route) => route.isFirst);
    } else {
      setState(() {
        _selectedIndex = index;
      });
      // If we're navigating from a different tab (e.g., from TradingPage), ensure we're popping back to the root.
      if (navigatorKey.currentState?.canPop() ?? false) {
        navigatorKey.currentState?.popUntil((route) => route.isFirst);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Navigator(
        key: navigatorKey,
        onGenerateRoute: (settings) {
          return MaterialPageRoute(
              builder: (_) => _buildScreens()[_selectedIndex]);
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
              icon: Icon(
                Icons.favorite,
                color: Colors.black,
              ),
              label: 'Favorites'),
          BottomNavigationBarItem(
              icon: Icon(
                Icons.history,
                color: Colors.black,
              ),
              label: 'Trades'),
          BottomNavigationBarItem(
              icon: Icon(
                Icons.newspaper,
                color: Colors.black,
              ),
              label: 'News'),
          BottomNavigationBarItem(
              icon: Icon(
                Icons.school,
                color: Colors.black,
              ),
              label: 'Learn'),
          BottomNavigationBarItem(
              icon: Icon(
                Icons.settings,
                color: Colors.black,
              ),
              label: 'Settings'),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.black, // Color of the text/icon when selected
        unselectedItemColor:
            Colors.black, // Color of the text/icon when not selected
        selectedLabelStyle:
            TextStyle(color: Colors.black), // Explicitly set text color
        unselectedLabelStyle:
            TextStyle(color: Colors.black), // Explicitly set text color
        backgroundColor:
            Colors.black, // Background color of the bottom navigation bar
      ),
    );
  }
}
