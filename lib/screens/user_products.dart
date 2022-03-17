import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/products.dart';
import 'package:shop_app/screens/edit_product.dart';
import 'package:shop_app/widgets/app_drawer.dart';
import 'package:shop_app/widgets/user_product_item.dart';

class UserProductsScreen extends StatelessWidget {
  static const routeName = '/user-products';
  const UserProductsScreen({Key? key}) : super(key: key);

  Future<void> _refreshProducts(BuildContext context) async {
    Provider.of<Products>(context, listen: false).fetchProducts(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Your Products'),
          actions: [
            IconButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(EditProductScreen.routeName);
                },
                icon: const Icon(Icons.add))
          ],
        ),
        drawer: const AppDrawer(),
        body: FutureBuilder(
          future: _refreshProducts(context),
          builder: (_, snapshot) {
            if (snapshot.error != null) {
              return Text('${snapshot.error}');
            } else if (snapshot.connectionState == ConnectionState.done) {
              return RefreshIndicator(
                onRefresh: () => _refreshProducts(context),
                child: Consumer<Products>(
                  builder: (_, product, __) => Padding(
                    padding: const EdgeInsets.all(8),
                    child: ListView.builder(
                      itemBuilder: (_, index) => Column(
                        children: [
                          UserProductItem(
                              id: product.items[index].id,
                              title: product.items[index].title,
                              imageUrl: product.items[index].imageUrl),
                          const Divider()
                        ],
                      ),
                      itemCount: product.items.length,
                    ),
                  ),
                ),
              );
            }
            return const CircularProgressIndicator();
          },
        ));
  }
}
