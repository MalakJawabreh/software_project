import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'config.dart';

class AddUserPage extends StatefulWidget {
  @override
  final String token; // أضف التوكن هنا

  const AddUserPage({required this.token});

  _AddUserPageState createState() => _AddUserPageState();
}

class _AddUserPageState extends State<AddUserPage> {
  String _role = 'Passenger'; // القيمة الافتراضية للدور
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String? _gender = 'Male'; // القيمة الافتراضية للجندر
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _carNumberController = TextEditingController();
  final TextEditingController _carTypeController = TextEditingController();

  Future<void> addUser({
    required String token,
    required String fullName,
    required String email,
    required String password,
    required String phoneNumber,
    required String gender,
    required String role,
    String? carNumber,
    String? carType,
  }) async {
    final url = Uri.parse(addUserEndpoint);  // استبدل بالرابط الفعلي للـ API

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    final body = jsonEncode({
      'fullName': fullName,
      'email': email,
      'password': password,
      'phoneNumber': phoneNumber,
      'gender': gender,
      'role': role,
      'carNumber': carNumber,
      'carType': carType,
    });

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 201) {
        // تم إضافة المستخدم بنجاح
        print('User added successfully');
      } else {
        // إذا كانت هناك مشكلة، يتم طباعة الخطأ
        print('Error: ${response.body}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add User"),
      ),
      backgroundColor: Color(0xFF8BA8B1),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            width: 650, // تحديد العرض هنا
          child: Card(
            elevation: 5.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // وضع العنوان في المنتصف
                    Align(
                      alignment: Alignment.center,
                      child: Text(
                        'Add User',
                        style: TextStyle(
                          fontSize: 24,
                          color:Colors.pink,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    // Full Name
                    TextFormField(
                      controller: _fullNameController,
                      decoration: InputDecoration(labelText: 'Full Name',
                        labelStyle: TextStyle(color: Color(0xFA46545C)), // اللون السكني
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a full name';
                        }
                        return null;
                      },
                    ),
                    // Email
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(labelText: 'Email',
                        labelStyle: TextStyle(color: Color(0xFA46545C)),
                      ),// اللون السكني),
                      validator: (value) {
                        if (value == null || value.isEmpty ||
                            !RegExp(r'^\S+@\S+\.\S+$').hasMatch(value)) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _passwordController,
                      decoration: InputDecoration(labelText: 'Password',
                        labelStyle: TextStyle(color: Color(0xFA46545C)), // اللون السكني
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a Password';
                        }
                        return null;
                      },
                    ),
                    // Phone Number
                    TextFormField(
                      controller: _phoneNumberController,
                      decoration: InputDecoration(labelText: 'Phone Number',
                        labelStyle: TextStyle(color: Color(0xFA46545C)), // اللون السكني
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty ||
                            !RegExp(r'^(\+?[1-9]\d{1,14}|0\d{9})$').hasMatch(value)) {
                          return 'Please enter a valid phone number';
                        }
                        return null;
                      },
                    ),
                    // Gender Selection (Radio Buttons)
                    Text('Gender:',style: TextStyle(color: Color(0xFA46545C)),),
                    Row(
                      children: [
                        Expanded(
                          child: RadioListTile<String>(
                            title: Text('Male'),
                            value: 'Male',
                            groupValue: _gender,
                            onChanged: (value) {
                              setState(() {
                                _gender = value;
                              });
                            },
                          ),
                        ),
                        Expanded(
                          child: RadioListTile<String>(
                            title: Text('Female'),
                            value: 'Female',
                            groupValue: _gender,
                            onChanged: (value) {
                              setState(() {
                                _gender = value;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    // Role Selection
                    DropdownButtonFormField<String>(
                      value: _role,
                      items: ['Passenger', 'Driver']
                          .map((role) =>
                          DropdownMenuItem(value: role, child: Text(role)))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _role = value!;
                        });
                      },
                      decoration: InputDecoration(labelText: 'Role',
                        labelStyle: TextStyle(color: Color(0xFA46545C)), // اللون السكني

                      ),
                    ),
                    // Car Number and Car Type (appear only if role is 'Driver')
                    if (_role == 'Driver') ...[
                      TextFormField(
                        controller: _carNumberController,
                        decoration: InputDecoration(labelText: 'Car Number'),
                      ),
                      TextFormField(
                        controller: _carTypeController,
                        decoration: InputDecoration(labelText: 'Car Type'),
                      ),
                    ],
                    // Submit Button
                    SizedBox(height: 40,),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20.0),
                      child: Center( // لتوسيط الزر داخل الكارد
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xE6A4ACB3), // تغيير لون الخلفية إلى اللون السكني

                            foregroundColor: Colors.pink, // تغيير لون النص إلى الأبيض
                          ),
                          onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                // استدعاء الدالة لإضافة المستخدم
                                addUser(
                                  token: widget.token, // التوكن الفعلي
                                  fullName: _fullNameController.text,
                                  email: _emailController.text,
                                  password: _passwordController.text,
                                  phoneNumber: _phoneNumberController.text,
                                  gender: _gender!,
                                  role: _role,
                                  carNumber: _role == 'Driver' ? _carNumberController.text : null,
                                  carType: _role == 'Driver' ? _carTypeController.text : null,
                                );
                              }
                          },
                          child: Text(
                            'Add User',
                            style: TextStyle(
                              fontSize: 18, // تغيير حجم الخط
                              fontWeight: FontWeight.bold, // جعل الخط عريض
                            ),
                          ),
                        ),
                      ),
                    ),

                  ],
                ),
              ),
            ),
          ),
        ),
        ),
      ),
    );
  }
}
