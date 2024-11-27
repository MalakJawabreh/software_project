import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'language_provider.dart';
class TwoStepVerificationPage extends StatefulWidget {
  @override
  _TwoStepVerificationPageState createState() =>
      _TwoStepVerificationPageState();
}

class _TwoStepVerificationPageState extends State<TwoStepVerificationPage> {
  bool showCreatePinPage = false; // للتحكم في عرض صفحة إنشاء PIN

  String? createdPin; // لتخزين رمز PIN المدخل في الصفحة الأولى

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final isArabic = languageProvider.isArabic;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          isArabic ? 'تحقق بخطوتين' : 'Two-step verification',  // Change the text based on language
          style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
        ),
        backgroundColor: SecondryColor,
      ),
      body: showCreatePinPage
          ? CreatePinWidget(
        onPinCreated: (pin) {
          setState(() {
            createdPin = pin; // حفظ رمز PIN
            showCreatePinPage = false; // الانتقال للصفحة التالية
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ConfirmPinWidget(createdPin: createdPin!),
              ),
            );
          });
        },
      )
          : MainPageWidget(
        onTurnOnPressed: () {
          setState(() {
            showCreatePinPage = true; // التبديل لعرض صفحة إنشاء PIN
          });
        },
      ),
    );
  }
}

// الصفحة الرئيسية
class MainPageWidget extends StatelessWidget {
  final VoidCallback onTurnOnPressed;

  MainPageWidget({required this.onTurnOnPressed});

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final isArabic = languageProvider.isArabic;
    return Column(
      children: [
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // رمز النجوم
              Container(
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: EdgeInsets.all(10),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.star, color: Color.fromARGB(230, 61, 104, 135), size: 24),
                    SizedBox(width: 5),
                    Icon(Icons.star, color:Color.fromARGB(230, 61, 104, 135), size: 24),
                    SizedBox(width: 5),
                    Icon(Icons.star, color:Color.fromARGB(230, 61, 104, 135), size: 24),
                  ],
                ),
              ),
              SizedBox(height: 30),
              // النصوص
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Text(
                  isArabic
                      ? 'لأمان إضافي، قم بتفعيل التحقق بخطوتين، والذي سيطلب منك رمز PIN عند إعادة تسجيل رقم هاتفك في التطبيق.'
                      : 'For extra security, turn on two-step verification, which will require a PIN when registering your phone number with App again.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.black87),
                ),

              ),
            ],
          ),
        ),
        // زر التفعيل
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: ElevatedButton(
            onPressed: onTurnOnPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: Text(
              isArabic ? 'تشغيل' : 'Turn on',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),

          ),
        ),
      ],
    );
  }
}


// صفحة إنشاء رمز PIN
class CreatePinWidget extends StatelessWidget {
  final Function(String) onPinCreated;

  CreatePinWidget({required this.onPinCreated});

  final TextEditingController _pinController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final isArabic = languageProvider.isArabic;
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            isArabic ? 'أنشئ رمز PIN مكون من 6 أرقام يمكنك تذكره' : 'Create a 6-digit PIN that you can remember',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18),
          ),

          SizedBox(height: 20),
          TextField(
            controller: _pinController,
            obscureText: true,
            keyboardType: TextInputType.number,
            maxLength: 6,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              hintText: isArabic ? 'أدخل رمز PIN الخاص بك' : 'Enter your PIN', // Dynamic hintText
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: primaryColor, width: 2),
              ),
            ),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              if (_pinController.text.length == 6) {
                onPinCreated(_pinController.text); // تمرير رمز PIN المدخل
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
            ),
            child: Text(
              isArabic ? 'التالي' : 'Next',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),

          ),
        ],
      ),
    );
  }
}
class ConfirmationWidget extends StatelessWidget {
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  ConfirmationWidget({required this.onConfirm, required this.onCancel});

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final isArabic = languageProvider.isArabic;
    return AlertDialog(
      title: Text(
        isArabic ? 'هل ترغب في إيقاف التحقق بخطوتين؟' : 'Turn off two-step verification?',
        style: TextStyle(
          color: primaryColor,
        ),
      ),

      actions: [
        TextButton(
          onPressed: onCancel,
          child: Text(
            isArabic ? 'إلغاء' : 'Cancel',
            style: TextStyle(color: primaryColor),
          ),

        ),
        ElevatedButton(
          onPressed: onConfirm,
          child: Text(
            isArabic ? 'إيقاف' : 'Turn off',
            style: TextStyle(color: primaryColor),
          ),

        ),
      ],
    );
  }
}

