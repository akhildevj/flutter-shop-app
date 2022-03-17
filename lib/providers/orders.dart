import 'dart:convert';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:shop_app/models/http_exception.dart';
import 'package:shop_app/providers/cart.dart';

const webUrl = 'akzshops-default-rtdb.asia-southeast1.firebasedatabase.app';

class OrderItem {
  final String id;
  final double amount;
  final List<CartItem> products;
  final DateTime dateTime;

  OrderItem(
      {required this.id,
      required this.amount,
      required this.products,
      required this.dateTime});
}

class Orders with ChangeNotifier {
  final String? token;
  final String userId;
  List<OrderItem> _orders = [];

  Orders(this.token, this.userId, this._orders);

  List<OrderItem> get orders {
    return [..._orders];
  }

  Future<void> fetchOrders() async {
    try {
      final url = Uri.https(webUrl, "/orders/$userId.json", {'auth': token});
      final response = await http.get(url);
      final Map<String, dynamic>? data = json.decode(response.body);

      if (data == null) {
        _orders = [];
        notifyListeners();
        return;
      }

      final List<OrderItem> orders = [];
      data.forEach(((id, order) => orders.add(OrderItem(
            id: id,
            amount: order['amount'],
            products: (order['products'] as List<dynamic>)
                .map((item) => CartItem(
                    id: item['id'],
                    title: item['title'],
                    quantity: item['quantity'],
                    price: item['price']))
                .toList(),
            dateTime: DateTime.parse(order['dateTime']),
          ))));

      _orders = orders.reversed.toList();
      notifyListeners();
    } catch (error) {
      return Future.error('An error occured!');
    }
  }

  Future<void> addOrder(List<CartItem> cartProducts, double total) async {
    final timestamp = DateTime.now();

    try {
      final url = Uri.https(webUrl, "/orders/$userId.json", {'auth': token});

      final body = json.encode({
        'amount': total,
        'products': cartProducts
            .map((cart) => {
                  "id": cart.id,
                  "title": cart.title,
                  "quantity": cart.quantity,
                  "price": cart.price
                })
            .toList(),
        'dateTime': timestamp.toIso8601String(),
      });

      final response = await http.post(url, body: body);

      final orderItem = OrderItem(
          id: json.decode(response.body)['name'],
          amount: total,
          products: cartProducts,
          dateTime: timestamp);

      _orders.insert(0, orderItem);
      notifyListeners();
    } catch (error) {
      throw HttpException("Your order could not be submitted!");
    }
  }
}
