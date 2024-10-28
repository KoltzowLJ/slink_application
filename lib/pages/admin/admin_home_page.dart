// lib/pages/admin/admin_home_page.dart

// A dashboard interface for administrators providing overview statistics
// and quick access to management functions.

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

  // Dashboard statistics
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

  /// Fetches latest statistics from the admin service
  Future<void> _loadStats() async {
    final stats = await _adminService.getDashboardStats();
    setState(() => _stats = stats);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: const Text('Admin Dashboard'),
      backgroundColor: Colors.blue[800],
    );
  }

  Widget _buildBody() {
    return RefreshIndicator(
      onRefresh: _loadStats,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Dashboard Overview'),
            const SizedBox(height: 20),
            _buildStatsGrid(),
            const SizedBox(height: 30),
            _buildSectionTitle('Quick Actions'),
            const SizedBox(height: 20),
            _buildActionGrid(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.headlineSmall,
    );
  }

  /// Grid of statistics cards showing current system status
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

  /// Individual statistic card widget
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

  /// Grid of action buttons for navigation
  Widget _buildActionGrid() {
    return GridView.count(
      shrinkWrap: true,
      crossAxisCount: 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      physics: const NeverScrollableScrollPhysics(),
      children: _buildActionCards(),
    );
  }

  /// List of action cards for management functions
  List<Widget> _buildActionCards() {
    return [
      _buildActionCard(
        'Manage Products',
        Icons.inventory_2,
        Colors.blue[700]!,
        () => _navigateTo(const ManageProductsPage()),
      ),
      _buildActionCard(
        'Manage Orders',
        Icons.shopping_cart_checkout,
        Colors.green[700]!,
        () => _navigateTo(const ManageOrdersPage()),
      ),
      _buildActionCard(
        'Manage Users',
        Icons.people,
        Colors.orange[700]!,
        () => _navigateTo(const ManageUsersPage()),
      ),
      _buildActionCard(
        'Manage Bookings',
        Icons.calendar_month,
        Colors.purple[700]!,
        () => _navigateTo(const ManageBookingsPage()),
      ),
    ];
  }

  /// Individual action card widget
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

  /// Helper method for navigation
  void _navigateTo(Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }
}
