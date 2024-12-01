import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'config.dart';

class TestPage extends StatefulWidget {
  @override
  _TestPageState createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  List<dynamic> trips = [];

  @override
  void initState() {
    super.initState();
    fetchTrips();
  }
  // دالة لجلب جميع الرحلات من الخادم
  Future<void> fetchTrips() async {
    try {
      final response = await http.get(Uri.parse(all_trip));

      if (response.statusCode == 200) {
        final List<dynamic> tripList = json.decode(response.body)['trips'];
        setState(() {
          trips = tripList;
        });
      } else {
        // يمكن معالجة الأخطاء هنا
        throw Exception('Failed to load trips');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('All Trips'),
      ),
      body: trips.isEmpty
          ? Center(child: CircularProgressIndicator()) // يعرض مؤشر التحميل إذا كانت الرحلات فارغة
          : ListView.builder(
        itemCount: trips.length,
        itemBuilder: (context, index) {
          final trip = trips[index];
          return ListTile(
            title: Text('Driver: ${trip['name']}'), // عرض اسم السائق
            subtitle: Text('From: ${trip['from']} To: ${trip['to']}'),
            trailing: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('Price: ${trip['price']}'),
                Text('Phone: ${trip['phoneNumber']}'),
                Text('Date: ${trip['date']}'),
              ],
            ),
          );
        },
      ),
    );
  }
}
