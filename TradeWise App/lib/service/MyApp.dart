import 'package:flutter/material.dart';

import '../pages/favorite_page.dart';
import '../pages/history_page.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "text",
      theme: ThemeData(
        primaryColor: Colors.cyan,
      ),
      home: FavoritePage(),
      routes: {
        'history_page': (context) => const HistoryPage(),
      },
    );
  }
}
