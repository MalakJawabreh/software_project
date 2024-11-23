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
                  "assalni Ma'ak",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(230, 41, 84, 115),
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
                mainAxisAlignment: MainAxisAlignment.end, // Align items to the right
                children: [
                  IconButton(
                    icon: Icon(Icons.notifications, size: 25, color: Color.fromARGB(230, 41, 84, 115)),
                    onPressed: () {
                      // Add action for notifications button here
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.chat, size: 25, color: Color.fromARGB(230, 41, 84, 115)),
                    onPressed: () {
                      // Add action for chat button here
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.menu, size: 25, color: Color.fromARGB(230, 41, 84, 115)),
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
                'Settings',
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(230, 41, 84, 115),
                ),
              ),
              onTap: () {},
            ),
            ListTile(
              leading: Icon(Icons.privacy_tip, size: 30),
              title: Text(
                'Privacy',
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(230, 41, 84, 115),
                ),
              ),
              onTap: () {},
            ),
            ListTile(
              leading: Icon(Icons.reviews, size: 30),
              title: Text(
                'Reviews',
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
                'Support',
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
                'Logout',
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
                    backgroundColor: Color.fromARGB(230, 41, 84, 115), // لون الخلفية
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

              // قسم الاعلانات
              Card(
                elevation: 5,
                color: Colors.grey.shade200,
                child: ListTile(
                  title: Text("Advertisements", style: TextStyle(color: primaryColor)),
                  subtitle: Text("View new Ads", style: TextStyle(color: Colors.black87)),
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
      floatingActionButtonLocation: FloatingActionButtonLocation.startDocked, // محاذاة يسار أسفل
    );
  }

  // حوار البحث
  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Search for Trips"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _destinationController,
                decoration: InputDecoration(labelText: "Enter destination"),
              ),
              DropdownButtonFormField<String>(
                value: _selectedFilter,
                onChanged: (newValue) {
                  setState(() {
                    _selectedFilter = newValue!;
                  });
                },
                items: <String>['Price', 'Duration', 'Ratings']
                    .map((value) => DropdownMenuItem<String>(value: value, child: Text(value)))
                    .toList(),
              ),
              DropdownButtonFormField<String>(
                value: _selectedTime,
                onChanged: (newValue) {
                  setState(() {
                    _selectedTime = newValue!;
                  });
                },
                items: <String>['Any Time', 'Morning', 'Afternoon', 'Evening']
                    .map((value) => DropdownMenuItem<String>(value: value, child: Text(value)))
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
              child: Text("Search"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Cancel"),
            ),
          ],
        );
      },
    );
  }
}

const Color primaryColor = Color.fromARGB(230, 41, 84, 115); // اللون الرئيسي
