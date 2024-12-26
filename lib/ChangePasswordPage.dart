import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import 'language_provider.dart';
import 'config.dart'; // Import the configuration file for URLs

class ChangePasswordPage extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController oldPasswordController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  Future<void> changePassword(BuildContext context) async {
    final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
    final isArabic = languageProvider.isArabic;

    if (_formKey.currentState!.validate()) {
      try {
        final response = await http.post(
          Uri.parse(change_password), // Use the URL defined in config.dart
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'email': emailController.text,
            'oldPassword': oldPasswordController.text,
            'newPassword': newPasswordController.text,
          }),
        );

        if (response.statusCode == 200) {
          final responseData = jsonDecode(response.body);
          if (responseData['status'] == true) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  isArabic
                      ? 'تم تغيير كلمة المرور بنجاح!'
                      : 'Password changed successfully!',
                ),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  responseData['error'] ??
                      (isArabic
                          ? 'حدث خطأ أثناء تغيير كلمة المرور.'
                          : 'An error occurred while changing the password.'),
                ),
              ),
            );
          }
        } else {
          throw Exception(isArabic ? 'فشل الاتصال بالخادم.' : 'Failed to connect to the server.');
        }
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isArabic ? 'حدث خطأ: $error' : 'An error occurred: $error',
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final isArabic = languageProvider.isArabic;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isArabic ? 'تغيير كلمة المرور' : 'Change Password',
          style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
        ),
        backgroundColor: secondaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: isArabic ? 'البريد الإلكتروني' : 'Email',
                  prefixIcon: Icon(Icons.email, color: primaryColor),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return isArabic
                        ? 'يرجى إدخال البريد الإلكتروني'
                        : 'Please enter your email';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              TextFormField(
                controller: oldPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: isArabic ? 'كلمة المرور القديمة' : 'Old Password',
                  prefixIcon: Icon(Icons.lock, color: primaryColor),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return isArabic
                        ? 'يرجى إدخال كلمة المرور القديمة'
                        : 'Please enter your old password';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              TextFormField(
                controller: newPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: isArabic ? 'كلمة المرور الجديدة' : 'New Password',
                  prefixIcon: Icon(Icons.lock_outline, color: primaryColor),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return isArabic
                        ? 'يرجى إدخال كلمة المرور الجديدة'
                        : 'Please enter your new password';
                  } else if (value.length < 8) {
                    return isArabic
                        ? 'يجب أن تكون كلمة المرور على الأقل 8 أحرف'
                        : 'Password must be at least 8 characters long';
                  } else if (!RegExp(r'[A-Za-z]').hasMatch(value)) {
                    return isArabic
                        ? 'يجب أن تحتوي كلمة المرور على حرف واحد على الأقل'
                        : 'Password must contain at least one letter';
                  } else if (!RegExp(r'[0-9]').hasMatch(value)) {
                    return isArabic
                        ? 'يجب أن تحتوي كلمة المرور على رقم واحد على الأقل'
                        : 'Password must contain at least one number';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              TextFormField(
                controller: confirmPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: isArabic ? 'تأكيد كلمة المرور' : 'Confirm Password',
                  prefixIcon: Icon(Icons.lock_outline, color: primaryColor),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return isArabic
                        ? 'يرجى تأكيد كلمة المرور'
                        : 'Please confirm your password';
                  } else if (value != newPasswordController.text) {
                    return isArabic
                        ? 'كلمتا المرور غير متطابقتين'
                        : 'Passwords do not match';
                  }
                  return null;
                },
              ),
              SizedBox(height: 24.0),
              Center(
                child: ElevatedButton(
                  onPressed: () => changePassword(context),
                  child: Text(
                    isArabic ? 'إرسال' : 'Submit',
                    style: TextStyle(color: secondaryColor),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

//const Color secondaryColor = Color.fromARGB(230, 196, 209, 219);
//const Color primaryColor = Color.fromARGB(230, 41, 84, 115);
const Color primaryColor = Color(0xFF296873); // Color from your previous design
const Color accentColor = Color(0xFF00796B); // Accent color for action items like buttons
const Color secondaryColor = Color(0xFFE1F5FE); // A lighter background color for cards and inputs