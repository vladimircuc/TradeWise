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
  final List<String> _headlines = [];
  final List<Uri> _links = [];
  final List<String> _thumbnails = [];
  final List<String> _publishers = [];
  List _stocks = [];
  @override
  void initState() {
    super.initState;
    readJson();
  }

  bool add = false;
  String url = '';
  Future<void> readJson() async {
    final String response =
        await rootBundle.loadString('assets/data/stocks.json');

    final data = await json.decode(response);

    setState(() {
      _stocks = data["stocks"];

      // Used for testing purposes only -- functionality testing
      // print(_stocks);
    });
    fetchAlbum();
  }

  Future<void> fetchAlbum() async {
    for (int i = 0; i < _stocks.length; i++) {
      var stock = _stocks[i]['code'];
      try {
        var resp =
            await http.get(Uri.parse('http://10.0.2.2:5000/stock/$stock/news'));
        // var resp = await http.get(Uri.parse('https://www.thunderclient.com/welcome'));
        var jsonData = jsonDecode(resp.body);

        //TESTING PURPOSES
        // print("${jsonData[0]['title']}");
        //print(jsonData.length);

        for (int i = 0; i < 2; i++) {
          add = false;
          String title = jsonData[i]['title'].toString();
          Uri link = Uri.parse(jsonData[i]['link']);
          String publisher = jsonData[i]['publisher'].toString();
          if (jsonData[i].length > 7) {
            if (!_headlines.contains(title)) {
              //print(title);
              var photo = jsonData[i]['thumbnail'];

              var photo2 = photo['resolutions'][0]['url'];

              url = photo2.toString();

              //TESTING PURPOSES
              //print(photo2);
              add = true;
            }
          }

          setState(() {
            if (add) {
              _headlines.add(title);
              _links.add(link);
              _thumbnails.add(url);
              _publishers.add(publisher);
            }
          });
        }

        //TESTING PURPOSES
        // print("news");
        // for (int i = 0; i < _headlines.length; i++) {
        //   print(_headlines[i]);
        //   print(_thumbnails[i]);
        // }
      } catch (e) {
        print(e);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Stack(
            children: <Widget>[
              Align(
                alignment: Alignment.center,
                child: Text("Breaking News",
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    )),
              ),
            ],
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
                          }))
            ],
          ),
        ));
  }
}
