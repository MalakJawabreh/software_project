import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'login.dart';
import 'package:provider/provider.dart';
import 'theme_provider.dart';
import 'language_provider.dart';
import 'ChangePasswordPage.dart';
import 'VisibilitySettingsScreen.dart';
class Passenger extends StatefulWidget {
  final String token;
  const Passenger({required this.token, super.key});

  @override
  State<Passenger> createState() => _PassengerState();
}

class _PassengerState extends State<Passenger> {
  late String email;
  late String fullName;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    // فك شفرة التوكن لاستخراج البريد الإلكتروني
    Map<String, dynamic> jwtDecodedToken = JwtDecoder.decode(widget.token);
    email = jwtDecodedToken['email'];
    fullName = jwtDecodedToken['fullName'];
  }

  void logout() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => Login()),
    );
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
    print("Searching trips to: ${_destinationController
        .text} with filter: $_selectedFilter at time: $_selectedTime");
  }

  void showAds() {
    // عرض الإعلانات
    print("Displaying ads...");
    // يمكنك إضافة دالة لإظهار الإعلانات أو الانتقال إلى شاشة الإعلانات
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final locale = languageProvider.locale.languageCode;
    final isArabic = languageProvider
        .isArabic; // الحصول على قيمة isArabic من LanguageProvider
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
                SizedBox(width: 10),
                Text(
                  isArabic ? "وصلني معك" : "Assalni Ma'ak",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
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
                mainAxisAlignment: MainAxisAlignment.end,
                // Align items to the right
                children: [
                  IconButton(
                    icon: Icon(Icons.notifications, size: 25,
                        color: Color.fromARGB(230, 41, 84, 115)),
                    onPressed: () {
                      // Add action for notifications button here
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.chat, size: 25,
                        color: Color.fromARGB(230, 41, 84, 115)),
                    onPressed: () {
                      // Add action for chat button here
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.menu, size: 25,
                        color: Color.fromARGB(230, 41, 84, 115)),
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
                      Text(
                        fullName,
                        style: TextStyle(
                          color: Color.fromARGB(230, 41, 84, 115),
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        email,
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

      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // الأيقونة والاسم في أعلى الصفحة
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Color.fromARGB(230, 41, 84, 115),
                    // لون الخلفية
                    radius: 25,
                    child: Icon(
                      Icons.person, // أيقونة البيرسون
                      size: 30, // حجم الأيقونة
                      color: Colors.white, // لون الأيقونة
                    ),
                  ),
                  SizedBox(width: 10), // مسافة بين الأيقونة والاسم
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        fullName, // الاسم الكامل
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(230, 41, 84, 115),
                        ),
                      ),
                      SizedBox(height: 5),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 20), // مسافة بعد الأيقونة والاسم

              // زر البحث عن الرحلات
              MouseRegion(
                onEnter: (_) {
                  setState(() {
                    _buttonColor = primaryColor.withOpacity(
                        0.7); // تغيير اللون عند المرور بالماوس
                  });
                },
                onExit: (_) {
                  setState(() {
                    _buttonColor = primaryColor; // العودة للون الأساسي
                  });
                },
                child: ElevatedButton(
                  onPressed: () {
                    _showSearchDialog(isArabic);
                  },
                  child: Text(isArabic ? 'ابحث عن رحلة' : 'Search for Trips'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _buttonColor,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(
                        horizontal: 100, vertical: 15),
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
                  title: Text(isArabic ? 'حجوزاتك' : 'Your Active Bookings',
                      style: TextStyle(color: primaryColor)),
                  subtitle: Text(isArabic
                      ? 'إدارة حجوزاتك الحالية'
                      : 'Manage your current bookings',
                      style: TextStyle(color: Colors.black87)),
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
                  title: Text(isArabic ? 'الأشعارات ' : 'Notifications',
                      style: TextStyle(color: primaryColor)),
                  subtitle: Text(isArabic
                      ? 'التحقق من الإشعارات الخاصة بك'
                      : 'Check your notifications',
                      style: TextStyle(color: Colors.black87)),
                  trailing: Icon(Icons.arrow_forward, color: primaryColor),
                  onTap: () {
                    // الانتقال إلى شاشة الإشعارات
                  },
                ),
              ),
              Card(
                elevation: 5,
                color: Colors.grey.shade200,
                child: ListTile(
                  title: Text(isArabic ? 'الأعلانات' : 'Advertisements',
                      style: TextStyle(color: primaryColor)),
                  subtitle: Text(isArabic
                      ? 'رؤية الأعلانات الجدية الآن'
                      : 'View new ads now!',
                      style: TextStyle(color: Colors.black87)),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pop(context); // الرجوع إلى الشاشة السابقة
        },
        backgroundColor: primaryColor,
        child: Icon(Icons.arrow_back, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation
          .startDocked, // محاذاة يسار أسفل
    );
  }

  // حوار البحث
  void _showSearchDialog(bool isArabic) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(isArabic ? "ابحث عن رحلات" : "Search for Trips"),

          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _destinationController,
                decoration: InputDecoration(
                  labelText: isArabic ? "أدخل الوجهة" : "Enter destination",
                ),
              ),
              SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: _selectedFilter,
                onChanged: (newValue) {
                  setState(() {
                    _selectedFilter = newValue!;
                  });
                },
                items: <String>['Price', 'Duration', 'Ratings']
                    .map((value) =>
                    DropdownMenuItem<String>(
                      value: value,
                      child: Text(isArabic ? translateFilter(value) : value),
                    ))
                    .toList(),
              ),
              SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: _selectedTime,
                onChanged: (newValue) {
                  setState(() {
                    _selectedTime = newValue!;
                  });
                },
                items: <String>['Any Time', 'Morning', 'Afternoon', 'Evening']
                    .map((value) =>
                    DropdownMenuItem<String>(
                      value: value,
                      child: Text(isArabic ? translateTime(value) : value),
                    ))
                    .toList(),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                searchTrips();
                Navigator.of(context).pop();
              },
              child: Text(isArabic ? "بحث" : "Search"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(isArabic ? "إلغاء" : "Cancel"),
            ),
          ],
        );
      },
    );
  }