// صفحة تأكيد رمز PIN
// صفحة تأكيد رمز PIN
class ConfirmPinWidget extends StatelessWidget {
  final String createdPin;

  ConfirmPinWidget({required this.createdPin});

  final TextEditingController _confirmPinController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final isArabic = languageProvider.isArabic;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          isArabic ? 'تحقق بخطوتين' : 'Two-step verification',  // Change the text based on language
          style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
        ),
        backgroundColor: SecondryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              isArabic ? 'تأكيد رمز PIN' : 'Confirm your PIN',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18),
            ),

            SizedBox(height: 20),
            TextField(
              controller: _confirmPinController,
              obscureText: true,
              keyboardType: TextInputType.number,
              maxLength: 6,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: isArabic ? 'أعد إدخال رمز PIN الخاص بك' : 'Re-enter your PIN', // Dynamic hintText
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: primaryColor, width: 2),
                ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (_confirmPinController.text == createdPin) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SuccessPage(),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      behavior: SnackBarBehavior.floating, // لجعل الـ SnackBar تطفو
                      backgroundColor: Colors.white, // تغيير لون الخلفية
                      elevation: 8, // إضافة ظل
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10), // حواف دائرية
                      ),
                      content: Row(
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: Colors.red,
                            size: 30,
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              isArabic
                                  ? 'رموز PIN غير متطابقة. يرجى المحاولة مرة أخرى.'
                                  : 'PINs do not match. Please try again.',
                              style: TextStyle(
                                color: primaryColor,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                          ),
                        ],
                      ),
                      duration: Duration(seconds: 3), // المدة الزمنية للعرض
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              ),
              child: Text(
                isArabic ? 'حفظ' : 'Save', // Dynamic text for 'Save'
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),

            ),
          ],
        ),
      ),
    );
  }
}
class ChangePinPage extends StatefulWidget {
  @override
  _ChangePinPageState createState() => _ChangePinPageState();
}

