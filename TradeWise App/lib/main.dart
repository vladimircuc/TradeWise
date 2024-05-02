import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';
import 'pages/auth/auth_page.dart';
import 'pages/auth/landing_page.dart';
import 'pages/auth/login_page.dart';
import 'pages/auth/register_page.dart';
import 'pages/favorite_page.dart';
import 'pages/history_page.dart';
import 'pages/portfolio.dart';
import 'pages/trading_page.dart';
import 'service/nav_bar.dart';
import 'service/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // await NotificationService.initializeNotification();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _notificationsAllowed = false;

  @override
  void initState() {
    super.initState();
    _checkNotificationPermission();
  }

  Future<void> _checkNotificationPermission() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool notificationsAllowed = prefs.getBool('notifications_allowed') ?? false;
    setState(() {
      _notificationsAllowed = notificationsAllowed;
    });

    // If notifications are not allowed, show permission dialog
    if (_notificationsAllowed) {
      NotificationService.initializeNotification();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/auth',
      routes: {
        '/landing': (context) => const LandingPage(),
        '/register': (context) => const RegisterPage(),
        '/login': (context) => const LoginPage(),
        '/auth': (context) => const AuthPage(),
        '/fav': (context) => const FavoritePage(),
        '/history': (context) => const HistoryPage(),
        '/nav': (context) => const NavBar(),
        '/portfolio': (context) {
          final args = ModalRoute.of(context)!.settings.arguments
              as Map<String, dynamic>;
          return PortfolioPage(
            userId: args['userId'],
            dataMap: args['dataMap'],
            chartData: args['chartData'],
            areThereStocks: args['areThereStocks'],
            navigatorKey: args['navigatorKey'],
          );
        },
        '/trade': (context) {
          final args = ModalRoute.of(context)!.settings.arguments
              as Map<String, dynamic>;
          return TradingPage(
            stockCode: args['stockCode'],
            userId: args['userId'],
            price: args['price'],
          );
        },
      },
    );
  }
}
