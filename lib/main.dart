import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/cart.dart';
import 'package:shop_app/providers/orders.dart';
import 'package:shop_app/providers/products.dart';
import 'package:shop_app/screens/cart.dart';
import 'package:shop_app/screens/edit_product.dart';
import 'package:shop_app/screens/orders.dart';
import 'package:shop_app/screens/products_detail.dart';
import 'package:shop_app/screens/products_overview.dart';
import 'package:shop_app/screens/user_products.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => Products()),
        ChangeNotifierProvider(create: (_) => Cart()),
        ChangeNotifierProvider(create: (_) => Orders())
      ],
      child: MaterialApp(
        theme: ThemeData(
            primarySwatch: Colors.brown,
            iconTheme: const IconThemeData(color: Colors.orangeAccent),
            fontFamily: 'Lato'),
        home: const ProductsOverviewScreen(),
        routes: {
          ProductDetailScreen.routeName: (_) => const ProductDetailScreen(),
          CartScreen.routeName: ((_) => const CartScreen()),
          OrdersScreen.routeName: ((_) => const OrdersScreen()),
          UserProductsScreen.routeName: ((_) => const UserProductsScreen()),
          EditProductScreen.routeName: ((_) => const EditProductScreen())
        },
      ),
    );
  }
}
