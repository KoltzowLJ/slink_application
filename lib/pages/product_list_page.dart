// lib/pages/product_list_page.dart

import 'package:flutter/material.dart';
import '../models/product.dart';
import '../widgets/product_tile.dart';
import '../service/product_service.dart';
import 'product_detail_page.dart';
import 'wishlist_page.dart';

class ProductListPage extends StatefulWidget {
  final Function(Product) onAddToCart;
  final Function(Product) onWishlistToggle;
  final List<Product> wishlist;

  const ProductListPage({
    super.key,
    required this.onAddToCart,
    required this.onWishlistToggle,
    required this.wishlist,
  });

  @override
  _ProductListPageState createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  // Service and state variables
  final ProductService _productService = ProductService();
  String selectedCategory = 'All';
  String searchQuery = '';

  // Available categories
  final List<String> _categories = [
    'All',
    'Wellness Products',
    'Fitness Equipment',
    'Supplements',
    'Accessories'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  // Main body content
  Widget _buildBody() {
    return Column(
      children: [
        _buildSearchBar(),
        _buildCategoryFilter(),
        Expanded(child: _buildProductList()),
      ],
    );
  }

  // App Bar with wishlist and cart icons
  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.blue[800],
      title: const Text(
        'SLINK Products',
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
      ),
      actions: [
        _buildWishlistButton(),
        _buildCartButton(),
      ],
    );
  }

  // Wishlist button with counter
  Widget _buildWishlistButton() {
    return IconButton(
      icon: Stack(
        children: [
          const Icon(Icons.favorite, color: Colors.white),
          if (widget.wishlist.isNotEmpty)
            _buildCounterBadge(widget.wishlist.length),
        ],
      ),
      onPressed: _navigateToWishlist,
    );
  }

  // Counter badge for wishlist/cart
  Widget _buildCounterBadge(int count) {
    return Positioned(
      right: 0,
      top: 0,
      child: Container(
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(10),
        ),
        constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
        child: Text(
          count.toString(),
          style: const TextStyle(color: Colors.white, fontSize: 10),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  // Cart button
  Widget _buildCartButton() {
    return IconButton(
      icon: const Icon(Icons.shopping_cart, color: Colors.white),
      onPressed: () => Navigator.pushNamed(context, '/cart'),
    );
  }

  // Search bar
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        decoration: _buildSearchDecoration(),
        onChanged: (value) => setState(() => searchQuery = value),
      ),
    );
  }

  // Search bar decoration
  InputDecoration _buildSearchDecoration() {
    return InputDecoration(
      hintText: 'Search products...',
      prefixIcon: const Icon(Icons.search),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.blue[800]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.blue[800]!, width: 2),
      ),
      filled: true,
      fillColor: Colors.grey[100],
    );
  }

  // Category filter dropdown
  Widget _buildCategoryFilter() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(12),
        ),
        child: _buildCategoryDropdown(),
      ),
    );
  }

  // Category dropdown
  Widget _buildCategoryDropdown() {
    return DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: selectedCategory,
        isExpanded: true,
        icon: const Icon(Icons.arrow_drop_down),
        style: TextStyle(color: Colors.blue[800], fontSize: 16),
        items: _buildCategoryItems(),
        onChanged: (String? newValue) {
          setState(() => selectedCategory = newValue ?? 'All');
        },
      ),
    );
  }

  // Category dropdown items
  List<DropdownMenuItem<String>> _buildCategoryItems() {
    return _categories.map<DropdownMenuItem<String>>((String category) {
      return DropdownMenuItem<String>(
        value: category,
        child: Text(category, style: TextStyle(color: Colors.grey[800])),
      );
    }).toList();
  }

  // Product list with StreamBuilder
  Widget _buildProductList() {
    return StreamBuilder<List<Product>>(
      stream: _productService.getProducts(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _buildErrorState(snapshot.error);
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final filteredProducts = _filterProducts(snapshot.data ?? []);

        if (filteredProducts.isEmpty) {
          return _buildEmptyState();
        }

        return _buildProductListView(filteredProducts);
      },
    );
  }

  // Error state widget
  Widget _buildErrorState(Object? error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 60, color: Colors.red[300]),
          const SizedBox(height: 16),
          Text(
            'Error loading products\n$error',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.red[300]),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => setState(() {}),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  // Empty state widget
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2_outlined, size: 60, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            searchQuery.isEmpty
                ? 'No products available'
                : 'No products found for "$searchQuery"',
            style: TextStyle(color: Colors.grey[600], fontSize: 16),
          ),
        ],
      ),
    );
  }

  // Product list view
  Widget _buildProductListView(List<Product> products) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: products.length,
      itemBuilder: (context, index) => _buildProductItem(products[index]),
    );
  }

  // Individual product item
  Widget _buildProductItem(Product product) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GestureDetector(
        onTap: () => _navigateToProductDetail(product),
        child: ProductTile(
          product: product,
          onWishlistToggle: widget.onWishlistToggle,
          onAddToCart: widget.onAddToCart,
        ),
      ),
    );
  }

  // Navigation methods
  void _navigateToWishlist() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WishlistPage(
          wishlist: widget.wishlist,
          onAddToCart: widget.onAddToCart,
          onWishlistToggle: widget.onWishlistToggle,
        ),
      ),
    );
  }

  void _navigateToProductDetail(Product product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductDetailPage(
          product: product,
          onAddToCart: widget.onAddToCart,
        ),
      ),
    );
  }

  // Helper methods
  List<Product> _filterProducts(List<Product> products) {
    return products.where((product) {
      bool matchesCategory = selectedCategory == 'All' ||
          product.category.toLowerCase() == selectedCategory.toLowerCase();
      bool matchesSearch =
          product.name.toLowerCase().contains(searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();
  }
}
