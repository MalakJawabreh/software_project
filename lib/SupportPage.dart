import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SupportPage extends StatelessWidget {
  final bool isArabic;

  SupportPage({required this.isArabic});

  @override
  Widget build(BuildContext context) {
    final String whatsappNumber ="970569758887"; // ضع رقم WhatsApp هنا
    final String supportEmail = "wslnymk@gmail.com"; // ضع بريد الدعم هنا
    final String phoneNumber = "970569758887";

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title:   Text(
          isArabic ? 'الدعم' : 'Support',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(230, 41, 84, 115),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            SizedBox(height: 16),
            ListTile(
              leading:Icon(FontAwesomeIcons.whatsapp, color: Colors.green, size: 30),

              title: Text(
                isArabic ? 'التواصل عبر WhatsApp' : 'Contact via WhatsApp',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              onTap: () => _launchWhatsApp(whatsappNumber),
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.email, size: 30, color: Colors.red),
              title: Text(
                isArabic ? 'إرسال بريد إلكتروني' : 'Send Email',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              onTap: () => _launchEmail(supportEmail),
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.phone, size: 30, color: Colors.blue),
              title: Text(
                isArabic ? 'الاتصال هاتفياً' : 'Call Support',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              onTap: () => _launchPhoneCall(phoneNumber),
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.question_answer, size: 30, color: Colors.orange),
              title: Text(
                isArabic ? 'الأسئلة الشائعة' : 'FAQs',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FAQPage(isArabic: isArabic), // صفحة الأسئلة الشائعة
                  ),
                );
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.message, size: 30, color: Colors.purple),
              title: Text(
                isArabic ? 'نموذج الدعم' : 'Support Form',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SupportFormPage(isArabic: isArabic), // صفحة نموذج الدعم
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _launchWhatsApp(String number) async {
    final url = "https://wa.me/$number";
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch WhatsApp';
    }
  }

  void _launchEmail(String email) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: email,

    );
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    } else {
      throw 'Could not launch email';
    }
  }

  void _launchPhoneCall(String phoneNumber) async {
    final Uri phoneUri = Uri.parse("tel:$phoneNumber");
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      throw 'Could not launch phone call';
    }

  }

}



class FAQPage extends StatefulWidget {
  final bool isArabic;

  FAQPage({required this.isArabic});

  @override
  _FAQPageState createState() => _FAQPageState();
}

class _FAQPageState extends State<FAQPage> {
  final List<Map<String, String>> faqs = [
    {
      'question': 'كيف يمكنني التسجيل في التطبيق؟',
      'answer': 'يمكنك التسجيل من خلال صفحة التسجيل باستخدام البريد الإلكتروني أو رقم الهاتف.',
      'question_en': 'How can I register in the app?',
      'answer_en': 'You can register through the registration page using your email or phone number.',
    },
    {
      'question': 'هل يمكنني تعديل بياناتي الشخصية؟',
      'answer': 'نعم، يمكنك تعديل بياناتك الشخصية من خلال صفحة الإعدادات.',
      'question_en': 'Can I edit my personal data?',
      'answer_en': 'Yes, you can edit your personal data through the settings page.',
    },
    {
      'question': 'كيف أستطيع التواصل مع الدعم الفني؟',
      'answer': 'يمكنك التواصل مع الدعم الفني من خلال صفحة "الدعم" في التطبيق.',
      'question_en': 'How can I contact support?',
      'answer_en': 'You can contact support through the "Support" page in the app.',
    },
    {
      'question': 'كيف أستطيع تغيير لغة التطبيق؟',
      'answer': 'لتغيير لغة التطبيق، قم بالذهاب إلى الإعدادات واختيار اللغة المفضلة لديك.',
      'question_en': 'How can I change the app language?',
      'answer_en': 'To change the app language, go to settings and select your preferred language.',
    },
    {
      'question': 'كيف أستطيع تغيير ثيم التطبيق؟',
      'answer': 'لتغيير ثبم التطبيق، قم بالذهاب إلى الإعدادات واختيار الثيم المفضل لديك.',
      'question_en': 'How can I change the app theme?',
      'answer_en': 'To change the app theme, go to settings and select your preferred theme.',
    },
    {
      'question': 'كيف يمكنني تقديم شكوى؟',
      'answer': 'لتقديم شكوى، قم بزيارة  صفحة "الشكاوي" في التطبيق واملأ النموذج المخصص للشكاوى.',
      'question_en': 'How can I file a complaint?',
      'answer_en': 'To file a complaint, visit the "complaint" page in the app and fill out the complaint form.',
    }
  ];

  List<Map<String, String>> filteredFaqs = [];

