import 'package:flutter/material.dart';
import 'language_provider.dart';
import 'dart:async';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class BookingDetailsScreen extends StatefulWidget {
  final dynamic booking;

  const BookingDetailsScreen({required this.booking, super.key});

  @override
  _BookingDetailsScreenState createState() => _BookingDetailsScreenState();
}

class _BookingDetailsScreenState extends State<BookingDetailsScreen> with SingleTickerProviderStateMixin {
  late bool _isVisible;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _isVisible = false;
    // هنا نبدأ تشغيل الحركة (تأثير التلاشي)
    _animationController = AnimationController(
      vsync: this, // الآن يمكننا استخدام `vsync` لأننا نستخدم `SingleTickerProviderStateMixin`
      duration: Duration(seconds: 2), // زمن التأثير
    );
    // بدء التأثير الحركي بعد فترة قصيرة
    Future.delayed(Duration(milliseconds: 100), () {
      setState(() {
        _isVisible = true; // جعل العناصر مرئية بعد التأثير
      });
      _animationController.forward();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final isArabic = languageProvider.isArabic;

    // استخراج البيانات من الحجز
    final nameP = widget.booking['nameP'] ?? (isArabic ? 'غير محدد' : 'Not specified');
    final emailP = widget.booking['EmailP'] ?? (isArabic ? 'غير محدد' : 'Not specified');
    final phoneNumberP = widget.booking['phoneNumberP'] ?? (isArabic ? 'غير محدد' : 'Not specified');
    final nameD = widget.booking['nameD'] ?? (isArabic ? 'غير محدد' : 'Not specified');
    final emailD = widget.booking['EmailD'] ?? (isArabic ? 'غير محدد' : 'Not specified');
    final phoneNumberD = widget.booking['phoneNumberD'] ?? (isArabic ? 'غير محدد' : 'Not specified');
    final from = widget.booking['from'] ?? (isArabic ? 'غير محدد' : 'Not specified');
    final to = widget.booking['to'] ?? (isArabic ? 'غير محدد' : 'Not specified');
    final price = widget.booking['price'] ?? 0;
    final date = widget.booking['date'] != null ? DateTime.parse(widget.booking['date']) : null;
    final time = widget.booking['time'] ?? (isArabic ? 'غير محدد' : 'Not specified');
    final carBrand = widget.booking['carBrand'] ?? (isArabic ? 'غير محدد' : 'Not specified');

    final note = widget.booking['Note'] ?? (isArabic ? 'لا يوجد ملاحظات' : 'No notes available');
    final seat = widget.booking['seat'] ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isArabic ? 'تفاصيل الحجز' : 'Booking Details',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor:primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [


              // عرض تفاصيل السائق
              _buildSectionTitle(isArabic ? 'معلومات السائق' : 'Driver Information'),
              _buildDetailCard(
                  isArabic,
                  isArabic ? 'الاسم:' : 'Name:',  // النص يعرض حسب اللغة
                  nameD),
              _buildDetailCard(isArabic,
                  isArabic ? 'البريد الإلكتروني:': 'Email:',
                  emailD),
              _buildDetailCard(isArabic,
                  isArabic ? 'رقم الهاتف:' : 'Phone Number:',  // النص يعرض حسب اللغة
                  phoneNumberD),
              SizedBox(height: 16),

              // تفاصيل الرحلة
              _buildSectionTitle(isArabic ? 'تفاصيل الرحلة' : 'Trip Details'),
              _buildDetailCard(isArabic,
                  isArabic ? 'من:':'From:',
                  from),
              _buildDetailCard(isArabic,
                  isArabic ?'إلى:':'To:',
                  to),
              _buildDetailCard(isArabic,
                  isArabic ? 'السعر:':'Price:',
                  '\$${price.toString()}'
              ),
              _buildDetailCard(isArabic,
                  isArabic ? 'التاريخ:':'Date:',
                  date != null ? '${date.day}/${date.month}/${date.year}' : (isArabic ? 'غير محدد' : 'Not specified')),
              _buildDetailCard(isArabic,
                  isArabic ?'الوقت:':'Time:',
                  time),
              _buildDetailCard(isArabic,
                  isArabic ?'عدد المقاعد:':'Seats:',
                  seat.toString()),
              SizedBox(height: 16),


              _buildDetailCard(isArabic,
                  isArabic ?'عدد المقاعد:':'carBrand:',
                  carBrand),

              // ملاحظات
              _buildSectionTitle(isArabic ? 'الملاحظات' : 'Notes'),
              _buildNoteCard(note),
            ],
          ),
        ),
      ),
    );
  }

  // بناء عنوان القسم (مثل "معلومات المسافر")
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryColor),
      ),
    );
  }

  // بناء كارد يحتوي على التفاصيل
  Widget _buildDetailCard(bool isArabic, String label, String value) {
    return AnimatedOpacity(
      opacity: _isVisible ? 1.0 : 0.0,
      duration: Duration(seconds: 1),
      child: Card(
        color:SecondryColor, // تحديد اللون الأسود للكارد

        elevation: 5,
        margin: const EdgeInsets.only(bottom: 15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
              ),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  value,
                  style: TextStyle(fontSize: 16),
                  textAlign: isArabic ? TextAlign.right : TextAlign.left,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // بناء الملاحظات في واجهة المستخدم
  Widget _buildNoteCard(String note) {
    return AnimatedOpacity(
      opacity: _isVisible ? 1.0 : 0.0,
      duration: Duration(seconds: 1),
      child: Card(
        color:SecondryColor, // تحديد اللون الأسود للكارد
        elevation: 5,
        margin: const EdgeInsets.only(bottom: 15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Text(
            note,
            style: TextStyle(fontSize: 16),
          ),
        ),
      ),
    );
  }
}

const Color SecondryColor = Color.fromARGB(230, 196, 209, 219);
//const Color SecondryColor2 = Color.fromARGB(230, 95, 190, 200);
const Color SecondryColor2 = Color.fromARGB(230, 130, 167, 175);
const Color complementaryPink = Color.fromARGB(230, 255, 153, 180);
const Color analogousPink = Color.fromARGB(230, 230, 100, 140);
const Color triadicPink = Color.fromARGB(230, 245, 115, 165);
const Color softPink = Color.fromARGB(230, 250, 170, 200);
const Color primaryColor = Color.fromARGB(230, 41, 84, 115); // اللون الأساسي
const Color primaryColor2 = Color.fromARGB(230, 20, 60, 115); // اللون الأساسي