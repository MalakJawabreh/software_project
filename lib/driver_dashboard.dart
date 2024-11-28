import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:project1/profile_driver.dart';
import 'package:project1/search.dart';
import 'creat_trip_page.dart';
import 'login.dart';

class Driver extends StatefulWidget {
  final String token;
  const Driver({required this.token, super.key});

  @override
  State<Driver> createState() => _DriverState();
}

class _DriverState extends State<Driver> {
  late String email;
  late String username;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    Map<String, dynamic> jwtDecodedToken = JwtDecoder.decode(widget.token);
    email = jwtDecodedToken['email'];
    username = jwtDecodedToken['fullName'];
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
                          MaterialPageRoute(builder: (context) => SetDestinationPage()), // اسم الصفحة
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
                    child: TabBarView(
                      children: [
                        Center(child: Text("Upcoming Trips")),
                        Center(child: Text("Completed Trips")),
                        Center(child: Text("Canceled Trips")),
                      ],
                    ),
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
