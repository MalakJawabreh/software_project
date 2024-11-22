import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'login.dart';

class Passenger extends StatefulWidget {
  final String token;
  const Passenger({required this.token, super.key});

  @override
  State<Passenger> createState() => _PassengerState();
}

class _PassengerState extends State<Passenger> {
  late String email;
  late String fullName;
  @override
  void initState() {
    super.initState();
    // فك شفرة التوكن لاستخراج البريد الإلكتروني
    Map<String, dynamic> jwtDecodedToken = JwtDecoder.decode(widget.token);
    email = jwtDecodedToken['email'];
    fullName = jwtDecodedToken['fullName'];

  }

  Color _buttonColor = primaryColor; // اللون الأساسي كافتراضي للزر

  final TextEditingController _destinationController = TextEditingController();
  String _selectedFilter = 'Price'; // الفلتر الافتراضي
  String _selectedTime = 'Any Time';



  void navigateToBookings() {
    // الانتقال إلى شاشة الحجوزات
    print("Navigating to My Bookings screen...");
  }

  void searchTrips() {
    // عملية البحث عن الرحلات
    print("Searching trips to: ${_destinationController.text} with filter: $_selectedFilter at time: $_selectedTime");
  }

  void showAds() {
    // عرض الإعلانات
    print("Displaying ads...");
    // يمكنك إضافة دالة لإظهار الإعلانات أو الانتقال إلى شاشة الإعلانات
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // عرض الأيقونة والبريد الإلكتروني في الشريط العلوي
        title: Row(
          children: [
            CircleAvatar(
              radius: 15, // حجم صغير للأيقونة
              backgroundColor: primaryColor,
              child: Icon(
                Icons.person,
                size: 15,
                color: Colors.white,
              ),
            ),
            SizedBox(width: 10), // مسافة بين الأيقونة والإيميل
            Expanded(
              child: Text(
                fullName,
                style: TextStyle(fontSize: 14), // حجم خط أصغر
                overflow: TextOverflow.ellipsis, // اقتصاص النص إذا كان طويلًا
              ),
            ),
          ],
        ),
        backgroundColor: primaryColor,
        actions: [
          IconButton(
            icon: Icon(Icons.notifications, color: Colors.white),
            onPressed: () {
              // عرض الإشعارات
            },
          ),
          IconButton(
            icon: Icon(Icons.chat, color: Colors.white),
            onPressed: () {
              // التعامل مع المحادثات
            },
          ),
          IconButton(
            icon: Icon(Icons.ads_click, color: Colors.white), // أيقونة الإعلانات
            onPressed: showAds, // استدعاء دالة عرض الإعلانات
          ),
          IconButton(
            icon: Icon(Icons.menu, color: Colors.white),
            onPressed: () {
              // عرض القائمة
            },
          ),
          // أيقونة الإعلانات الجديدة

        ],
        automaticallyImplyLeading: false, // تعيين إلى false لإزالة السهم
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // زر البحث عن الرحلات
              MouseRegion(
                onEnter: (_) {
                  setState(() {
                    _buttonColor = primaryColor.withOpacity(0.7); // تغيير اللون عند المرور بالماوس
                  });
                },
                onExit: (_) {
                  setState(() {
                    _buttonColor = primaryColor; // العودة للون الأساسي
                  });
                },
                child: ElevatedButton(
                  onPressed: () {
                    _showSearchDialog();
                  },
                  child: Text("Search for Trips"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _buttonColor,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 100, vertical: 15),
                    textStyle: TextStyle(fontSize: 18),
                  ),
                ),
              ),
              SizedBox(height: 20),

              // قسم الحجوزات
              Card(
                elevation: 5,
                color: Colors.grey.shade200,
                child: ListTile(
                  title: Text("Your Active Bookings", style: TextStyle(color: primaryColor)),
                  subtitle: Text("Manage your current bookings", style: TextStyle(color: Colors.black87)),
                  trailing: Icon(Icons.arrow_forward, color: primaryColor),
                  onTap: navigateToBookings,
                ),
              ),
              SizedBox(height: 20),

              // قسم الإشعارات
              Card(
                elevation: 5,
                color: Colors.grey.shade200,
                child: ListTile(
                  title: Text("Notifications", style: TextStyle(color: primaryColor)),
                  subtitle: Text("Check your notifications", style: TextStyle(color: Colors.black87)),
                  trailing: Icon(Icons.arrow_forward, color: primaryColor),
                  onTap: () {
                    // الانتقال إلى شاشة الإشعارات
                  },
                ),
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
      // زر الرجوع في أسفل الصفحة
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pop(context); // الرجوع إلى الشاشة السابقة
        },
        backgroundColor: primaryColor,
        child: Icon(Icons.arrow_back, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startDocked, // محاذاة يسار أسفل
    );
  }

  // نافذة البحث
  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [primaryColor, primaryColor.withOpacity(0.7), Colors.blueAccent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            padding: EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // حقل إدخال الوجهة
                TextField(
                  controller: _destinationController,
                  decoration: InputDecoration(
                    labelText: "Enter destination (e.g., Ramallah)",
                    labelStyle: TextStyle(color: Colors.white),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                  ),
                  style: TextStyle(color: Colors.white),
                ),
                SizedBox(height: 20),

                // اختيار الفلتر
                DropdownButton<String>(
                  value: _selectedFilter,
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedFilter = newValue!;
                    });
                  },
                  items: <String>['Price', 'Time', 'Seats', 'Ratings']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(
                        value,
                        style: TextStyle(color: Colors.white),
                      ),
                    );
                  }).toList(),
                  dropdownColor: primaryColor.withOpacity(0.8),
                ),
                SizedBox(height: 20),

                // أزرار الإجراء
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context); // إغلاق النافذة
                      },
                      child: Text("Cancel", style: TextStyle(color: Colors.white)),
                    ),
                    TextButton(
                      onPressed: () {
                        searchTrips();
                        Navigator.pop(context);
                      },
                      child: Text("Search", style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// اللون الأساسي
const Color primaryColor = Color.fromARGB(230, 41, 84, 115);
