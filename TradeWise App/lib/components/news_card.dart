import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// NewsCard displays a headline, publisher, and thumbnail from a news article.
/// It supports tapping to launch the article URL in a web browser.
class NewsCard extends StatefulWidget {
  final String headline; // The headline of the news article
  final String publisher; // The publisher of the news article
  final String thumbnail; // URL to a thumbnail image for the news article
  final Uri url; // URL to the full news article

  const NewsCard({
    super.key,
    required this.headline,
    required this.publisher,
    required this.thumbnail,
    required this.url,
  });

  @override
  State<NewsCard> createState() => _NewsCardState();
}

class _NewsCardState extends State<NewsCard> {
  /// Attempts to launch the provided URL.
  /// If the URL cannot be launched, throws an exception.
  Future<void> _launchUrl(Uri url) async {
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onDoubleTap: () {
        _launchUrl(widget.url); // Launch the URL when the card is double tapped
      },
      child: Column(
        children: [
          Container(
            height: 90,
            margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 4),
            padding: const EdgeInsets.only(left: 6, right: 6),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8.0),
                border: Border.all(
                  color: const Color.fromARGB(255, 225, 177, 35),
                  width: 2.0,
                )),
            child: Row(
              children: [
                Container(
                  width: 120,
                  margin: const EdgeInsets.only(right: 10),
                  child: Image.network(widget.thumbnail,
                      fit: BoxFit.cover), // Displays the thumbnail image
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        widget.headline,
                        softWrap: true,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.publisher,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w200,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
