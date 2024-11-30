import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:project1/profile_driver.dart';
import 'package:project1/search.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'config.dart';
import 'creat_trip_page.dart';
import 'package:http/http.dart' as http;
import 'login.dart';
import 'dart:async';

class Driver extends StatefulWidget {
  final String token;
  Driver({this.token = ''});

  @override
  State<Driver> createState() => _DriverState();
}

class _DriverState extends State<Driver> {
  late String email = '';  // تعيين قيمة افتراضية
  late String username = '';  // تعيين قيمة افتراضية
  List<dynamic> upcomingTrips = [];
  List<dynamic> completedTrips = [];



  StreamController<Map<String, dynamic>> dashboardStreamController = StreamController.broadcast();


  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    // محاولة استخراج البيانات من التوكن إذا كان موجودًا
    if (widget.token.isNotEmpty) {
      try {
        Map<String, dynamic> jwtDecodedToken = JwtDecoder.decode(widget.token);
        email = jwtDecodedToken['email'];
        username = jwtDecodedToken['fullName'];

        // حفظ البيانات في SharedPreferences
        saveUserData(email, username);

        fetchUpcomingTrips().then((_) {
          updateTripsBasedOnTime();
        });
      } catch (e) {
        print("Invalid token: $e");
      }
    } else {
      // إذا لم يكن هناك توكن، نحاول جلب البيانات من SharedPreferences
      loadUserData().then((_) {
        // بعد تحميل البيانات من SharedPreferences، استدعاء fetchUpcomingTrips
        fetchUpcomingTrips().then((_) {
          updateTripsBasedOnTime();
        });
      });
    }
    // إضافة مؤقت لتحديث البيانات
    Timer.periodic(Duration(seconds: 30), (timer) {
      updateTripsBasedOnTime();
    });

  }

// دالة لحفظ البيانات في SharedPreferences
  Future<void> saveUserData(String email, String username) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('email', email);
    await prefs.setString('username', username);

    print('Saved email: $email');
    print('Saved username: $username');
  }