class _ChangePinPageState extends State<ChangePinPage> {
  final TextEditingController _pinController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final isArabic = languageProvider.isArabic;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          isArabic ? 'تغيير رمز PIN' : 'Change PIN', // Dynamic text for 'Change PIN'
          style: TextStyle(
            color: primaryColor, // Using the primary color
            fontWeight: FontWeight.bold, // Making the text bold
          ),
        ),

        backgroundColor: SecondryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _pinController,
                obscureText: true,
                keyboardType: TextInputType.number,
                maxLength: 6, // فقط 4 أرقام للـ PIN
                decoration: InputDecoration(
                  labelText: isArabic ? 'أدخل رمز PIN جديد' : 'Enter new PIN', // Dynamic labelText
                  hintText: isArabic ? 'أدخل رمز PIN مكون من 6 أرقام' : 'Enter 6-digit PIN', // Dynamic hintText
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return isArabic ? 'الرجاء إدخال رمز PIN' : 'Please enter a PIN';
                  }
                  if (value.length != 6) {
                    return isArabic ? 'يجب أن يتكون PIN من 6 أرقام' : 'PIN must be 6 digits';
                  }
                  return null;
                },

              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState?.validate() ?? false) {
                    // تنفيذ عملية تغيير الـ PIN
                    String newPin = _pinController.text;
                    // يمكنك إضافة كود هنا لتحديث الـ PIN في النظام أو قاعدة البيانات

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          isArabic ? 'تم تغيير رمز PIN بنجاح!' : 'PIN changed successfully!',
                        ),
                      ),
                    );
                    Navigator.pop(context); // العودة إلى الصفحة السابقة
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor, // تعيين اللون الأساسي للزر                ),
                  ),
                child: Text(
                  isArabic ? 'تأكيد' : 'Confirm', // Dynamic text for 'Confirm'
                  style: TextStyle(
                    color: Colors.white, // Setting the text color to white
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



class SuccessPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final isArabic = languageProvider.isArabic;
    return Scaffold(
      backgroundColor: Colors.white, // لون الخلفية أبيض ليكون قريبًا من التصميم
      appBar: AppBar(
        backgroundColor: SecondryColor,
        title: Text(
          isArabic ? 'تحقق بخطوتين' : 'Two-step verification',  // Change the text based on language
          style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
        ),
        iconTheme: IconThemeData(color: primaryColor),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 50),
            // أيقونة النجاح
            Stack(
              clipBehavior: Clip.none, // للسماح للعنصر بالخروج عن الحدود إذا لزم
              alignment: Alignment.center,
              children: [
                // الحاوية الرئيسية
                Container(
                  width: 100,
                  height: 60,
                  decoration: BoxDecoration(
                    border: Border.all(color: primaryColor, width: 2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      '***',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                  ),
                ),
                // أيقونة النجاح
                Positioned(
                  bottom: -8, // تعديل الموضع السفلي
                  right: -8,  // تعديل الموضع الأيمن
                  child: CircleAvatar(
                    backgroundColor: Color.fromARGB(230, 61, 104, 135),
                    radius: 16, // حجم الدائرة
                    child: Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 30),
            // النصوص
            Text(
              isArabic ? 'تحقق بخطوتين' : 'Two-step verification',  // Change the text based on language
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 10),
            Text(
              isArabic
                  ? 'ستحتاج إلى إدخال رمز PIN إذا قمت بتسجيل رقم هاتفك في التطبيق مرة أخرى.'
                  : "You'll need to enter your PIN if you register your phone number on App again.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
              ),
            ),

            SizedBox(height: 10),
            InkWell(
              onTap: () {
                // تنفيذ رابط Learn More
              },
              child: Text(
                isArabic ? 'اعرف أكثر' : 'Learn more',
                style: TextStyle(
                  fontSize: 14,
                  color: primaryColor,
                  decoration: TextDecoration.underline,
                ),
              ),

            ),
           // Spacer(),
            // الأزرار
            ListTile(
              leading: Icon(
                Icons.cancel,
                color: Colors.black,
              ),
              title:Text(
                isArabic ? 'إيقاف التشغيل' : 'Turn off',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                ),
              ),

              onTap: () {
                // تنفيذ إجراء Turn off
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return ConfirmationWidget(
                      onConfirm: () {
                        // هنا سنقوم بإلغاء التحقق بخطوتين
                        // مثال: إذا كنت تحفظ الرقم في متغير أو قاعدة بيانات، قم بحذفه هنا

                        // على سبيل المثال:
                        // حذف الرقم أو تعطيل التحقق بخطوتين في الـ SharedPreferences أو قاعدة بيانات:
                        // SharedPreferences prefs = await SharedPreferences.getInstance();
                        // prefs.remove("PIN Number");

                        // العودة إلى الصفحة التي تحتوي على إعدادات التحقق بخطوتين
                        Navigator.pop(context); // إغلاق نافذة التأكيد
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => TwoStepVerificationPage()), // تأكد من أن هذه الصفحة هي صفحة الإعدادات
                        );

                        // عرض إشعار يفيد بأن التحقق بخطوتين قد تم تعطيله
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              isArabic
                                  ? 'تم إيقاف التحقق بخطوتين.'
                                  : 'Two-step verification has been turned off.',
                              style: TextStyle(
                                fontSize: 18.0, // Adjust the font size
                                color: Color(0x80B2EBF2), // Adjust the color to a transparent light blue
                              ),
                            ),

                            behavior: SnackBarBehavior.floating, // يجعل الـ SnackBar يطفو
                            margin: EdgeInsets.only(bottom: 100.0), // تحديد المسافة من أسفل الشاشة
                          ),
                        );

                      },
                      onCancel: () {
                        Navigator.pop(context); // إغلاق نافذة التأكيد دون فعل أي شيء
                      },
                    );
                  },
                );
              },
            ),



            Divider(),
            ListTile(
              leading: Icon(
                Icons.password,
                color: Colors.black,
              ),
              title: Text(
                isArabic ? 'تغيير رمز PIN' : 'Change PIN',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                ),
              ),

              onTap: () {
                // تنفيذ إجراء Change PIN
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ChangePinPage()),
                );
              },
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

const Color SecondryColor = Color.fromARGB(230, 196, 209, 219);
const Color primaryColor = Color.fromARGB(230, 41, 84, 115);
