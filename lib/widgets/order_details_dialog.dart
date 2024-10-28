// lib/widgets/order_details_dialog.dart

import 'package:flutter/material.dart';
import '../models/order.dart';

// A dialog widget that displays detailed information about an order
class OrderDetailsDialog extends StatelessWidget {
  final OrderModel order;

  const OrderDetailsDialog({
    super.key,
    required this.order,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: _buildTitle(),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildOrderInformation(),
            const Divider(),
            _buildOrderItems(),
            const Divider(),
            _buildShippingInformation(),
          ],
        ),
      ),
      actions: [
        _buildCloseButton(context),
      ],
    );
  }

  // Builds the dialog title with order ID
  Widget _buildTitle() {
    return Text(
      'Order Details #${_formatOrderId(order.id)}',
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  // Formats the order ID for display
  String _formatOrderId(String id) {
    return id.substring(0, 8).toUpperCase();
  }

  // Builds the order information section
  Widget _buildOrderInformation() {
    return _buildSection(
      'Order Information',
      [
        _buildInfoRow('Status', order.status.toUpperCase()),
        _buildInfoRow('Date', _formatDate(order.createdAt)),
        _buildInfoRow('Total', _formatCurrency(order.total)),
      ],
    );
  }

  // Builds the order items section
  Widget _buildOrderItems() {
    return _buildSection(
      'Items',
      order.items
          .map((item) => _buildInfoRow(
                item.productName,
                '${item.quantity}x @ ${_formatCurrency(item.price)}',
              ))
          .toList(),
    );
  }

  // Builds the shipping information section
  Widget _buildShippingInformation() {
    return _buildSection(
      'Shipping Information',
      [
        _buildInfoRow('Address', order.shippingAddress),
      ],
    );
  }

  // Builds a section with title and content
  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ...children,
        const SizedBox(height: 16),
      ],
    );
  }

  // Builds an information row with label and value
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(value),
        ],
      ),
    );
  }

  // Builds the close button
  Widget _buildCloseButton(BuildContext context) {
    return TextButton(
      onPressed: () => Navigator.pop(context),
      child: const Text('Close'),
    );
  }

  // Formats the date for display
  String _formatDate(DateTime date) {
    return date.toString().substring(0, 16);
  }

  // Formats currency for display
  String _formatCurrency(double amount) {
    return 'R${amount.toStringAsFixed(2)}';
  }
}
