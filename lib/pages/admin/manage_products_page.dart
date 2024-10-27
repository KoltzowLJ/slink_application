// lib/pages/admin/manage_products_page.dart

import 'package:flutter/material.dart';
import '../../models/product.dart';
import '../../service/product_service.dart';
import '../../service/admin_service.dart';

class ManageProductsPage extends StatefulWidget {
  const ManageProductsPage({super.key});

  @override
  State<ManageProductsPage> createState() => _ManageProductsPageState();
}

class _ManageProductsPageState extends State<ManageProductsPage> {
  final ProductService _productService = ProductService();
  final AdminService _adminService = AdminService();
  String _selectedCategory = 'All';

  void _showAddEditProductDialog([Product? product]) {
    final isEditing = product != null;
    final nameController = TextEditingController(text: product?.name);
    final descriptionController =
        TextEditingController(text: product?.description);
    final priceController =
        TextEditingController(text: product?.price.toString() ?? '');
    final imageUrlController = TextEditingController(text: product?.imageUrl);
    final stockQuantityController =
        TextEditingController(text: product?.stockQuantity.toString() ?? '0');

    // Default values for new products
    Map<String, dynamic> specifications = product?.specifications ??
        {
          'material': '',
          'dimensions': '',
          'thickness': '',
          'weight': '',
          'colors': <String>[]
        };

    List<String> features = product?.features ?? [];
    String selectedCategory = product?.category ?? 'Fitness Equipment';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEditing ? 'Edit Product' : 'Add New Product'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Basic Information
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Product Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: priceController,
                      decoration: const InputDecoration(
                        labelText: 'Price',
                        border: OutlineInputBorder(),
                        prefixText: 'R',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: stockQuantityController,
                      decoration: const InputDecoration(
                        labelText: 'Stock Quantity',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: imageUrlController,
                decoration: const InputDecoration(
                  labelText: 'Image URL',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
                items: [
                  'Fitness Equipment',
                  'Supplements',
                  'Accessories',
                  'Wellness Products'
                ].map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) {
                  selectedCategory = value ?? selectedCategory;
                },
              ),

              // Specifications Section
              const SizedBox(height: 24),
              const Text(
                'Specifications',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Material',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  specifications['material'] = value;
                },
                controller: TextEditingController(
                    text: specifications['material']?.toString()),
              ),
              const SizedBox(height: 8),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Dimensions',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  specifications['dimensions'] = value;
                },
                controller: TextEditingController(
                    text: specifications['dimensions']?.toString()),
              ),
              const SizedBox(height: 8),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Thickness',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  specifications['thickness'] = value;
                },
                controller: TextEditingController(
                    text: specifications['thickness']?.toString()),
              ),
              const SizedBox(height: 8),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Weight',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  specifications['weight'] = value;
                },
                controller: TextEditingController(
                    text: specifications['weight']?.toString()),
              ),

              // Features Section
              const SizedBox(height: 24),
              const Text(
                'Features',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              // Features list with add/remove capability
              ...features.asMap().entries.map((entry) {
                return Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          labelText: 'Feature ${entry.key + 1}',
                          border: const OutlineInputBorder(),
                        ),
                        controller: TextEditingController(text: entry.value),
                        onChanged: (value) {
                          features[entry.key] = value;
                        },
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.remove_circle),
                      onPressed: () {
                        setState(() {
                          features.removeAt(entry.key);
                        });
                        Navigator.pop(context);
                        _showAddEditProductDialog(product);
                      },
                    ),
                  ],
                );
              }),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    features.add('');
                  });
                  Navigator.pop(context);
                  _showAddEditProductDialog(product);
                },
                child: const Text('Add Feature'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                final name = nameController.text.trim();
                final description = descriptionController.text.trim();
                final price = double.tryParse(priceController.text) ?? 0.0;
                final imageUrl = imageUrlController.text.trim();
                final stockQuantity =
                    int.tryParse(stockQuantityController.text) ?? 0;

                if (name.isEmpty || description.isEmpty || price <= 0) {
                  throw 'Please fill in all required fields correctly';
                }

                final newProduct = Product(
                  id: product?.id ?? '',
                  name: name,
                  description: description,
                  price: price,
                  imageUrl: imageUrl,
                  category: selectedCategory,
                  stockQuantity: stockQuantity,
                  specifications: specifications,
                  features: features.where((f) => f.isNotEmpty).toList(),
                  isWishlisted: product?.isWishlisted ?? false,
                  reviews: product?.reviews ?? [],
                  createdAt: product?.createdAt ?? DateTime.now(),
                  lastUpdated: DateTime.now(),
                );

                if (isEditing) {
                  await _adminService.updateProduct(newProduct);
                } else {
                  await _adminService.addProduct(newProduct);
                }

                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          '${isEditing ? 'Updated' : 'Added'} product successfully'),
                    ),
                  );
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: $e')),
                );
              }
            },
            child: Text(isEditing ? 'Update' : 'Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Products'),
        backgroundColor: Colors.blue[800],
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() {
                _selectedCategory = value;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'All',
                child: Text('All Categories'),
              ),
              const PopupMenuItem(
                value: 'Fitness Equipment',
                child: Text('Fitness Equipment'),
              ),
              const PopupMenuItem(
                value: 'Supplements',
                child: Text('Supplements'),
              ),
              const PopupMenuItem(
                value: 'Accessories',
                child: Text('Accessories'),
              ),
              const PopupMenuItem(
                value: 'Wellness Products',
                child: Text('Wellness Products'),
              ),
            ],
            icon: const Icon(Icons.filter_list),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEditProductDialog(),
        backgroundColor: Colors.blue[800],
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<List<Product>>(
        stream: _productService.getProducts(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final products = snapshot.data ?? [];
          final filteredProducts = _selectedCategory == 'All'
              ? products
              : products.where((p) => p.category == _selectedCategory).toList();

          if (filteredProducts.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inventory_2_outlined,
                      size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No products found${_selectedCategory == 'All' ? '' : ' in $_selectedCategory'}',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: filteredProducts.length,
            itemBuilder: (context, index) {
              final product = filteredProducts[index];
              return Dismissible(
                key: Key(product.id),
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                confirmDismiss: (direction) async {
                  return await showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Delete Product'),
                      content: Text(
                          'Are you sure you want to delete ${product.name}?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('Delete'),
                        ),
                      ],
                    ),
                  );
                },
                onDismissed: (direction) async {
                  try {
                    await _adminService.deleteProduct(product.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${product.name} deleted successfully'),
                      ),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: $e')),
                    );
                  }
                },
                child: Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        product.imageUrl,
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 50,
                            height: 50,
                            color: Colors.grey[300],
                            child: const Icon(Icons.image_not_supported),
                          );
                        },
                      ),
                    ),
                    title: Text(
                      product.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      '${product.category}\n${product.formattedPrice}',
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => _showAddEditProductDialog(product),
                    ),
                    isThreeLine: true,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
