import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/show_model.dart';

class ApiService {
  static const String baseUrl = "https://api.tvmaze.com";

  Future<List<Show>> fetchShows() async {
    final response = await http.get(Uri.parse("$baseUrl/shows"));

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => Show.fromJson(e)).toList();
    } else {
      throw Exception("Failed to load shows");
    }
  }

  Future<List<Show>> searchShows(String query) async {
    final response = await http.get(
      Uri.parse("$baseUrl/search/shows?q=$query"),
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);

      return data.map((e) => Show.fromJson(e['show'])).toList();
    } else {
      throw Exception("Search failed");
    }
  }

}