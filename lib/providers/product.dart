import 'dart:convert';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;

class Product with ChangeNotifier {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final double price;
  bool isFavorite;

  Product(
      {required this.id,
      required this.title,
      required this.description,
      required this.imageUrl,
      required this.price,
      this.isFavorite = false});

  void _setFavoriteValue(bool value) {
    isFavorite = value;
    notifyListeners();
  }

  Future<void> toggleFavorite(String token, String userId) async {
    final prevStatus = isFavorite;

    try {
      _setFavoriteValue(!isFavorite);

      final url = Uri.https(
          "akzshops-default-rtdb.asia-southeast1.firebasedatabase.app",
          '/userFavorites/$userId/$id.json',
          {'auth': token});
      final body = json.encode(isFavorite);

      final response = await http.put(url, body: body);
      if (response.statusCode >= 400) {
        _setFavoriteValue(prevStatus);
      }
    } catch (error) {
      _setFavoriteValue(prevStatus);
    }
  }
}
