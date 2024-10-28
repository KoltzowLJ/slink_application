// lib/pages/order_history_page.dart

import 'package:flutter/material.dart';

class OrderHistoryPage extends StatelessWidget {
  // Mock data for orders
  final List<Map<String, dynamic>> mockOrders = [
    {'id': 'Order 1', 'date': '12 Oct 2024', 'total': 99.99},
    {'id': 'Order 2', 'date': '10 Oct 2024', 'total': 59.49},
    {'id': 'Order 3', 'date': '8 Oct 2024', 'total': 120.00},
  ];

  OrderHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildOrdersList(),
    );
  }

  // App Bar
  AppBar _buildAppBar() {
    return AppBar(
      title: const Text('Order History'),
      backgroundColor: Colors.blue[800],
    );
  }

  // Main orders list
  Widget _buildOrdersList() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView.builder(
        itemCount: mockOrders.length,
        itemBuilder: (context, index) {
          final order = mockOrders[index];
          return _buildOrderCard(order);
        },
      ),
    );
  }

  // Individual order card
  Widget _buildOrderCard(Map<String, dynamic> order) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10.0),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order icon
            _buildOrderIcon(),
            const SizedBox(width: 16),

            // Order details
            _buildOrderDetails(order),

            // Order price and action button
            _buildOrderActions(order),
          ],
        ),
      ),
    );
  }

  // Order icon widget
  Widget _buildOrderIcon() {
    return Icon(Icons.receipt_long, color: Colors.blue[800]);
  }

  // Order details section
  Widget _buildOrderDetails(Map<String, dynamic> order) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Order ID
          Text(
            order['id'],
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 4),

          // Order date
          Text(
            'Placed on ${order['date']}',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  // Order price and action button section
  Widget _buildOrderActions(Map<String, dynamic> order) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Order total
        Text(
          'R${order['total'].toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.blue[800],
          ),
        ),
        const SizedBox(height: 6),

        // View details button
        TextButton(
          onPressed: () {
            // TODO: Implement order details view
          },
          style: TextButton.styleFrom(
            foregroundColor: Colors.blue[800],
          ),
          child: const Text('View Details'),
        ),
      ],
    );
  }
}
