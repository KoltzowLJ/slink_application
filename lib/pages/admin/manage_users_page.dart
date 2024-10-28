// lib/pages/admin/manage_users_page.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/user.dart';
import '../../service/admin_service.dart';

class ManageUsersPage extends StatefulWidget {
  const ManageUsersPage({super.key});

  @override
  State<ManageUsersPage> createState() => _ManageUsersPageState();
}

class _ManageUsersPageState extends State<ManageUsersPage> {
  final AdminService _adminService = AdminService();
  String _searchQuery = '';
  String _filterType = 'all'; // all, admin, user
  bool _showInactiveUsers = false;

  Future<void> _showUserDetailsDialog(UserModel user) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(user.name),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.email),
                title: const Text('Email'),
                subtitle: Text(user.email),
              ),
              ListTile(
                leading: const Icon(Icons.admin_panel_settings),
                title: const Text('Role'),
                subtitle: Text(user.isAdmin ? 'Admin' : 'User'),
              ),
              ListTile(
                leading: const Icon(Icons.stars),
                title: const Text('Loyalty Points'),
                subtitle: Text(user.loyaltyPoints.toString()),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          TextButton(
            onPressed: () => _showEditUserDialog(user),
            child: const Text('Edit'),
          ),
        ],
      ),
    );
  }

  Future<void> _showEditUserDialog(UserModel user) async {
    final nameController = TextEditingController(text: user.name);
    final pointsController =
        TextEditingController(text: user.loyaltyPoints.toString());
    bool isAdmin = user.isAdmin;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Edit User'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: pointsController,
                  decoration:
                      const InputDecoration(labelText: 'Loyalty Points'),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  title: const Text('Admin Access'),
                  value: isAdmin,
                  onChanged: (value) {
                    setState(() {
                      isAdmin = value;
                    });
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                try {
                  await _adminService.updateUser(
                    user.uid,
                    {
                      'name': nameController.text,
                      'loyaltyPoints': int.parse(pointsController.text),
                      'isAdmin': isAdmin,
                    },
                  );
                  if (mounted) {
                    Navigator.pop(context);
                    _showSnackBar('User updated successfully');
                  }
                } catch (e) {
                  _showSnackBar('Error updating user: $e', isError: true);
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showActionDialog(UserModel user) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Manage ${user.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.password),
              title: const Text('Reset Password'),
              onTap: () async {
                Navigator.pop(context);
                await _resetUserPassword(user);
              },
            ),
            ListTile(
              leading: Icon(
                user.isAdmin
                    ? Icons.remove_moderator
                    : Icons.admin_panel_settings,
              ),
              title: Text(
                user.isAdmin ? 'Remove Admin Access' : 'Make Admin',
              ),
              onTap: () async {
                Navigator.pop(context);
                await _toggleAdminStatus(user);
              },
            ),
            ListTile(
              leading: const Icon(Icons.block, color: Colors.red),
              title: const Text('Disable Account'),
              onTap: () async {
                Navigator.pop(context);
                await _disableUserAccount(user);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_forever, color: Colors.red),
              title: const Text('Delete Account'),
              onTap: () async {
                Navigator.pop(context);
                await _deleteUser(user);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _resetUserPassword(UserModel user) async {
    try {
      await _adminService.sendPasswordResetEmail(user.email);
      _showSnackBar('Password reset email sent to ${user.email}');
    } catch (e) {
      _showSnackBar('Error sending password reset email: $e', isError: true);
    }
  }

  Future<void> _toggleAdminStatus(UserModel user) async {
    final bool newStatus = !user.isAdmin;
    try {
      await _adminService.updateUser(user.uid, {'isAdmin': newStatus});
      _showSnackBar(
          '${user.name} is ${newStatus ? 'now' : 'no longer'} an admin');
    } catch (e) {
      _showSnackBar('Error updating admin status: $e', isError: true);
    }
  }

  Future<void> _disableUserAccount(UserModel user) async {
    // Show confirmation dialog
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Disable Account'),
        content:
            Text('Are you sure you want to disable ${user.name}\'s account?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Disable'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _adminService.disableUser(user.uid);
        _showSnackBar('Account disabled successfully');
      } catch (e) {
        _showSnackBar('Error disabling account: $e', isError: true);
      }
    }
  }

  Future<void> _deleteUser(UserModel user) async {
    // Show confirmation dialog
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text(
            'Are you sure you want to permanently delete ${user.name}\'s account? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _adminService.deleteUser(user.uid);
        _showSnackBar('User deleted successfully');
      } catch (e) {
        _showSnackBar('Error deleting user: $e', isError: true);
      }
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Users'),
        actions: [
          // Search
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Search Users'),
                  content: TextField(
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                    decoration: const InputDecoration(
                      hintText: 'Search by name or email',
                      prefixIcon: Icon(Icons.search),
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _searchQuery = '';
                        });
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
            },
          ),
          // Filter
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            onSelected: (value) {
              setState(() {
                _filterType = value;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'all', child: Text('All Users')),
              const PopupMenuItem(value: 'admin', child: Text('Admins Only')),
              const PopupMenuItem(value: 'user', child: Text('Regular Users')),
            ],
          ),
          // Show/Hide inactive users
          IconButton(
            icon: Icon(
                _showInactiveUsers ? Icons.visibility_off : Icons.visibility),
            onPressed: () {
              setState(() {
                _showInactiveUsers = !_showInactiveUsers;
              });
            },
            tooltip: _showInactiveUsers
                ? 'Hide inactive users'
                : 'Show inactive users',
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _adminService.getUsers(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          var users = snapshot.data!.docs.map((doc) {
            return UserModel.fromMap(doc.data() as Map<String, dynamic>);
          }).toList();

          // Apply filters
          if (_filterType == 'admin') {
            users = users.where((user) => user.isAdmin).toList();
          } else if (_filterType == 'user') {
            users = users.where((user) => !user.isAdmin).toList();
          }

          if (_searchQuery.isNotEmpty) {
            users = users.where((user) {
              return user.name
                      .toLowerCase()
                      .contains(_searchQuery.toLowerCase()) ||
                  user.email.toLowerCase().contains(_searchQuery.toLowerCase());
            }).toList();
          }

          if (users.isEmpty) {
            return const Center(
              child: Text('No users found'),
            );
          }

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: user.isAdmin ? Colors.blue : Colors.grey,
                    child: Text(
                      user.name[0].toUpperCase(),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  title: Text(user.name),
                  subtitle: Text(
                    '${user.email}\nPoints: ${user.loyaltyPoints}',
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.more_vert),
                    onPressed: () => _showActionDialog(user),
                  ),
                  onTap: () => _showUserDetailsDialog(user),
                  isThreeLine: true,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
