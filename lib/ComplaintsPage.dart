import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'config.dart';
import 'language_provider.dart';
import 'package:provider/provider.dart';


class ComplaintsPage extends StatefulWidget {
  @override
  _ComplaintsPageState createState() => _ComplaintsPageState();
}

class _ComplaintsPageState extends State<ComplaintsPage> {
  final _formKeyStep1 = GlobalKey<FormState>();
  final _formKeyStep2 = GlobalKey<FormState>();
  final _formKeyStep3 = GlobalKey<FormState>();

  // البيانات المدخلة
  String? complainantName;
  String? complainantEmail;
  String? complainantPhone;
  String? reportedPersonName;
  String? reportedPersonRole;
  String? reportedPersonPhone;
  String? complaintDetails;
  String? complaintType;

  final List<String> complaintTypes = [
    'Delay',
    'Bad Behavior',
    'Technical Issue',
    'Other',
  ];

  final List<String> reportedPersonRoles = [
    'Driver',
    'Passenger',
  ];

  final String whatsappNumber = "970569758887"; // رقم واتساب الخاص بك

  PageController _pageController = PageController();

  // لتتبع الخطوات المكتملة
  int currentStep = 0;

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final isArabic = languageProvider.isArabic;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isArabic ? "تقديم الشكوى" : "Complaint Submission",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
        backgroundColor: accentColor,
        elevation: 5,
      ),
      body: Column(
        children: [
          _buildStepIndicator(isArabic: isArabic), // عرض الخطوات بالأعلى
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  currentStep = index;
                });
              },
              children: [
                // الخطوة الأولى: معلوماتك
                _buildStep1(isArabic: isArabic),

                // الخطوة الثانية: معلومات الشخص المبلغ عنه
                _buildStep2(isArabic: isArabic),

                // الخطوة الثالثة: المراجعة والإرسال
                _buildStep3(isArabic: isArabic),
              ],
            ),
          ),
        ],
      ),
    );
  }


  // بناء المؤشر العلوي للخطوات
  Widget _buildStepIndicator({required bool isArabic}) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final isArabic = languageProvider.isArabic;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(3, (index) {
          bool isCompleted = index < currentStep;
          bool isCurrent = index == currentStep;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Column(
              mainAxisSize: MainAxisSize.min, // يجعل العمود بأقل ارتفاع ممكن
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 30, // زيادة حجم الدائرة
                      backgroundColor: isCompleted
                          ? Color(0xFF00796B) // اللون الأخضر
                          : (isCurrent
                          ? Color(0xFF00796B) // اللون الأخضر الحالي
                          : Colors.grey),
                      child: isCompleted
                          ? Icon(Icons.check, color: Colors.white)
                          : Text(
                        "${index + 1}",
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                    if (index < 2)
                      Container(
                        height: 3,
                        width: 50, // جعل الخط أطول بين الدوائر
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: isCompleted ? Color(0xFF00796B) : Colors.grey,
                            width: 1.5,
                          ),
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                  ],
                ),
                SizedBox(height: 4), // المسافة بين الدائرة والنص

              ],
            ),
          );
        }),
      ),
    );
  }



  Widget _buildStep1({required bool isArabic}) {
    return Form(
      key: _formKeyStep1,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildTextField(
              label: isArabic ? "اسمك" : "Your Name",
              hint: isArabic ? "أدخل اسمك الكامل" : "Enter your full name",
              onChanged: (value) {
                complainantName = value;
              },
            ),
            SizedBox(height: 16),
            _buildTextField(
              label: isArabic ? "بريدك الإلكتروني" : "Your Email",
              hint: isArabic ? "أدخل بريدك الإلكتروني" : "Enter your email",
              onChanged: (value) {
                complainantEmail = value;
              },
            ),
            SizedBox(height: 16),
            _buildTextField(
              label: isArabic ? "رقم هاتفك" : "Your Phone Number",
              hint: isArabic ? "أدخل رقم هاتفك" : "Enter your phone number",
              keyboardType: TextInputType.phone,
              onChanged: (value) {
                complainantPhone = value;
              },
            ),
            SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (currentStep > 0)
                  ElevatedButton(
                    onPressed: () {
                      _pageController.previousPage(
                        duration: Duration(milliseconds: 300),
                        curve: Curves.easeIn,
                      );
                    },
                    child: Text(isArabic ? "رجوع" : "Back"),
                  ),
                ElevatedButton(
                  onPressed: () {
                    if (_formKeyStep1.currentState!.validate()) {
                      _pageController.nextPage(
                        duration: Duration(milliseconds: 300),
                        curve: Curves.easeIn,
                      );
                    }
                  },
                  child: Text(isArabic ? "التالي" : "Next"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep2({required bool isArabic}) {
    return Form(
      key: _formKeyStep2,
      child: SingleChildScrollView( // إضافة ScrollView هنا
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildTextField(
                label: isArabic ? "اسم الشخص المُبلَّغ عنه" : "Reported Person's Name",
                hint: isArabic ? "أدخل اسم الشخص الذي تبلغ عنه" : "Enter the name of the person you're reporting",
                onChanged: (value) {
                  reportedPersonName = value;
                },
              ),
              SizedBox(height: 16),
              _buildChipSelector(
                label: isArabic ? "دور الشخص المُبلَّغ عنه:" : "Role of Reported Person:",
                selectedValue: reportedPersonRole,
                items: reportedPersonRoles,
                onSelected: (value) {
                  setState(() {
                    reportedPersonRole = value;
                  });
                },
              ),
              SizedBox(height: 16),
              _buildTextField(
                label: isArabic ? "رقم هاتف الشخص المُبلَّغ عنه" : "Phone Number of Reported Person",
                hint: isArabic ? "أدخل رقم هاتف الشخص المُبلَّغ عنه" : "Enter phone number of the reported person",
                keyboardType: TextInputType.phone,
                onChanged: (value) {
                  reportedPersonPhone = value;
                },
              ),
              SizedBox(height: 16),
              _buildChipSelector(
                label: isArabic ? "نوع الشكوى:" : "Complaint Type:",
                selectedValue: complaintType,
                items: complaintTypes,
                onSelected: (value) {
                  setState(() {
                    complaintType = value;
                  });
                },
              ),
              SizedBox(height: 24),
              _buildTextField(
                label: isArabic ? "تفاصيل الشكوى" : "Complaint Details",
                hint: isArabic ? "قدم تفاصيل حول الشكوى" : "Provide details about the complaint",
                maxLines: 5,
                onChanged: (value) {
                  complaintDetails = value;
                },
              ),
              SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      _pageController.previousPage(
                        duration: Duration(milliseconds: 300),
                        curve: Curves.easeIn,
                      );
                    },
                    child: Text(isArabic ? "رجوع" : "Back"),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKeyStep2.currentState!.validate()) {
                        _pageController.nextPage(
                          duration: Duration(milliseconds: 300),
                          curve: Curves.easeIn,
                        );
                      }
                    },
                    child: Text(isArabic ? "التالي" : "Next"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }



  Widget _buildStep3({required bool isArabic}) {
    return Form(
      key: _formKeyStep3,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView( // لتجنب Overflow إذا كانت البيانات كثيرة
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, // يجعل النصوص تبدأ من الجهة اليسرى
            children: [
              Text(
                isArabic
                    ? "مراجعة معلوماتك قبل التقديم:"
                    : "Review your information before submitting:",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
              SizedBox(height: 20),

              // جميع البيانات داخل Card واحد
              Card(
                elevation: 4,
                margin: EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoRow(isArabic ? "اسمك" : "Your Name", complainantName),
                      _buildInfoRow(isArabic ? "بريدك الإلكتروني" : "Your Email", complainantEmail),
                      _buildInfoRow(isArabic ? "رقم هاتفك" : "Your Phone Number", complainantPhone),
                      _buildInfoRow(isArabic ? "اسم الشخص المُبلَّغ عنه" : "Reported Person's Name", reportedPersonName),
                      _buildInfoRow(isArabic ? "دور الشخص المُبلَّغ عنه" : "Reported Person's Role", reportedPersonRole),
                      _buildInfoRow(isArabic ? "رقم هاتف الشخص المُبلَّغ عنه" : "Reported Person's Phone", reportedPersonPhone),
                      _buildInfoRow(isArabic ? "نوع الشكوى" : "Complaint Type", complaintType),
                      _buildInfoRow(isArabic ? "تفاصيل الشكوى" : "Complaint Details", complaintDetails),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 24),

              // أزرار التقديم والرجوع
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Previous Button
                  ElevatedButton(
                    onPressed: () {
                      _pageController.previousPage(
                        duration: Duration(milliseconds: 300),
                        curve: Curves.easeIn,
                      );
                    },
                    child: Text(isArabic ? "رجوع" : "Back"),
                  ),
                  // Submit Button
                  ElevatedButton(
                    onPressed: () {
                      // Call API to submit the complaint
                      _submitComplaint();
                    },
                    child: Text(isArabic ? "تقديم الشكوى" : "Submit Complaint"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Function to submit complaint via API
  Future<void> _submitComplaint() async {
    try {
      final response = await http.post(
        Uri.parse(submitComplaint), // استخدم المتغير المعرف من الكونفيج
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'complainantName': complainantName,
          'complainantEmail': complainantEmail,
          'complainantPhone': complainantPhone,
          'reportedPersonName': reportedPersonName,
          'reportedPersonRole': reportedPersonRole,
          'reportedPersonPhone': reportedPersonPhone,
          'complaintDetails': complaintDetails,
          'complaintType': complaintType,

        }),
      );

      // إذا كانت الاستجابة ناجحة
      if (response.statusCode == 201) {
        _showSuccessDialog();
      } else {
        print("Error response: ${response.body}"); // طباعة الاستجابة عند الخطأ
        _showErrorDialog("There was an issue submitting your complaint.");
      }
    } catch (e) {
      print("Error: $e"); // طباعة الخطأ عند حدوث استثناء
      _showErrorDialog("An error occurred while submitting your complaint.");
    }
  }


// Show success dialog
  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Complaint Submitted Successfully!"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: () => _launchWhatsApp(whatsappNumber),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(FontAwesomeIcons.whatsapp, color: Colors.green, size: 30),
                  SizedBox(width: 8),
                  Text(
                    "Contact via WhatsApp",
                    style: TextStyle(
                      color: Colors.blue,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            Text("You can follow up after 3 days."),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text("Close"),
          ),
        ],
      ),
    );
  }

// Show error dialog
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Error"),
        content: Text(message), // استخدام الرسالة المرسلة
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text("Close"),
          ),
        ],
      ),
    );
  }


  // Widget for displaying each information row
  Widget _buildInfoRow(String title, String? value) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final isArabic = languageProvider.isArabic;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          // عرض العنوان باللغة العربية إذا كانت اللغة العربية مفعلّة
          Text(
            isArabic ? "$title: " : "$title: ", // إذا أردت تعديل العنوان ليناسب اللغة
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: primaryColor,
            ),
          ),
          Expanded(
            child: Text(
              value ?? (isArabic ? "غير مذكور" : "Not provided"), // تغيير النص البديل بناءً على اللغة
              style: TextStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
              overflow: TextOverflow.ellipsis, // لتقليل النصوص الزائدة
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildTextField({
    required String label,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    required Function(String) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: primaryColor,
          ),
        ),
        SizedBox(height: 8),
        TextFormField(
          decoration: InputDecoration(
            filled: true,
            fillColor: secondaryColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            hintText: hint,
            hintStyle: TextStyle(
              color: Colors.grey.shade400, // لون النص الخاص بـ hint
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
          keyboardType: keyboardType,
          maxLines: maxLines,
          onChanged: onChanged,
          validator: (value) => value!.isEmpty ? "$label is required" : null,
        ),
      ],
    );
  }


  Widget _buildChipSelector({
    required String label,
    required String? selectedValue,
    required List<String> items,
    required Function(String) onSelected,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: primaryColor),
        ),
        SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: items.map((item) {
            final isSelected = item == selectedValue;
            return ChoiceChip(
              label: Text(
                item,
                style: TextStyle(
                  color: isSelected ? Colors.white : primaryColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              selected: isSelected,
              onSelected: (selected) {
                onSelected(item);
              },
              selectedColor: accentColor,
              backgroundColor: secondaryColor,
              elevation: 3,
            );
          }).toList(),
        ),
      ],
    );
  }




_launchWhatsApp(String number) async {
    final whatsappUrl = "https://wa.me/$number?text=Hello%20I%20have%20a%20complaint.";
    await canLaunch(whatsappUrl) ? await launch(whatsappUrl) : throw 'Could not launch $whatsappUrl';
  }
}

//final primaryColor =Color.fromARGB(230, 230, 100, 140);

final secondaryColor = Color(0xFFF1F1F1);
//final accentColor =Color.fromARGB(230, 245, 115, 165);
const Color primaryColor = Color(0xFF296873); // Color from your previous design
const Color accentColor = Color(0xFF00796B); // Accent color for action items like buttons

