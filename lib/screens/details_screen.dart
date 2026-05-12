import 'package:flutter/material.dart';
import 'webview_screen.dart';
import '../models/show_model.dart';

class DetailsScreen extends StatelessWidget {
  final Show show;

  const DetailsScreen({super.key, required this.show});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(show.name)),

      body: SingleChildScrollView(
        child: Column(
          children: [
            Hero(
              tag: show.id,
              child: Image.network(
                show.image,
                width: double.infinity,
                height: 300,
                fit: BoxFit.cover,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              show.name,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            Text("⭐ ${show.rating}"),

            const SizedBox(height: 10),

            /// GENRES
            if (show.genres.isNotEmpty)
              Wrap(
                spacing: 6,
                children: show.genres.map<Widget>((genre) {
                  return Chip(
                    label: Text(genre.toString()),
                  );
                }).toList(),
              ),

            const SizedBox(height: 10),

            const Padding(
              padding: EdgeInsets.all(10),
              child: Text(
                "Summary",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(10),
              child: Text(
                show.summary.replaceAll(RegExp(r'<[^>]*>'), ''),
              ),
            ),

            const SizedBox(height: 10),

            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (show.url.isNotEmpty) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => WebViewScreen(url: show.url),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("No URL available")),
                      );
                    }
                  },
                  child: const Text("View More"),
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}