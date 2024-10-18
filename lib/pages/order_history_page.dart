import 'package:flutter/material.dart';

class OrderHistoryPage extends StatelessWidget {
  final List<Map<String, dynamic>> mockOrders = [
    {'id': 'Order 1', 'date': '12 Oct 2024', 'total': 99.99},
    {'id': 'Order 2', 'date': '10 Oct 2024', 'total': 59.49},
    {'id': 'Order 3', 'date': '8 Oct 2024', 'total': 120.00},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Order History'),
        backgroundColor: Colors.blue[800],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: mockOrders.length,
          itemBuilder: (context, index) {
            final order = mockOrders[index];
            return Card(
              margin: EdgeInsets.symmetric(vertical: 10.0),
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.receipt_long, color: Colors.blue[800]),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            order['id'],
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Placed on ${order['date']}',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '\R${order['total'].toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[800],
                          ),
                        ),
                        SizedBox(height: 6),
                        TextButton(
                          onPressed: () {
                            // Handle view order details or reorder
                          },
                          child: Text('View Details'),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.blue[800],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
