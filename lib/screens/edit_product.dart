import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/product.dart';
import 'package:shop_app/providers/products.dart';

class EditProductScreen extends StatefulWidget {
  static const routeName = '/edit-product';
  const EditProductScreen({Key? key}) : super(key: key);

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _priceFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();
  final _imageController = TextEditingController();
  final _form = GlobalKey<FormState>();

  var _editedProduct =
      Product(id: "", title: "", description: "", imageUrl: "", price: 0);
  var _initValues = {"title": "", "description": "", "price": ""};

  var _isInit = true;

  @override
  void didChangeDependencies() {
    if (_isInit) {
      final product = ModalRoute.of(context)?.settings.arguments;
      if (product != null) {
        final productId = product as String;
        if (productId.isNotEmpty) {
          _editedProduct = Provider.of<Products>(context).findById(productId);
          _initValues = {
            "title": _editedProduct.title,
            "description": _editedProduct.description,
            "price": _editedProduct.price.toString(),
          };
          _imageController.text = _editedProduct.imageUrl;
        }
      }
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _priceFocusNode.dispose();
    _descriptionFocusNode.dispose();
    _imageController.dispose();
    super.dispose();
  }

  void _saveForm() {
    final isValid = _form.currentState?.validate();
    if (isValid == null) return;
    if (!isValid) return;
    _form.currentState?.save();

    if (_editedProduct.id.isNotEmpty) {
      Provider.of<Products>(context, listen: false)
          .updateProduct(_editedProduct.id, _editedProduct);
    } else {
      Provider.of<Products>(context, listen: false).addProduct(_editedProduct);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Products'),
        actions: [
          IconButton(onPressed: _saveForm, icon: const Icon(Icons.save))
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
            key: _form,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  TextFormField(
                    initialValue: _initValues['title'],
                    decoration: const InputDecoration(labelText: 'Title'),
                    textInputAction: TextInputAction.next,
                    onFieldSubmitted: (_) {
                      FocusScope.of(context).requestFocus(_priceFocusNode);
                    },
                    validator: (String? value) {
                      if (value == null) return 'Please provide value';
                      if (value.isEmpty) return 'Please provide value';
                      return null;
                    },
                    onSaved: (value) {
                      _editedProduct = Product(
                          id: _editedProduct.id,
                          title: value as String,
                          description: _editedProduct.description,
                          imageUrl: _editedProduct.imageUrl,
                          price: _editedProduct.price,
                          isFavorite: _editedProduct.isFavorite);
                    },
                  ),
                  TextFormField(
                    initialValue: _initValues['price'],
                    decoration: const InputDecoration(labelText: 'Price'),
                    textInputAction: TextInputAction.next,
                    keyboardType: TextInputType.number,
                    focusNode: _priceFocusNode,
                    onFieldSubmitted: (_) {
                      FocusScope.of(context)
                          .requestFocus(_descriptionFocusNode);
                    },
                    validator: (String? value) {
                      if (value == null) return 'Please enter a price';
                      if (value.isEmpty) return 'Please enter a price';
                      if (double.tryParse(value) == null) {
                        return 'Please enter a valid number';
                      }
                      if (double.parse(value) <= 0) {
                        return 'Please enter a valid price greater than zero';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _editedProduct = Product(
                          id: _editedProduct.id,
                          title: _editedProduct.title,
                          description: _editedProduct.description,
                          imageUrl: _editedProduct.imageUrl,
                          price: double.parse(value as String),
                          isFavorite: _editedProduct.isFavorite);
                    },
                  ),
                  TextFormField(
                    initialValue: _initValues['description'],
                    decoration: const InputDecoration(labelText: 'Description'),
                    keyboardType: TextInputType.multiline,
                    maxLines: 3,
                    focusNode: _descriptionFocusNode,
                    validator: (String? value) {
                      if (value == null) return 'Please enter a description';
                      if (value.isEmpty) return 'Please enter a description';
                      if (value.length <= 10) {
                        return 'Should be at least 10 characters long';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _editedProduct = Product(
                          id: _editedProduct.id,
                          title: _editedProduct.title,
                          description: value as String,
                          imageUrl: _editedProduct.imageUrl,
                          price: _editedProduct.price,
                          isFavorite: _editedProduct.isFavorite);
                    },
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        margin: const EdgeInsets.only(top: 8, right: 10),
                        decoration: BoxDecoration(
                            border: Border.all(width: 1, color: Colors.grey)),
                        child: _imageController.text.isEmpty
                            ? const Text('Enter A URL')
                            : FittedBox(
                                child: Image.network(
                                  _imageController.text,
                                  fit: BoxFit.cover,
                                ),
                              ),
                      ),
                      Expanded(
                          child: TextFormField(
                        decoration:
                            const InputDecoration(labelText: 'Image URL'),
                        keyboardType: TextInputType.url,
                        textInputAction: TextInputAction.done,
                        controller: _imageController,
                        onEditingComplete: () => setState(() {}),
                        validator: (String? value) {
                          if (value == null) return 'Please enter an image URL';
                          if (value.isEmpty) return 'Please enter an image URL';
                          if (!value.startsWith('http') &&
                              !value.startsWith('https')) {
                            return 'Please enter a valid URL';
                          }
                          return null;
                        },
                        onFieldSubmitted: (_) => _saveForm(),
                        onSaved: (value) {
                          _editedProduct = Product(
                              id: _editedProduct.id,
                              title: _editedProduct.title,
                              description: _editedProduct.description,
                              imageUrl: value as String,
                              price: _editedProduct.price,
                              isFavorite: _editedProduct.isFavorite);
                        },
                      )),
                    ],
                  )
                ],
              ),
            )),
      ),
    );
  }
}
