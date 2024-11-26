import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'language_provider.dart';

const Color SecondryColor = Color.fromARGB(230, 196, 209, 219);
const Color primaryColor = Color.fromARGB(230, 41, 84, 115);

class EmailAddressPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final isArabic = languageProvider.isArabic;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isArabic ? 'عنوان البريد الإلكتروني' : 'Email address',
          style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
        ),
        backgroundColor: SecondryColor,
        elevation: 0,
      ),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        color: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 40),
            Icon(
              Icons.email,
              color: Color.fromARGB(230, 51, 94, 125),
              size: 100,
            ),
            SizedBox(height: 20),
            Text(
              isArabic
                  ? 'أضف بريدًا إلكترونيًا لحماية حسابك'
                  : 'Add email to protect your account',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 20),
            Column(
              children: [
                ListTile(
                  leading: Icon(Icons.verified_user, color: Colors.grey[600]),
                  title: Text(
                    isArabic
                        ? 'قم بالتحقق من حسابك حتى بدون رسالة نصية.'
                        : 'Verify your account, even without SMS.',
                    style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                  ),
                ),
                ListTile(
                  leading: Icon(Icons.help_outline, color: Colors.grey[600]),
                  title: Text(
                    isArabic
                        ? 'يساعدنا البريد الإلكتروني في الوصول إليك عند وجود مشاكل أمنية أو دعم.'
                        : 'Email helps us reach you in case of security or support issues.',
                    style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                  ),
                ),
                ListTile(
                  leading: Icon(Icons.lock_outline, color: Colors.grey[600]),
                  title: Text(
                    isArabic
                        ? 'لن يكون عنوان بريدك الإلكتروني مرئيًا للآخرين.'
                        : 'Your email address won’t be visible to others.',
                    style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                  ),
                ),
              ],
            ),
            Spacer(),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                minimumSize: Size(double.infinity, 50),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddEmailPage()),
                );
              },
              child: Text(
                isArabic ? 'أضف البريد الإلكتروني' : 'Add email',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AddEmailPage extends StatefulWidget {
  @override
  _AddEmailPageState createState() => _AddEmailPageState();
}

class _AddEmailPageState extends State<AddEmailPage> {
  final TextEditingController emailController = TextEditingController();
  bool isButtonEnabled = false;

  Future<String> _getEmailFromDatabase() async {
    await Future.delayed(Duration(seconds: 2)); // محاكاة زمن الاستجابة
    return 'example@example.com'; // البريد الإلكتروني المحاكى
  }

  void _validateEmail(String value) {
    setState(() {
      isButtonEnabled = RegExp(
          r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
          .hasMatch(value);
    });
  }

  void _showVerificationDialog(BuildContext context, String email) {
    final isArabic = Provider.of<LanguageProvider>(context, listen: false).isArabic;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.verified, color: primaryColor, size: 60),
              SizedBox(height: 20),
              Text(
                isArabic ? 'تم التحقق' : 'Verified',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
              SizedBox(height: 10),
              Text(
                isArabic
                    ? 'تم التحقق من حسابك بأمان على هذا الجهاز.'
                    : 'Your account has been securely verified on this device.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: primaryColor),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  minimumSize: Size(double.infinity, 50),
                ),
                onPressed: () {
                  Navigator.pop(context); // يغلق النافذة
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          VerificationSuccessPage(email: email),
                    ),
                  );
                },
                child: Text(
                  isArabic ? 'متابعة' : 'Continue',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _getEmailFromDatabase().then((email) {
      emailController.text = email;
      _validateEmail(email);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = Provider.of<LanguageProvider>(context).isArabic;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isArabic ? 'أضف بريدك الإلكتروني' : 'Add your email',
          style: TextStyle(color: primaryColor),
        ),
        backgroundColor: SecondryColor,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isArabic
                  ? 'سنرسل رمز تحقق إلى عنوان البريد الإلكتروني هذا.'
                  : "We'll send a verification code to this email address.",
              style: TextStyle(fontSize: 16, color: primaryColor),
            ),
            SizedBox(height: 20),
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: isArabic ? 'البريد الإلكتروني' : 'Email',
                border: UnderlineInputBorder(),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: primaryColor),
                ),
              ),
              onChanged: _validateEmail,
              keyboardType: TextInputType.emailAddress,
            ),
            Spacer(),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor:
                isButtonEnabled ? primaryColor : Colors.grey[300],
                foregroundColor: isButtonEnabled ? Colors.white : Colors.grey,
                minimumSize: Size(double.infinity, 50),
              ),
              onPressed: isButtonEnabled
                  ? () {
                _showVerificationDialog(context, emailController.text);
              }
                  : null,
              child: Text(isArabic ? 'التالي' : 'Next'),
            ),
          ],
        ),
      ),
    );
  }
}

class VerificationSuccessPage extends StatelessWidget {
  final String email;

  VerificationSuccessPage({required this.email});

  @override
  Widget build(BuildContext context) {
    final isArabic = Provider.of<LanguageProvider>(context).isArabic;

    return Scaffold(
      appBar: AppBar(
        title: Text(isArabic ? 'عنوان البريد الإلكتروني' : 'Email address'),
        backgroundColor: SecondryColor,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.email, color: primaryColor, size: 60),
            SizedBox(height: 20),
            Text(
              isArabic
                  ? 'يساعدك البريد الإلكتروني في الوصول إلى حسابك. لن يكون مرئيًا للآخرين.'
                  : "Email helps you access your account. It isn't visible to others.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: primaryColor),
            ),
            SizedBox(height: 20),
            Text(
              isArabic ? 'بريدك الإلكتروني:' : 'Your email:',
              style: TextStyle(fontSize: 16, color: primaryColor),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  email,
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: primaryColor),
                ),
                SizedBox(width: 10),
                IconButton(
                  icon: Icon(Icons.edit, color: primaryColor),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AddEmailPage()),
                    );
                  },
                ),
              ],
            ),
            SizedBox(height: 20),
            Icon(Icons.check_circle, color: primaryColor, size: 30),
            Text(
              isArabic ? 'تم التحقق' : 'Verified',
              style: TextStyle(
                  fontSize: 16, fontWeight: FontWeight.bold, color: primaryColor),
            ),
          ],
        ),
      ),
    );
  }
}


