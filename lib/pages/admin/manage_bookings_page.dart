// lib/pages/admin/manage_bookings_page.dart
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
  String _selectedStatus = 'all';
  DateTime? _selectedDate;

  Future<void> _showBookingDetailsDialog(Booking booking) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Booking #${booking.id.substring(0, 8)}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('Client'),
                subtitle: Text(booking.userName),
              ),
              ListTile(
                title: const Text('Service'),
                subtitle: Text(booking.serviceType),
              ),
              ListTile(
                title: const Text('Date & Time'),
                subtitle: Text(booking.dateTime.toString()),
              ),
              ListTile(
                title: const Text('Duration'),
                subtitle: Text('${booking.duration} hours'),
              ),
              ListTile(
                title: const Text('Price'),
                subtitle: Text('R${booking.price.toStringAsFixed(2)}'),
              ),
              if (booking.trainerName.isNotEmpty)
                ListTile(
                  title: const Text('Trainer'),
                  subtitle: Text(booking.trainerName),
                ),
              ListTile(
                title: const Text('Status'),
                subtitle: Text(booking.status),
              ),
              if (booking.notes.isNotEmpty)
                ListTile(
                  title: const Text('Notes'),
                  subtitle: Text(booking.notes),
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
            onPressed: () async {
              // Show edit dialog
              await _showEditBookingDialog(booking);
              Navigator.pop(context);
            },
            child: const Text('Edit'),
          ),
        ],
      ),
    );
  }

  Future<void> _showEditBookingDialog(Booking booking) async {
    final notesController = TextEditingController(text: booking.notes);
    final statusOptions = ['pending', 'confirmed', 'completed', 'cancelled'];

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Booking'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: booking.status,
                decoration: const InputDecoration(labelText: 'Status'),
                items: statusOptions.map((status) {
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
              ),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Bookings'),
        actions: [
          // Filter by status
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            onSelected: (value) {
              setState(() {
                _selectedStatus = value;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'all',
                child: Text('All Statuses'),
              ),
              const PopupMenuItem(
                value: 'pending',
                child: Text('Pending'),
              ),
              const PopupMenuItem(
                value: 'confirmed',
                child: Text('Confirmed'),
              ),
              const PopupMenuItem(
                value: 'completed',
                child: Text('Completed'),
              ),
              const PopupMenuItem(
                value: 'cancelled',
                child: Text('Cancelled'),
              ),
            ],
          ),
          // Date picker
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _selectedDate ?? DateTime.now(),
                firstDate: DateTime(2023),
                lastDate: DateTime(2025),
              );
              if (picked != null) {
                setState(() {
                  _selectedDate = picked;
                });
              }
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _adminService.getBookings(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          var bookings = snapshot.data!.docs.map((doc) {
            return Booking.fromFirestore(doc);
          }).toList();

          // Apply filters
          if (_selectedStatus != 'all') {
            bookings = bookings
                .where((booking) => booking.status == _selectedStatus)
                .toList();
          }

          if (_selectedDate != null) {
            bookings = bookings.where((booking) {
              return booking.dateTime.year == _selectedDate!.year &&
                  booking.dateTime.month == _selectedDate!.month &&
                  booking.dateTime.day == _selectedDate!.day;
            }).toList();
          }

          // Sort by date
          bookings.sort((a, b) => b.dateTime.compareTo(a.dateTime));

          if (bookings.isEmpty) {
            return const Center(
              child: Text('No bookings found'),
            );
          }

          return ListView.builder(
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              final booking = bookings[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  onTap: () => _showBookingDetailsDialog(booking),
                  title: Text('${booking.serviceType} - ${booking.userName}'),
                  subtitle: Text(
                    '${booking.dateTime.toString().substring(0, 16)}\n'
                    'Status: ${booking.status.toUpperCase()}',
                  ),
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) async {
                      if (value == 'delete') {
                        // Show confirmation dialog
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Confirm Delete'),
                            content: const Text(
                                'Are you sure you want to delete this booking?'),
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

                        if (confirm == true) {
                          await _adminService.deleteBooking(booking.id);
                        }
                      } else {
                        await _adminService.updateBookingStatus(
                            booking.id, value);
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'confirmed',
                        child: Text('Mark as Confirmed'),
                      ),
                      const PopupMenuItem(
                        value: 'completed',
                        child: Text('Mark as Completed'),
                      ),
                      const PopupMenuItem(
                        value: 'cancelled',
                        child: Text('Mark as Cancelled'),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Text('Delete Booking'),
                      ),
                    ],
                  ),
                  isThreeLine: true,
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Implement add new booking
          // You might want to create a separate dialog/form for this
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
