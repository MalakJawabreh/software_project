import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'language_provider.dart';

class ChangePasswordPage extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController oldPasswordController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

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
        backgroundColor: SecondryColor,
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
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // تنفيذ منطق تغيير كلمة السر هنا
                      print('Email: ${emailController.text}');
                      print('Old Password: ${oldPasswordController.text}');
                      print('New Password: ${newPasswordController.text}');
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            isArabic
                                ? 'تم تغيير كلمة المرور بنجاح!'
                                : 'Password changed successfully!',
                          ),
                        ),
                      );
                    }
                  },
                  child: Text(
                    isArabic ? 'إرسال' : 'Submit',
                    style: TextStyle(color: SecondryColor),
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

const Color SecondryColor = Color.fromARGB(230, 196, 209, 219);
const Color primaryColor = Color.fromARGB(230, 41, 84, 115);
