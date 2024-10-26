// lib/pages/admin/admin_home_page.dart

import 'package:flutter/material.dart';
import 'manage_products_page.dart';
import 'manage_bookings_page.dart';
import 'manage_users_page.dart';
import 'manage_orders_page.dart';

class AdminHomePage extends StatelessWidget {
  const AdminHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: Colors.blue[800],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Admin Dashboard',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            _buildStatsCards(),
            const SizedBox(height: 30),
            const Text(
              'Management',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildManagementGrid(context),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCards() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: [
        _buildStatCard('Total Products', '23', Icons.shopping_bag, Colors.blue),
        _buildStatCard('Total Orders', '12', Icons.shopping_cart, Colors.green),
        _buildStatCard('Active Users', '45', Icons.people, Colors.orange),
        _buildStatCard(
            'Total Bookings', '8', Icons.calendar_today, Colors.purple),
      ],
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildManagementGrid(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: [
        _buildManagementCard(
          context,
          'Manage Products',
          Icons.inventory,
          Colors.blue[700]!,
          () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ManageProductsPage()),
          ),
        ),
        _buildManagementCard(
          context,
          'Manage Bookings',
          Icons.calendar_month,
          Colors.green[700]!,
          () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ManageBookingsPage()),
          ),
        ),
        _buildManagementCard(
          context,
          'Manage Users',
          Icons.people,
          Colors.orange[700]!,
          () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ManageUsersPage()),
          ),
        ),
        _buildManagementCard(
          context,
          'Manage Orders',
          Icons.shopping_cart,
          Colors.purple[700]!,
          () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ManageOrdersPage()),
          ),
        ),
      ],
    );
  }

  Widget _buildManagementCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                color: color,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
