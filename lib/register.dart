import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:project1/login.dart';
import 'package:http/http.dart' as http ;
import 'config.dart';
import 'package:flutter_svg/flutter_svg.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController carNumberController = TextEditingController();
  final TextEditingController carTypeController = TextEditingController();

  String? selectedGender;
  String? selectedRole;
  bool isNotValidated = false;
  bool _obscureText = true; // متغير لتحديد إذا كانت كلمة المرور مخفية


  void registerUser() async {
    // Print values before sending
    print("Full Name: ${fullNameController.text}");
    print("Email: ${emailController.text}");
    print("Password: ${passwordController.text}");
    print("Phone: ${phoneController.text}");
    print("Gender: $selectedGender");
    print("Role: $selectedRole");

    if (fullNameController.text.isNotEmpty &&
        emailController.text.isNotEmpty &&
        passwordController.text.isNotEmpty &&
        phoneController.text.isNotEmpty &&
        selectedGender != null &&
        selectedRole != null &&
        (selectedRole != "Driver" || (carNumberController.text.isNotEmpty && carTypeController.text.isNotEmpty))) {

      var regbody = {
        "fullName": fullNameController.text,
        "email": emailController.text,
        "password": passwordController.text,
        "phoneNumber": phoneController.text,
        "gender": selectedGender,
        "role": selectedRole,
        if (selectedRole == "Driver") ...{
          "carNumber": carNumberController.text,
          "carType": carTypeController.text,
        }
      };

      var response = await http.post(Uri.parse(registeration),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(regbody));

      var jsonResponse = jsonDecode(response.body);
      print(jsonResponse['status']);

      if (jsonResponse['status']) {
        Navigator.push(context, MaterialPageRoute(builder: (context) => Login()));
      } else {
        print("Something Error");
      }
    } else {
      setState(() {
        isNotValidated = true;
      });
    }
  }

  @override
  void dispose() {
    fullNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    phoneController.dispose();
    carNumberController.dispose(); // تنظيف حقل رقم السيارة
    carTypeController.dispose(); // تنظيف حقل نوع السيارة
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: content(),
      ),
    );
  }

  Widget content() {
    return Column(
      children: [
        Container(
          height: 260,
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
                padding: const EdgeInsets.only(top: 2.0,left: 130),
                child: Image.asset(
                  "imagess/signup_icon.png",
                  width: 170,
                  height: 170,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 20.0),
                child: Text(
                  "Register",
                  textAlign: TextAlign.left,
                  style: TextStyle(fontSize: 36, color: Colors.blueGrey[600], fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.only(left: 20.0),
                child: Text(
                  "Please register to login.",
                  style: TextStyle(fontSize: 18, color: Colors.blueGrey[600], fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 10),

        inputStyle("Full Name", "Enter your full name", fullNameController),
        SizedBox(height: 5),
        inputStyle("Email", "test@gmail.com", emailController),
        SizedBox(height: 5),
        inputStyle("Password", "****", passwordController),
        SizedBox(height: 5),
        inputStyle("Phone Number", "Enter your phone number", phoneController),
        SizedBox(height: 5),

        // Gender selection
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    "Gender:",
                    style: TextStyle(fontSize: 20, color: Colors.black,fontWeight: FontWeight.bold),
                  ),
                  SizedBox(width: 10),
                  Radio(
                    value: "Male",
                    groupValue: selectedGender,
                    onChanged: (value) {
                      setState(() {
                        selectedGender = value.toString();
                      });
                    },
                  ),
                  Text("Male",
                    style: TextStyle(fontSize: 20, color: Colors.black),
                  ),
                  Radio(
                    value: "Female",
                    groupValue: selectedGender,
                    onChanged: (value) {
                      setState(() {
                        selectedGender = value.toString();
                      });
                    },
                  ),
                  Text("Female",
                    style: TextStyle(fontSize: 20, color: Colors.black),
                  ),
                ],
              ),
              if (isNotValidated && selectedGender == null)
                Text('Please select your gender', style: TextStyle(color: Colors.red)),
            ],
          ),
        ),

        SizedBox(height: 5),

        // Role selection as Dropdown
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    "Role:",
                    style: TextStyle(fontSize: 20, color: Colors.black, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(width: 60),
                  DropdownButton<String>(
                    value: selectedRole,
                    hint: Text("Select your role"),
                    items: <String>['Passenger', 'Driver', 'Service Provider'].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedRole = newValue;
                      });
                    },
                  ),
                ],
              ),
              if (isNotValidated && selectedRole == null)
                Text('Please select a role', style: TextStyle(color: Colors.red)),
            ],
          ),
        ),

        // إضافة حقول رقم السيارة ونوع السيارة إذا كان الدور هو "Driver"
        if (selectedRole == "Driver") ...[
          SizedBox(height: 10),
          inputStyle("Car Number", "Enter your car number", carNumberController),
          SizedBox(height: 5),
          inputStyle("Car Type", "Enter your car type", carTypeController),
          SizedBox(height: 5),
        ],

        // زر التسجيل
        Container(
          height: 50,
          width: 360,
          decoration: BoxDecoration(
            color:Color.fromARGB(230, 41, 84, 115),
            borderRadius: BorderRadius.circular(20),
          ),
          child: TextButton(
            onPressed: () {
              registerUser();
            },
            child: Text(
              "Register",
              style: TextStyle(fontSize: 25, color: Colors.white),
            ),
          ),
        ),
        SizedBox(height: 0),

        Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Already have an account? ",
                style: TextStyle(fontSize: 15, color: Colors.blueGrey[500],fontWeight: FontWeight.bold),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(builder: (context) => Login()));
                },
                child: Text(
                  "Sign in",
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
    );
  }

  Widget inputStyle(String label, String hint, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: TextField(
        controller: controller,
        obscureText: label == "Password" ? _obscureText : false, // إخفاء النص فقط في كلمة المرور
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
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
          errorText: isNotValidated && controller.text.isEmpty ? 'Enter proper info' : null,
          // إضافة الأيقونة كـ prefixIcon فقط في حال كان الحقل هو "Full Name"
          // تخصيص الأيقونة بناءً على اسم الحقل
          prefixIcon: Padding(
            padding: const EdgeInsets.all(13.0), // ضبط المسافة حسب الرغبة
            child: _getIconForField(label),
          ),
          // suffixIcon: label == "Password"
          //     ? IconButton(
          //   icon: Icon(
          //     _obscureText ? Icons.visibility_off : Icons.visibility,
          //     color: Colors.grey[600],
          //   ),
          //   onPressed: () {
          //     setState(() {
          //       _obscureText = !_obscureText;
          //     });
          //   },
          // )
          //     : null,
        ),
      ),
    );
  }

  // دالة لتحديد الأيقونة حسب اسم الحقل
  Widget _getIconForField(String label) {
    switch (label) {
      case "Full Name":
        return Icon(Icons.person, size: 20);  // أيقونة المستخدم
      case "Email":
        return Icon(Icons.email, size: 20);   // أيقونة البريد الإلكتروني
      case "Password":
        return Icon(Icons.lock, size: 20);    // أيقونة القفل
      case "Phone Number":
        return Icon(Icons.phone, size: 20);   // أيقونة الهاتف
      case "Car Number":
        return SvgPicture.asset('imagess/car_num.svg', width: 24, height: 40);
      case "Car Type":
        return Icon(Icons.car_repair, size: 30);   // أيقونة نوع السيارة
      default:
        return Container();  // إذا لم يكن هناك تطابق، يتم إرجاع حاوية فارغة
    }
  }
}