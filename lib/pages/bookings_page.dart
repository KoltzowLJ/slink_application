// lib/pages/bookings_page.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'booking_details_page.dart';

class BookingsPage extends StatelessWidget {
  const BookingsPage({super.key});

  // Helper method to get appropriate icon based on service type
  IconData _getServiceIcon(String type) {
    switch (type.toLowerCase()) {
      case 'personal training':
        return Icons.fitness_center;
      case 'yoga':
        return Icons.self_improvement;
      case 'consultation':
        return Icons.health_and_safety;
      default:
        return Icons.sports;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // App Bar
      appBar: AppBar(
        backgroundColor: Colors.blue[800],
        title: const Text('Available Sessions'),
      ),

      // Body with StreamBuilder for real-time data
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('services')
            .orderBy('title')
            .snapshots(),
        builder: (context, snapshot) {
          // Handle error state
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          // Handle loading state
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final services = snapshot.data!.docs;

          // Main list view of services
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView.builder(
              itemCount: services.length,
              itemBuilder: (context, index) {
                final service = services[index].data() as Map<String, dynamic>;

                // Service card
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 3,
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16.0),
                    // Service icon
                    leading: CircleAvatar(
                      backgroundColor: Colors.blue[800],
                      child: Icon(
                        _getServiceIcon(service['type'] ?? ''),
                        color: Colors.white,
                      ),
                    ),
                    // Service title
                    title: Text(
                      service['title'] ?? '',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    // Service details
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        // Location
                        Text(
                          service['location'] ?? '',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 4),
                        // Price
                        Text(
                          'R${(service['price'] ?? 0.0).toStringAsFixed(2)}',
                          style: TextStyle(
                            color: Colors.green[700],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    trailing:
                        Icon(Icons.chevron_right, color: Colors.blue[800]),
                    // Navigation to booking details
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BookingDetailsPage(
                            serviceId: services[index].id,
                            serviceData: service,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