  @override
  void initState() {
    super.initState();
    filteredFaqs = faqs;  // تهيئة الفئة لتخزين الأسئلة الافتراضية
  }

  void filterFAQs(String query) {
    final results = faqs
        .where((faq) =>
    faq['question']!.toLowerCase().contains(query.toLowerCase()) ||
        faq['question_en']!.toLowerCase().contains(query.toLowerCase()))
        .toList();
    setState(() {
      filteredFaqs = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(

        backgroundColor: Color.fromARGB(230, 41, 84, 115), // لون أزرق مميز
        title: Text(
          widget.isArabic ? 'الأسئلة الشائعة' : 'FAQs',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () async {
              final query = await showSearch(
                context: context,
                delegate: FAQSearchDelegate(),
              );
              if (query != null) {
                filterFAQs(query);
              }
            },
          ),
        ],
      ),
      body: Container(
        color: Color(0xFFF1F8E9), // خلفية خفيفة ولطيفة
        padding: EdgeInsets.all(16),
        child: ListView.builder(
          itemCount: filteredFaqs.length,
          itemBuilder: (context, index) {
            return Card(
              elevation: 5, // الظل لإضفاء تأثير ثلاثي الأبعاد
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10), // حواف دائرية
              ),
              margin: EdgeInsets.symmetric(vertical: 8),
              child: ExpansionTile(
                tilePadding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                title: Text(
                  widget.isArabic
                      ? filteredFaqs[index]['question']!
                      : filteredFaqs[index]['question_en']!,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color:Color.fromARGB(230, 41, 84, 115), // اللون الأزرق
                  ),
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      widget.isArabic
                          ? filteredFaqs[index]['answer']!
                          : filteredFaqs[index]['answer_en']!,
                      style: TextStyle(fontSize: 16, color: Colors.black),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class FAQSearchDelegate extends SearchDelegate<String?> {
  final List<Map<String, String>> faqs = [
    {
      'question': 'كيف يمكنني التسجيل في التطبيق؟',
      'answer': 'يمكنك التسجيل من خلال صفحة التسجيل باستخدام البريد الإلكتروني أو رقم الهاتف.',
      'question_en': 'How can I register in the app?',
      'answer_en': 'You can register through the registration page using your email or phone number.',
    },
    {
      'question': 'هل يمكنني تعديل بياناتي الشخصية؟',
      'answer': 'نعم، يمكنك تعديل بياناتك الشخصية من خلال صفحة الإعدادات.',
      'question_en': 'Can I edit my personal data?',
      'answer_en': 'Yes, you can edit your personal data through the settings page.',
    },
    {
      'question': 'كيف أستطيع التواصل مع الدعم الفني؟',
      'answer': 'يمكنك التواصل مع الدعم الفني من خلال صفحة "الدعم" في التطبيق.',
      'question_en': 'How can I contact support?',
      'answer_en': 'You can contact support through the "Support" page in the app.',
    },
    {
      'question': 'كيف أستطيع تغيير لغة التطبيق؟',
      'answer': 'لتغيير لغة التطبيق، قم بالذهاب إلى الإعدادات واختيار اللغة المفضلة لديك.',
      'question_en': 'How can I change the app language?',
      'answer_en': 'To change the app language, go to settings and select your preferred language.',
    },
    {
      'question': 'كيف أستطيع تغيير ثيم التطبيق؟',
      'answer': 'لتغيير ثيم التطبيق، قم بالذهاب إلى الإعدادات واختيار الثيم المفضل لديك.',
      'question_en': 'How can I change the app theme?',
      'answer_en': 'To change the app theme, go to settings and select your preferred theme.',
    },
    {
      'question': 'كيف يمكنني تقديم شكوى؟',
      'answer': 'لتقديم شكوى، قم بزيارة  صفحة "الشكاوي" في التطبيق واملأ النموذج المخصص للشكاوى.',
      'question_en': 'How can I file a complaint?',
      'answer_en': 'To file a complaint, visit the "complaint" page in the app and fill out the complaint form.',
    }

  ];

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final results = faqs
        .where((faq) => faq['question']!.toLowerCase().contains(query.toLowerCase()) ||
        faq['question_en']!.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return ListView(
      children: results
          .map(
            (faq) => ListTile(
          title: Text(faq['question']!),
          onTap: () {
            close(context, faq['question']);
          },
        ),
      )
          .toList(),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestions = faqs
        .where((faq) => faq['question']!.toLowerCase().contains(query.toLowerCase()) ||
        faq['question_en']!.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return ListView(
      children: suggestions
          .map(
            (faq) => ListTile(
          title: Text(faq['question']!),
          onTap: () {
            query = faq['question']!;
            showResults(context);
          },
        ),
      )
          .toList(),
    );
  }
}




class SupportFormPage extends StatefulWidget {
  final bool isArabic;

  SupportFormPage({required this.isArabic});

  @override
  _SupportFormPageState createState() => _SupportFormPageState();
}

class _SupportFormPageState extends State<SupportFormPage> {
  final TextEditingController complaintController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  String? selectedCategory;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isArabic ? 'نموذج الدعم' : 'Support Form',
          style: TextStyle(color: Color(0xFF006699),fontWeight: FontWeight.bold), // جعل النص باللون الأزرق الغامق
        ),

      //  backgroundColor: Color(0xFF003366), // اللون الأزرق الداكن (Deep Blue)
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF006699),  // الأزرق الفاتح
                    Color(0xFF3399CC),  // الأزرق السماوي
                    Color(0x004266E7),  // الأزرق الداكن

                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  stops: [0.2, 0.5, 0.8],
                  tileMode: TileMode.mirror, // تأثير تكرار اللون
                ),
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.isArabic ? 'يرجى ملء النموذج أدناه' : 'Please fill out the form below',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  SizedBox(height: 16),
                  Text(
                    widget.isArabic ? 'الشكوى أو الاستفسار:' : 'Complaint or Inquiry:',
                    style: TextStyle(fontSize: 16, color: Colors.white70),
                  ),
                  SizedBox(height: 8),
                  TextField(
                    controller: complaintController,
                    decoration: InputDecoration(
                      hintText: widget.isArabic ? 'اكتب شكواك هنا' : 'Write your complaint here',
                      hintStyle: TextStyle(color: Colors.grey),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.9),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Color(0xFF003366), width: 2), // Deep Blue
                      ),
                    ),
                    maxLines: 5,
                  ),
                  SizedBox(height: 16),
                  Text(
                    widget.isArabic ? 'اختر الفئة:' : 'Choose a category:',
                    style: TextStyle(fontSize: 16, color: Colors.white70),
                  ),
                  SizedBox(height: 8),
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 5, horizontal: 15),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 6,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: DropdownButton<String>(
                      value: selectedCategory,
                      hint: Text(widget.isArabic ? 'اختر الفئة' : 'Select Category'),
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedCategory = newValue;
                        });
                      },
                      isExpanded: true,
                      icon: Icon(Icons.arrow_drop_down, color: Color(0xFF003366)), // Deep Blue
                      underline: Container(),
                      items: <String>['دعم فني', 'شكاوى عامة', 'استفسار']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value, style: TextStyle(color: Color(0xFF003366))),
                        );
                      }).toList(),
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    widget.isArabic ? 'البريد الإلكتروني (اختياري):' : 'Email (Optional):',
                    style: TextStyle(fontSize: 16, color: Colors.white70),
                  ),
                  SizedBox(height: 8),
                  TextField(
                    controller: emailController,
                    decoration: InputDecoration(
                      hintText: widget.isArabic ? 'اكتب بريدك الإلكتروني هنا' : 'Enter your email here',
                      hintStyle: TextStyle(color: Colors.white60),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.9),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Color(0xFF003366), width: 2), // Deep Blue
                      ),
                    ),
                  ),
                  SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      if (complaintController.text.isNotEmpty && selectedCategory != null) {
                        String complaint = complaintController.text;
                        String category = selectedCategory!;
                        String email = emailController.text.isNotEmpty ? emailController.text : "Not Provided";

                        // عرض رسالة تأكيد
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text(widget.isArabic ? 'تم إرسال الشكوى' : 'Complaint Submitted'),
                            content: Text(widget.isArabic
                                ? 'تم إرسال شكواك بنجاح. سنقوم بالرد عليك في أقرب وقت.'
                                : 'Your complaint has been successfully submitted. We will respond to you shortly.'),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: Text(widget.isArabic ? 'موافق' : 'OK'),
                              ),
                            ],
                          ),
                        );
                      } else {
                        // في حال كانت الحقول فارغة أو لم يتم اختيار الفئة
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text(widget.isArabic ? 'خطأ' : 'Error'),
                            content: Text(widget.isArabic
                                ? 'يرجى إدخال شكوى أو استفسار واختيار الفئة.'
                                : 'Please enter a complaint or inquiry and select a category.'),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: Text(widget.isArabic ? 'موافق' : 'OK'),
                              ),
                            ],
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF003366), // Deep Blue
                      padding: EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    child: Text(
                      widget.isArabic ? 'إرسال ' : 'Submit ',
                      style: TextStyle(color: Colors.white), // جعل النص باللون الأبيض
                    ),

                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
