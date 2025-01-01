import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart'; // مكتبة لتنسيق التاريخ
import 'config.dart';

class AdminTripManagementPage extends StatefulWidget {
  @override
  _AdminTripManagementPageState createState() =>
      _AdminTripManagementPageState();
}

class _AdminTripManagementPageState extends State<AdminTripManagementPage> {
  List<dynamic> trips = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchAllTrips();
  }

  Future<void> fetchAllTrips() async {
    try {
      final response = await http.get(Uri.parse(all_trip));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == true) {
          setState(() {
            trips = data['trips'];
            isLoading = false;
          });
        } else {
          setState(() {
            errorMessage = 'Failed to fetch trips.';
            isLoading = false;
          });
        }
      } else {
        setState(() {
          errorMessage = 'Server error: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'An error occurred: $e';
        isLoading = false;
      });
    }
  }

  String formatDate(String date) {
    try {
      final parsedDate = DateTime.parse(date);
      return DateFormat('dd MMMM yyyy').format(parsedDate); // تنسيق "15 يناير 2025"
    } catch (e) {
      return date; // إذا فشل التنسيق، أعد النص الأصلي
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Trip Management'),
        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.black,
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: Colors.pink))
          : errorMessage.isNotEmpty
          ? Center(
        child: Text(
          errorMessage,
          style: TextStyle(color: Colors.redAccent),
        ),
      )
          : trips.isEmpty
          ? Center(
        child: Text(
          'No trips available.',
          style: TextStyle(color: Colors.white),
        ),
      )
          : ListView.builder(
        itemCount: trips.length,
        itemBuilder: (context, index) {
          final trip = trips[index];
          return Card(
            margin: EdgeInsets.symmetric(
                vertical: 8.0, horizontal: 16.0),
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            color: Colors.grey[900],
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // عنوان الرحلة
                  Text(
                    '${trip['from']} → ${trip['to']}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.pinkAccent,
                    ),
                  ),
                  Divider(color: Colors.pinkAccent),
                  // معلومات السائق
                  _buildInfoRow('Driver Name:', trip['name']),
                  _buildInfoRow(
                      'Driver Email:', trip['driverEmail']),
                  _buildInfoRow(
                      'Phone Number:', trip['phoneNumber']),
                  Divider(color: Colors.pinkAccent),
                  // معلومات الرحلة
                  _buildInfoRow('Price:', '${trip['price']}'),
                  _buildInfoRow(
                    'Passengers:',
                    '${trip['currentPassengers']} / ${trip['maxPassengers']}',
                  ),
                  _buildInfoRow('Date:', formatDate(trip['date'])),
                  _buildInfoRow('Time:', trip['time']),
                  if (trip['carBrand'] != null)
                    _buildInfoRow(
                        'Car Brand:', trip['carBrand']),
                  if (trip['driverRating'] != null)
                    _buildInfoRow(
                      'Driver Rating:',
                      '${trip['driverRating']} / 5',
                    ),
                  Divider(color: Colors.pinkAccent),
                  // حالة الرحلة
                  Text(
                    'Status: ${trip['status_trip']}',
                    style: TextStyle(
                      color: trip['status_trip'] == 'upcoming'
                          ? Colors.green
                          : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  // أزرار الصلاحيات
                  Wrap(
                    spacing: 10.0,
                    runSpacing: 10.0,
                    alignment: WrapAlignment.center,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () =>
                            editTrip(trip['id']), // تعديل الرحلة
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                              horizontal: 20, vertical: 12),
                          backgroundColor: Colors.blue,
                          shape: RoundedRectangleBorder(
                            borderRadius:
                            BorderRadius.circular(30.0),
                          ),
                          elevation: 5,
                        ),
                        icon: Icon(Icons.edit,
                            color: Colors.white),
                        label: Text(
                          'Edit',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () =>
                            deleteTrip(trip['id']), // حذف الرحلة
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                              horizontal: 20, vertical: 12),
                          backgroundColor: Colors.red,
                          shape: RoundedRectangleBorder(
                            borderRadius:
                            BorderRadius.circular(30.0),
                          ),
                          elevation: 5,
                        ),
                        icon: Icon(Icons.delete,
                            color: Colors.white),
                        label: Text(
                          'Delete',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () => changeTripStatus(
                            trip['id']), // تغيير الحالة
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                              horizontal: 20, vertical: 12),
                          backgroundColor: Colors.green,
                          shape: RoundedRectangleBorder(
                            borderRadius:
                            BorderRadius.circular(30.0),
                          ),
                          elevation: 5,
                        ),
                        icon: Icon(Icons.sync,
                            color: Colors.white),
                        label: Text(
                          'Change Status',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
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
    );
  }

  void editTrip(String tripId) {
    // فتح صفحة تعديل الرحلة
   /* Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditTripPage(tripId: tripId),
      ),
    );*/
  }

  Future<void> deleteTrip(String tripId) async {
    try {
      final response = await http.delete(Uri.parse('$delete_trip/$tripId'));
      if (response.statusCode == 200) {
        setState(() {
          trips.removeWhere((trip) => trip['id'] == tripId);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Trip deleted successfully!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete trip.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e')),
      );
    }
  }
  Future<void> changeTripStatus(String tripId) async {/*
    try {
      final response = await http.put(
        Uri.parse('$change_status/$tripId'),
        body: jsonEncode({'status': 'Completed'}), // أو Active أو Canceled
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        setState(() {
          trips = trips.map((trip) {
            if (trip['id'] == tripId) {
              trip['status_trip'] = 'Completed'; // تحديث الحالة
            }
            return trip;
          }).toList();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Trip status updated successfully!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update trip status.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e')),
      );
    }*/
  }


  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Text(
              label,
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.pinkAccent),
            ),
          ),
          Expanded(
            flex: 5,
            child: Text(
              value,
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
