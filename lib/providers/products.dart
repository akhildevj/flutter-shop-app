import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:shop_app/models/http_exception.dart';
import 'package:shop_app/providers/product.dart';

const webUrl = 'akzshops-default-rtdb.asia-southeast1.firebasedatabase.app';

class Products with ChangeNotifier {
  List<Product> _items = [];

  List<Product> get items {
    return [..._items];
  }

  List<Product> get favoriteItems {
    return _items.where((item) => item.isFavorite).toList();
  }

  Product findById(String id) {
    return _items.firstWhere((product) => product.id == id);
  }

  Future<void> fetchProducts() async {
    try {
      final url = Uri.https(webUrl, "/products.json");

      final response = await http.get(url);
      if (response.statusCode == 200) {
        final Map<String, dynamic>? data = json.decode(response.body);
        if (data == null) return;

        final List<Product> products = [];
        data.forEach(((id, product) => products.add(Product(
            id: id,
            title: product['title'],
            description: product['description'],
            imageUrl: product['imageUrl'],
            price: product['price'],
            isFavorite: product['isFavorite']))));

        _items = products;
      }
    } catch (err) {
      return Future.error('An error occured!');
    }
  }

  Future<void> addProduct(Product product) async {
    try {
      final url = Uri.https(webUrl, "/products.json");

      final body = json.encode({
        'title': product.title,
        'description': product.description,
        'price': product.price,
        'imageUrl': product.imageUrl,
        'isFavorite': product.isFavorite
      });

      final response = await http.post(url, body: body);

      final newProduct = Product(
          id: json.decode(response.body)['name'],
          title: product.title,
          description: product.description,
          price: product.price,
          imageUrl: product.imageUrl);

      _items.add(newProduct);
      notifyListeners();
    } catch (error) {
      throw HttpException("Adding product failed!");
    }
  }

  Future<void> updateProduct(String id, Product product) async {
    try {
      final index = _items.indexWhere((item) => item.id == id);
      if (index >= 0) {
        final url = Uri.https(webUrl, '/products/$id.json');

        final body = json.encode({
          'title': product.title,
          'description': product.description,
          'price': product.price,
          'imageUrl': product.imageUrl
        });

        final response = await http.patch(url, body: body);

        if (response.statusCode >= 400) {
          throw HttpException("Updating product failed!");
        }

        _items[index] = product;
        notifyListeners();
      }
    } catch (error) {
      rethrow;
    }
  }

  Future<void> deleteProduct(String id) async {
    try {
      final url = Uri.https(webUrl, '/products/$id.json');

      final index = _items.indexWhere((item) => item.id == id);
      Product? product = _items[index];
      _items.removeWhere((item) => item.id == id);
      notifyListeners();

      final response = await http.delete(url);

      if (response.statusCode >= 400) {
        _items.insert(index, product);
        notifyListeners();
        throw HttpException("Deleting product failed.");
      }
      product = null;
    } catch (error) {
      rethrow;
    }
  }
}
