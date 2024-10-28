// lib/pages/admin/admin_home_page.dart

import 'package:flutter/material.dart';
import 'manage_products_page.dart';
import 'manage_orders_page.dart';
import 'manage_users_page.dart';
import 'manage_bookings_page.dart';
import '../../service/admin_service.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  final AdminService _adminService = AdminService();
  Map<String, int> _stats = {
    'products': 0,
    'orders': 0,
    'users': 0,
    'bookings': 0,
  };

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final stats = await _adminService.getDashboardStats();
    setState(() {
      _stats = stats;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: Colors.blue[800],
      ),
      body: RefreshIndicator(
        onRefresh: _loadStats,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Dashboard Overview',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 20),
              _buildStatsGrid(),
              const SizedBox(height: 30),
              Text(
                'Quick Actions',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 20),
              _buildActionGrid(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsGrid() {
    return GridView.count(
      shrinkWrap: true,
      crossAxisCount: 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _buildStatCard(
          'Products',
          _stats['products'].toString(),
          Icons.inventory,
          Colors.blue[700]!,
        ),
        _buildStatCard(
          'Orders',
          _stats['orders'].toString(),
          Icons.shopping_cart,
          Colors.green[700]!,
        ),
        _buildStatCard(
          'Users',
          _stats['users'].toString(),
          Icons.people,
          Colors.orange[700]!,
        ),
        _buildStatCard(
          'Bookings',
          _stats['bookings'].toString(),
          Icons.calendar_today,
          Colors.purple[700]!,
        ),
      ],
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color),
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
      ),
    );
  }

  Widget _buildActionGrid() {
    return GridView.count(
      shrinkWrap: true,
      crossAxisCount: 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _buildActionCard(
          'Manage Products',
          Icons.inventory_2,
          Colors.blue[700]!,
          () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ManageProductsPage(),
            ),
          ),
        ),
        _buildActionCard(
          'Manage Orders',
          Icons.shopping_cart_checkout,
          Colors.green[700]!,
          () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ManageOrdersPage(),
            ),
          ),
        ),
        _buildActionCard(
          'Manage Users',
          Icons.people,
          Colors.orange[700]!,
          () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ManageUsersPage(),
            ),
          ),
        ),
        _buildActionCard(
          'Manage Bookings',
          Icons.calendar_month,
          Colors.purple[700]!,
          () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ManageBookingsPage(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionCard(
      String title, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 32, color: color),
              const SizedBox(height: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
