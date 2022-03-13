import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/cart.dart';
import 'package:shop_app/screens/cart.dart';
import 'package:shop_app/widgets/app_drawer.dart';
import 'package:shop_app/widgets/badge.dart';
import 'package:shop_app/widgets/products_grid.dart';

enum FILTER { favorites, all }

class ProductsOverviewScreen extends StatefulWidget {
  const ProductsOverviewScreen({Key? key}) : super(key: key);

  @override
  State<ProductsOverviewScreen> createState() => _ProductsOverviewScreenState();
}

class _ProductsOverviewScreenState extends State<ProductsOverviewScreen> {
  var _showFavorites = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Akz Shop'),
        actions: [
          PopupMenuButton(
            onSelected: (FILTER value) => {
              setState(() {
                if (value == FILTER.favorites) {
                  _showFavorites = true;
                } else {
                  _showFavorites = false;
                }
              })
            },
            itemBuilder: (_) => [
              const PopupMenuItem(
                  child: Text('Favorites'), value: FILTER.favorites),
              const PopupMenuItem(child: Text('Show All'), value: FILTER.all)
            ],
            icon: const Icon(Icons.more_vert),
          ),
          Consumer<Cart>(
            builder: ((_, cart, child) => Badge(
                child: child as Widget, value: cart.itemCount.toString())),
            child: IconButton(
              icon: const Icon(Icons.shopping_cart),
              onPressed: () {
                Navigator.of(context).pushNamed(CartScreen.routeName);
              },
            ),
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: ProductsGrid(showFavorites: _showFavorites),
    );
  }
}
