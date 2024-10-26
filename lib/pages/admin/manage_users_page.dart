// lib/pages/admin/manage_users_page.dart
import 'package:flutter/material.dart';

class ManageUsersPage extends StatelessWidget {
  const ManageUsersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Users'),
        backgroundColor: Colors.blue[800],
      ),
      body: const Center(
        child: Text('User management coming soon...'),
      ),
    );
  }
}
