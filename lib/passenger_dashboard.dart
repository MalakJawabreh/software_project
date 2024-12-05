import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:project1/test.dart';
import 'dart:async';
import 'login.dart';
import 'package:provider/provider.dart';
import 'theme_provider.dart';
import 'language_provider.dart';
import 'ChangePasswordPage.dart';
import 'VisibilitySettingsScreen.dart';
import 'BlockedContactsScreen.dart';
import 'LiveLocationPage.dart';
import 'EmailAddressPage.dart';
import 'TwoStepVerificationPage.dart';
import 'profile_driver.dart';
import 'package:http/http.dart' as http;

import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Upcoming_Passview.dart';
import 'SearchPassenger.dart';
import 'driver_dashboard.dart';

class Passenger extends StatefulWidget {
  final String? token;
  final List<dynamic> ?upcomingTrips;

  const Passenger({ this.token,this.upcomingTrips, super.key});


  @override
  State<Passenger> createState() => _PassengerState();
}

class _PassengerState extends State<Passenger> {
  late String email;
  late String fullName;
  late String phoneNumber;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final List<String> _images = [
    'imagess/a11.jpg',
    'imagess/a2.jpg',
    'imagess/Jerusalem.jpg',

  ];

  final PageController _pageController = PageController();
  late Timer _timer;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // Method to decode token and save user data in shared preferences
  void _loadUserData() async {
    if (widget.token != null) {
      Map<String, dynamic> jwtDecodedToken = JwtDecoder.decode(widget.token!);
      email = jwtDecodedToken['email'];
      fullName = jwtDecodedToken['fullName'];
      phoneNumber = jwtDecodedToken['phoneNumber'];

      // Save email and full name in SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('email', email);
      await prefs.setString('fullName', fullName);
      await prefs.setString('phoneNumber', phoneNumber);
    }

    // إعداد التايمر للحركة التلقائية للسلايدر
    _timer = Timer.periodic(Duration(seconds: 5), (Timer timer) {
      if (_currentPage < _images.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }
      _pageController.animateToPage(
        _currentPage,
        duration: Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }



  @override
  void dispose() {
    _timer.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void logout() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => Login()),
    );
  }
  Color _buttonColor = primaryColor;

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final isArabic = languageProvider.isArabic;

    return Scaffold(
      key: _scaffoldKey,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(80),
        child: AppBar(
          automaticallyImplyLeading: false,
          title: Padding(
            padding: const EdgeInsets.only(top: 32),
            child: Row(
              children: [
                Image.asset(
                  'imagess/app_icon.jpg',
                  height: 40,
                ),
                SizedBox(width: 0),
                Text(
                  isArabic ? "وصلني معك" : "Assalni Ma'ak",
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 41, 84, 115),
                  ),
                ),
              ],
            ),
          ),
          backgroundColor: Color.fromARGB(230, 196, 209, 219),
          actions: [
            Padding(
              padding: const EdgeInsets.only(top: 19),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.notifications,
                        size: 25, color: Color.fromARGB(230, 41, 84, 115)),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: Icon(Icons.chat,
                        size: 25, color: Color.fromARGB(230, 41, 84, 115)),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: Icon(Icons.menu,
                        size: 25, color: Color.fromARGB(230, 41, 84, 115)),
                    onPressed: () {
                      _scaffoldKey.currentState?.openEndDrawer();
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      endDrawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.white),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundImage: AssetImage('imagess/signup_icon.png'),
                    radius: 30,
                  ),
                  SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,

                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProfileDriver(
                                email: email,
                                username: fullName,
                              ),
                            ),
                          );
                        },
                     child:  Text(
                        fullName,
                        style: TextStyle(
                          color: Color.fromARGB(230, 41, 84, 115),
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                     ),
                      ),
                      SizedBox(height: 5), // مسافة بين الاسم والبريد الإلكتروني
                      Text(
                        email, // عرض البريد الإلكتروني
                        style: TextStyle(
                          color: Color.fromARGB(230, 41, 84, 115),
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 30,),

            ListTile(
              leading: Icon(Icons.settings, size: 30),
              title: Text(
                isArabic ? 'الإعدادات' : 'Settings',
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(230, 41, 84, 115),
                ),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SettingsPage()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.privacy_tip, size: 30),
              title: Text(
                isArabic ? 'الخصوصية' : 'Privacy',
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(230, 41, 84, 115),
                ),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PrivacyPage()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.reviews, size: 30),
              title: Text(
                isArabic ? 'الأراء' : 'Reviews',
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(230, 41, 84, 115),
                ),
              ),
              onTap: () {},
            ),
            ListTile(
              leading: Icon(Icons.contact_support, size: 30),
              title: Text(
                isArabic ? 'الدعم' : 'Support',
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(230, 41, 84, 115),
                ),
              ),
              onTap: () {},
            ),
            ListTile(
              leading: Icon(Icons.logout, size: 30),
              title: Text(
                isArabic ? 'الخروج' : 'Logout',
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(230, 41, 84, 115),
                ),
              ),
              onTap: logout,
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          SizedBox(
            height: 200,
            child: PageView.builder(
              controller: _pageController,
              itemCount: _images.length,
              itemBuilder: (context, index) {
                return Image.asset(
                  _images[index], // تحميل الصورة من الأصول
                  fit: BoxFit.cover,
                  width: double.infinity,
                );
              },
            ),
          ),
         // SizedBox(height: 15),

          // إضافة الكاتلوج

          Card(
            elevation: 5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10), // لجعل الزوايا مدورة (اختياري)
            ),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    primaryColor,
                    SecondryColor,
                  ],
                ),
                borderRadius: BorderRadius.circular(10), // نفس الخاصية لتدوير الزوايا
              ),
              child: ListTile(
                title: Text(
                  isArabic ? 'حجوزاتك' : 'Your Active Bookings',
                  style: TextStyle(color: Colors.white), // تغيير اللون للنص إلى الأبيض ليكون واضحًا مع التدرج
                ),
                subtitle: Text(
                  isArabic ? 'إدارة حجوزاتك الحالية' : 'Manage your current bookings',
                  style: TextStyle(color: Colors.white70), // اللون الرمادي الفاتح للنص الفرعي
                ),
                trailing: Icon(
                  Icons.arrow_forward,
                  color: primaryColor2, // تغيير لون الأيقونة إلى الأبيض
                ),
                onTap: () {
                  // تنفيذ الإجراء عند النقر
                },
              ),
            ),
          ),
          SizedBox(height: 20),
          Card(
            elevation: 5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10), // لجعل الزوايا مدورة (اختياري)
            ),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    primaryColor,
                    SecondryColor,
                  ],
                ),
                borderRadius: BorderRadius.circular(10), // نفس الخاصية لتدوير الزوايا
              ),
              child: ListTile(
                title: Text(
                  isArabic ? 'الأعلانات' : 'Advertisements',
                  style: TextStyle(color: Colors.white), // تغيير اللون للنص إلى الأبيض ليكون واضحًا مع التدرج
                ),
                subtitle: Text(
                  isArabic ? 'رؤية الأعلانات الجديدة الآن' : 'View new ads now!',
                  style: TextStyle(color: Colors.white70), // اللون الرمادي الفاتح للنص الفرعي
                ),
                trailing: Icon(
                  Icons.arrow_forward,
                  color:primaryColor2, // تغيير لون الأيقونة إلى الأبيض
                ),
                onTap: () {

                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => TestPage(emailP:email,nameP: fullName,phoneP: phoneNumber,)),
                  );



                },

              ),
            ),
          ),
          SizedBox(height: 20),
          Card(
            elevation: 5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10), // لجعل الزوايا مدورة (اختياري)
            ),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    primaryColor,
                    SecondryColor,
                  ],
                ),
                borderRadius: BorderRadius.circular(10), // نفس الخاصية لتدوير الزوايا
              ),
              child: ListTile(
                title: Text(
                  isArabic ? 'البحث عن رحلات ' : 'Search Trips',
                  style: TextStyle(color: Colors.white), // تغيير اللون للنص إلى الأبيض ليكون واضحًا مع التدرج
                ),
                subtitle: Text(
                  isArabic ? 'ابحث عن وجهتك الآن ' : 'Find your destination now',
                  style: TextStyle(color: Colors.white70), // اللون الرمادي الفاتح للنص الفرعي
                ),
                trailing: Icon(
                  Icons.arrow_forward,
                  color:primaryColor2, // تغيير لون الأيقونة إلى الأبيض
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SearchTripsPage()),
                  );
                },
              ),
            ),
          ),



        ],
      ),
    );
  }
}

  // حوار البحث


