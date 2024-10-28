// lib/widgets/product_form_dialog.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product.dart';

class ProductFormDialog extends StatefulWidget {
  final Product? product; // null for new product, existing product for edit

  const ProductFormDialog({super.key, this.product});

  @override
  State<ProductFormDialog> createState() => _ProductFormDialogState();
}

class _ProductFormDialogState extends State<ProductFormDialog> {
  final _formKey = GlobalKey<FormState>();

  // Basic product info controllers
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _stockController = TextEditingController();

  // Specification controllers
  final _materialController = TextEditingController();
  final _dimensionsController = TextEditingController();
  final _thicknessController = TextEditingController();
  final _weightController = TextEditingController();

  String _selectedCategory = 'Fitness Equipment';
  List<String> _colors = [];
  List<String> _features = [];
  bool _isImageValid = false;

  @override
  void initState() {
    super.initState();
    if (widget.product != null) {
      // Populate form with existing product data
      _nameController.text = widget.product!.name;
      _descriptionController.text = widget.product!.description;
      _priceController.text = widget.product!.price.toString();
      _imageUrlController.text = widget.product!.imageUrl;
      _stockController.text = widget.product!.stockQuantity.toString();
      _selectedCategory = widget.product!.category;

      // Populate specifications
      _materialController.text =
          widget.product!.specifications['material'] ?? '';
      _dimensionsController.text =
          widget.product!.specifications['dimensions'] ?? '';
      _thicknessController.text =
          widget.product!.specifications['thickness'] ?? '';
      _weightController.text = widget.product!.specifications['weight'] ?? '';
      _colors =
          List<String>.from(widget.product!.specifications['colors'] ?? []);
      _features = List<String>.from(widget.product!.features);

      // Validate image URL
      _validateImageUrl(widget.product!.imageUrl);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _imageUrlController.dispose();
    _stockController.dispose();
    _materialController.dispose();
    _dimensionsController.dispose();
    _thicknessController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  Future<void> _validateImageUrl(String url) async {
    try {
      await NetworkImage(url).resolve(ImageConfiguration.empty);
      setState(() {
        _isImageValid = true;
      });
    } catch (e) {
      setState(() {
        _isImageValid = false;
      });
    }
  }

  void _addColor() {
    showDialog(
      context: context,
      builder: (context) {
        final controller = TextEditingController();
        return AlertDialog(
          title: const Text('Add Color'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'Color name',
              hintText: 'e.g., Blue, Red, Black',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (controller.text.isNotEmpty) {
                  setState(() {
                    _colors.add(controller.text);
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _addFeature() {
    showDialog(
      context: context,
      builder: (context) {
        final controller = TextEditingController();
        return AlertDialog(
          title: const Text('Add Feature'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'Feature description',
              hintText: 'e.g., Non-slip surface, Easy to clean',
            ),
            maxLines: 2,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (controller.text.isNotEmpty) {
                  setState(() {
                    _features.add(controller.text);
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        padding: const EdgeInsets.all(16),
        constraints: const BoxConstraints(maxWidth: 500),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Center(
                  child: Text(
                    widget.product == null ? 'Add Product' : 'Edit Product',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
                const SizedBox(height: 24),

                // Basic Information Section
                const Text(
                  'Basic Information',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Product Name',
                    border: OutlineInputBorder(),
                    hintText: 'e.g., Premium Yoga Mat',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a product name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                    hintText: 'Describe the product...',
                  ),
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a description';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _priceController,
                        decoration: const InputDecoration(
                          labelText: 'Price',
                          prefixText: 'R',
                          border: OutlineInputBorder(),
                          hintText: '0.00',
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a price';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Please enter a valid number';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _stockController,
                        decoration: const InputDecoration(
                          labelText: 'Stock Quantity',
                          border: OutlineInputBorder(),
                          hintText: '0',
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter stock quantity';
                          }
                          if (int.tryParse(value) == null) {
                            return 'Please enter a valid number';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(),
                  ),
                  items: ['Fitness Equipment', 'Supplements', 'Accessories']
                      .map((category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCategory = value!;
                    });
                  },
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _imageUrlController,
                  decoration: InputDecoration(
                    labelText: 'Image URL',
                    border: const OutlineInputBorder(),
                    hintText: 'https://...',
                    suffixIcon: _isImageValid
                        ? const Icon(Icons.check_circle, color: Colors.green)
                        : const Icon(Icons.error, color: Colors.red),
                  ),
                  onChanged: (value) => _validateImageUrl(value),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an image URL';
                    }
                    if (!_isImageValid) {
                      return 'Please enter a valid image URL';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Specifications Section
                const Text(
                  'Specifications',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _materialController,
                  decoration: const InputDecoration(
                    labelText: 'Material',
                    border: OutlineInputBorder(),
                    hintText: 'e.g., Eco-friendly TPE',
                  ),
                ),
                const SizedBox(height: 8),

                TextFormField(
                  controller: _dimensionsController,
                  decoration: const InputDecoration(
                    labelText: 'Dimensions',
                    border: OutlineInputBorder(),
                    hintText: 'e.g., 183cm x 61cm',
                  ),
                ),
                const SizedBox(height: 8),

                TextFormField(
                  controller: _thicknessController,
                  decoration: const InputDecoration(
                    labelText: 'Thickness',
                    border: OutlineInputBorder(),
                    hintText: 'e.g., 6mm',
                  ),
                ),
                const SizedBox(height: 8),

                TextFormField(
                  controller: _weightController,
                  decoration: const InputDecoration(
                    labelText: 'Weight',
                    border: OutlineInputBorder(),
                    hintText: 'e.g., 1.8kg',
                  ),
                ),
                const SizedBox(height: 16),

                // Colors Section
                Row(
                  children: [
                    const Text('Colors:'),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: _addColor,
                      tooltip: 'Add Color',
                    ),
                  ],
                ),
                if (_colors.isNotEmpty)
                  Wrap(
                    spacing: 8,
                    children: _colors
                        .map((color) => Chip(
                              label: Text(color),
                              onDeleted: () {
                                setState(() {
                                  _colors.remove(color);
                                });
                              },
                            ))
                        .toList(),
                  ),
                const SizedBox(height: 24),

                // Features Section
                Row(
                  children: [
                    const Text('Features:'),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: _addFeature,
                      tooltip: 'Add Feature',
                    ),
                  ],
                ),
                if (_features.isNotEmpty)
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _features.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        leading: const Icon(Icons.check_circle_outline),
                        title: Text(_features[index]),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            setState(() {
                              _features.removeAt(index);
                            });
                          },
                        ),
                      );
                    },
                  ),
                const SizedBox(height: 24),

                // Action Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          final productData = {
                            'name': _nameController.text,
                            'description': _descriptionController.text,
                            'price': double.parse(_priceController.text),
                            'imageUrl': _imageUrlController.text,
                            'category': _selectedCategory,
                            'stockQuantity': int.parse(_stockController.text),
                            'specifications': {
                              'material': _materialController.text,
                              'dimensions': _dimensionsController.text,
                              'thickness': _thicknessController.text,
                              'weight': _weightController.text,
                              'colors': _colors,
                            },
                            'features': _features,
                            'isWishlisted': false,
                            'reviews': [],
                            'createdAt': Timestamp.now(),
                            'lastUpdated': Timestamp.now(),
                          };
                          Navigator.pop(context, productData);
                        }
                      },
                      child: Text(widget.product == null ? 'Add' : 'Update'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
