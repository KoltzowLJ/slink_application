import 'package:flutter/material.dart';
import '../models/session.dart';

class SessionDetailPage extends StatelessWidget {
  final Session session;

  SessionDetailPage({required this.session});

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
              style: TextStyle(
                fontSize: 28.0,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 8.0),
            Row(
              children: [
                Icon(Icons.location_on, color: Colors.blue[800]),
                SizedBox(width: 8),
                Text(
                  session.location,
                  style: TextStyle(fontSize: 18.0, color: Colors.grey[700]),
                ),
              ],
            ),
            SizedBox(height: 16.0),
            Text(
              '\R${session.price.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 22.0,
                color: Colors.green[700],
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16.0),
            Text(
              'Description',
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8.0),
            Text(
              session.description,
              style: TextStyle(fontSize: 16.0, color: Colors.grey[700]),
            ),
            SizedBox(height: 24.0),
            ElevatedButton(
              onPressed: () {
                // Add to cart or proceed with booking logic
              },
              child: Text('Book Now'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[800],
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                minimumSize: Size(double.infinity, 50),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
