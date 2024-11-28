import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'language_provider.dart';

class LiveLocationPage extends StatefulWidget {
  final bool isLocationShared;
  final String? sharedContactName;
  final String? timeLeft;

  LiveLocationPage({
    this.isLocationShared = false, // القيمة الافتراضية
    this.sharedContactName,
    this.timeLeft,
  });


  @override
  _LiveLocationPageState createState() => _LiveLocationPageState();
}

class _LiveLocationPageState extends State<LiveLocationPage> {
  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final isArabic = languageProvider.isArabic;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isArabic ? 'الموقع المباشر' : 'Live Location',
          style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
        ),
      ),
      body: widget.isLocationShared
          ? Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // عرض جهة الاتصال
          ListTile(
            leading: CircleAvatar(
              child: Icon(Icons.person, color: Colors.white),
              backgroundColor: primaryColor,
            ),
            title: Text(
              widget.sharedContactName ?? "",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            subtitle: Text(widget.timeLeft ?? ""),
          ),
          // النص السفلي
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text(
              isArabic
                  ? 'يتطلب الموقع المباشر إعدادات الخلفية. يمكنك إدارتها من إعدادات جهازك.'
                  : 'Live location requires background location. You can manage this in your device settings.',
              style: TextStyle(fontSize: 14, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
            child: ElevatedButton(
              onPressed: () {
                // هنا يتم تحديث الصفحة لوقف المشاركة
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      isArabic
                          ? 'تم إيقاف مشاركة الموقع'
                          : 'Location sharing stopped',
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                minimumSize: Size(double.infinity, 60), // عرض الزر كامل الشاشة وارتفاعه 60
                padding: EdgeInsets.symmetric(vertical: 20), // زيادة المساحة الداخلية
              ),
              child: Text(
                isArabic ? 'إيقاف المشاركة' : 'Stop Sharing',
                style: TextStyle(fontSize: 20, color: Colors.white), // تكبير النص إلى 20
              ),
            ),
          ),
        ],
      )
          : Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.location_off, size: 60, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              isArabic
                  ? 'لا يتم مشاركة الموقع المباشر في أي محادثة'
                  : 'You aren\'t sharing live location in any chats',
              style: TextStyle(fontSize: 16, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Text(
              isArabic
                  ? 'يتطلب الموقع المباشر إعدادات الخلفية. يمكنك إدارتها من إعدادات جهازك.'
                  : 'Live location requires background location. You can manage this in your device settings.',
              style: TextStyle(fontSize: 14, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

const Color primaryColor = Color.fromARGB(230, 41, 84, 115);
