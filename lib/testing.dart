import 'package:flutter/material.dart';

class TravelCard extends StatefulWidget {
  final String destination;
  final double budget;
  final int duration;
  final int travelers;

  const TravelCard({
    Key? key,
    required this.destination,
    required this.budget,
    required this.duration,
    required this.travelers,
  }) : super(key: key);

  @override
  State<TravelCard> createState() => _TravelCardState();
}

class _TravelCardState extends State<TravelCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 5,
      margin: EdgeInsets.all(16),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.destination,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Icon(Icons.location_on, color: Colors.blueAccent),
              ],
            ),
            SizedBox(height: 10),
            Divider(),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildInfoTile(Icons.attach_money, 'Budget', '\$${widget.budget.toStringAsFixed(2)}'),
                _buildInfoTile(Icons.calendar_today, 'Duration', '${widget.duration} Days'),
              ],
            ),
            SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildInfoTile(Icons.group, 'Travelers', '${widget.travelers} People'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.blueAccent),
        SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(fontWeight: FontWeight.w500, color: Colors.grey)),
            Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
      ],
    );
  }
}

class TravelPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Travel Plan')),
      body: Center(
        child: TravelCard(
          destination: 'Paris, France',
          budget: 2000,
          duration: 7,
          travelers: 2,
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: TravelPage(),
  ));
}
