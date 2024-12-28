import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:project1/rating_page.dart';
import 'package:project1/test.dart';
import 'dart:async';
import 'config.dart';
import 'dart:typed_data';
import 'login.dart';
import 'package:provider/provider.dart';
import 'notifications_service.dart';
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
import 'BookingTripsPage.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'SearchPassenger.dart';
import 'package:project1/ComplaintsPage.dart';
import 'SupportPage.dart';
class Passenger extends StatefulWidget {
  final String? token;
  final List<dynamic> ?upcomingTrips;

  const Passenger({ this.token,this.upcomingTrips, super.key});


  @override
  State<Passenger> createState() => _PassengerState();
}

class _PassengerState extends State<Passenger> {
  late String email='';
  late String fullName='';
  late String phoneNumber='';
  late String Picture='';
  late String gender='';

  String? profilePicture; // لتخزين رابط صورة الملف الشخصي

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
    _startImageSlider();
    _loadUserData().then((_) {
      _fetchProfilePicture();
    });
  }
  void _startImageSlider() {
    _timer = Timer.periodic(Duration(seconds: 3), (timer) {
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
  Future<void> _fetchProfilePicture() async {
    final picture = await fetchProfilePicture();
    if (picture != null) {
      setState(() {
        profilePicture = picture; // تحديث رابط الصورة
      });
    }
  }

  // Method to decode token and save user data in shared preferences
  Future<void> _loadUserData() async {
    if (widget.token != null) {
      Map<String, dynamic> jwtDecodedToken = JwtDecoder.decode(widget.token!);
      email = jwtDecodedToken['email'];
      fullName = jwtDecodedToken['fullName'];
      phoneNumber = jwtDecodedToken['phoneNumber'];
      Picture=jwtDecodedToken['profilePicture'];
      gender=jwtDecodedToken['gender'];

      // Save email and full name in SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('email', email);
      await prefs.setString('fullName', fullName);
      await prefs.setString('phoneNumber', phoneNumber);
      await prefs.setString('profilePicture', Picture);
      await prefs.setString('gender', gender);
    }

    // إعداد التايمر للحركة التلقائية للسلايدر
    _timer = Timer.periodic(Duration(seconds: 3), (Timer timer) {
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


  Future<String?> fetchProfilePicture() async {
    try {
      // URL الخاص بالـ API
      final url = Uri.parse('$profile_picture?email=${email}');

      // إرسال طلب GET
      final response = await http.get(url);

      if (response.statusCode == 200) {
        // فك تشفير الـ JSON
        final data = json.decode(response.body);

        if (data['status'] == true) {
          profilePicture = data['profilePicture'];
         // setState(() {}); // إعادة تعيين الحالة لتحديث الصورة الجديدة
          print("Fetched profile picture URL: $profilePicture");
          return profilePicture;
        } else {
          throw Exception(data['error']);
        }
      } else {
        throw Exception("Failed to fetch profile picture. Status code: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching profile picture: $e");
      return null;
    }

  }

  Widget base64ToImage(String base64String) {
    try {
      Uint8List imageBytes = base64Decode(base64String);
      return CircleAvatar(
        radius: 30, // التحكم في حجم الصورة الدائرية
        backgroundImage: MemoryImage(imageBytes), // فك تشفير الصورة
        child: ClipOval( // لتنسيق الصورة لتكون دائرية
          child: Image.memory(
            imageBytes,
            fit: BoxFit.cover,
            width: 60, // عرض الصورة
            height: 60, // ارتفاع الصورة
          ),
        ),
      );

    } catch (e) {
      print("Error decoding Base64: $e");
      return Center(
        child: Text("Unable to load image"),
      );
    }
  }



  @override
  void dispose() {
    _timer.cancel();
    _pageController.dispose();
    super.dispose();
  }


  void logout() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => Login()),
    );
  }
  Color _buttonColor = primaryColor;

  OverlayEntry? _overlayEntry; // لإدارة القائمة المنسدلة
  final LayerLink _layerLink = LayerLink();
  bool isDropdownOpen = false;

  // إنشاء القائمة المنسدلة
  OverlayEntry _createOverlayEntry() {
    return OverlayEntry(
      builder: (context) => Positioned(
        width: 250,
        child: CompositedTransformFollower(
          link: _layerLink,
          offset: Offset(-150, 40.0),
          child: Material(
            elevation: 5.0,
            borderRadius: BorderRadius.circular(8.0),
            child: Container(
              color: Colors.white,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (NotificationService.getNotifications(email)!.isEmpty)
                    Padding(
                      padding: EdgeInsets.all(20.0),
                      child: Text(
                        'لا توجد إشعارات جديدة',
                        style: TextStyle(color: Colors.black54),
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      itemCount: NotificationService.getNotifications(email)!.length,
                      itemBuilder: (context, index) {
                        print('Rendering notification at index $index: ${NotificationService.getNotifications(email)![index]}');
                        return ListTile(
                          leading: Icon(Icons.check_circle, color: Colors.green),
                          title: Text(NotificationService.getNotifications(email)![index]),
                        );
                      },
                    ),
                  Divider(),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        NotificationService.clearNotifications(email);
                        _closeDropdown();
                      });
                    },
                    child: Text('مسح الإشعارات'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _openDropdown() {
    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
    setState(() {
      isDropdownOpen = true;
    });
  }

  void _closeDropdown() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    setState(() {
      isDropdownOpen = false;
    });
  }


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
            padding: const EdgeInsets.only(top: 28),
            child: Row(
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      'imagess/app_white.jpg',
                      height: 30,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                    child:Text(
                      isArabic ? "وصلني معك" : "assalni Ma'ak",
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 41, 84, 115),
                      ),
                    ),
                    ),
                  ],
                ),
              ],

            ),
          ),
          //backgroundColor: Color.fromARGB(230, 196, 209, 219),
          backgroundColor: Colors.white,
          actions: [
            Padding(
              padding: const EdgeInsets.only(top: 21),
              child: Row(
                children: [
                  // أيقونة الإشعارات مع القائمة المنسدلة
                  CompositedTransformTarget(
                    link: _layerLink,
                    child: IconButton(
                      icon: Stack(
                        children: [
                          Icon(Icons.notifications, size: 30, color: Color.fromARGB(230, 41, 84, 115)),
                          if (NotificationService.getNotificationCount(email) > 0)
                            Positioned(
                              right: 0,
                              top: 0,
                              child: Container(
                                padding: EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                constraints: BoxConstraints(
                                  minWidth: 10,
                                  minHeight: 10,
                                ),
                                child: Text(
                                  '${NotificationService.getNotificationCount(email)}',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                        ],
                      ),
                      onPressed: () {
                        if (isDropdownOpen) {
                          _closeDropdown();
                        } else {
                          _openDropdown();
                        }
                      },
                    ),
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
                  profilePicture != null
                      ? base64ToImage(profilePicture!)
                      : CircleAvatar(
                    backgroundImage:
                    AssetImage('imagess/signup_icon.png'),
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
                  if (widget.token == null || email.isEmpty) {
                    // التعامل مع الحالة إذا كانت القيم غير موجودة
                    print("Error: token or email is missing!");
                    return;
                  }
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PrivacyPage(
                        token: widget.token,
                        email: email,
                      ),
                    ),
                  );
                }
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
              leading: Icon(Icons.report_problem, size: 30),
              title: Text(
                isArabic ? 'الشكاوي' : 'Complaints',
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(230, 41, 84, 115),
                ),
              ),

              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ComplaintsPage()),
                );
              },
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
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SupportPage(isArabic: isArabic),
                  ),
                );
              },
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
      body: SingleChildScrollView(
        child: Column(
          //crossAxisAlignment: CrossAxisAlignment.start, // لجعل الأطفال يصطفون على اليسار
          children: [
            Divider(
              height: 1, // تحديد ارتفاع الـ Divider
              color: Color(0xE6617383), // اللون السكني (لون رمادي فاتح)
            ),
            Align(
              alignment: Alignment.centerLeft, // محاذاة النص لليسار
              child: Padding(
                padding: const EdgeInsets.only(left: 16.0,top:16.0), // ضبط المسافة من اليسار
                child: Text(
                  'Hi $fullName!', // دمج كلمة "Hi" مع fullName
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xE61B3453),
                  ),
                ),
              ),
            ),
            SizedBox(height: 20,),
            Container(
              width: 350, // تحديد العرض المطلوب
              decoration: BoxDecoration(
                border: Border.all(
                  color: Color(0xFF143C73), // لون الكحلي (يمكن تغييره حسب رغبتك)
                  width: 3, // سماكة الحدود
                ),
                borderRadius: BorderRadius.circular(15), // نفس الانحناء للبطاقة
              ),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      // النصوص
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome!',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            "Let's book your trips now!",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[800],
                            ),
                          ),
                          SizedBox(height: 16), // مسافة بين النصوص والزر
                          Padding(
                            padding: EdgeInsets.only(left: 20.0), // إضافة padding من اليسار فقط
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => RatingPage(emailP: email),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor:Color(0xE6FFCD09), // لون الزر
                                foregroundColor:Color(0xE6131A75), // لون النص داخل الزر
                                textStyle: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20), // حواف مستديرة
                                ),
                                elevation: 5, // ارتفاع الزر ليبدو مميزاً
                                padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 8.0), // تعديل padding لتغيير العرض
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.star, // اختر الأيقونة التي ترغب بها
                                    color: Color(0xE6131A75), // لون الأيقونة
                                    size: 20, // حجم الأيقونة
                                  ),
                                  SizedBox(width:3), // فاصل بين الأيقونة والنص
                                  Text('Rating now !'),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(width: 20),
                      Image.asset(
                        'imagess/Mobile inbox-pana.png', // استبدل بمسار الصورة
                        height: 120,
                        width: 130,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.only(left: 20.0, top: 20.0), // إضافة مساحة حول النص
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start, // لضمان أن النص والأيقونة على اليسار
                children: [
                  Icon(
                    Icons.category_sharp, // رمز يعبر عن الأقسام (يمكن تغييره لأي أيقونة أخرى)
                    size: 30, // حجم الأيقونة يتماشى مع النص
                    color: Color(0xE63D5778), // نفس لون النص
                  ),
                  SizedBox(width: 10), // مساحة بين النص والأيقونة
                  Text(
                    'Categories', // النص الذي تريد عرضه
                    style: TextStyle(
                      fontSize: 30, // حجم الخط كبير
                      fontWeight: FontWeight.bold, // خط عريض
                      color: Color(0xE63D5778), // لون أزرق داكن // لون النص
                    ),
                  ),
                  SizedBox(width: 130), // مساحة بين النص والأيقونة
                  Text(
                    'View all', // النص الذي تريد عرضه
                    style: TextStyle(
                      fontSize: 15, // حجم الخط كبير
                      fontWeight: FontWeight.bold, // خط عريض
                      color: Color(0xE60757BC), // لون أزرق داكن // لون النص
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 15),
            // إضافة الكاتلوج
            Card(
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30), // لجعل الزوايا مدورة
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      SecondryColor,
                      softPink,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(10), // نفس الخاصية لتدوير الزوايا
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // صورة الكارد: PageView للصور المتحركة
                    ClipRRect(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(15),
                        topRight: Radius.circular(15),
                      ),
                      child: SizedBox(
                        height: 150,
                        width: double.infinity,
                        child: PageView.builder(
                          controller: _pageController,
                          itemCount: _images.length,
                          itemBuilder: (context, index) {
                            return Image.asset(
                              _images[index],
                              fit: BoxFit.cover,
                              width: double.infinity,
                            );
                          },
                        ),
                      ),
                    ),
                    ListTile(
                      title: Text(
                        isArabic ? 'تصفح جميع الرحلات المتاحة' : 'Browse all available trips',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                          color: Color.fromARGB(230, 20, 60, 115),
                        ),
                      ),
                      subtitle: Text(
                        isArabic ? 'شاهد الرحلات الجديدة الآن!' : 'View new trips now!',
                        style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 18,
                          color: Color.fromARGB(230, 20, 60, 115),
                        ),
                      ),
                      trailing: Icon(
                        Icons.arrow_forward,
                        size: 45,
                        color: primaryColor2,
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TestPage(
                              emailP: email,
                              nameP: fullName,
                              phoneP: phoneNumber,
                              gender:gender,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            Card(
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30), // لجعل الزوايا مدورة
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      SecondryColor,
                      softPink,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(10), // نفس الخاصية لتدوير الزوايا
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // صورة الكارد
                    ClipRRect(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(15),
                        topRight: Radius.circular(15),
                      ),
                      child: Image.asset(
                        'imagess/booking.jpg', // استبدل هذا بالمسار الصحيح للصورة
                        height: 150,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    ListTile(
                      title: Text(
                        isArabic ? 'البحث عن رحلات ' : 'Search Trips',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                          color: Color.fromARGB(230, 20, 60, 115),
                        ),
                      ),
                      subtitle: Text(
                        isArabic ? 'ابحث عن وجهتك الآن باستخدام الفلترة ' : 'Find your destination now using filtering',
                        style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 16,
                          color: Color.fromARGB(230, 20, 60, 115),
                        ),
                      ),
                      trailing: Icon(
                        Icons.arrow_forward,
                        size: 45,
                        color: primaryColor2,
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SearchTripsPage(
                              emailP: email,
                              nameP: fullName,
                              phoneP: phoneNumber,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            Card(
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30), // لجعل الزوايا مدورة
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      SecondryColor,
                      softPink,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(10), // نفس الخاصية لتدوير الزوايا
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // صورة الكارد
                    ClipRRect(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(15),
                        topRight: Radius.circular(15),
                      ),
                      child: Image.asset(
                        'imagess/active.jpg', // استبدل هذا بالمسار الصحيح للصورة
                        height: 150,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    ListTile(
                      title: Text(
                        isArabic ? 'حجوزاتك' : 'Your Active Bookings',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                          color: Color.fromARGB(230, 20, 60, 115),
                        ),
                      ),
                      subtitle: Text(
                        isArabic ? 'إدارة حجوزاتك الحالية' : 'Manage your current bookings',
                        style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 16,
                          color: Color.fromARGB(230, 20, 60, 115),
                        ),
                      ),
                      trailing: Icon(
                        Icons.arrow_forward,
                        size: 45,
                        color: primaryColor2,
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BookingTripsPage(emailP: email),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            Card(
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30), // لجعل الزوايا مدورة
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      SecondryColor,
                      softPink,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(10), // نفس الخاصية لتدوير الزوايا
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // صورة الكارد
                    ClipRRect(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(15),
                        topRight: Radius.circular(15),
                      ),
                      child: Image.asset(
                        'imagess/drive_pass.jpg', // استبدل هذا بالمسار الصحيح للصورة
                        height: 150,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    ListTile(
                      title: Text(
                        isArabic ? 'جميع السائقين في التطبيق' : 'All Drivers in Application',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                          color: Color.fromARGB(230, 20, 60, 115),
                        ),
                      ),
                      subtitle: Text(
                        isArabic ? 'توصل الى اي سائق تريده بسرعة.' : 'Quickly connect with any driver you need',
                        style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 16,
                          color: Color.fromARGB(230, 20, 60, 115),
                        ),
                      ),
                      trailing: Icon(
                        Icons.arrow_forward,
                        size: 45,
                        color: primaryColor2,
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BookingTripsPage(emailP: email),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
          ],
        ),
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
  final String? token;  // إضافة الـ token هنا
  final String email;

  // Constructor لتمرير الـ token
  PrivacyPage({Key? key, this.token,required this.email}) : super(key: key);

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
                  MaterialPageRoute(builder: (context) => VisibilitySettingsScreen(email:email)),
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
              leading: Icon(Icons.block, size: 30, color: primaryColor2),
              title: Text(
                isArabic ? 'جهات اتصال محظورة' : 'Blocked Contact',
                style: TextStyle(fontSize: 20, color: SecondryColor2, fontWeight: FontWeight.bold),
              ),
              onTap: () {
                // تمرير الـ token والمعلومات إلى صفحة BlockedContactsScreen
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BlockedContactsScreen(
                    //  token: token,  // استخدام الـ token الذي تم تمريره
                    ),
                  ),
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