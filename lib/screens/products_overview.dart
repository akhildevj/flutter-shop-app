import 'package:flutter/material.dart';
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
          )
        ],
      ),
      body: ProductsGrid(showFavorites: _showFavorites),
    );
  }
}
