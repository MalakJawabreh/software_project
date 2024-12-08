import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:project1/profile_driver.dart';
import 'package:project1/regist_driver_1.dart';
import 'package:project1/regist_driver_3.dart';
import 'package:project1/search.dart';
import 'package:project1/test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'config.dart';
import 'creat_trip_page.dart';
import 'package:http/http.dart' as http;
import 'driver_data_model.dart';
import 'login.dart';
import 'dart:async';

class Driver extends StatefulWidget {
  final String token;
  Driver({this.token = ''});

  @override
  State<Driver> createState() => _DriverState();
}

class _DriverState extends State<Driver> {
  late String email = '';
  late String username = '';
  late String phoneNumber='';
  late String licensePicture='';
  late String profilePicture='';
  List<dynamic> upcomingTrips = [];
  List<dynamic> completedTrips = [];
  List<dynamic> canceledTrips = [];

  late String profilepicture="";


  StreamController<Map<String, dynamic>> dashboardStreamController = StreamController.broadcast();


  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();


  @override
  void initState() {
    super.initState();

    // تخصيص لون شريط الحالة فقط
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark.copyWith(
      statusBarColor: Colors.black, // جعل شريط الحالة شفافًا
      statusBarIconBrightness: Brightness.dark, // أيقونات الساعة والشحن داكنة
    ));

