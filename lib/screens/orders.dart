import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/orders.dart' show Orders;
import 'package:shop_app/widgets/app_drawer.dart';
import 'package:shop_app/widgets/order_item.dart';

class OrdersScreen extends StatefulWidget {
  static const routeName = '/orders';

  const OrdersScreen({Key? key}) : super(key: key);

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  late Future _ordersFuture;
  Future _getOrdersFuture() {
    return Provider.of<Orders>(context, listen: false).fetchOrders();
  }

  @override
  void initState() {
    _ordersFuture = _getOrdersFuture();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Your Orders'),
        ),
        drawer: const AppDrawer(),
        body: Center(
          child: FutureBuilder(
            future: _ordersFuture,
            builder: (_, snapshot) {
              if (snapshot.error != null) {
                return Text('${snapshot.error}');
              } else if (snapshot.connectionState == ConnectionState.done) {
                return Consumer<Orders>(builder: (_, orderData, child) {
                  return orderData.orders.isEmpty
                      ? const Text('No Orders Yet')
                      : ListView.builder(
                          itemBuilder: (_, index) =>
                              OrderItem(order: orderData.orders[index]),
                          itemCount: orderData.orders.length,
                        );
                });
              }
              return const Center(child: CircularProgressIndicator());
            },
          ),
        ));
  }
}
