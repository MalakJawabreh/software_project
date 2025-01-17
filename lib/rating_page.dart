import 'package:flutter/material.dart';
import 'dart:convert'; // لتحليل البيانات من JSON
import 'package:http/http.dart' as http;
import 'config.dart';
import 'language_provider.dart';
import 'dart:async';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'BookingDetailsScreen.dart';

class RatingPage extends StatefulWidget {
  final String emailP;
  const RatingPage({required this.emailP, super.key});

  @override
  _RatingPageState createState() => _RatingPageState();
}

class _RatingPageState extends State<RatingPage> {
  List<dynamic> bookings = []; // لتخزين الحجوزات
  List<dynamic> expiredBookings = []; // لتخزين الحجوزات
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

  void updateTripsBasedOnTime() {
    final now = DateTime.now();
    final dateFormat = DateFormat("yyyy-MM-ddTHH:mm:ss.SSS'Z' h:mm a");

    setState(() {
      bookings.removeWhere((booking) {
        try {
          final dateTime = dateFormat
              .parse(booking['date'] + ' ' + booking['time'], true)
              .toLocal();
          if (dateTime.isBefore(now)) {
            expiredBookings.add(booking); // إضافة الحجوزات المنتهية إلى القائمة
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

  Future<void> saveChanges(int selectedStars,String feedbackText,String bookingid) async {
    final updatedBooking = {
      'driverRate':selectedStars,
      'NoteRate': feedbackText,
    };

    try {
      final response = await http.put(
        Uri.parse('$update_Booking_Rate/$bookingid'),
        body: json.encode(updatedBooking),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Booking updated successfully')));

      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to update booking: ${response.statusCode}')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error updating booking: $e')));
    }
  }

  Future<void> createReview (
      String nameP,
      String nameD,
      String emailD,
      int selectedStars,
      String feedbackText,
      ) async {
    final url = Uri.parse(review_post);

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'reviewerName': nameP,
        'reviewerEmail': widget.emailP,
        'reviewedName': nameD,
        'reviewedEmail': emailD,
        'rating': selectedStars,
        'notes': feedbackText,
      }),
    );

    if (response.statusCode == 201) {
      print('Review created successfully!');
    } else {
      print('Failed to create review: ${response.body}');
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



  void showRatingDialog(BuildContext context, String nameD,String emailD,String nameP) {
    int selectedStars = 0; // متغير لحفظ عدد النجوم المختارة
    String feedbackText = ""; // لحفظ نص التغذية الراجعة

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    nameD,
                    style: TextStyle(color: analogousPink, fontWeight: FontWeight.bold, fontSize: 25),
                  ),
                  SizedBox(height: 1),
                  Text(
                    "Driver",
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18, color: Colors.black),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Be responsible during the evaluation to help us move forward and together towards a better society.",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Colors.grey[600]),
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      5,
                          (index) => GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedStars = index + 1; // تحديث عدد النجوم المختارة
                          });
                          print("Rating: $selectedStars stars"); // طباعة درجة الريتنغ
                        },
                        child: Icon(
                          index < selectedStars ? Icons.star : Icons.star_border, // تغيير الأيقونة بناءً على التحديد
                          color: Colors.yellow, // لون النجوم والحدود
                          size: 30,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 16), // مسافة بين النجوم وحقل النص
                  TextField(
                    onChanged: (value) {
                      feedbackText = value; // تخزين نص التغذية الراجعة
                    },
                    maxLines: 2, // عدد الأسطر لحقل النص
                    decoration: InputDecoration(
                      labelText: "Write your feedback", // عنوان الحقل
                      labelStyle: TextStyle(color: Colors.grey),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color:analogousPink), // لون الحدود عند التركيز
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      print("Rating: $selectedStars stars");
                      print("feedbackText: $feedbackText");
                      createReview (nameP, nameD,emailD,selectedStars,feedbackText);
                      Navigator.pop(context); // إغلاق الحوار
                      showThankYouDialog(context,selectedStars,feedbackText); // فتح نافذة الشكر
                    },
                    child: Text("Submit",style: TextStyle(color: Colors.white,fontSize: 20),),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: analogousPink,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }


