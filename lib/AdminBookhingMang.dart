import 'package:flutter/material.dart';
import 'package:flutter_calendar_carousel/flutter_calendar_carousel.dart'; // مكتبة التقويم
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'config.dart';

class BookingsPage extends StatefulWidget {
  @override
  _BookingsPageState createState() => _BookingsPageState();
}

class _BookingsPageState extends State<BookingsPage> {
  List<dynamic> bookings = [];
  List<dynamic> filteredBookings = [];
  bool isLoading = true;
  String errorMessage = '';
  TextEditingController searchController = TextEditingController();
  DateTime? selectedDate; // تخزين التاريخ المحدد من التقويم

  @override
  void initState() {
    super.initState();
    fetchBookings();
  }

  Future<void> fetchBookings() async {
    try {
      final response = await http.get(Uri.parse(get_booking_trip));
      if (response.statusCode == 200) {
        setState(() {
          bookings = json.decode(response.body);
          filteredBookings = bookings;
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Failed to load bookings.';
          isLoading = false;
        });
      }
    } catch (error) {
      setState(() {
        errorMessage = 'Error: $error';
        isLoading = false;
      });
    }
  }

  String formatDate(String dateStr) {
    DateTime date = DateTime.parse(dateStr);
    return DateFormat('yyyy-MM-dd HH:mm').format(date);
  }

  void searchBookings(String query) {
    final filtered = bookings.where((booking) {
      final nameP = booking['nameP'].toLowerCase();
      final nameD = booking['nameD'].toLowerCase();
      final from = booking['from'].toLowerCase();
      final to = booking['to'].toLowerCase();
      return nameP.contains(query.toLowerCase()) ||
          nameD.contains(query.toLowerCase()) ||
          from.contains(query.toLowerCase()) ||
          to.contains(query.toLowerCase());
    }).toList();

    setState(() {
      filteredBookings = filtered;
    });
  }

  void filterBookingsByDate(DateTime date) {
    final filtered = bookings.where((booking) {
      final bookingDate = DateTime.parse(booking['date']);
      return bookingDate.year == date.year &&
          bookingDate.month == date.month &&
          bookingDate.day == date.day;
    }).toList();

    setState(() {
      filteredBookings = filtered;
    });
  }

  void showCalendarDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              color: Color(0xFFF5F5DC),// خلفية للكاليندر

              borderRadius: BorderRadius.circular(12), // زوايا مستديرة
            ),
            child: CalendarCarousel(
              onDayPressed: (DateTime date, _) {
                filterBookingsByDate(date); // تصفية الحجوزات
                Navigator.pop(context); // إغلاق النافذة
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

  Future<void> cancelBooking(String bookingId) async {
    try {
      final response = await http.delete(
        Uri.parse('$get_booking_trip/$bookingId'),
      );
      if (response.statusCode == 200) {
        setState(() {
          bookings.removeWhere((booking) => booking['_id'] == bookingId);
          filteredBookings.removeWhere((booking) => booking['_id'] == bookingId);
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Booking cancelled successfully')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to cancel booking')));
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $error')));
    }
  }

  Future<void> editBooking(String bookingId) async {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Edit feature coming soon')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('All Bookings'),
        actions: [
          IconButton(
            icon: Icon(Icons.calendar_today, color: Colors.white),
            onPressed: showCalendarDialog, // فتح التقويم عند النقر
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Container(
              width: 250,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 1,
                    blurRadius: 3,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: TextField(
                controller: searchController,
                onChanged: searchBookings,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.search, color: Colors.deepPurple),
                  hintText: 'Search by name or location...',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 8),
                ),
              ),
            ),
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
          ? Center(child: Text(errorMessage))
          : ListView.builder(
        itemCount: filteredBookings.length,
        itemBuilder: (context, index) {
          final booking = filteredBookings[index];
          return Card(
            margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            elevation: 5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ExpansionTile(
                title: Text(
                  'Passenger: ${booking['nameP']}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                ),
                leading: Icon(Icons.account_circle, color: Colors.deepPurple),
                trailing: Icon(Icons.expand_more),
                children: [
                  _buildDetailRow('Driver: ${booking['nameD']}', Colors.blue),
                  _buildDetailRow('Passenger Email: ${booking['EmailP']}', Colors.green),
                  _buildDetailRow('Driver Email: ${booking['EmailD']}', Colors.green),
                  _buildDetailRow('From: ${booking['from']}', Colors.orange),
                  _buildDetailRow('To: ${booking['to']}', Colors.orange),
                  _buildDetailRow('Price: \$${booking['price']}', Colors.red, isPrice: true),
                  _buildDetailRow('Seats: ${booking['seat']}', Colors.purple),
                  _buildDetailRow('Car Brand: ${booking['carBrand'] ?? 'N/A'}', Colors.brown),
                  _buildDetailRow('Note: ${booking['Note'] ?? 'N/A'}', Colors.grey),
                  _buildDetailRow('Date: ${formatDate(booking['date'])}', Colors.blueAccent),
                  _buildDetailRow('Time: ${booking['time']}', Colors.blueAccent),
                  _buildDetailRow('Driver Rating: ${booking['driverRate'] ?? 'N/A'}', Colors.yellow),
                  _buildDetailRow('Note Rate: ${booking['NoteRate'] ?? 'N/A'}', Colors.yellow),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () => cancelBooking(booking['_id']),
                        child: Text('Cancel'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      SizedBox(width: 20),
                      ElevatedButton(
                        onPressed: () => editBooking(booking['_id']),
                        child: Text('Edit'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
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

  Widget _buildDetailRow(String value, Color color, {bool isPrice = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Icon(Icons.arrow_right, color: color),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 16,
                color: isPrice ? Colors.redAccent : color,
                fontWeight: isPrice ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
