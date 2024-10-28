// lib/pages/booking_details_page.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/booking.dart';

class BookingDetailsPage extends StatefulWidget {
  final String serviceId;
  final Map<String, dynamic> serviceData;

  const BookingDetailsPage({
    super.key,
    required this.serviceId,
    required this.serviceData,
  });

  @override
  State<BookingDetailsPage> createState() => _BookingDetailPageState();
}

class _BookingDetailPageState extends State<BookingDetailsPage> {
  // State variables
  DateTime? _selectedDate;
  String? _selectedTime;

  // Available time slots
  final List<String> _availableTimes = [
    '09:00',
    '10:00',
    '11:00',
    '14:00',
    '15:00',
    '16:00'
  ];

  // Date picker function
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );

    if (picked != null && mounted) {
      setState(() => _selectedDate = picked);
    }
  }

  // Create booking function
  Future<void> _createBooking() async {
    // Validate date and time selection
    if (_selectedDate == null || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select both date and time')),
      );
      return;
    }

    try {
      // Check if user is authenticated
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please sign in to book a session')),
        );
        return;
      }

      // Get user data
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      final userData = userDoc.data() as Map<String, dynamic>;

      // Parse duration and price
      final duration = (widget.serviceData['duration'] is int)
          ? (widget.serviceData['duration'] as int).toDouble()
          : (widget.serviceData['duration'] as num?)?.toDouble() ?? 1.0;

      final price = (widget.serviceData['price'] is int)
          ? (widget.serviceData['price'] as int).toDouble()
          : (widget.serviceData['price'] as num?)?.toDouble() ?? 0.0;

      // Create booking object
      final booking = Booking(
        id: '',
        userId: user.uid,
        userName: userData['name'] ?? '',
        serviceType: widget.serviceData['title'] ?? '',
        dateTime: DateTime(
          _selectedDate!.year,
          _selectedDate!.month,
          _selectedDate!.day,
          int.parse(_selectedTime!.split(':')[0]),
          0,
        ),
        duration: duration,
        price: price,
      );

      // Save booking to Firestore
      await FirebaseFirestore.instance
          .collection('bookings')
          .add(booking.toFirestore());

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Booking created successfully')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error creating booking: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue[800],
        title: Text(widget.serviceData['title'] ?? ''),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Service title
            Text(
              widget.serviceData['title'] ?? '',
              style: const TextStyle(
                fontSize: 28.0,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8.0),

            // Location
            Row(
              children: [
                Icon(Icons.location_on, color: Colors.blue[800]),
                const SizedBox(width: 8),
                Text(
                  widget.serviceData['location'] ?? '',
                  style: TextStyle(fontSize: 18.0, color: Colors.grey[700]),
                ),
              ],
            ),
            const SizedBox(height: 16.0),

            // Price
            Text(
              'R${(widget.serviceData['price'] ?? 0.0).toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 22.0,
                color: Colors.green[700],
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16.0),

            // Description section
            const Text(
              'Description',
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8.0),
            Text(
              widget.serviceData['description'] ?? '',
              style: TextStyle(fontSize: 16.0, color: Colors.grey[700]),
            ),
            const SizedBox(height: 24.0),

            // Date and time selection
            const Text(
              'Select Date and Time',
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16.0),

            // Date picker button
            OutlinedButton.icon(
              onPressed: () => _selectDate(context),
              icon: const Icon(Icons.calendar_today),
              label: Text(
                _selectedDate == null
                    ? 'Select Date'
                    : 'Date: ${_selectedDate.toString().substring(0, 10)}',
              ),
            ),
            const SizedBox(height: 16.0),

            // Time selection chips
            if (_selectedDate != null) ...[
              const Text(
                'Available Times',
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8.0),
              Wrap(
                spacing: 8.0,
                children: _availableTimes.map((time) {
                  return ChoiceChip(
                    label: Text(time),
                    selected: _selectedTime == time,
                    onSelected: (selected) {
                      setState(() {
                        _selectedTime = selected ? time : null;
                      });
                    },
                  );
                }).toList(),
              ),
            ],
            const SizedBox(height: 24.0),

            // Book now button
            ElevatedButton(
              onPressed: _createBooking,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[800],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text('Book Now'),
            ),
          ],
        ),
      ),
    );
  }
}