class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // الحصول على قيمة isArabic من LanguageProvider
    final languageProvider = Provider.of<LanguageProvider>(context);
    final isArabic = languageProvider.isArabic;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isArabic ? 'الإعدادات' : 'Settings',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: primaryColor, // استخدام اللون الأساسي
          ),
        ),
        backgroundColor: SecondryColor, // تدرج أفتح من اللون الأساسي لــ AppBar
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ListTile(
              leading: Icon(Icons.language, size: 30, color: primaryColor2), // تغيير لون الأيقونة
              title: Text(
                isArabic ? 'اختر اللغة' : 'Select Language',
                style: TextStyle(fontSize: 20, color: SecondryColor2,fontWeight: FontWeight.bold), // تغيير لون النص
              ),
              onTap: () {
                // إظهار مربع حوار لاختيار اللغة
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text(isArabic ? "اختر اللغة" : "Select Language", style: TextStyle(color: primaryColor)), // تغيير لون النص
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ListTile(
                          title: Text(isArabic ? "الإنجليزية" : "English", style: TextStyle(color: primaryColor)), // تغيير لون النص
                          onTap: () {
                            // تغيير اللغة إلى الإنجليزية
                            Provider.of<LanguageProvider>(context, listen: false)
                                .setLocale(Locale('en', 'US'));
                            Navigator.pop(context); // إغلاق مربع الحوار
                          },
                        ),
                        ListTile(
                          title: Text(isArabic ? "العربية" : "Arabic", style: TextStyle(color: primaryColor)), // تغيير لون النص
                          onTap: () {
                            // تغيير اللغة إلى العربية
                            Provider.of<LanguageProvider>(context, listen: false)
                                .setLocale(Locale('ar', 'EG'));
                            Navigator.pop(context); // إغلاق مربع الحوار
                          },
                        ),


                      ],
                    ),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.palette, color: primaryColor2), // تغيير لون الأيقونة
              title: Text(
                isArabic ? 'تغيير الثيم' : 'Change Theme',
                style: TextStyle(fontSize: 20, color: SecondryColor2,fontWeight: FontWeight.bold), // تغيير لون النص
              ),
              onTap: () {
                // تغيير الثيم
                Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
              },
            ),
            ListTile(
              leading: Icon(Icons.email, color: primaryColor2), // تغيير لون الأيقونة
              title: Text(
                isArabic ? 'عنوان البريد الإلكتروني' : 'Email address',
                style: TextStyle(fontSize: 20, color: SecondryColor2,fontWeight: FontWeight.bold), // تغيير لون النص
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => EmailAddressPage()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.privacy_tip, color: primaryColor2), // تغيير لون الأيقونة
              title: Text(
                isArabic ? 'التحقق بخطوتين' : 'Two-step verification',
                style: TextStyle(fontSize: 20, color: SecondryColor2,fontWeight: FontWeight.bold), // تغيير لون النص
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TwoStepVerificationPage(),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.notifications, size: 30, color: primaryColor2), // تغيير لون الأيقونة
              title: Text(
                isArabic ? 'الإشعارات' : 'Notifications',
                style: TextStyle(fontSize: 20, color: SecondryColor2,fontWeight: FontWeight.bold), // تغيير لون النص
              ),
              onTap: () {
                // التعامل مع الإشعارات هنا
              },
            ),
          ],
        ),
      ),
    );
  }
}
class PrivacyPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // الحصول على قيمة isArabic من LanguageProvider
    final languageProvider = Provider.of<LanguageProvider>(context);
    final isArabic = languageProvider.isArabic;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isArabic ? 'الخصوصية' : 'Privacy',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: primaryColor, // استخدام اللون الأساسي للعنوان
          ),
        ),
        backgroundColor: SecondryColor, // تدرج أفتح من اللون الأساسي لــ AppBar
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ListTile(
              leading: Icon(Icons.lock_outline, size: 30, color: primaryColor2), // تغيير لون الأيقونة
              title: Text(
                isArabic ? 'تغيير كلمة السر' : 'Change password',
                style: TextStyle(fontSize: 20, color: SecondryColor2,fontWeight: FontWeight.bold), // تغيير لون النص
              ),
              onTap: () {
                // الانتقال إلى صفحة تغيير كلمة السر
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ChangePasswordPage()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.visibility, size: 30, color: primaryColor2),
              title: Text(
                isArabic ? 'رؤية الحساب' : 'Visibility',
                style: TextStyle(fontSize: 20, color: SecondryColor2,fontWeight: FontWeight.bold),
              ),
              onTap: () {
                // الانتقال إلى صفحة إعدادات الرؤية
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => VisibilitySettingsScreen()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.security, size: 30, color: primaryColor2), // تغيير لون الأيقونة
              title: Text(
                isArabic ? 'المصادقة' : 'Authentication',
                style: TextStyle(fontSize: 20, color: SecondryColor2,fontWeight: FontWeight.bold), // تغيير لون النص
              ),
              onTap: () {
                // التعامل مع المصادقة هنا
              },
            ),
            ListTile(
              leading: Icon(Icons.block, size: 30, color: primaryColor2), // تغيير لون الأيقونة
              title: Text(
                isArabic ? 'جهات اتصال محظورة' : 'Blocked Contact',
                style: TextStyle(fontSize: 20, color: SecondryColor2,fontWeight: FontWeight.bold), // تغيير لون النص
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => BlockedContactsScreen()),
                );
              },
            ),
            ListTile(
                leading: Icon(Icons.location_on, size: 30, color: primaryColor2), // تغيير لون الأيقونة
                title: Text(
                  isArabic ? 'الموقع المباشر' : 'Live Location',
                  style: TextStyle(fontSize: 20, color: SecondryColor2,fontWeight: FontWeight.bold), // تغيير لون النص
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => LiveLocationPage()),
                  );
                }
            ),
          ],
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