    // محاولة استخراج البيانات من التوكن إذا كان موجودًا
    if (widget.token.isNotEmpty) {
      try {
        Map<String, dynamic> jwtDecodedToken = JwtDecoder.decode(widget.token);
        email = jwtDecodedToken['email'];
        username = jwtDecodedToken['fullName'];
        phoneNumber=jwtDecodedToken['phoneNumber'];
        licensePicture=jwtDecodedToken['licensePicture'];
        profilePicture=jwtDecodedToken['profilePicture'];

        fetchProfilePicture();
        // استدعاء دالة التحديث
        // حفظ البيانات في SharedPreferences
        saveUserData(email, username,phoneNumber,licensePicture,profilePicture);

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
  Future<void> saveUserData(String email, String username,String phone,String licensePicture,String profilePicture) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('email', email);
    await prefs.setString('username', username);
    await prefs.setString('phone', phone);
    await prefs.setString('phone', licensePicture);
    await prefs.setString('phone', profilePicture);


    print('Saved email: $email');
    print('Saved username: $username');
    print('Saved phone: $phone');
  }

// دالة لتحميل البيانات من SharedPreferences
  Future<void> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      email = prefs.getString('email') ?? 'defaultEmail@example.com'; // القيمة الافتراضية في حالة عدم وجود بيانات
      username = prefs.getString('username') ?? 'defaultUsername';
      phoneNumber = prefs.getString('phone') ?? '0000';
      licensePicture=prefs.getString('licensePicture') ?? '0000';
      profilePicture=prefs.getString('profilePicture') ?? '0000';
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
          profilepicture = data['profilePicture'];
          setState(() {}); // إعادة تعيين الحالة لتحديث الصورة الجديدة
          print("Fetched profile picture URL: $profilepicture");
          return profilepicture;
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


  String formatDate(String dateTime) {
    // تحويل النص إلى كائن DateTime
    final parsedDate = DateTime.parse(dateTime);
    // تنسيق التاريخ بالشكل المطلوب
    return DateFormat('dd MMMM yyyy').format(parsedDate); // مثال: 11 ديسمبر 2024
  }

  void cancelTrip(int index) async {
    final canceledTrip = upcomingTrips[index]; // احصل على الرحلة التي سيتم إلغاؤها
    final tripId = canceledTrip['_id']; // تأكد من استخدام الحقل الصحيح للـ id
    try {
      // إرسال طلب الحذف إلى السيرفر
      final response = await http.delete(Uri.parse('$delete_trip/$tripId'), headers: {
        'Content-Type': 'application/json',
      });

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status']) {
          // إذا تم الحذف بنجاح، قم بتحديث القائمة
          setState(() {
            upcomingTrips.removeAt(index); // حذف الرحلة من قائمة upcoming
            canceledTrips.add(canceledTrip); // إضافة الرحلة إلى قائمة canceled
          });
          print('Trip canceled successfully.');
        } else {
          print('Failed to cancel trip: ${data['error']}');
        }
      } else {
        print('Failed to cancel trip. Status code: ${response.statusCode}');
      }
    } catch (error) {
      print('Error canceling trip: $error');
    }
  }

  void logout() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => Login()),
    );
  }


  @override
  Widget build(BuildContext context) {
    final driverData = Provider.of<DriverDataModel>(context);
    return Scaffold(
      key: _scaffoldKey,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(80),
        child: AppBar(
          automaticallyImplyLeading: false,
          title: Padding(
            padding: const EdgeInsets.only(top: 25),
            child: Row(
              children: [
                Image.asset(
                  'imagess/app_icon.jpg',
                  height: 40,
                ),
                //base64ToImage(licensePicture),
                SizedBox(width: 0),
                Padding(
                  padding: const EdgeInsets.only(top: 13),
                  child: Text(
                    "assalni Ma'ak",
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(230, 41, 84, 115),
                    ),
                  ),
                )
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
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => DriverRegistrationPage()), // اسم الصفحة
                      );
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.chat, size: 30, color: Color.fromARGB(230, 41, 84, 115)),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => DriverLicenseUpload()), // اسم الصفحة
                      );

                    },
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
                      // child: CircleAvatar(
                      //   radius: 35,
                      //   backgroundImage:FileImage(driverData.profileImage!),
                      // ),
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
              radius: 25,
              backgroundImage:profilepicture.isNotEmpty
                  ? MemoryImage(base64Decode(profilepicture))
                  : null,
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
                          MaterialPageRoute(builder: (context) => SetDestinationPage(email: email,name:username,phone:phoneNumber)), // اسم الصفحة
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
                        // Upcoming Trips
                        ListView.builder(
                          itemCount: upcomingTrips.length,
                          itemBuilder: (context, index) {
                            final trip = upcomingTrips[index];
                            return Card(
                              elevation: 4,
                              margin: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                                side: BorderSide(color:Colors.grey.shade500, width: 1), // إضافة حافة ملونة
                              ),
                              color:Color.fromARGB(255, 234, 241, 246), // تعيين لون الخلفية
                              shadowColor:Color.fromARGB(230, 41, 84, 115),
                              child: Padding(
                                padding: EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Details: Time, Date
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween, // توزيع العناصر بين اليسار واليمين
                                      children: [
                                        Row(
                                          children: [
                                            Icon(Icons.calendar_month_outlined, color: Colors.pinkAccent),
                                            SizedBox(width: 1),
                                            Text("Date:${formatDate(trip['date'])}",style: TextStyle(fontSize: 15.5,fontWeight: FontWeight.w600,color:Color.fromARGB(230, 41, 84, 115),),),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            Icon(Icons.access_time, color: Colors.pinkAccent),
                                            SizedBox(width: 1),
                                            Text("Time:${trip['time']}",style: TextStyle(fontSize: 15.5,fontWeight: FontWeight.w600,color:Color.fromARGB(230, 41, 84, 115),),),
                                          ],
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 1),
                                    // Header: From and To
                                    Row(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(top: 0.0),  // المسافة من الأعلى
                                          child: Column(
                                            children: [
                                              Icon(Icons.my_location, color: Colors.green, size: 22),
                                              Container(
                                                height: 5,
                                                width: 2,
                                                color: Colors.grey, // الخط الوهمي
                                              ),
                                              SizedBox(height: 3),
                                              Container(
                                                height: 5,
                                                width: 2,
                                                color: Colors.grey, // الخط الوهمي
                                              ),
                                              SizedBox(height: 3),
                                              Container(
                                                height: 5,
                                                width: 2,
                                                color: Colors.grey, // الخط الوهمي
                                              ),
                                              Icon(Icons.pin_drop, color: Colors.orange, size: 22),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(top: 1.0),  // المسافة من الأعلى
                                                child: Row(
                                                  children: [
                                                    RichText(
                                                      text: TextSpan(
                                                        children: [
                                                          TextSpan(
                                                            text: "From: ",
                                                            style: TextStyle(
                                                              fontSize: 16,
                                                              fontWeight: FontWeight.bold,
                                                              color: Colors.green,  // اللون الذي ترغب فيه لكلمة "From"
                                                            ),
                                                          ),
                                                          TextSpan(
                                                            text: "${trip['from']}",
                                                            style: TextStyle(
                                                              fontSize: 16,
                                                              fontWeight: FontWeight.bold,
                                                              color: Colors.black,  // اللون لبقية النص
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    Spacer(),  // هذا سيضمن أن الأيقونة تكون في أقصى اليمين
                                                    IconButton(
                                                      icon: Icon(Icons.map_outlined, color:Color.fromARGB(230, 41, 84, 115),),  // اختر الأيقونة المناسبة (مثل خريطة)
                                                      onPressed: () {
                                                        // أضف هنا الكود الذي سيعرض الخريطة أو يقوم بالإجراء الذي تريده
                                                        print("Open map from ${trip['from']} to ${trip['to']}");
                                                      },
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              const SizedBox(height: 7),
                                              RichText(
                                                text: TextSpan(
                                                  children: [
                                                    TextSpan(
                                                      text: "To: ",
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                        fontWeight: FontWeight.bold,
                                                        color: Colors.orange,  // اللون الذي ترغب فيه لكلمة "From"
                                                      ),
                                                    ),
                                                    TextSpan(
                                                      text: "${trip['to']}",
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                        fontWeight: FontWeight.bold,
                                                        color: Colors.black,  // اللون لبقية النص
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              SizedBox(height: 8),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 1),
                                    // Number of passengers
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        Icon(Icons.person, color: Colors.black, size: 25), // الأيقونة
                                        SizedBox(width: 4),  // المسافة بين الأيقونة والنص
                                        RichText(
                                          text: TextSpan(
                                            children: [
                                              TextSpan(
                                                text: "${trip['currentPassengers']} / ${trip['maxPassengers']} ",
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w500,
                                                  color: Color.fromARGB(230, 41, 84, 115),
                                                ),
                                              ),
                                              TextSpan(
                                                text: "   Passengers",
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                  color:Color.fromARGB(230, 41, 84, 115), // اللون الجديد لكلمة "passengers"
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(width: 135),
                                        Icon(Icons.visibility_outlined, color: Colors.indigo, size: 25), // الأيقونة

                                      ],
                                    ),
                                    SizedBox(height: 8),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        ElevatedButton.icon(
                                          icon: Icon(Icons.edit, color: Colors.white),
                                          label: Text(
                                            "Edit",
                                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 17),
                                          ),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:Color.fromARGB(230, 80, 103, 124),
                                            shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(12)),
                                            padding: EdgeInsets.symmetric(horizontal: 15),  // تقليل العرض بتحديد المسافة الأفقية
                                          ),
                                          onPressed: () {
                                            // Edit action
                                          },
                                        ),
                                        SizedBox(width: 10,),
                                        ElevatedButton.icon(
                                          icon: Icon(Icons.delete, color: Colors.white),
                                          label: Text(
                                            "Cancel",
                                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 17),
                                          ),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.red[500],
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            padding: EdgeInsets.symmetric(horizontal: 10),
                                          ),
                                          onPressed: () {
                                            showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return AlertDialog(
                                                  title: Text("Confirm Cancellation"),
                                                  content: Text("Are you sure you want to cancel this trip?"),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () {
                                                        Navigator.of(context).pop(); // إغلاق مربع الحوار
                                                      },
                                                      child: Text("Cancel", style: TextStyle(color: Colors.red)),
                                                    ),
                                                    TextButton(
                                                      onPressed: () {
                                                        Navigator.of(context).pop(); // إغلاق مربع الحوار
                                                        cancelTrip(index); // استدعاء دالة الإلغاء
                                                      },
                                                      child: Text("OK", style: TextStyle(color: Colors.green)),
                                                    ),
                                                  ],
                                                );
                                              },
                                            );
                                          },
                                        )


                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),

                        //completed trip
                        ListView.builder(
                          itemCount: completedTrips.length,
                          itemBuilder: (context, index) {
                            final trip = completedTrips[index];
                            return Card(
                              elevation: 4,
                              margin: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                                side: BorderSide(color:Colors.grey.shade500, width: 1), // إضافة حافة ملونة
                              ),
                              color:Color.fromARGB(255, 234, 241, 246),    // تعيين لون الخلفية
                              shadowColor:Color.fromARGB(230, 41, 84, 115),
                              child: Padding(
                                padding: EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Details: Time, Date
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween, // توزيع العناصر بين اليسار واليمين
                                      children: [
                                        Row(
                                          children: [
                                            Icon(Icons.calendar_month_outlined, color: Colors.pinkAccent),
                                            SizedBox(width: 1),
                                            Text("Date:${formatDate(trip['date'])}",style: TextStyle(fontSize: 15.5,fontWeight: FontWeight.w600,color:Color.fromARGB(230, 41, 84, 115),),),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            Icon(Icons.access_time, color: Colors.pinkAccent),
                                            SizedBox(width: 1),
                                            Text("Time:${trip['time']}",style: TextStyle(fontSize: 15.5,fontWeight: FontWeight.w600,color:Color.fromARGB(230, 41, 84, 115),),),
                                          ],
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 1),
                                    // Header: From and To
                                    Row(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(top: 0.0),  // المسافة من الأعلى
                                          child: Column(
                                            children: [
                                              Icon(Icons.my_location, color: Colors.green, size: 22),
                                              Container(
                                                height: 5,
                                                width: 2,
                                                color: Colors.grey, // الخط الوهمي
                                              ),
                                              SizedBox(height: 3),
                                              Container(
                                                height: 5,
                                                width: 2,
                                                color: Colors.grey, // الخط الوهمي
                                              ),
                                              SizedBox(height: 3),
                                              Container(
                                                height: 5,
                                                width: 2,
                                                color: Colors.grey, // الخط الوهمي
                                              ),
                                              Icon(Icons.pin_drop, color: Colors.orange, size: 22),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(top: 1.0),  // المسافة من الأعلى
                                                child: Row(
                                                  children: [
                                                    RichText(
                                                      text: TextSpan(
                                                        children: [
                                                          TextSpan(
                                                            text: "From: ",
                                                            style: TextStyle(
                                                              fontSize: 16,
                                                              fontWeight: FontWeight.bold,
                                                              color: Colors.green,  // اللون الذي ترغب فيه لكلمة "From"
                                                            ),
                                                          ),
                                                          TextSpan(
                                                            text: "${trip['from']}",
                                                            style: TextStyle(
                                                              fontSize: 16,
                                                              fontWeight: FontWeight.bold,
                                                              color: Colors.black,  // اللون لبقية النص
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    Spacer(),  // هذا سيضمن أن الأيقونة تكون في أقصى اليمين
                                                    IconButton(
                                                      icon: Icon(Icons.map_outlined, color:Color.fromARGB(230, 41, 84, 115),),  // اختر الأيقونة المناسبة (مثل خريطة)
                                                      onPressed: () {
                                                        // أضف هنا الكود الذي سيعرض الخريطة أو يقوم بالإجراء الذي تريده
                                                        print("Open map from ${trip['from']} to ${trip['to']}");
                                                      },
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              const SizedBox(height: 7),
                                              RichText(
                                                text: TextSpan(
                                                  children: [
                                                    TextSpan(
                                                      text: "To  : ",
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                        fontWeight: FontWeight.bold,
                                                        color: Colors.orange,  // اللون الذي ترغب فيه لكلمة "From"
                                                      ),
                                                    ),
                                                    TextSpan(
                                                      text: "${trip['to']}",
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                        fontWeight: FontWeight.bold,
                                                        color: Colors.black,  // اللون لبقية النص
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              SizedBox(height: 8),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 1),
                                    // Number of passengers
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        Icon(Icons.person, color: Colors.black, size: 25), // الأيقونة
                                        SizedBox(width: 4),  // المسافة بين الأيقونة والنص
                                        RichText(
                                          text: TextSpan(
                                            children: [
                                              TextSpan(
                                                text: "${trip['currentPassengers']} / ${trip['maxPassengers']} ",
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w500,
                                                  color: Color.fromARGB(230, 41, 84, 115),
                                                ),
                                              ),
                                              TextSpan(
                                                text: "   Passengers",
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                  color:Color.fromARGB(230, 41, 84, 115), // اللون الجديد لكلمة "passengers"
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(width: 135),
                                        Icon(Icons.visibility_outlined, color: Colors.indigo, size: 25), // الأيقونة

                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                        // Canceled Trips
                        ListView.builder(
                          itemCount: canceledTrips.length,
                          itemBuilder: (context, index) {
                            final trip = canceledTrips[index];
                            return Card(
                              elevation: 4,
                              margin: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                                side: BorderSide(color:Colors.grey.shade500, width: 1), // إضافة حافة ملونة
                              ),
                              color:Color.fromARGB(255, 234, 241, 246),    // تعيين لون الخلفية
                              shadowColor:Color.fromARGB(230, 41, 84, 115),
                              child: Padding(
                                padding: EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Details: Time, Date
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween, // توزيع العناصر بين اليسار واليمين
                                      children: [
                                        Row(
                                          children: [
                                            Icon(Icons.calendar_month_outlined, color: Colors.pinkAccent),
                                            SizedBox(width: 1),
                                            Text("Date:${formatDate(trip['date'])}",style: TextStyle(fontSize: 15.5,fontWeight: FontWeight.w600,color:Color.fromARGB(230, 41, 84, 115),),),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            Icon(Icons.access_time, color: Colors.pinkAccent),
                                            SizedBox(width: 1),
                                            Text("Time:${trip['time']}",style: TextStyle(fontSize: 15.5,fontWeight: FontWeight.w600,color:Color.fromARGB(230, 41, 84, 115),),),
                                          ],
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 1),
                                    // Header: From and To
                                    Row(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(top: 0.0),  // المسافة من الأعلى
                                          child: Column(
                                            children: [
                                              Icon(Icons.my_location, color: Colors.green, size: 22),
                                              Container(
                                                height: 5,
                                                width: 2,
                                                color: Colors.grey, // الخط الوهمي
                                              ),
                                              SizedBox(height: 3),
                                              Container(
                                                height: 5,
                                                width: 2,
                                                color: Colors.grey, // الخط الوهمي
                                              ),
                                              SizedBox(height: 3),
                                              Container(
                                                height: 5,
                                                width: 2,
                                                color: Colors.grey, // الخط الوهمي
                                              ),
                                              Icon(Icons.pin_drop, color: Colors.orange, size: 22),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(top: 1.0),  // المسافة من الأعلى
                                                child: Row(
                                                  children: [
                                                    RichText(
                                                      text: TextSpan(
                                                        children: [
                                                          TextSpan(
                                                            text: "From: ",
                                                            style: TextStyle(
                                                              fontSize: 16,
                                                              fontWeight: FontWeight.bold,
                                                              color: Colors.green,  // اللون الذي ترغب فيه لكلمة "From"
                                                            ),
                                                          ),
                                                          TextSpan(
                                                            text: "${trip['from']}",
                                                            style: TextStyle(
                                                              fontSize: 16,
                                                              fontWeight: FontWeight.bold,
                                                              color: Colors.black,  // اللون لبقية النص
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    Spacer(),  // هذا سيضمن أن الأيقونة تكون في أقصى اليمين
                                                    IconButton(
                                                      icon: Icon(Icons.map_outlined, color:Color.fromARGB(230, 41, 84, 115),),  // اختر الأيقونة المناسبة (مثل خريطة)
                                                      onPressed: () {
                                                        // أضف هنا الكود الذي سيعرض الخريطة أو يقوم بالإجراء الذي تريده
                                                        print("Open map from ${trip['from']} to ${trip['to']}");
                                                      },
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              const SizedBox(height: 7),
                                              RichText(
                                                text: TextSpan(
                                                  children: [
                                                    TextSpan(
                                                      text: "To  : ",
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                        fontWeight: FontWeight.bold,
                                                        color: Colors.orange,  // اللون الذي ترغب فيه لكلمة "From"
                                                      ),
                                                    ),
                                                    TextSpan(
                                                      text: "${trip['to']}",
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                        fontWeight: FontWeight.bold,
                                                        color: Colors.black,  // اللون لبقية النص
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              SizedBox(height: 8),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 1),
                                    // Number of passengers
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        Icon(Icons.person, color: Colors.black, size: 25), // الأيقونة
                                        SizedBox(width: 4),  // المسافة بين الأيقونة والنص
                                        RichText(
                                          text: TextSpan(
                                            children: [
                                              TextSpan(
                                                text: "${trip['currentPassengers']} / ${trip['maxPassengers']} ",
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w500,
                                                  color: Color.fromARGB(230, 41, 84, 115),
                                                ),
                                              ),
                                              TextSpan(
                                                text: "   Passengers",
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                  color:Color.fromARGB(230, 41, 84, 115), // اللون الجديد لكلمة "passengers"
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(width: 135),
                                        Icon(Icons.visibility_outlined, color: Colors.indigo, size: 25), // الأيقونة

                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
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