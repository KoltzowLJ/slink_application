// lib/pages/admin/manage_orders_page.dart

// An admin interface for managing e-commerce orders with features

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

  // Filter and search states
  String _selectedStatus = 'all';
  DateTime? _selectedDate;
  String _searchQuery = '';

  // Order status options
  static const List<String> _statusOptions = [
    'pending',
    'processing',
    'shipped',
    'delivered',
    'cancelled'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildOrderList(),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: const Text('Manage Orders'),
      actions: [
        _buildSearchButton(),
        _buildStatusFilter(),
        _buildDateFilter(),
      ],
    );
  }

  Widget _buildSearchButton() {
    return IconButton(
      icon: const Icon(Icons.search),
      onPressed: () => _showSearchDialog(),
    );
  }

  Future<void> _showSearchDialog() {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Search Orders'),
        content: TextField(
          onChanged: (value) => setState(() => _searchQuery = value),
          decoration: const InputDecoration(
            hintText: 'Enter order ID or customer name',
            prefixIcon: Icon(Icons.search),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() => _searchQuery = '');
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
  }

  Widget _buildStatusFilter() {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.filter_list),
      onSelected: (value) => setState(() => _selectedStatus = value),
      itemBuilder: (context) => [
        const PopupMenuItem(value: 'all', child: Text('All Statuses')),
        ..._statusOptions.map((status) => PopupMenuItem(
              value: status,
              child: Text(status.capitalize()),
            )),
      ],
    );
  }

  Widget _buildDateFilter() {
    return IconButton(
      icon: const Icon(Icons.calendar_today),
      onPressed: () => _selectDate(context),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2023),
      lastDate: DateTime(2025),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Widget _buildOrderList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _adminService.getOrders(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final orders = _filterOrders(snapshot.data!.docs);

        if (orders.isEmpty) {
          return const Center(child: Text('No orders found'));
        }

        return ListView.builder(
          itemCount: orders.length,
          itemBuilder: (context, index) => _buildOrderCard(orders[index]),
        );
      },
    );
  }

  List<OrderModel> _filterOrders(List<QueryDocumentSnapshot> docs) {
    var orders = docs.map((doc) => OrderModel.fromFirestore(doc)).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    if (_selectedStatus != 'all') {
      orders =
          orders.where((order) => order.status == _selectedStatus).toList();
    }

    if (_selectedDate != null) {
      orders = orders
          .where((order) => _isSameDay(order.createdAt, _selectedDate!))
          .toList();
    }

    if (_searchQuery.isNotEmpty) {
      orders = orders.where((order) {
        return order.id.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            order.userId.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }

    return orders;
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  Widget _buildOrderCard(OrderModel order) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ExpansionTile(
        title: _buildOrderTitle(order),
        subtitle: _buildOrderSubtitle(order),
        children: [_buildOrderDetails(order)],
      ),
    );
  }

  Widget _buildOrderTitle(OrderModel order) {
    return Row(
      children: [
        Text('Order #${order.id.substring(0, 8)}'),
        const SizedBox(width: 8),
        _buildStatusBadge(order.status),
      ],
    );
  }

  Widget _buildOrderSubtitle(OrderModel order) {
    return Text(
      'Total: R${order.total.toStringAsFixed(2)}\n'
      'Date: ${order.createdAt.toString().substring(0, 16)}',
    );
  }

  Widget _buildOrderDetails(OrderModel order) {
    return Column(
      children: [
        ..._buildOrderItems(order),
        _buildShippingAddress(order),
        _buildActionButtons(order),
      ],
    );
  }

  List<Widget> _buildOrderItems(OrderModel order) {
    return order.items
        .map((item) => ListTile(
              title: Text(item.productName),
              subtitle: Text('Quantity: ${item.quantity}'),
              trailing: Text('R${item.price.toStringAsFixed(2)}'),
            ))
        .toList();
  }

  Widget _buildShippingAddress(OrderModel order) {
    return ListTile(
      leading: const Icon(Icons.location_on),
      title: const Text('Shipping Address'),
      subtitle: Text(order.shippingAddress),
    );
  }

  Widget _buildActionButtons(OrderModel order) {
    return OverflowBar(
      alignment: MainAxisAlignment.spaceEvenly,
      children: [
        TextButton.icon(
          icon: const Icon(Icons.visibility),
          label: const Text('Details'),
          onPressed: () => _showOrderDetails(order),
        ),
        TextButton.icon(
          icon: const Icon(Icons.update),
          label: const Text('Update Status'),
          onPressed: () => _showUpdateStatusDialog(order),
        ),
      ],
    );
  }

  void _showOrderDetails(OrderModel order) {
    showDialog(
      context: context,
      builder: (context) => OrderDetailsDialog(order: order),
    );
  }

  Future<void> _showUpdateStatusDialog(OrderModel order) {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Order Status'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: _statusOptions
              .map((status) => ListTile(
                    title: Text(status.capitalize()),
                    onTap: () {
                      _updateOrderStatus(order, status);
                      Navigator.pop(context);
                    },
                  ))
              .toList(),
        ),
      ),
    );
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

  Future<void> _updateOrderStatus(OrderModel order, String newStatus) async {
    try {
      await _adminService.updateOrderStatus(order.id, newStatus);
      _showSuccessMessage('Order status updated to $newStatus');
    } catch (e) {
      _showErrorMessage('Error updating order: $e');
    }
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
