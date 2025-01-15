import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:project1/rating_driver_page.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;


import 'chat_page.dart';
import 'config.dart';
import 'driver_data_model.dart';

class DriverDetailsScreen extends StatelessWidget {
  final String name;
  final String email;
  final String phoneNumber;
  final String emailP;
  final String nameP;

  const DriverDetailsScreen({
    Key? key,
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.emailP,
    required this.nameP,
  }) : super(key: key);

  Future<Map<String, dynamic>?> getAverageRating() async {
    final String endpoint = '$average_rate/$email';

    try {
      final response = await http.get(Uri.parse(endpoint));
      if (response.statusCode == 200) {
        // تحويل الاستجابة إلى JSON
        return json.decode(response.body);
      } else if (response.statusCode == 404) {
        // لا توجد تقييمات
        print('No reviews found for this user');
        return null;
      } else {
        // طباعة أي خطأ آخر
        print('Error: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Exception: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    late DriverDataModel driverData = Provider.of<DriverDataModel>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        // title: Text("Passenger Details"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // شريط الأيقونات
              SizedBox(height: 5),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildIconButton(Icons.call, "call", Color.fromARGB(230, 41, 84, 115), () {}),
                  _buildIconButton(Icons.chat, "chat", Color.fromARGB(230, 41, 84, 115), () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatPage(currentUserEmail:emailP,currentUserName:nameP,recevuserName:name,recevEmail:email), // استبدل CallPage بالصفحة التي تريد الانتقال إليها
                      ),
                    );
                  }),
                  _buildPopupMenuButton(),
                ],
              ),
              SizedBox(height: 35), // مسافة بين شريط الأيقونات والكارد
              // كارد تفاصيل الراكب
              Card(
                elevation: 4,
                color: Color.fromARGB(230, 239, 248, 255), // تغيير لون الكارد
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // عرض الاسم
                          Text(
                            "Username",
                            style: TextStyle(
                              fontSize: 23,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  name, // عرض الاسم
                                  style: TextStyle(
                                    fontSize: 25,
                                    color: Color.fromARGB(230, 24, 83, 131),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Divider(
                            height: 32, // المسافة الرأسية حول الديفايدر
                            thickness: 2, // سماكة الخط
                            color: Colors.grey, // لون الديفايدر
                          ),
                          // عرض الإيميل تحت الاسم
                          Text(
                            "Email",
                            style: TextStyle(
                              fontSize: 23,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  email, // عرض الإيميل
                                  style: TextStyle(
                                    fontSize: 25,
                                    color: Color.fromARGB(230, 24, 83, 131),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Divider(
                            height: 32,
                            thickness: 2,
                            color: Colors.grey,
                          ),
                          // عرض رقم الهاتف
                          Text(
                            "Mobile",
                            style: TextStyle(
                              fontSize: 23,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  phoneNumber, // عرض رقم الهاتف
                                  style: TextStyle(
                                    fontSize: 25,
                                    color: Color.fromARGB(230, 24, 83, 131),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Divider(
                            height: 32,
                            thickness: 2,
                            color: Colors.grey,
                          ),
                          driverData.getLocationByEmail(email) != null
                              ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Location",
                                style: TextStyle(
                                  fontSize: 23,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(Icons.location_on, color: Color.fromARGB(240, 38, 28, 44)),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child:Text(
                                      driverData.getLocationByEmail(email) ?? 'الموقع غير متوفر',
                                      style: TextStyle(
                                        fontSize: 25,
                                        color: Color.fromARGB(230, 24, 83, 131),
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                            ],
                          )
                              : SizedBox(),
                          Text(
                            "Review",
                            style: TextStyle(
                              fontSize: 23,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Row(
                            children: [
                              Expanded(
                                child: FutureBuilder<Map<String, dynamic>?>(
                                  future: getAverageRating(), // استدعاء دالة الحصول على التقييم
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState == ConnectionState.waiting) {
                                      return Text(
                                        'Loading...',
                                        style: TextStyle(
                                          fontSize: 25,
                                          color: Color.fromARGB(230, 24, 83, 131),
                                        ),
                                      );
                                    } else if (snapshot.hasError) {
                                      return Text(
                                        'Error: ${snapshot.error}',
                                        style: TextStyle(
                                          fontSize: 25,
                                          color: Color.fromARGB(230, 24, 83, 131),
                                        ),
                                      );
                                    } else if (snapshot.hasData) {
                                      // تحويل قيمة التقييم من String إلى double
                                      final averageRating = snapshot.data?['averageRating'];
                                      if (averageRating != null) {
                                        double rating = double.tryParse(averageRating.toString()) ?? 0.0;

                                        int fullStars = rating.floor(); // النجوم الممتلئة
                                        int halfStars = (rating - fullStars) >= 0.5 ? 1 : 0; // النجوم نصف الممتلئة
                                        int emptyStars = 5 - fullStars - halfStars; // النجوم الفارغة

                                        return GestureDetector(
                                          onTap: () {
                                            // الانتقال إلى صفحة RatingDriverPage عند النقر
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(builder: (context) => RatingDriverPage(rating:rating,email:email)),
                                            );
                                          },
                                          child: Row(
                                            children: [
                                              // عرض النجوم
                                              Row(
                                                children: [
                                                  for (int i = 0; i < fullStars; i++)
                                                    Icon(Icons.star, color: Colors.amber, size: 30),
                                                  for (int i = 0; i < halfStars; i++)
                                                    Icon(Icons.star_half, color: Colors.amber, size: 30),
                                                  for (int i = 0; i < emptyStars; i++)
                                                    Icon(Icons.star_border, color: Colors.amber, size: 30),
                                                ],
                                              ),
                                              SizedBox(width: 10), // المسافة بين النجوم والرقم
                                              // عرض الرقم
                                              Text(
                                                '$rating', // عرض التقييم
                                                style: TextStyle(
                                                  fontSize: 25,
                                                  color: Color.fromARGB(230, 24, 83, 131),
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      } else {
                                        return Text('No rating available');
                                      }
                                    } else {
                                      return Text('No data available');
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                          Divider(
                            height: 32, // المسافة الرأسية حول الديفايدر
                            thickness: 2, // سماكة الخط
                            color: Colors.grey, // لون الديفايدر
                          ),

                        ],
                      ),
                      SizedBox(height: 30),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton.icon(
                            onPressed: () {},
                            icon: Icon(
                              Icons.share,
                              size: 25,
                              color: Colors.white,
                            ),
                            label: Text(
                              "Share Profile",
                              style: TextStyle(fontSize: 22, color: Colors.white),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color.fromARGB(230, 41, 84, 115),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIconButton(IconData icon, String label, Color color, VoidCallback onPressed) {
    return Column(
      children: [
        GestureDetector(
          onTap: onPressed,
          child: Container(
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            padding: EdgeInsets.all(12),
            child: Icon(icon, color: color, size: 28),
          ),
        ),
        SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _buildPopupMenuButton() {
    return Column(
      children: [
        PopupMenuButton<int>(
          icon: Container(
            decoration: BoxDecoration(
              color: Color.fromARGB(230, 41, 84, 115).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            padding: EdgeInsets.all(12),
            child: Icon(Icons.more_horiz, color: Color.fromARGB(230, 41, 84, 115), size: 28),
          ),
          onSelected: (int value) {
            print("Option $value selected");
          },
          itemBuilder: (BuildContext context) => <PopupMenuEntry<int>>[
            PopupMenuItem<int>(
              value: 1,
              child: ListTile(
                leading: Icon(Icons.share),
                title: Text("Share Contact", style: TextStyle(fontSize: 20)),
              ),
            ),
            PopupMenuItem<int>(
              value: 2,
              child: ListTile(
                leading: Icon(Icons.clear),
                title: Text("Clear Messages", style: TextStyle(fontSize: 20)),
              ),
            ),
            PopupMenuItem<int>(
              value: 3,
              child: ListTile(
                leading: Icon(Icons.block, color: Colors.red),
                title: Text(
                  "Block User",
                  style: TextStyle(color: Colors.red, fontSize: 20),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 0),
        Text(
          "More",
          style: TextStyle(
              color: Color.fromARGB(230, 41, 84, 115), fontSize: 20, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}



