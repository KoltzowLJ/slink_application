import 'package:flutter/material.dart';
import '../models/session.dart';

class SessionDetailPage extends StatelessWidget {
  final Session session;

  const SessionDetailPage({super.key, required this.session});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue[800],
        title: Text(session.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              session.title,
              style: const TextStyle(
                fontSize: 28.0,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8.0),
            Row(
              children: [
                Icon(Icons.location_on, color: Colors.blue[800]),
                const SizedBox(width: 8),
                Text(
                  session.location,
                  style: TextStyle(fontSize: 18.0, color: Colors.grey[700]),
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            Text(
              'R${session.price.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 22.0,
                color: Colors.green[700],
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16.0),
            const Text(
              'Description',
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8.0),
            Text(
              session.description,
              style: TextStyle(fontSize: 16.0, color: Colors.grey[700]),
            ),
            const SizedBox(height: 24.0),
            ElevatedButton(
              onPressed: () {
                // Add to cart or proceed with booking logic
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[800],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                minimumSize: const Size(double.infinity, 50),
              ),
              child: Text('Book Now'),
            ),
          ],
        ),
      ),
    );
  }
}
