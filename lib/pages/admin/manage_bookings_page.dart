// lib/pages/admin/manage_bookings_page.dart

// An admin interface for managing service bookings with features

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/booking.dart';
import '../../service/admin_service.dart';

class ManageBookingsPage extends StatefulWidget {
  const ManageBookingsPage({super.key});

  @override
  State<ManageBookingsPage> createState() => _ManageBookingsPageState();
}

class _ManageBookingsPageState extends State<ManageBookingsPage> {
  final AdminService _adminService = AdminService();

  // Filter states
  String _selectedStatus = 'all';
  DateTime? _selectedDate;

  // Status options for dropdowns
  static const List<String> _statusOptions = [
    'pending',
    'confirmed',
    'completed',
    'cancelled'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildBookingsList(),
      floatingActionButton: _buildAddButton(),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: const Text('Manage Bookings'),
      actions: [
        _buildStatusFilter(),
        _buildDateFilter(),
      ],
    );
  }

  Widget _buildStatusFilter() {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.filter_list),
      onSelected: (value) => setState(() => _selectedStatus = value),
      itemBuilder: (context) => [
        const PopupMenuItem(value: 'all', child: Text('All Statuses')),
        ..._statusOptions.map((status) => PopupMenuItem(
              value: status,
              child: Text(status.toUpperCase()),
            )),
      ],
    );
  }

  Widget _buildDateFilter() {
    return IconButton(
      icon: const Icon(Icons.calendar_today),
      onPressed: () => _selectDate(context),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2023),
      lastDate: DateTime(2025),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Widget _buildBookingsList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _adminService.getBookings(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final bookings = _filterBookings(snapshot.data!.docs);

        if (bookings.isEmpty) {
          return const Center(child: Text('No bookings found'));
        }

        return ListView.builder(
          itemCount: bookings.length,
          itemBuilder: (context, index) => _buildBookingCard(bookings[index]),
        );
      },
    );
  }

  List<Booking> _filterBookings(List<QueryDocumentSnapshot> docs) {
    var bookings = docs.map((doc) => Booking.fromFirestore(doc)).toList()
      ..sort((a, b) => b.dateTime.compareTo(a.dateTime));

    if (_selectedStatus != 'all') {
      bookings = bookings.where((b) => b.status == _selectedStatus).toList();
    }

    if (_selectedDate != null) {
      bookings = bookings
          .where((b) => _isSameDay(b.dateTime, _selectedDate!))
          .toList();
    }

    return bookings;
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  Widget _buildBookingCard(Booking booking) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        onTap: () => _showBookingDetailsDialog(booking),
        title: Text('${booking.serviceType} - ${booking.userName}'),
        subtitle: Text(
          '${booking.dateTime.toString().substring(0, 16)}\n'
          'Status: ${booking.status.toUpperCase()}',
        ),
        trailing: _buildBookingActions(booking),
        isThreeLine: true,
      ),
    );
  }

  Widget _buildBookingActions(Booking booking) {
    return PopupMenuButton<String>(
      onSelected: (value) => _handleBookingAction(booking, value),
      itemBuilder: (context) => [
        ..._statusOptions.map((status) => PopupMenuItem(
              value: status,
              child: Text('Mark as ${status.toUpperCase()}'),
            )),
        const PopupMenuItem(
          value: 'delete',
          child: Text('Delete Booking'),
        ),
      ],
    );
  }

  Future<void> _handleBookingAction(Booking booking, String action) async {
    if (action == 'delete') {
      final confirm = await _showDeleteConfirmation();
      if (confirm == true) {
        await _adminService.deleteBooking(booking.id);
      }
    } else {
      await _adminService.updateBookingStatus(booking.id, action);
    }
  }

  Future<bool?> _showDeleteConfirmation() {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('Are you sure you want to delete this booking?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _showBookingDetailsDialog(Booking booking) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Booking #${booking.id.substring(0, 8)}'),
        content: SingleChildScrollView(
          child: _buildBookingDetails(booking),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          TextButton(
            onPressed: () async {
              await _showEditBookingDialog(booking);
              Navigator.pop(context);
            },
            child: const Text('Edit'),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingDetails(Booking booking) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildDetailTile('Client', booking.userName),
        _buildDetailTile('Service', booking.serviceType),
        _buildDetailTile('Date & Time', booking.dateTime.toString()),
        _buildDetailTile('Duration', '${booking.duration} hours'),
        _buildDetailTile('Price', 'R${booking.price.toStringAsFixed(2)}'),
        if (booking.trainerName.isNotEmpty)
          _buildDetailTile('Trainer', booking.trainerName),
        _buildDetailTile('Status', booking.status),
        if (booking.notes.isNotEmpty) _buildDetailTile('Notes', booking.notes),
      ],
    );
  }

  Widget _buildDetailTile(String title, String subtitle) {
    return ListTile(
      title: Text(title),
      subtitle: Text(subtitle),
    );
  }

  Future<void> _showEditBookingDialog(Booking booking) async {
    final notesController = TextEditingController(text: booking.notes);

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Booking'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildStatusDropdown(booking),
              TextField(
                controller: notesController,
                decoration: const InputDecoration(labelText: 'Notes'),
                maxLines: 3,
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
              await _adminService.updateBookingNotes(
                  booking.id, notesController.text);
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusDropdown(Booking booking) {
    return DropdownButtonFormField<String>(
      value: booking.status,
      decoration: const InputDecoration(labelText: 'Status'),
      items: _statusOptions.map((status) {
        return DropdownMenuItem(
          value: status,
          child: Text(status.toUpperCase()),
        );
      }).toList(),
      onChanged: (value) async {
        if (value != null) {
          await _adminService.updateBookingStatus(booking.id, value);
        }
      },
    );
  }

  Widget _buildAddButton() {
    return FloatingActionButton(
      onPressed: () {
        // TODO: Implement add new booking functionality
      },
      child: const Icon(Icons.add),
    );
  }
}
