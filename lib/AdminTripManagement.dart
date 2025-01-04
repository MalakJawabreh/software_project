import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:flutter_calendar_carousel/flutter_calendar_carousel.dart';
import 'package:flutter_calendar_carousel/classes/event.dart';
import 'config.dart';

class AdminTripManagementPage extends StatefulWidget {
  @override
  _AdminTripManagementPageState createState() =>
      _AdminTripManagementPageState();
}

class _AdminTripManagementPageState extends State<AdminTripManagementPage> {
  List<dynamic> trips = [];
  List<dynamic> filteredTrips = [];
  bool isLoading = true;
  String errorMessage = '';
  DateTime selectedDate = DateTime.now();
  String searchQuery = '';

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
            filteredTrips = trips;
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
      return DateFormat('dd MMMM yyyy').format(parsedDate);
    } catch (e) {
      return date;
    }
  }

  void filterTripsByDate(DateTime selectedDate) {
    setState(() {
      this.selectedDate = selectedDate;
      filteredTrips = trips.where((trip) {
        DateTime tripDate = DateTime.parse(trip['date']);
        return tripDate.year == selectedDate.year &&
            tripDate.month == selectedDate.month &&
            tripDate.day == selectedDate.day;
      }).toList();
    });
  }

  void filterTripsBySearch(String query) {
    setState(() {
      searchQuery = query;
      filteredTrips = trips.where((trip) {
        final tripDetails = [
          trip['name'],
          trip['driverEmail'],
          trip['phoneNumber'],
          trip['from'],
          trip['to']
        ].join(' ').toLowerCase();
        return tripDetails.contains(query.toLowerCase());
      }).toList();
    });
  }

  void showCalendarDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Container(
            width: 300, // عرض الكاليندر
            height: 300, // ارتفاع الكاليندر
            decoration: BoxDecoration(
              color: Color(0xFFF5F5DC),// خلفية للكاليندر
              borderRadius: BorderRadius.circular(12), // زوايا مستديرة
            ),
            child: CalendarCarousel<Event>(
              onDayPressed: (DateTime date, List<Event> events) {
                filterTripsByDate(date);
                Navigator.pop(context); // إغلاق النافذة عند اختيار التاريخ
              },
              selectedDateTime: selectedDate,
              todayBorderColor: Colors.pinkAccent,
              selectedDayButtonColor: Colors.pinkAccent,
              headerTextStyle: TextStyle(
                color: Colors.black, // النص في الهيدر بالأسود
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              weekdayTextStyle: TextStyle(
                color: Colors.black, // أسماء الأيام بالأسود
                fontWeight: FontWeight.bold,
              ),
              weekendTextStyle: TextStyle(
                color: Colors.redAccent, // أيام عطلة باللون الأحمر
              ),
              daysTextStyle: TextStyle(
                color: Colors.black, // الأرقام باللون الأسود
              ),
              iconColor: Colors.black, // لون الأيقونات (الأسهم) بالأسود
              height: 400, // ارتفاع الكاليندر الداخلي
              // عرض الكاليندر الداخلي
              showOnlyCurrentMonthDate: true,
              todayButtonColor: Colors.transparent,
              todayTextStyle: TextStyle(
                color: Colors.pinkAccent, // اليوم الحالي باللون الوردي
                fontWeight: FontWeight.bold,
              ),
              selectedDayBorderColor: Colors.black, // حدود اليوم المحدد
              selectedDayTextStyle: TextStyle(
                color: Colors.black, // النص داخل اليوم المحدد بالأسود
                fontWeight: FontWeight.bold,
              ),
              prevDaysTextStyle: TextStyle(
                color: Colors.grey, // الأيام السابقة باللون الرمادي
              ),
              nextDaysTextStyle: TextStyle(
                color: Colors.grey, // الأيام اللاحقة باللون الرمادي
              ),
            ),
          ),
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Trip Management'),
        backgroundColor: Colors.black,
        actions: [
          IconButton(
            icon: Icon(Icons.calendar_today, color: Colors.white),
            onPressed: showCalendarDialog,
          ),
        ],
      ),
      backgroundColor: Colors.black,
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: TextField(
              onChanged: (value) => filterTripsBySearch(value),
              decoration: InputDecoration(
                hintText: 'Search by name, email, or phone',
                hintStyle: TextStyle(color: Colors.white60),
                prefixIcon: Icon(Icons.search, color: Colors.white),
                filled: true,
                fillColor: Colors.grey[800],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  borderSide: BorderSide.none,
                ),
              ),
              style: TextStyle(color: Colors.white),
            ),
          ),
          isLoading
              ? Center(child: CircularProgressIndicator(color: Colors.pink))
              : errorMessage.isNotEmpty
              ? Center(
            child: Text(
              errorMessage,
              style: TextStyle(color: Colors.redAccent),
            ),
          )
              : filteredTrips.isEmpty
              ? Center(
            child: Text(
              'No trips available for the selected date.',
              style: TextStyle(color: Colors.white),
            ),
          )
              : Expanded(
            child: ListView.builder(
              itemCount: filteredTrips.length,
              itemBuilder: (context, index) {
                final trip = filteredTrips[index];
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
                        // معلومات الرحلة
                        Text(
                          '${trip['from']} → ${trip['to']}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.pinkAccent,
                          ),
                        ),
                        Divider(color: Colors.pinkAccent),
                        _buildInfoRow('Driver Name:', trip['name']),
                        _buildInfoRow(
                            'Driver Email:', trip['driverEmail']),
                        _buildInfoRow('Phone Number:',
                            trip['phoneNumber']),
                        Divider(color: Colors.pinkAccent),
                        _buildInfoRow('Price:',
                            '${trip['price']}'),
                        _buildInfoRow(
                          'Passengers:',
                          '${trip['currentPassengers']} / ${trip['maxPassengers']}',
                        ),
                        _buildInfoRow(
                            'Date:', formatDate(trip['date'])),
                        _buildInfoRow('Time:', trip['time']),

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
                              onPressed: () => editTrip(trip['id']),
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
                                  deleteTrip(trip['id']),
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
                              onPressed: () =>
                                  changeTripStatus(trip['id']),
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
          ),
        ],
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
        children: [
          Expanded(
            flex: 3,
            child: Text(
              label,
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.pinkAccent),
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