  void showThankYouDialog(BuildContext context, int star, String feedback) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Thank you!",
                style: TextStyle(color:analogousPink,fontWeight: FontWeight.bold, fontSize: 22),
              ),
              SizedBox(height: 8),
              Text("Your feedback is very helpful to us",style: TextStyle(color:Colors.grey[600],fontWeight: FontWeight.bold, fontSize: 17),
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  5,
                      (index) => Icon(
                    index < star ? Icons.star : Icons.star_border, // نجوم ممتلئة أو فارغة بناءً على عدد النجوم
                    color: Colors.yellow, // اللون الأساسي
                    size: 30,
                  ),
                ),
              ),
              SizedBox(height: 16),
              Text(
                feedback.isNotEmpty
                    ? feedback
                    : "", // النص المعروض بناءً على التغذية الراجعة
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600],fontWeight: FontWeight.w500,fontSize: 17),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // إغلاق الحوار
                },
                child: Text("OK",style: TextStyle(color: Colors.white),),
                style: ElevatedButton.styleFrom(
                  backgroundColor:analogousPink,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }



  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final isArabic = languageProvider.isArabic;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isArabic ? "تقييمك" : "Give feedback",
          style: TextStyle(color:primaryColor2,fontSize: 26,fontWeight: FontWeight.w500),
        ),
        backgroundColor: Colors.white,
      ),
      body: expiredBookings.isNotEmpty
          ? Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(  // إضافة SingleChildScrollView هنا
          child: Column(
            children: [
              Text(
                isArabic
                    ? "من فضلك قم باعطائنا رأيك لمساعدتنا في تطوير تطبيقنا وخدماتنا . نحن نسعى لأجلكم دائما."
                    : "If you'd like to help us improve our service and app, we kindly ask you to rate the trips and drivers you have previously interacted with.",
                style: TextStyle(
                  color: Colors.grey[600], // لون النص
                  fontSize: 16, // حجم الخط
                  fontWeight: FontWeight.bold, // جعل النص عريضًا
                ),
              ),
              SizedBox(height: 16), // مسافة بين الجملة والقائمة
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(), // منع التمرير داخل القائمة
                itemCount: expiredBookings.length,
                itemBuilder: (context, index) {
                  final booking = expiredBookings[index];
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
                              yellowColor2,
                              yellowColor1,
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
                                        Text(
                                          isArabic
                                              ? 'من $from إلى $to'
                                              : 'From $from To $to',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20,
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
                                        style: TextStyle(fontSize:17,color: Colors.black,fontWeight: FontWeight.w500),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Icon(Icons.access_time, color: analogousPink),
                                      SizedBox(width: 4),
                                      Text(
                                        customTime,
                                        style: TextStyle(fontSize:17,color: Colors.black,fontWeight: FontWeight.w500),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              SizedBox(height: 20),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Row(
                                    children: [
                                      ElevatedButton(
                                        onPressed: () {
                                          showRatingDialog(context,booking['nameD'],booking['EmailD'],booking['nameP']);
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: analogousPink, // لون الزر
                                          foregroundColor: Colors.white, // لون النص داخل الزر
                                          padding: EdgeInsets.symmetric(horizontal: 50, vertical: 6), // حجم الزر
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(20), // حواف مستديرة
                                          ),
                                        ),
                                        child: Text(
                                          "Rating",
                                          style: TextStyle(
                                            fontSize: 20, // حجم النص
                                            //fontWeight: FontWeight.bold, // سماكة النص
                                          ),
                                        ),
                                      ),
                                    ],
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
        ),
      )
          : Center(
        child: Text(
          isArabic ? "لا يوجد حجوزات لتقوم بتقييمها" : "No bookings to Rate it.",
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
const Color yellowColor2 = Color.fromARGB(230, 236, 220, 149);
const Color yellowColor1 = Color.fromARGB(230, 251, 251, 234);
const Color complementaryPink = Color.fromARGB(230, 255, 153, 180);
const Color analogousPink = Color.fromARGB(230, 138, 15, 54);
const Color triadicPink = Color.fromARGB(230, 245, 115, 165);
const Color softPink = Color.fromARGB(230, 250, 170, 200);
const Color primaryColor = Color.fromARGB(230, 41, 84, 115); // اللون الأساسي
const Color primaryColor2 = Color.fromARGB(230, 20, 60, 115); // اللون الأساسي