// دالة لتحميل البيانات من SharedPreferences
  Future<void> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      email = prefs.getString('email') ?? 'defaultEmail@example.com'; // القيمة الافتراضية في حالة عدم وجود بيانات
      username = prefs.getString('username') ?? 'defaultUsername'; // القيمة الافتراضية في حالة عدم وجود بيانات
    });
    // طباعة البيانات للتحقق منها
    print('Loaded email: $email');
    print('Loaded username: $username');
  }

    Future<void> fetchUpcomingTrips() async {

      try {
        print('Fetching trips for email: $email');
        final response = await http.get(Uri.parse('$driver_trips?driverEmail=$email'));
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          if (data['status']) {
            setState(() {
              upcomingTrips = data['trips'];
            });
          }
        } else {
          print('Failed to fetch trips: ${response.statusCode}');
        }
      } catch (error) {
        print('Error fetching trips: $error');
      }
    }



  void updateTripsBasedOnTime() {
    final now = DateTime.now();
    final dateFormat = DateFormat("yyyy-MM-ddTHH:mm:ss.SSS'Z' h:mm a");

    setState(() {
      upcomingTrips.removeWhere((trip) {
        try {
          final dateTime = dateFormat.parse(trip['date'] + ' ' + trip['time'], true).toLocal();
          if (dateTime.isBefore(now)) {
            completedTrips.add(trip); // نقل الرحلة إلى completed
            return true; // إزالة من upcoming
          }
        } catch (e) {
          print('Error parsing date: $e');
        }
        return false;
      });
    });
  }




  void logout() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => Login()),
    );
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
                    fontSize: 25,
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
              padding: const EdgeInsets.only(top: 22),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.notifications, size: 30, color: Color.fromARGB(230, 41, 84, 115)),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: Icon(Icons.chat, size: 30, color: Color.fromARGB(230, 41, 84, 115)),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: Icon(Icons.menu, size: 30, color: Color.fromARGB(230, 41, 84, 115)),
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
        width: 340,
        child: Container(
          color: Colors.white,  // تغيير اللون الأبيض كخلفية للـ Drawer بالكامل
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              Container(
                color: Colors.white,
                //height: 100, // تحديد ارتفاع مخصص
                padding: EdgeInsets.only(top: 100),
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 25),
                      child: CircleAvatar(
                        backgroundImage: AssetImage('imagess/signup_icon.png'),
                        radius: 30,
                      ),
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
                                  username: username,
                                ),
                              ),
                            );
                          },
                          child: Text(
                            username,
                            style: TextStyle(
                              color: Color.fromARGB(230, 41, 84, 115),
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 30,),
              ListTile(
                leading: Icon(Icons.settings, size: 30, color: Color.fromARGB(230, 41, 84, 115)),
                title: Text(
                  'Settings',
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(230, 41, 84, 115),
                  ),
                ),
                contentPadding: EdgeInsets.only(left: 30),  // إضافة بادينغ من اليسار
                onTap: () {},
              ),
              SizedBox(height: 10,),
              ListTile(
                leading: Icon(Icons.privacy_tip, size: 30, color: Color.fromARGB(230, 41, 84, 115)),
                title: Text(
                  'Privacy',
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(230, 41, 84, 115),
                  ),
                ),
                contentPadding: EdgeInsets.only(left: 30),
                onTap: () {},
              ),
              SizedBox(height: 10,),
              ListTile(
                leading: Icon(Icons.reviews, size: 30, color: Color.fromARGB(230, 41, 84, 115)),
                title: Text(
                  'Reviews',
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(230, 41, 84, 115),
                  ),
                ),
                contentPadding: EdgeInsets.only(left: 30),
                onTap: () {},
              ),
              SizedBox(height: 10,),
              ListTile(
                leading: Icon(Icons.contact_support, size: 30, color: Color.fromARGB(230, 41, 84, 115)),
                title: Text(
                  'Support',
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(230, 41, 84, 115),
                  ),
                ),
                contentPadding: EdgeInsets.only(left: 30),
                onTap: () {},
              ),
              SizedBox(height: 10,),
              ListTile(
                leading: Icon(Icons.logout, size: 30, color: Color.fromARGB(230, 41, 84, 115)),
                title: Text(
                  'Logout',
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(230, 41, 84, 115),
                  ),
                ),
                contentPadding: EdgeInsets.only(left: 30),
                onTap: logout,
              ),
            ],
          ),
        ),
      ),

      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 15, left: 16, right: 16),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundImage: AssetImage('imagess/signup_icon.png'),
                  radius: 25,
                ),
                SizedBox(width: 7),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      username,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(230, 41, 84, 115),
                      ),
                    ),
                    Text(
                      email,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(230, 41, 84, 115),
                      ),
                    ),
                  ],
                ),
                Spacer(),
              ],
            ),
          ),
          SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 20),
                child: Text(
                  "My Trips",
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.grey[700]),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 20),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.add_circle_outline, size: 30, color: Colors.grey[700]),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => SetDestinationPage(email: email)), // اسم الصفحة
                        );
                      },
                    ),
                  ],

                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          Expanded(
            child: DefaultTabController(
              length: 3,
              child: Column(
                children: [
                  TabBar(
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.grey[800],
                    indicator: BoxDecoration(
                      color: Color.fromARGB(230, 41, 84, 115),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    indicatorSize: TabBarIndicatorSize.tab,
                    indicatorWeight: 0,
                    labelStyle: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    unselectedLabelStyle: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                    tabs: [
                      Tab(
                        child: Text("UPCOMING"),
                      ),
                      Tab(
                        child: Text("COMPLETED"),
                      ),
                      Tab(
                        child: Text("CANCELED"),
                      ),
                    ],
                  ),
                  Expanded(
                    child:TabBarView(
                      children: [
                        ListView.builder(
                          itemCount: upcomingTrips.length,
                          itemBuilder: (context, index) {
                            final trip = upcomingTrips[index];
                            return ListTile(
                              title: Text("From: ${trip['from']}"),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("To: ${trip['to']}"),
                                  Text("Time: ${trip['time']}"),
                                ],
                              ),
                              trailing: Text("Date: ${trip['date']}"),
                            );
                          },
                        ),
                        ListView.builder(
                          itemCount: completedTrips.length,
                          itemBuilder: (context, index) {
                            final trip = completedTrips[index];
                            return ListTile(
                              title: Text("From: ${trip['from']}"),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("To: ${trip['to']}"),
                                  Text("Time: ${trip['time']}"),
                                ],
                              ),
                              trailing: Text("Date: ${trip['date']}"),
                            );
                          },
                        ),
                        Center(child: Text("Canceled Trips")),
                      ],
                    )

                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}