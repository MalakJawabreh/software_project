import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:project1/register.dart';
import 'package:http/http.dart' as http ;
import 'package:shared_preferences/shared_preferences.dart';
import 'config.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dashboard.dart';
import 'driver_dashboard.dart';
import 'passenger_dashboard.dart';
import 'professional_dashboard.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  bool isDarkMode = false;

  // Controllers for email and password fields
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isNotValidated = false;
  late SharedPreferences prefs;
  bool _obscureText = true; // متغير لتحديد إذا كانت كلمة المرور مخفية

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initSharePref();
  }

  void initSharePref() async {
    prefs = await SharedPreferences.getInstance();
  }


  // دالة لتبديل الوضع
  void toggleTheme() {
    setState(() {
      isDarkMode = !isDarkMode;
    });
  }

  void loginUser() async {
    if (emailController.text.isNotEmpty && passwordController.text.isNotEmpty) {
      var regbody = {
        "email": emailController.text,
        "password": passwordController.text
      };

      var response = await http.post(Uri.parse(login),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(regbody));

      var jsonResponse = jsonDecode(response.body);
      if (jsonResponse['status']) {
        var myToken = jsonResponse['token'];
        var userRole = jsonResponse['role'];

        prefs.setString('token', myToken);

        if (userRole == 'Driver') {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => Driver(token: myToken)),
          );
        } else if (userRole == 'Passenger') {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => Passenger(token: myToken)),
          );
        } else if (userRole == 'Service Provider') {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => Professional(token: myToken)),
          );
        } else {
          print('Role not recognized');
        }
      } else {
        // طباعة الرسالة الواردة من السيرفر في حالة وجود خطأ
        String errorMessage = jsonResponse['message'] ?? 'Unknown error occurred';
        if (errorMessage == 'Email does not exist') {
          // عرض نافذة صغيرة تخبر المستخدم بأن الإيميل غير صحيح
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Row(
                  children: [
                    Icon(
                      Icons.warning, // أيقونة تحذير
                      color: Colors.red, // اللون الأحمر للأيقونة
                    ),
                    SizedBox(width: 8), // مساحة بين الأيقونة والنص
                    Text(
                      'Login Error',
                      style: TextStyle(
                        color: Colors.red, // اللون الأحمر للنص
                        fontWeight: FontWeight.bold, // جعل النص عريضًا
                      ),
                    ),
                  ],
                ),
                content: Text(
                  'The email you entered does not exist. Please try again.',style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // إغلاق النافذة
                    },
                    child: Text('OK'),
                  ),
                ],
              );
            },
          );
        } else if (errorMessage == 'Invalid password') {
          // عرض نافذة صغيرة تخبر المستخدم بأن الإيميل غير صحيح
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title:  Row(
                  children: [
                    Icon(
                      Icons.warning, // أيقونة تحذير
                      color: Colors.red, // اللون الأحمر للأيقونة
                    ),
                    SizedBox(width: 8), // مساحة بين الأيقونة والنص
                    Text(
                      'Login Error',
                      style: TextStyle(
                        color: Colors.red, // اللون الأحمر للنص
                        fontWeight: FontWeight.bold, // جعل النص عريضًا
                      ),
                    ),
                  ],
                ),
                content: Text('The password is wrong. Please try again.',style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold),),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // إغلاق النافذة
                    },
                    child: Text('OK'),
                  ),
                ],
              );
            },
          );
        } else {
          print('Error: $errorMessage');
        }
      }
    }
    else {
      setState(() {
        isNotValidated = true;
      });
    }
  }

  @override
  void dispose() {
    // Dispose controllers when not needed to free up resources
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : Colors.white,
      body: content(),
    );
  }

  Widget content() {
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            height: 450,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                bottomRight: Radius.elliptical(80, 80),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 2.0, left: 50),
                  child: Image.asset(
                    "imagess/login_icon.png",
                    width: 350,
                    height: 350,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 20.0),
                  child: Text(
                    "Login",
                    textAlign: TextAlign.left,
                    style: TextStyle(
                        fontSize: 36,
                        color: Colors.blueGrey[600],
                        fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.only(left: 20.0),
                  child: Text(
                    "Please Sign in to Continue.",
                    style: TextStyle(
                        fontSize: 18,
                        color: Colors.blueGrey[600],
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 10),
          inputStyle("Email", "Enter Your Email:", emailController),
          SizedBox(height: 20),
          inputStyle("Password", "Enter Your Password:", passwordController),
          SizedBox(height: 40),
          Container(
            height: 50,
            width: 360,
            decoration: BoxDecoration(
              color: Color.fromARGB(230, 41, 84, 115),
              borderRadius: BorderRadius.circular(20),
            ),
            child: TextButton(
              onPressed: () {
                loginUser();
              },
              child: Text(
                "Sign in",
                style: TextStyle(fontSize: 25, color: Colors.white),
              ),
            ),
          ),
          SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Don't have an account? ",
                  style: TextStyle(
                      fontSize: 15,
                      color: Colors.blueGrey[500],
                      fontWeight: FontWeight.bold),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.of(context)
                        .push(
                        MaterialPageRoute(builder: (context) => Register()));
                  },
                  child: Text(
                    "Sign Up",
                    style: TextStyle(
                      fontSize: 15,
                      color: Color.fromARGB(230, 41, 84, 115),
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget inputStyle(String title, String hintTxt,
      TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: TextField(
        controller: controller,
        obscureText: title == "Password" ? _obscureText : false, // إخفاء النص فقط في كلمة المرور
        decoration: InputDecoration(
          labelText: title,
          hintText: hintTxt,
          hintStyle: TextStyle(color: Colors.grey[400]),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.blueGrey),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.blueGrey),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.blueGrey, width: 3.0),
          ),
          errorText: isNotValidated && controller.text.isEmpty
              ? 'Enter proper info'
              : null,
          prefixIcon: Padding(
            padding: const EdgeInsets.all(13.0),
            child: _getIconForField(title),
          ),
          suffixIcon: title == "Password"
              ? IconButton(
            icon: Icon(
              _obscureText ? Icons.visibility_off : Icons.visibility,
              color: Colors.grey[600],
            ),
            onPressed: () {
              setState(() {
                _obscureText = !_obscureText;
              });
            },
          )
              : null,
        ),
      ),
    );
  }

  Widget _getIconForField(String label) {
    switch (label) {
      case "Email":
        return Icon(Icons.email, size: 20); // أيقونة البريد الإلكتروني
      case "Password":
        return Icon(Icons.lock, size: 20);  // أيقونة القفل
      default:
        return Container();  // إذا لم يكن هناك تطابق، يتم إرجاع حاوية فارغة
    }
  }

}