import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
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

  // نضيف GlobalKey لفتح الـ Drawer
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
      key: _scaffoldKey,  // تحديد الـ GlobalKey هنا
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(80), // تحديد الارتفاع الجديد لـ AppBar
        child: AppBar(
          automaticallyImplyLeading: false,
          title: Padding(
            padding: const EdgeInsets.only(top: 32), // مسافة رأسية لتحريك النص والصورة للأسفل
            child: Row(
              children: [
                // إضافة صورة بجانب النص
                Image.asset(
                  'imagess/app_icon.jpg', // مسار الصورة
                  height: 40, // تحديد ارتفاع الصورة
                ),
                SizedBox(width: 0), // مسافة بين الصورة والنص
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
            // إضافة Padding للأيقونة
            Padding(
              padding: const EdgeInsets.only(top: 19), // تحديد الـ padding للأيقونة
              child: IconButton(
                icon: Icon(Icons.menu, size: 30,color: Color.fromARGB(230, 41, 84, 115)),
                onPressed: () {
                  _scaffoldKey.currentState?.openEndDrawer(); // فتح الـ Drawer من الجهة اليمنى
                },
              ),
            ),
          ],
        ),
      ),

      endDrawer: Container(
        width: 300, // تحديد عرض الـ Drawer
        child: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              // تعديل DrawerHeader لإضافة صورة البروفايل والنص
              DrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.white, // لون خلفية الهيدر
                ),
                child: Row(
                  children: [
                    // إضافة صورة البروفايل بشكل دائري
                    CircleAvatar(
                      backgroundImage: AssetImage('imagess/signup_icon.png'), // مسار صورة البروفايل
                      radius: 30, // حجم الصورة (دائري)
                    ),
                    SizedBox(width: 10), // مسافة بين الصورة والنص
                    // إضافة الاسم والبريد الإلكتروني في Column
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center, // محاذاة النص في المنتصف عموديًا بالنسبة للصورة
                      children: [
                        Text(
                          username, // اسم المستخدم
                          style: TextStyle(
                            color: Color.fromARGB(230, 41, 84, 115),
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 5), // إضافة مسافة بين الاسم والبريد الإلكتروني
                        Text(
                          email, // البريد الإلكتروني
                          style: TextStyle(
                            color: Color.fromARGB(230, 41, 84, 115), // لون أخف للبريد الإلكتروني
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // إضافة الخيارات في الـ Drawer
              ListTile(
                leading: Icon(Icons.settings,size:30),  // أيقونة الإعدادات
                title: Text(
                    'Settings',
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(230, 41, 84, 115),
                  ),
                ),
                onTap: () {
                  // منطق لفتح خيار معين
                },
              ),
              //Privacy  Reviews  Support  Logout
              ListTile(
                leading: Icon(Icons.privacy_tip,size:30),  // أيقونة الإعدادات
                title: Text(
                  'Privacy',
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(230, 41, 84, 115),
                  ),
                ),
                onTap: () {
                  // منطق لفتح خيار معين
                },
              ),
              ListTile(
                leading: Icon(Icons.reviews,size:30),  // أيقونة الإعدادات
                title: Text(
                  'Reviews',
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(230, 41, 84, 115),
                  ),
                ),
                onTap: () {
                  // منطق لفتح خيار معين
                },
              ),
              ListTile(
                leading: Icon(Icons.contact_support,size:30),  // أيقونة الإعدادات
                title: Text(
                  'Support',
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(230, 41, 84, 115),
                  ),
                ),
                onTap: () {
                  // منطق لفتح خيار معين
                },
              ),
              ListTile(
                leading: Icon(Icons.logout,size:30),  // أيقونة الإعدادات
                title: Text(
                  'Logout',
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(230, 41, 84, 115),
                  ),
                ),
                onTap: () {
                  // منطق لفتح خيار معين
                },
              ),
            ],
          ),
        ),
      ),



      body: Column(
        children: [
          // الجزء العلوي الذي يحتوي على صورة الشخص واسم الشخص وأيقونات الإشعارات، الشات، والمنيو
          Padding(
            padding: const EdgeInsets.only(top: 20, left: 16, right: 16),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundImage: AssetImage('imagess/signup_icon.png'),
                  radius: 20, // تغيير الحجم حسب الحاجة
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
                  ],
                ),
                Spacer(),
                // أيقونة الإشعارات
                IconButton(
                  icon: Icon(Icons.notifications, size: 25),
                  onPressed: () {
                    // منطق الإشعارات
                  },
                ),
                // أيقونة الشات
                IconButton(
                  icon: Icon(Icons.chat, size: 25),
                  onPressed: () {
                    // منطق الشات
                  },
                ),
              ],
            ),
          ),

          SizedBox(height: 20), // إضافة مسافة بين الجزء العلوي وبقية الصفحة

          // المحتوى الرئيسي الذي يحتوي على زر الخروج
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Drivers",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: logout,
                  child: Text("Logout"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
