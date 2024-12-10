import 'package:flutter/material.dart';
import 'dart:convert'; // لتحليل البيانات من JSON
import 'package:http/http.dart' as http;
import 'config.dart';
import 'package:flutter/material.dart';
import 'dart:convert'; // لتحليل البيانات من JSON
import 'package:http/http.dart' as http;
import 'language_provider.dart';
import 'dart:async';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'BookingDetailsScreen.dart';


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


  String formatDate(String dateTime) {
    final parsedDate = DateTime.parse(dateTime);
    return DateFormat('dd MMMM yyyy').format(parsedDate); // تنسيق التاريخ فقط
  }

  String formatTime(String dateTime) {
    final parsedDate = DateTime.parse(dateTime);
    return DateFormat('hh:mm a').format(parsedDate); // تنسيق الوقت فقط
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final isArabic = languageProvider.isArabic;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isArabic ? "حجوزاتي" : "My bookings",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor:primaryColor,
      ),
      body: bookings.isNotEmpty
          ? Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(), // منع التمرير داخل القائمة
              itemCount: bookings.length,
              itemBuilder: (context, index) {
                final booking = bookings[index];
                final from = booking['from'] ?? (isArabic ? 'غير محدد' : 'Not specified');
                final to = booking['to'] ?? (isArabic ? 'غير محدد' : 'Not specified');
                final dateRaw = booking['date'];
                final formattedDate = dateRaw != null && dateRaw.isNotEmpty
                    ? formatDate(dateRaw)
                    : (isArabic ? 'غير محدد' : 'Not specified');
                final extractedTime = dateRaw != null && dateRaw.isNotEmpty
                    ? formatTime(dateRaw)
                    : (isArabic ? 'غير محدد' : 'Not specified');
                final customTime = booking['time'] ?? extractedTime;

                return GestureDetector(
                  onTap: () {
                    // تنفيذ الإجراء عند النقر على البطاقة
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BookingDetailsScreen(booking: booking),
                      ),
                    );
                  },
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    margin: EdgeInsets.symmetric(vertical: 8.0),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                           // complementaryPink, // اللون الزهري
                            softPink,
                            SecondryColor                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(

                                ),
                                SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        isArabic
                                            ? 'من $from إلى $to'
                                            : 'From $from To $to',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                          color: primaryColor2,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            Divider(color: Colors.grey),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.calendar_today, color: analogousPink),
                                    SizedBox(width: 4),
                                    Text(
                                      formattedDate,
                                      style: TextStyle(color: Colors.black),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Icon(Icons.access_time, color: analogousPink),
                                    SizedBox(width: 4),
                                    Text(
                                      customTime,
                                      style: TextStyle(color: Colors.black),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            SizedBox(height: 16),
                            // الأزرار الثلاثة بتنسيق أصغر وأنيق
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly, // لتقليل المسافات بين الأزرار
                              children: [
                                TextButton(
                                  onPressed: () {
                                    // تأكيد الحجز
                                  },
                                  style: TextButton.styleFrom(
                                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                    backgroundColor: primaryColor, // لون الزر
                                    foregroundColor: Colors.white, // لون النص
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      side: BorderSide(color: Colors.white, width: 1.5), // إضافة الحدود البيضاء حول الزر
                                    ),
                                    elevation: 5, // إضافة ظل خفيف للزر
                                  ),
                                  child: Text(isArabic ? 'تأكيد' : 'Confirm'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    // حذف الحجز
                                  },
                                  style: TextButton.styleFrom(
                                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                    backgroundColor: primaryColor, // لون الزر
                                    foregroundColor: Colors.white, // لون النص
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      side: BorderSide(color: Colors.white, width: 1.5), // إضافة الحدود البيضاء حول الزر
                                    ),
                                    elevation: 5, // إضافة ظل خفيف للزر
                                  ),
                                  child: Text(isArabic ? 'حذف' : 'Delete'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    // تعديل الحجز
                                  },
                                  style: TextButton.styleFrom(
                                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                    backgroundColor: primaryColor, // لون الزر
                                    foregroundColor: Colors.white, // لون النص
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      side: BorderSide(color: Colors.white, width: 1.5), // إضافة الحدود البيضاء حول الزر
                                    ),
                                    elevation: 5, // إضافة ظل خفيف للزر
                                  ),
                                  child: Text(isArabic ? 'تعديل' : 'Edit'),
                                ),
                              ],
                            ),

                          ],
                        ),
                      ),
                    ),
                  )
                  ,
                );
              },
            ),
          ],
        ),
      )
          : Center(
        child: Text(
          isArabic ? "لم يتم العثور على حجوزات" : "No bookings found.",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: SecondryColor2,
            shadows: [
              Shadow(
                offset: Offset(1.5, 1.5),
                blurRadius: 3.0,
                color: Colors.grey.withOpacity(0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


const Color SecondryColor = Color.fromARGB(230, 196, 209, 219);
//const Color SecondryColor2 = Color.fromARGB(230, 95, 190, 200);
const Color SecondryColor2 = Color.fromARGB(230, 130, 167, 175);
const Color complementaryPink = Color.fromARGB(230, 255, 153, 180);
const Color analogousPink = Color.fromARGB(230, 230, 100, 140);
const Color triadicPink = Color.fromARGB(230, 245, 115, 165);
const Color softPink = Color.fromARGB(230, 250, 170, 200);
const Color primaryColor = Color.fromARGB(230, 41, 84, 115); // اللون الأساسي
const Color primaryColor2 = Color.fromARGB(230, 20, 60, 115); // اللون الأساسي