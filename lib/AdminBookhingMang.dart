import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart'; // استيراد مكتبة intl
import 'config.dart'; // استيراد ملف الكونفج

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

  @override
  void initState() {
    super.initState();
    fetchBookings();
  }

  Future<void> fetchBookings() async {
    try {
      final response = await http.get(Uri.parse(get_booking_trip)); // استخدام الرابط من ملف الكونفج

      if (response.statusCode == 200) {
        setState(() {
          bookings = json.decode(response.body);
          filteredBookings = bookings; // لتصفية الحجز عند بدء التحميل
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

  // دالة لتنسيق التاريخ بشكل مناسب
  String formatDate(String dateStr) {
    DateTime date = DateTime.parse(dateStr);
    return DateFormat('yyyy-MM-dd HH:mm').format(date); // تنسيق التاريخ بالشكل المطلوب
  }

  // دالة لتصفية الحجوزات بناءً على البحث
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

  // دالة لإلغاء الحجز
  Future<void> cancelBooking(String bookingId) async {
    try {
      final response = await http.delete(
        Uri.parse('$get_booking_trip/$bookingId'), // رابط API للإلغاء
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

  // دالة لتعديل الحجز
  Future<void> editBooking(String bookingId) async {
    // سيتم فتح شاشة لتعديل الحجز بناءً على bookingId
    // يمكن تنفيذ ذلك باستخدام Navigator push إلى صفحة أخرى مع نموذج تعديل الحجز
    // وسيتم تعديل الحجز باستخدام API بعد إتمام التعديل
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Edit feature coming soon')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('All Bookings'),
        backgroundColor: Colors.deepPurple,
        actions: [
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
                  // أزرار الإدارة مع الترتيب الجديد
                  SizedBox(height: 16), // زيادة المسافة بين المعلومات والأزرار
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
                      SizedBox(width: 20), // إضافة مسافة بين الأزرار
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
