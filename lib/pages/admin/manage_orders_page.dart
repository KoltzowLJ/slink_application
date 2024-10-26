// lib/pages/admin/manage_orders_page.dart
import 'package:flutter/material.dart';

class ManageOrdersPage extends StatelessWidget {
  const ManageOrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Orders'),
        backgroundColor: Colors.blue[800],
      ),
      body: const Center(
        child: Text('Order management coming soon...'),
      ),
    );
  }
}
