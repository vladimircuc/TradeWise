import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../components/news_card.dart';

class NewsPage extends StatefulWidget {
  const NewsPage({super.key});

  @override
  State<NewsPage> createState() => _NewsPageState();
}

class _NewsPageState extends State<NewsPage> {
  // Lists to store news data
  final List<String> _headlines = [];
  final List<Uri> _links = [];
  final List<String> _thumbnails = [];
  final List<String> _publishers = [];
  List _stocks = [];
  bool add = false;
  String url = '';

  @override
  void initState() {
    super.initState();
    readJson(); // Load stock data and fetch news on initialization
  }

  // Load stock data from JSON and trigger news fetch
  Future<void> readJson() async {
    final String response =
        await rootBundle.loadString('assets/data/stocks.json');
    final data = await json.decode(response);

    setState(() {
      _stocks = data["stocks"]; // Populate stock list
    });

    fetchNewsForStocks(); // Fetch news for each stock
  }

  // Fetch news for each stock from the server and update the state
  Future<void> fetchNewsForStocks() async {
    for (int i = 0; i < _stocks.length; i++) {
      var stockCode = _stocks[i]['code'];
      try {
        // Fetch news data for the current stock
        var response = await http
            .get(Uri.parse('http://10.0.2.2:5000/stock/$stockCode/news'));
        var jsonData = jsonDecode(response.body);

        // Parse the news data and add to the list if valid
        for (int i = 0; i < 2; i++) {
          _parseNewsItem(jsonData[i]);
        }
      } catch (e) {
        print(
            'Error fetching news for stock $stockCode: $e'); // Handle fetch error
      }
    }
  }

  // Helper method to parse individual news items and add them to the list
  void _parseNewsItem(Map<String, dynamic> newsItem) {
    add = false; // Reset the add flag for each news item
    String title = newsItem['title'].toString();
    Uri link = Uri.parse(newsItem['link']);
    String publisher = newsItem['publisher'].toString();

    if (newsItem.length > 7 && !_headlines.contains(title)) {
      var photo = newsItem['thumbnail'];
      url = photo['resolutions'][0]['url'].toString();
      add = true; // Mark item for addition if it meets criteria
    }

    if (add) {
      setState(() {
        _headlines.add(title);
        _links.add(link);
        _thumbnails.add(url);
        _publishers.add(publisher);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Text(
            "Breaking News",
            style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/background.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            // Display a loading message or the list of news items
            _headlines.isEmpty
                ? const Center(child: Text('Loading...'))
                : Expanded(
                    child: ListView.builder(
                      itemCount: _headlines.length,
                      itemBuilder: (context, index) {
                        return NewsCard(
                          headline: _headlines[index],
                          publisher: _publishers[index],
                          thumbnail: _thumbnails[index],
                          url: _links[index],
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
