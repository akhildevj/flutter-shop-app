import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/auth.dart';
import 'package:shop_app/screens/orders.dart';
import 'package:shop_app/screens/user_products.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(children: [
        AppBar(
          title: const Text('Hi There'),
          automaticallyImplyLeading: false,
        ),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.shop),
          title: const Text('Shop'),
          onTap: () => Navigator.of(context).pushReplacementNamed('/'),
        ),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.payment),
          title: const Text('Orders'),
          onTap: () => Navigator.of(context)
              .pushReplacementNamed(OrdersScreen.routeName),
        ),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.edit),
          title: const Text('Manage Products'),
          onTap: () => Navigator.of(context)
              .pushReplacementNamed(UserProductsScreen.routeName),
        ),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.exit_to_app),
          title: const Text('Logout'),
          onTap: () {
            Provider.of<Auth>(context, listen: false).logout();
            Navigator.of(context).pop();
            Navigator.of(context).pushReplacementNamed('/');
          },
        )
      ]),
    );
  }
}
