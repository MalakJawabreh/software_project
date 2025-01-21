import 'package:flutter/material.dart';
import 'dart:convert'; // لتحليل البيانات من JSON
import 'package:http/http.dart' as http;
import 'package:project1/passenger_dashboard.dart';
import 'config.dart';
import 'package:flutter/material.dart';
import 'dart:convert'; // لتحليل البيانات من JSON
import 'package:http/http.dart' as http;
import 'language_provider.dart';
import 'dart:async';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'BookingDetailsScreen.dart';
import 'notifications_service.dart';
import 'EditBookingScreen.dart';
import 'PaymentPage.dart';
import'payment_manager.dart';

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
    fetchUpcomingTrips().then((_) {
      // بعد إحضار البيانات، قم بتحديث المواعيد بناءً على الوقت
      updateTripsBasedOnTime();
    });

    // تحديث المواعيد كل 20 ثانية
    Timer.periodic(Duration(seconds: 20), (timer) {
      if (!mounted) {
        timer.cancel(); // إذا تم إلغاء الـ widget، قم بإلغاء الـ timer
      } else {
        updateTripsBasedOnTime();
      }
    });
  }

  Future<void> updatePayStatus(String bookingId) async {
    final url = Uri.parse('$update_booking/$bookingId'); // عدّل رابط الـ API الخاص بك
    final headers = {
      'Content-Type': 'application/json',
    };
    final body = json.encode({
      'pay': true, // تحديث حالة `pay` إلى `true`
    });

    try {
      final response = await http.put(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        print('Booking updated successfully: $responseData');
      } else {
        print('Failed to update booking. Status code: ${response.statusCode}');
        print('Response: ${response.body}');
      }
    } catch (error) {
      print('Error updating booking: $error');
    }
  }

  void updateTripsBasedOnTime() {
    final now = DateTime.now();
    final dateFormat = DateFormat("yyyy-MM-ddTHH:mm:ss.SSS'Z' h:mm a");

    setState(() {
      bookings.removeWhere((booking) {
        try {
          final dateTime = dateFormat.parse(
              booking['date'] + ' ' + booking['time'], true).toLocal();
          if (dateTime.isBefore(now)) {
            return true;
          }
        } catch (e) {
          print('Error parsing date: $e');
        }
        return false;
      });
    });
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

  Future<void> deleteBooking(String bookingId,String emaild,String nameP) async {
    try {
      final response = await http.delete(Uri.parse('$delete_booking/$bookingId'));

      if (response.statusCode == 200) {
        setState(() {
          print('Booking deleted successfully.');
          NotificationService.addNotification(emaild, 'User ${nameP} has delete this booking successfully!');
          NotificationService.addNotification(widget.emailP,'canceled book!');

        });
      } else {
        print('Failed to delete booking: ${response.body}');
        // معالجة الأخطاء المناسبة هنا.
      }
    } catch (error) {
      print('Error: $error');
      // معالجة الأخطاء المناسبة هنا.
    }
  }


  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final isArabic = languageProvider.isArabic;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isArabic ? "حجوزاتي" : "My bookings",
          style: TextStyle(
            color: primaryColor,
            fontSize: 23,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(
              Icons.settings, // أيقونة الإعدادات
              color: primaryColor, // لون الأيقونة
            ),
            onPressed: () {
              // الكود الذي يتم تنفيذه عند الضغط على الأيقونة
              print("Settings button pressed");
            },
          ),
        ],
      ),
      body: bookings.isNotEmpty
          ? Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView( // إضافة SingleChildScrollView
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
                    //color: Color.fromARGB(230, 246, 216, 239),
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
                            Color.fromARGB(230, 244, 225, 233),
                            Color.fromARGB(230, 246, 216, 239),
                          ],
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
                                      Text.rich(
                                        TextSpan(
                                          children: [
                                            WidgetSpan(
                                              child: Icon(
                                                Icons.location_on, // الأيقونة التي تشير إلى الموقع
                                                color: Colors.green, // لون الأيقونة
                                                size: 22, // حجم الأيقونة
                                              ),
                                            ),
                                            TextSpan(
                                              text: ' $from ', // النص الأول (من)
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18,
                                                color: Color.fromARGB(
                                                    230, 50, 49, 49),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            Padding(
                              padding: EdgeInsets.only(left: 25), // مسافة من اليسار
                              child: Container(
                                width: 2, // عرض الخط
                                height: 20, // طول الخط
                                color: Colors.grey, // لون الخط
                              ),
                            ),
                            SizedBox(height: 2,),
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
                                      Text.rich(
                                        TextSpan(
                                          children: [
                                            WidgetSpan(
                                              child: Icon(
                                                Icons.location_on, // الأيقونة التي تشير إلى الموقع
                                                color: Colors.green, // لون الأيقونة
                                                size: 22, // حجم الأيقونة
                                              ),
                                            ),
                                            TextSpan(
                                              text: '$to',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18,
                                                color: Color.fromARGB(
                                                    230, 50, 49, 49),
                                              ),
                                            ),
                                          ],
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
                                      style: TextStyle(fontSize:18,color: Colors.black),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Icon(Icons.access_time, color: analogousPink),
                                    SizedBox(width: 4),
                                    Text(
                                      customTime,
                                      style: TextStyle(fontSize:18,color: Colors.black),
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
                                  onPressed: () async {
                                    final price = booking['price']; // الحصول على السعر من البيانات
                                    if (price != null && price > 0) {
                                      try {
                                        await PaymentManager.makePayment(price, "ils"); // استخدام السعر الديناميكي
                                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                          content: Text(isArabic ? 'تمت عملية الدفع بنجاح' : 'Payment successful'),
                                          backgroundColor: Colors.green,
                                        ));

                                        final bookingId = booking['_id'].toString();
                                        updatePayStatus(bookingId);
                                      } catch (error) {
                                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                          content: Text(isArabic ? 'فشلت عملية الدفع' : 'Payment failed: $error'),
                                          backgroundColor: Colors.red,
                                        ));
                                      }
                                    } else {
                                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                        content: Text(isArabic ? 'السعر غير متوفر' : 'Price not available'),
                                        backgroundColor: Colors.orange,
                                      ));
                                    }
                                  },
                                  style: TextButton.styleFrom(
                                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                    backgroundColor: primaryColor,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      side: BorderSide(color: Colors.white, width: 1.5),
                                    ),
                                    elevation: 5,
                                  ),
                                  child: Text(isArabic ? 'ادفع الآن' : 'Pay Now',style: TextStyle(fontSize: 17),),
                                ),

                                TextButton(
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: Text(isArabic ? 'تأكيد الإلغاء' : 'Confirm Deletion'),
                                          content: Text(
                                            isArabic
                                                ? 'هل تريد فعلاً إلغاء هذا الحجز؟'
                                                : 'Do you really want to cancel this booking?',
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () {
                                                Navigator.of(context).pop(); // إغلاق النافذة عند الضغط على Cancel
                                              },
                                              child: Text(isArabic ? 'إلغاء' : 'Cancel'),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                Navigator.of(context).pop(); // إغلاق النافذة
                                                final bookingId = booking['_id'].toString();
                                                deleteBooking(bookingId,booking['EmailD'],booking['nameP']); // تنفيذ عملية الحذف
                                              },
                                              style: TextButton.styleFrom(
                                                foregroundColor: Colors.red, // لون النص
                                              ),
                                              child: Text(isArabic ? 'موافق' : 'OK'),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                  style: TextButton.styleFrom(
                                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                    backgroundColor: Colors.red, // لون الزر
                                    foregroundColor: Colors.white, // لون النص
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      side: BorderSide(color: Colors.white, width: 1.5), // إضافة الحدود البيضاء حول الزر
                                    ),
                                    elevation: 5, // إضافة ظل خفيف للزر
                                  ),
                                  child: Text(isArabic ? 'حذف' : 'Delete',style: TextStyle(fontSize: 17),),
                                ),

                                TextButton(
                                  onPressed: () {
                                    // التوجه إلى شاشة تعديل الحجز
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => EditBookingScreen(booking: booking),
                                      ),
                                    ).then((updatedBooking) {
                                      if (updatedBooking != null) {
                                        // تحديث واجهة المستخدم بعد تعديل الحجز
                                        setState(() {
                                          final index = bookings.indexOf(booking);
                                          bookings[index] = updatedBooking;
                                        });
                                      }
                                    });
                                  },
                                  style: TextButton.styleFrom(
                                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                    backgroundColor:Color.fromARGB(
                                        230, 234, 186, 49), // لون الزر
                                    foregroundColor: Colors.white, // لون النص
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      side: BorderSide(color: Colors.white, width: 1.5), // إضافة الحدود البيضاء حول الزر
                                    ),
                                    elevation: 5, // إضافة ظل خفيف للزر
                                  ),
                                  child: Text(isArabic ? 'تعديل' : 'Edit',style: TextStyle(fontSize: 18),),
                                )
                                ,
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