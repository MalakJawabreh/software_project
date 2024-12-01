import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class UpcomingTripsPage extends StatelessWidget {
  final List<dynamic> upcomingTrips;

  UpcomingTripsPage({required this.upcomingTrips});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Upcoming Trips'),
      ),
      body: ListView.builder(
        itemCount: upcomingTrips.length,
        itemBuilder: (context, index) {
          final trip = upcomingTrips[index];

          // افترض أن الرحلة تحتوي على "price" و "from" و "date" و "time"
          final price = trip['price'];   // الوصول إلى السعر
          final fromLocation = trip['from'];  // الوصول إلى نقطة الانطلاق
          final toLocation = trip['to'];    // الوصول إلى نقطة الوصول
          final date = trip['date'];   // تاريخ الرحلة
          final time = trip['time'];   // وقت الرحلة

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
                    'To: $toLocation',  // عرض مكان الوصول
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Date: $date',  // عرض تاريخ الرحلة
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Time: $time',  // عرض وقت الرحلة
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