// دالة لترجمة الفلاتر حسب اللغة
  String translateFilter(String value) {
    switch (value) {
      case 'Price':
        return 'السعر';
      case 'Duration':
        return 'المدة';
      case 'Ratings':
        return 'التقييمات';
      default:
        return value;
    }
  }

// دالة لترجمة الأوقات حسب اللغة
  String translateTime(String value) {
    switch (value) {
      case 'Any Time':
        return 'في أي وقت';
      case 'Morning':
        return 'الصباح';
      case 'Afternoon':
        return 'الظهر';
      case 'Evening':
        return 'المساء';
      default:
        return value;
    }
  }
}

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
              leading: Icon(Icons.language, size: 30, color: primaryColor), // تغيير لون الأيقونة
              title: Text(
                isArabic ? 'اختر اللغة' : 'Select Language',
                style: TextStyle(fontSize: 20, color: primaryColor), // تغيير لون النص
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
              leading: Icon(Icons.palette, color: primaryColor), // تغيير لون الأيقونة
              title: Text(
                isArabic ? 'تغيير الثيم' : 'Change Theme',
                style: TextStyle(fontSize: 20, color: primaryColor), // تغيير لون النص
              ),
              onTap: () {
                // تغيير الثيم
                Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
              },
            ),
            ListTile(
              leading: Icon(Icons.notifications, size: 30, color: primaryColor), // تغيير لون الأيقونة
              title: Text(
                isArabic ? 'الإشعارات' : 'Notifications',
                style: TextStyle(fontSize: 20, color: primaryColor), // تغيير لون النص
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
              leading: Icon(Icons.lock_outline, size: 30, color: primaryColor), // تغيير لون الأيقونة
              title: Text(
                isArabic ? 'تغيير كلمة السر' : 'Change password',
                style: TextStyle(fontSize: 20, color: primaryColor), // تغيير لون النص
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
              leading: Icon(Icons.visibility, size: 30, color: primaryColor),
              title: Text(
                isArabic ? 'رؤية الحساب' : 'Visibility',
                style: TextStyle(fontSize: 20, color: primaryColor),
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
              leading: Icon(Icons.security, size: 30, color: primaryColor), // تغيير لون الأيقونة
              title: Text(
                isArabic ? 'المصادقة' : 'Authentication',
                style: TextStyle(fontSize: 20, color: primaryColor), // تغيير لون النص
              ),
              onTap: () {
                // التعامل مع المصادقة هنا
              },
            ),
          ],
        ),
      ),
    );
  }
}
const Color SecondryColor = Color.fromARGB(230, 196, 209, 219);

const Color primaryColor = Color.fromARGB(230, 41, 84, 115); // اللون الأساسي
