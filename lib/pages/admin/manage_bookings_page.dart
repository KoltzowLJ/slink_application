// lib/pages/admin/manage_bookings_page.dart
import 'package:flutter/material.dart';

class ManageBookingsPage extends StatelessWidget {
  const ManageBookingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Bookings'),
        backgroundColor: Colors.blue[800],
      ),
      body: const Center(
        child: Text('Booking management coming soon...'),
      ),
    );
  }
}
