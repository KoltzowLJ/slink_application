// lib/widgets/order_details_dialog.dart
import 'package:flutter/material.dart';
import '../models/order.dart';

class OrderDetailsDialog extends StatelessWidget {
  final OrderModel order;

  const OrderDetailsDialog({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Order Details #${order.id.substring(0, 8)}'),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildSection('Order Information', [
              _buildInfoRow('Status', order.status.toUpperCase()),
              _buildInfoRow(
                  'Date', order.createdAt.toString().substring(0, 16)),
              _buildInfoRow('Total', 'R${order.total.toStringAsFixed(2)}'),
            ]),
            const Divider(),
            _buildSection('Items', [
              ...order.items.map((item) => _buildInfoRow(
                    item.productName,
                    '${item.quantity}x @ R${item.price.toStringAsFixed(2)}',
                  )),
            ]),
            const Divider(),
            _buildSection('Shipping Information', [
              _buildInfoRow('Address', order.shippingAddress),
            ]),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }

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
}
