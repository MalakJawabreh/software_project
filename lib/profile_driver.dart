import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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

  @override
  void initState() {
    super.initState();
    _controller.text = _bioText; // تعيين النص الحالي في الـ controller
  }

  @override
  Widget build(BuildContext context) {
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
                CircleAvatar(
                  radius: 35,
                  backgroundImage: AssetImage('imagess/signup_icon.png'),
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
                      SizedBox(height: 1),
                      Row(
                        children: [
                          Expanded(
                            child: _isEditing
                                ? TextField(
                              controller: _controller,
                              decoration: InputDecoration(
                                hintText: 'Enter your bio',
                                border: OutlineInputBorder(),
                              ),
                            )
                                : Text(
                              _bioText,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              _isEditing ? Icons.check : Icons.edit,
                              color: Colors.orange,
                            ),
                            onPressed: () {
                              setState(() {
                                if (_isEditing) {
                                  _bioText = _controller.text; // حفظ النص المُعدل
                                }
                                _isEditing = !_isEditing; // التبديل بين التعديل والعرض
                              });
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Divider(),
          SizedBox(height: 20),
          ListTile(
            leading: Icon(Icons.person, color: Colors.indigo,size: 31,),
            title: Text("Account",
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
            leading: Icon(Icons.location_on, color: Colors.indigo,size: 31,),
            title: Text("Addresses Book",
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
            leading: Icon(Icons.lightbulb_circle_rounded, color: Colors.indigo,size: 31,),
            title: Text("Status",
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
            leading: Icon(Icons.notifications, color: Colors.indigo,size: 31,),
            title: Text("Notification",
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
            leading: Icon(Icons.chat, color: Colors.indigo,size: 31,),
            title: Text("Chat settings",
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
            leading: Icon(Icons.lock, color: Colors.indigo,size: 31,),
            title: Text("Privacy and security",
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
            leading: Icon(Icons.info, color: Colors.indigo,size: 31,),
            title: Text("About",
              style: TextStyle(
                fontSize: 23, // تحديد حجم الخط
                color: Colors.blueGrey, // تغيير اللون
                fontWeight: FontWeight.bold, // تغيير سمك الخط
              ),
            ),
            trailing: Icon(Icons.arrow_forward_ios),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
