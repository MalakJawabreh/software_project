import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CompletedTripsPage extends StatelessWidget {
  final List<dynamic> completedTrips;

  CompletedTripsPage({required this.completedTrips});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Completed Trips')),
      body: ListView.builder(
        itemCount: completedTrips.length,
        itemBuilder: (context, index) {
          final trip = completedTrips[index];

          // افترض أن الرحلة تحتوي على "price" و "from"
          final price = trip['price'];   // الوصول إلى السعر
          final fromLocation = trip['from'];  // الوصول إلى نقطة الانطلاق

          return Card(
            elevation: 4,
            margin: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
              side: BorderSide(color: Colors.grey.shade500, width: 1),
            ),
            color: Color.fromARGB(255, 234, 241, 246),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Trip ${index + 1}',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'From: $fromLocation',  // عرض مكان الانطلاق
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Price: \$${price.toString()}',  // عرض السعر
                    style: TextStyle(fontSize: 16, color: Colors.green),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
