// lib/pages/admin/manage_orders_page.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/order.dart';
import '../../service/admin_service.dart';
import '../../widgets/order_details_dialog.dart';

class ManageOrdersPage extends StatefulWidget {
  const ManageOrdersPage({super.key});

  @override
  State<ManageOrdersPage> createState() => _ManageOrdersPageState();
}

class _ManageOrdersPageState extends State<ManageOrdersPage> {
  final AdminService _adminService = AdminService();
  String _selectedStatus = 'all';
  DateTime? _selectedDate;
  String _searchQuery = '';

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'processing':
        return Colors.blue;
      case 'shipped':
        return Colors.purple;
      case 'delivered':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Widget _buildStatusBadge(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getStatusColor(status).withOpacity(0.1),
        border: Border.all(color: _getStatusColor(status)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: _getStatusColor(status),
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Future<void> _updateOrderStatus(OrderModel order, String newStatus) async {
    try {
      await _adminService.updateOrderStatus(order.id, newStatus);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Order status updated to $newStatus'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating order: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Orders'),
        actions: [
          // Search
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Search Orders'),
                  content: TextField(
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                    decoration: const InputDecoration(
                      hintText: 'Enter order ID or customer name',
                      prefixIcon: Icon(Icons.search),
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _searchQuery = '';
                        });
                        Navigator.pop(context);
                      },
                      child: const Text('Clear'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Done'),
                    ),
                  ],
                ),
              );
            },
          ),
          // Filter by status
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            onSelected: (value) {
              setState(() {
                _selectedStatus = value;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'all', child: Text('All Statuses')),
              const PopupMenuItem(value: 'pending', child: Text('Pending')),
              const PopupMenuItem(
                  value: 'processing', child: Text('Processing')),
              const PopupMenuItem(value: 'shipped', child: Text('Shipped')),
              const PopupMenuItem(value: 'delivered', child: Text('Delivered')),
              const PopupMenuItem(value: 'cancelled', child: Text('Cancelled')),
            ],
          ),
          // Date filter
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _selectedDate ?? DateTime.now(),
                firstDate: DateTime(2023),
                lastDate: DateTime(2025),
              );
              if (picked != null) {
                setState(() {
                  _selectedDate = picked;
                });
              }
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _adminService.getOrders(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          var orders = snapshot.data!.docs.map((doc) {
            return OrderModel.fromFirestore(doc);
          }).toList();

          // Apply filters
          if (_selectedStatus != 'all') {
            orders = orders
                .where((order) => order.status == _selectedStatus)
                .toList();
          }

          if (_selectedDate != null) {
            orders = orders.where((order) {
              return order.createdAt.year == _selectedDate!.year &&
                  order.createdAt.month == _selectedDate!.month &&
                  order.createdAt.day == _selectedDate!.day;
            }).toList();
          }

          if (_searchQuery.isNotEmpty) {
            orders = orders.where((order) {
              return order.id
                      .toLowerCase()
                      .contains(_searchQuery.toLowerCase()) ||
                  order.userId
                      .toLowerCase()
                      .contains(_searchQuery.toLowerCase());
            }).toList();
          }

          // Sort by date
          orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));

          if (orders.isEmpty) {
            return const Center(
              child: Text('No orders found'),
            );
          }

          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ExpansionTile(
                  title: Row(
                    children: [
                      Text('Order #${order.id.substring(0, 8)}'),
                      const SizedBox(width: 8),
                      _buildStatusBadge(order.status),
                    ],
                  ),
                  subtitle: Text(
                    'Total: R${order.total.toStringAsFixed(2)}\n'
                    'Date: ${order.createdAt.toString().substring(0, 16)}',
                  ),
                  children: [
                    Column(
                      children: [
                        // Order items
                        ...order.items.map((item) => ListTile(
                              title: Text(item.productName),
                              subtitle: Text('Quantity: ${item.quantity}'),
                              trailing:
                                  Text('R${item.price.toStringAsFixed(2)}'),
                            )),
                        // Shipping address
                        ListTile(
                          leading: const Icon(Icons.location_on),
                          title: const Text('Shipping Address'),
                          subtitle: Text(order.shippingAddress),
                        ),
                        // Action buttons
                        ButtonBar(
                          alignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            TextButton.icon(
                              icon: const Icon(Icons.visibility),
                              label: const Text('Details'),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (context) =>
                                      OrderDetailsDialog(order: order),
                                );
                              },
                            ),
                            TextButton.icon(
                              icon: const Icon(Icons.update),
                              label: const Text('Update Status'),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Update Order Status'),
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        ListTile(
                                          title: const Text('Processing'),
                                          onTap: () {
                                            _updateOrderStatus(
                                                order, 'processing');
                                            Navigator.pop(context);
                                          },
                                        ),
                                        ListTile(
                                          title: const Text('Shipped'),
                                          onTap: () {
                                            _updateOrderStatus(
                                                order, 'shipped');
                                            Navigator.pop(context);
                                          },
                                        ),
                                        ListTile(
                                          title: const Text('Delivered'),
                                          onTap: () {
                                            _updateOrderStatus(
                                                order, 'delivered');
                                            Navigator.pop(context);
                                          },
                                        ),
                                        ListTile(
                                          title: const Text('Cancelled'),
                                          onTap: () {
                                            _updateOrderStatus(
                                                order, 'cancelled');
                                            Navigator.pop(context);
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
