import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http ;
import 'VisibilitySettingsScreen.dart';
import 'account.dart';
import 'config.dart';
import 'driver_data_model.dart';

class ProfileDriver extends StatefulWidget {
  final String username;
  final String email;

  const ProfileDriver({required this.username, required this.email, Key? key})
      : super(key: key);

  @override
  _ProfileDriverState createState() => _ProfileDriverState();
}

class _ProfileDriverState extends State<ProfileDriver> {
  String _bioText = "Enter Your Bio.";
  bool _isEditing = false; // لتحديد إذا كنا في وضع التعديل أم لا
  TextEditingController _controller = TextEditingController();
  XFile? _profileImage; // لتخزين الصورة التي تم تحميلها
  String? profilepicture;
  String? profilepicturedatabase;
  late String profilePicture="";

  @override
  void initState() {
    super.initState();
    _controller.text = _bioText; // تعيين النص الحالي في الـ controller
    print(widget.email);

      fetchProfilePicture();
  }
  Future<void> _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImage = pickedFile;
      });
    }

    if (_profileImage != null) {
      profilepicture = convertImageToBase64(File(_profileImage!.path));
    }
    _updateProfileImage(profilepicture!);
  }

  void saveProfilepicture() {
      Provider.of<DriverDataModel>(context, listen: false).setProfileImage(
        File(_profileImage!.path)
      );
  }
  Future<void> _updateProfileImage(String imagePath) async {

    print('Email: ${widget.email}');
    if (widget.email == null || widget.email.isEmpty) {
      print('Email is missing!');
      return;
    }
    try {
      // Create the request body as JSON
      final requestBody = {
        'email': widget.email,
        'profilePicture': imagePath,
      };

      // Send the request and get the response
      final response = await http.post(
        Uri.parse(update_profile_picture),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        // Successfully updated the profile picture
        print('Profile picture updated successfully.');
        await fetchProfilePicture(); // تحديث الصورة بعد التحديث

      } else {
        // Handle error
        print('Failed to update profile picture.');
      }
    } catch (e) {
      print('Error updating profile picture: $e');
    }
  }

  Future<Map<String, dynamic>?> getAverageRating() async {
    final String endpoint = '$average_rate/${widget.email}';

    try {
      final response = await http.get(Uri.parse(endpoint));
      if (response.statusCode == 200) {
        // تحويل الاستجابة إلى JSON
        return json.decode(response.body);
      } else if (response.statusCode == 404) {
        // لا توجد تقييمات
        print('No reviews found for this user');
        return null;
      } else {
        // طباعة أي خطأ آخر
        print('Error: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Exception: $e');
      return null;
    }
  }

  String? convertImageToBase64(File? imageFile) {
    if (imageFile == null) return null;

    try {
      List<int> imageBytes = imageFile.readAsBytesSync();
      String base64String = base64Encode(imageBytes);
      print("Base64 Encoded Image: $base64String");
      return base64String;
    } catch (e) {
      print("Error converting image to Base64: $e");
      return null;
    }
}

  Future<String?> fetchProfilePicture() async {

      try {
        // URL الخاص بالـ API
        final url = Uri.parse('$profile_picture?email=${widget.email}');

        // إرسال طلب GET
        final response = await http.get(url);

        if (response.statusCode == 200) {
          // فك تشفير الـ JSON
          final data = json.decode(response.body);

          if (data['status'] == true) {
            profilePicture = data['profilePicture'];
            setState(() {}); // إعادة تعيين الحالة لتحديث الصورة الجديدة
            print("Fetched profile picture URL: $profilePicture");
            return profilePicture;
          } else {
            throw Exception(data['error']);
          }
        } else {
          throw Exception(
              "Failed to fetch profile picture. Status code: ${response
                  .statusCode}");
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
  Widget build(BuildContext context) {
    final driverData = Provider.of<DriverDataModel>(context);
    // تغيير إعدادات الـ Status Bar لعرض الأيقونات بشكل صحيح
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light.copyWith(
      statusBarColor: Colors.transparent, // شفاف لتقليل التداخل
      statusBarIconBrightness: Brightness.dark, // تغيير الأيقونات لتكون داكنة
    ));

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(80), // زيادة ارتفاع AppBar
        child: Padding(
          padding: const EdgeInsets.only(top: 20), // تنزيل البار لأسفل
          child: AppBar(
            title: Text(
              'Profile',
              style: TextStyle(
                color: Color.fromARGB(230, 41, 84, 115), // لون النص
                fontSize: 30,
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.search, size: 35, color: Color.fromARGB(230, 41, 84, 115)),
                onPressed: () {},
              ),
            ],
            backgroundColor: Colors.white, // لون خلفية الـ AppBar
            elevation: 0, // إزالة الظل
            centerTitle: false, // محاذاة النص إلى اليسار
          ),
        ),
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                GestureDetector(
                   onTap: _pickImage,
                   child: Stack(
                     children: [
                           CircleAvatar(
                             radius: 35,
                            backgroundImage:profilePicture.isNotEmpty
                       ? MemoryImage(base64Decode(profilePicture))
                       : null,
                          ),
                     Positioned(
                        bottom: 0,
                        right: 0,
                        child: Icon(
                          Icons.add_a_photo,
                          size: 20,
                          color: Colors.black,
                          //backgroundColor: Colors.indigo,
                          //shape: BoxShape.circle,
                         ),
                       ),
                     ],
                   ),
                 ),
                SizedBox(width: 20),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.username,
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 8), // مسافة بين الاسم والتقييم
            FutureBuilder<Map<String, dynamic>?>(
              future: getAverageRating(), // استدعاء دالة الحصول على التقييم
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Text(
                    'Loading...',
                    style: TextStyle(
                      fontSize: 18,
                      color: Color.fromARGB(230, 24, 83, 131),
                    ),
                  );
                } else if (snapshot.hasError) {
                  return Text(
                    'Error: ${snapshot.error}',
                    style: TextStyle(
                      fontSize: 18,
                      color: Color.fromARGB(230, 24, 83, 131),
                    ),
                  );
                } else if (snapshot.hasData) {
                  // تحويل قيمة التقييم من String إلى double
                  final averageRating = snapshot.data?['averageRating'];
                  if (averageRating != null) {
                    double rating = double.tryParse(averageRating.toString()) ?? 0.0;

                    int fullStars = rating.floor(); // النجوم الممتلئة
                    int halfStars = (rating - fullStars) >= 0.5 ? 1 : 0; // النجوم نصف الممتلئة
                    int emptyStars = 5 - fullStars - halfStars; // النجوم الفارغة

                    return Row(
                      children: [
                        // النجوم
                        Row(
                          children: [
                            for (int i = 0; i < fullStars; i++)
                              Icon(Icons.star, color: Colors.amber, size: 20),
                            for (int i = 0; i < halfStars; i++)
                              Icon(Icons.star_half, color: Colors.amber, size: 20),
                            for (int i = 0; i < emptyStars; i++)
                              Icon(Icons.star_border, color: Colors.amber, size: 20),
                          ],
                        ),
                        SizedBox(width: 8), // مسافة بين النجوم والرقم
                        // التقييم كرقم
                        Text(
                          '$rating', // عرض التقييم كرقم
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(230, 24, 83, 131),
                          ),
                        ),
                      ],
                    );
                  } else {
                    return Row(
                      children: [
                        for (int i = 0; i < 5; i++)
                          Icon(Icons.star_border, color: Colors.amber, size: 20),
                      ],
                    );
                  }
                } else {
                  return Row(
                    children: [
                      for (int i = 0; i < 5; i++)
                        Icon(Icons.star_border, color: Colors.amber, size: 20),
                    ],
                  );
                }

              },
            ),
          ],
        ),
      )
      ],
            ),
          ),
          Divider(),
          SizedBox(height: 20),
          ListTile(
            leading: Icon(Icons.person, color: Colors.indigo, size: 31),
            title: Text(
              "Account",
              style: TextStyle(
                fontSize: 23, // تحديد حجم الخط
                color: Colors.blueGrey, // تغيير اللون
                fontWeight: FontWeight.bold, // تغيير سمك الخط
              ),
            ),
            trailing: Icon(Icons.arrow_forward_ios),
            onTap: () {
              fetchProfilePicture().then((profilePicture) {
                if (profilePicture != null) {
                  print("Profile picture URL: $profilePicture");
                } else {
                  print("Failed to fetch profile picture.");
                }
              });
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AccountsCenterPage(username:widget.username,email:widget.email
                  ),
                ),
              );
            },
          ),
          SizedBox(height: 15),
          ListTile(
            leading: Icon(Icons.location_on, color: Colors.indigo, size: 31),
            title: Text(
              "Addresses Book",
              style: TextStyle(
                fontSize: 23, // تحديد حجم الخط
                color: Colors.blueGrey, // تغيير اللون
                fontWeight: FontWeight.bold, // تغيير سمك الخط
              ),
            ),
            trailing: Icon(Icons.arrow_forward_ios),
            onTap: () {},
          ),
          SizedBox(height: 15),
          ListTile(
            leading: Icon(Icons.lightbulb_circle_rounded, color: Colors.indigo, size: 31),
            title: Text(
              "Status",
              style: TextStyle(
                fontSize: 23, // تحديد حجم الخط
                color: Colors.blueGrey, // تغيير اللون
                fontWeight: FontWeight.bold, // تغيير سمك الخط
              ),
            ),
            trailing: Icon(Icons.arrow_forward_ios),
            onTap: () {

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => VisibilitySettingsScreen(email:widget.email
                  ),
                ),
              );

            },
          ),
          SizedBox(height: 15),
          ListTile(
            leading: Icon(Icons.chat, color: Colors.indigo, size: 31),
            title: Text(
              "Chat settings",
              style: TextStyle(
                fontSize: 23, // تحديد حجم الخط
                color: Colors.blueGrey, // تغيير اللون
                fontWeight: FontWeight.bold, // تغيير سمك الخط
              ),
            ),
            trailing: Icon(Icons.arrow_forward_ios),
            onTap: () {},
          ),
          // profilePicture.isNotEmpty
          //     ? base64ToImage(profilePicture) // استدعاء الدالة لعرض الصورة
          //     : CircularProgressIndicator(),
        ],
      ),
    );
  }
}
