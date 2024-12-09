import 'package:flutter/material.dart';
import 'dart:convert'; // لتحليل البيانات من JSON
import 'package:http/http.dart' as http;
import 'config.dart';
import 'package:flutter/material.dart';
import 'dart:convert'; // لتحليل البيانات من JSON
import 'package:http/http.dart' as http;

class BookingTripsPage extends StatefulWidget {
  final String emailP;
  const BookingTripsPage({required this.emailP, super.key});

  @override
  _BookingTripsPageState createState() => _BookingTripsPageState();
}

class _BookingTripsPageState extends State<BookingTripsPage> {
  List<dynamic> bookings = []; // لتخزين الحجوزات
  bool isLoading = false; // لإظهار مؤشر التحميل
  String? error;

  // عنوان الـ API

  @override
  void initState() {
    super.initState();
    print('Fetching trips for email: ${widget.emailP}');

    // جلب البيانات عند تحميل الصفحة
    fetchUpcomingTrips();

  }

  // دالة لجلب الحجوزات بناءً على البريد الإلكتروني
  Future<void> fetchUpcomingTrips() async {
    // بدء تحميل البيانات
    setState(() {
      isLoading = true;
      error = null; // إعادة تعيين حالة الخطأ
    });

    try {
      print('Fetching trips for email: ${widget.emailP}');
      final response = await http.get(
          Uri.parse('$Bookung_emailP?EmailP=${widget.emailP}'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data != null && data['status'] == true) {
          setState(() {
            bookings = data['trips'] ?? [];
            isLoading = false; // إيقاف مؤشر التحميل
          });
        } else {
          setState(() {
            error = 'No trips available or invalid data format';
            isLoading = false;
          });
        }
      } else {
        setState(() {
          error = 'Failed to fetch trips: ${response.statusCode}';
          isLoading = false;
        });
        print('Failed to fetch trips: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        error = 'Error fetching trips: $e';
        isLoading = false;
      });
      print('Error fetching trips: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('حجوزات الباسنجر'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())  // عرض مؤشر التحميل
          : bookings.isEmpty
          ? Center(child: Text('لا توجد حجوزات'))  // عرض رسالة إذا كانت الحجوزات فارغة
          : ListView.builder(
        itemCount: bookings.length,
        itemBuilder: (context, index) {
          final booking = bookings[index];
          final from = booking['from'] ?? 'غير محدد';
          final to = booking['to'] ?? 'غير محدد';
          final date = booking['date'] ?? 'غير محدد';

          return ListTile(
            title: Text('الرحلة من $from إلى $to'),
            subtitle: Text('التاريخ: $date'),
          );
        },
      ),
    );
  }
}
