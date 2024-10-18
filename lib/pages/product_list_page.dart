import 'package:flutter/material.dart';
import '../models/product.dart';
import '../widgets/product_tile.dart';
import 'product_detail_page.dart';

class ProductListPage extends StatefulWidget {
  final List<Product> products;
  final Function(Product) onAddToCart;
  final Function(Product) onWishlistToggle;
  final List<Product> wishlist;

  ProductListPage({
    required this.products,
    required this.onAddToCart,
    required this.onWishlistToggle,
    required this.wishlist,
  });

  @override
  _ProductListPageState createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  String selectedCategory = 'All';
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    List<Product> filteredProducts = widget.products.where((product) {
      bool matchesCategory = selectedCategory == 'All' ||
          product.category.toLowerCase() == selectedCategory.toLowerCase();
      bool matchesSearch =
          product.name.toLowerCase().contains(searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue[800],
        title: Text('SLINK Products'),
        actions: [
          IconButton(
            icon: Icon(Icons.favorite, color: Colors.white),
            onPressed: () {
              Navigator.pushNamed(context, '/wishlist');
            },
          ),
          IconButton(
            icon: Icon(Icons.shopping_cart, color: Colors.white),
            onPressed: () {
              Navigator.pushNamed(context, '/cart');
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildCategoryFilter(),
          Expanded(
            child: ListView.builder(
              itemCount: filteredProducts.length,
              itemBuilder: (context, index) {
                final product = filteredProducts[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProductDetailPage(
                          product: product,
                          onAddToCart: widget.onAddToCart,
                        ),
                      ),
                    );
                  },
                  child: ProductTile(
                    product: product,
                    onWishlistToggle: widget.onWishlistToggle,
                    onAddToCart: widget.onAddToCart,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        decoration: InputDecoration(
          labelText: 'Search products...',
          border: OutlineInputBorder(),
          prefixIcon: Icon(Icons.search),
        ),
        onChanged: (query) {
          setState(() {
            searchQuery = query;
          });
        },
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: DropdownButton<String>(
        value: selectedCategory,
        isExpanded: true,
        items: <String>['All', 'Wellness Products', 'Fitness Equipment']
            .map<DropdownMenuItem<String>>((String category) {
          return DropdownMenuItem<String>(
            value: category,
            child: Text(category),
          );
        }).toList(),
        onChanged: (String? newValue) {
          setState(() {
            selectedCategory = newValue ?? 'All';
          });
        },
      ),
    );
  }
}
