import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:project1/passengerDetails.dart';
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
import 'currentlocation.dart';
import 'driver_data_model.dart';
import 'location.dart';
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
import 'login.dart';
import 'dart:async';
import 'ComplaintsPage.dart';
import 'SupportPage.dart';

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
  late String carType='';
  List<dynamic> upcomingTrips = [];
  List<dynamic> completedTrips = [];
  List<dynamic> canceledTrips = [];

  List<String> passengerNames = [];
  List<String> currentPassengerNames=[];
  List<String> currentPassengerNamesForCanceledTrip = [];



  String? Picture; // لتخزين رابط صورة الملف الشخصي


  StreamController<Map<String, dynamic>> dashboardStreamController = StreamController.broadcast();


  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();


  @override
  void initState() {
    super.initState();

    _fetchProfilePicture();

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
        carType=jwtDecodedToken['carType'];

        //fetchProfilePicture();
        // استدعاء دالة التحديث
        // حفظ البيانات في SharedPreferences
        saveUserData(email, username,phoneNumber,licensePicture,profilePicture,carType);

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
  Future<void> saveUserData(String email, String username,String phone,String licensePicture,String profilePicture,String carType) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('email', email);
    await prefs.setString('username', username);
    await prefs.setString('phone', phone);
    await prefs.setString('picture', licensePicture);
    await prefs.setString('picture', profilePicture);
    await prefs.setString('carType',carType);


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
      phoneNumber = prefs.getString('phone') ?? '000000000';
      licensePicture=prefs.getString('licensePicture') ?? '0000';
      profilePicture=prefs.getString('profilePicture') ?? '0000';
      carType=prefs.getString('carType') ?? 'mmm';
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

  Future<void> _fetchProfilePicture() async {
    final picture = await fetchProfilePicture();
    if (picture != null) {
      setState(() {
        Picture = picture; // تحديث رابط الصورة
      });
    }
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
          Picture = data['profilePicture'];
          setState(() {}); // إعادة تعيين الحالة لتحديث الصورة الجديدة
          print("Fetched profile picture URL: $Picture");
          return Picture;
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

  Future<void> showPassengersPopup(
      BuildContext context,
      String driverEmail,
      String from,
      String to,
      String date,
      String time,
      ) async {
    try {


      // إعداد الاستعلام
      final Uri uri = Uri.parse(passengers).replace(queryParameters: {
        "driverEmail": driverEmail,
        "from": from,
        "to": to,
        "date": date,
        "time": time,
      });

      // تنفيذ الطلب HTTP GET
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        // تحليل البيانات القادمة من API
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> passengers = data['passengers'];

        // عرض Popup مع قائمة الركاب
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Passengers List",style: TextStyle(color: Color.fromARGB(
                  240, 51, 66, 76),),),
              content: passengers.isNotEmpty
                  ? SizedBox(
                height: 300, // تحديد ارتفاع مناسب
                width: 300, // تحديد عرض مناسب
                child: ListView.builder(
                  itemCount: passengers.length,
                  itemBuilder: (context, index) {
                    final passenger = passengers[index];
                    passengerNames.add(passenger['EmailP']);
                    currentPassengerNames = List.from(passengerNames);
                    return ListTile(
                      leading: Icon(Icons.person, color: Colors.indigo),
                      title: Text(passenger['nameP'],style: TextStyle(fontWeight:FontWeight.bold,fontSize: 20,color: Color.fromARGB(230, 41, 84, 115)),),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Seats: ${passenger['seat']}",
                            style: TextStyle(color: Colors.red, fontSize: 18),
                          ),
                          if (passenger['Note'] != null && passenger['Note'].isNotEmpty)
                            Text(
                              "Notes: ${passenger['Note']}",
                              style: TextStyle(color: Colors.green, fontSize: 16),
                            ),
                        ],
                      ),
                      onTap: (){
                        // التنقل إلى صفحة التفاصيل
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PassengerDetailsPage(passenger: passenger),
                          ),
                        );
                      },
                    );
                  },
                ),
              )
                  : Text("No passengers found for this trip."),
              actions: [
                TextButton(
                  child: Text("Close"),
                  onPressed: () {
                    print('Passenger Names before: $passengerNames'); // طباعة القائمة للتحقق
                    passengerNames.clear(); // تفرغ القائمة تماماً
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      } else {
        throw Exception("Failed to fetch passengers.");
      }
    } catch (e) {
      // عرض رسالة خطأ في حالة الفشل
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Error"),
            content: Text(e.toString()),
            actions: [
              TextButton(
                child: Text("Close"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
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
            print('Trip canceled successfully.');
            NotificationService.addNotification(email, 'Trip canceled successfully !');

            for (var emailpass in currentPassengerNames) {
              NotificationService.addNotification(emailpass, '${username} has cancelled this trip.');
            }

          });
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
      MaterialPageRoute(builder: (context) => Login()), // تأكد من أن `Driver` هو اسم صفحة السائق
    );
  }

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
    final driverData = Provider.of<DriverDataModel>(context);
    final languageProvider = Provider.of<LanguageProvider>(context);
    final isArabic = languageProvider.isArabic;
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
              padding: const EdgeInsets.only(top: 18),
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
                  // أيقونة الدردشة
                  IconButton(
                    icon: Icon(Icons.chat, size: 30, color: Color.fromARGB(230, 41, 84, 115)),
                    onPressed: () {
                      print('Passenger Names before: $passengerNames'); // طباعة القائمة للتحقق
                      print('Passenger Names: $currentPassengerNames'); // طباعة القائمة للتحقق
                      print('Passenger Names afterr: $currentPassengerNamesForCanceledTrip'); // طباعة القائمة للتحقق
                    },
                  ),
                  // أيقونة القائمة
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
                      child: profilePicture != null
                          ? base64ToImage(profilePicture!)
                          : CircleAvatar(
                        backgroundImage:
                        AssetImage('imagess/signup_icon.png'),
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
              SizedBox(height: 10,),
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
                  },
              ),
              SizedBox(height: 10,),
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
      ),

      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 15, left: 16, right: 16),
            child: Row(
              children: [
                profilePicture != null
                    ? base64ToImage(profilePicture!)
                    : CircleAvatar(
                  backgroundImage:
                  AssetImage('imagess/signup_icon.png'),
                  radius: 30,
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
                          MaterialPageRoute(builder: (context) => SetDestinationPage(email: email,name:username,phone:phoneNumber,carType:carType)), // اسم الصفحة
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
                                                        // Navigator.push(
                                                        //   context,
                                                        //   MaterialPageRoute(builder: (context) => RouteMapScreen(
                                                        //     fromLocation: trip['from'],
                                                        //     toLocation: trip['to'],
                                                        //   ),), // اسم الصفحة
                                                        // );

                                                        // Navigator.push(
                                                        //   context,
                                                        //   MaterialPageRoute(builder: (context) => CurrentLocationPage(),), // اسم الصفحة
                                                        // );


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
                                        // Icon(Icons.visibility_outlined, color: Colors.indigo, size: 25), // الأيقونة
                                        IconButton(
                                          icon: Icon(Icons.visibility_outlined, color: Colors.indigo, size: 25),
                                          onPressed: () async {
                                            await showPassengersPopup(context, email, trip['from'], trip['to'], trip['date'], trip['time']);
                                          },
                                        )

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