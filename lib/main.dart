import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/helpers/custom_route.dart';
import 'package:shop_app/providers/auth.dart';
import 'package:shop_app/providers/cart.dart';
import 'package:shop_app/providers/orders.dart';
import 'package:shop_app/providers/products.dart';
import 'package:shop_app/screens/auth.dart';
import 'package:shop_app/screens/cart.dart';
import 'package:shop_app/screens/edit_product.dart';
import 'package:shop_app/screens/orders.dart';
import 'package:shop_app/screens/products_detail.dart';
import 'package:shop_app/screens/products_overview.dart';
import 'package:shop_app/screens/splash.dart';
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
          ChangeNotifierProvider(create: (_) => Auth()),
          ChangeNotifierProxyProvider<Auth, Products>(
              create: (_) => Products('', '', []),
              update: (_, auth, prevProducts) => Products(
                  auth.token ?? '',
                  auth.userId ?? '',
                  prevProducts == null ? [] : prevProducts.items)),
          ChangeNotifierProvider(create: (_) => Cart()),
          ChangeNotifierProxyProvider<Auth, Orders>(
              create: (_) => Orders('', '', []),
              update: (_, auth, prevOrders) => Orders(
                  auth.token ?? '',
                  auth.userId ?? '',
                  prevOrders == null ? [] : prevOrders.orders))
        ],
        child: Consumer<Auth>(
          builder: (_, auth, __) => MaterialApp(
            theme: ThemeData(
                primarySwatch: Colors.brown,
                iconTheme: const IconThemeData(color: Colors.orangeAccent),
                fontFamily: 'Lato',
                pageTransitionsTheme: PageTransitionsTheme(builders: {
                  TargetPlatform.android: CustomPageTransitionBuilder(),
                  TargetPlatform.iOS: CustomPageTransitionBuilder()
                })),
            home: auth.isAuth
                ? const ProductsOverviewScreen()
                : FutureBuilder(
                    future: auth.autoLogin(),
                    builder: (_, snapshot) {
                      if (snapshot.error != null) {
                        return Text('${snapshot.error}');
                      } else if (snapshot.connectionState ==
                          ConnectionState.done) {
                        return const AuthScreen();
                      }
                      return const SplashScreen();
                    },
                  ),
            routes: {
              ProductDetailScreen.routeName: (_) => const ProductDetailScreen(),
              CartScreen.routeName: ((_) => const CartScreen()),
              OrdersScreen.routeName: ((_) => const OrdersScreen()),
              UserProductsScreen.routeName: ((_) => const UserProductsScreen()),
              EditProductScreen.routeName: ((_) => const EditProductScreen())
            },
          ),
        ));
  }
}
