import 'package:flutter/material.dart';
import 'language_provider.dart';
import 'dart:async';
import 'package:provider/provider.dart';
import 'DriverDetailsBooking.dart';

class BookingDetailsScreen extends StatefulWidget {
  final dynamic booking;

  const BookingDetailsScreen({required this.booking, super.key});

  @override
  _BookingDetailsScreenState createState() => _BookingDetailsScreenState();
}

class _BookingDetailsScreenState extends State<BookingDetailsScreen>
    with SingleTickerProviderStateMixin {
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

        backgroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // عرض تفاصيل السائق
              _buildSectionTitle(isArabic ? 'معلومات السائق' : 'Driver Information'),
              _buildDetailCard(isArabic, "", nameD, () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DriverDetailsScreen(
                      name: nameD,
                      email: emailD,
                      phoneNumber: phoneNumberD,
                      emailP:emailP,
                        nameP:nameP,
                    ),
                  ),
                );
              }),


            //  _buildDetailCard(isArabic, isArabic ? 'البريد الإلكتروني:' : 'Email:', emailD),
            //  _buildDetailCard(isArabic, isArabic ? 'رقم الهاتف:' : 'Phone Number:', phoneNumberD),
              SizedBox(height: 16),

              // تفاصيل الرحلة
              _buildSectionTitle(isArabic ? 'تفاصيل الرحلة' : 'Trip Details'),

            _buildDetailCard2(isArabic,from, to),

            _buildDetailCard3(
              isArabic,
              date != null ? '${date.day}/${date.month}/${date.year}' : (isArabic ? 'غير محدد' : 'Not specified'),
              time,
                '${price.toString()}\ ILS'
            ),

            _buildDetailCard(isArabic, isArabic ? 'عدد المقاعد:' : 'Seats:', seat.toString()),

              _buildDetailCard4(isArabic, isArabic ? 'ماركة السيارة:' : 'Car Brand:', carBrand),

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
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: primaryColor),
      ),
    );
  }

  // بناء كارد يحتوي على التفاصيل (عرض الأيقونة بجانب اسم السائق فقط)
  Widget _buildDetailCard(bool isArabic, String label, String value, [VoidCallback? onTap]) {
    return AnimatedOpacity(
      opacity: _isVisible ? 1.0 : 0.0, // استخدام متغير التحكم في التلاشي
      duration: Duration(seconds: 1),  // زمن التلاشي
      child: GestureDetector(
        onTap: onTap,
        child: Card(
          color: Color.fromARGB(230, 245, 249, 255),
          elevation: 5,
          margin: const EdgeInsets.only(bottom: 15),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // إضافة الأيقونة بجانب الاسم فقط إذا كان هذا هو كارد السائق
                if (label == "") ...[
                  Icon(Icons.account_circle, color: Colors.grey[600], size: 30),
                  SizedBox(width: 8), // مسافة بين الأيقونة والاسم
                ],
                Text(
                  label,
                  style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold, color: Color.fromARGB(
                      150, 189, 10, 102)),                ),
                Expanded(
                  child: Text(
                    value,
                    style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold),
                    textAlign: isArabic ? TextAlign.right : TextAlign.left, // عرض النص حسب اللغة
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  bool _isDetailVisible = false; // التحكم في عرض التفاصيل الإضافية


  Widget _buildDetailCard4(bool isArabic, String label, String value, [VoidCallback? onTap]) {

    return AnimatedOpacity(
      opacity: 1.0,
      duration: Duration(seconds: 1),
      child: GestureDetector(
        onTap: onTap,
        child: Card(
          color: Color.fromARGB(230, 245, 249, 255),
          elevation: 5,
          margin: const EdgeInsets.only(bottom: 15),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      label,
                      style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold, color: Color.fromARGB(150, 189, 10, 102)),
                    ),
                    Expanded(
                      child: Text(
                        value,
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        textAlign: isArabic ? TextAlign.right : TextAlign.left,
                      ),
                    ),
                    // السهم في أقصى اليمين
                    IconButton(
                      icon: Icon(Icons.arrow_drop_down),
                      onPressed: () {
                        setState(() {
                          _isDetailVisible = !_isDetailVisible; // تبديل القيمة عند الضغط على السهم
                        });
                      },
                    ),
                  ],
                ),
                // توسيع الكارد عند تغيير _isDetailVisible إلى true
                if (_isDetailVisible) ...[
                  Padding(
                    padding: const EdgeInsets.only(left: 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Car Number : 123456 ', style: TextStyle(fontSize: 17,fontWeight: FontWeight.bold)),
                        Row(
                          children: [
                            Text('Color : ', style: TextStyle(fontSize: 17,fontWeight: FontWeight.bold)),
                            Container(
                              width: 20, // عرض المربع
                              height: 20, // ارتفاع المربع
                              color: Colors.red, // لون المربع
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }






  Widget _buildDetailCard2(bool isArabic, String from, String to, [VoidCallback? onTap]) {
    return AnimatedOpacity(
      opacity: _isVisible ? 1.0 : 0.0, // استخدام متغير التحكم في التلاشي
      duration: Duration(seconds: 1), // زمن التلاشي
      child: GestureDetector(
        onTap: onTap,
        child: Card(
          color: Color.fromARGB(230, 245, 249, 255),
          elevation: 5,
          margin: const EdgeInsets.only(bottom: 15),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // "From" النص والقيمة
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(Icons.location_on, color: Colors.green, size: 20), // الأيقونة
                    SizedBox(width: 8), // مسافة بين الأيقونة والنص
                    Text(
                      isArabic ? 'من:' : 'From: ',
                      style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold, color: Color.fromARGB(
                          150, 189, 10, 102)),
                    ),
                    Expanded(
                      child: Text(
                          from,
                        style: TextStyle(fontSize: 17,fontWeight: FontWeight.bold),
                        textAlign: isArabic ? TextAlign.right : TextAlign.left, // عرض النص حسب اللغة
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 5), // مسافة بين "From" و "To"
                Padding(
                  padding: const EdgeInsets.only(left: 8.0), // تحديد المسافة على اليسار
                  child: Container(
                    width: 2, // عرض الخط
                    height: 20, // طول الخط
                    color: Colors.grey, // لون الخط
                  ),
                ),
                // "To" النص والقيمة
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(Icons.location_on, color: Colors.green, size: 20), // الأيقونة
                    SizedBox(width: 8),
                    Text(
                      isArabic ? 'إلى:' : 'To: ',
                      style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold, color: Color.fromARGB(
                          150, 189, 10, 102)),
                    ),
                    Expanded(
                      child: Text(
                        to,
                        style: TextStyle(fontSize: 17,fontWeight: FontWeight.bold),
                        textAlign: isArabic ? TextAlign.right : TextAlign.left, // عرض النص حسب اللغة
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailCard3(bool isArabic, String date, String time,String Price, [VoidCallback? onTap]) {
    return AnimatedOpacity(
      opacity: _isVisible ? 1.0 : 0.0, // استخدام متغير التحكم في التلاشي
      duration: Duration(seconds: 1), // زمن التلاشي
      child: GestureDetector(
        onTap: onTap,
        child: Card(
          color: Color.fromARGB(230, 245, 249, 255),
          elevation: 5,
          margin: const EdgeInsets.only(bottom: 15),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween, // توزيع العناصر بالتساوي
              children: [
                // التاريخ
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isArabic ? 'التاريخ:' : 'Date:',
                        style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold, color: Color.fromARGB(
                            150, 189, 10, 102)),
                      ),
                      Text(
                        date,
                        style: TextStyle(fontSize: 16, color: Colors.black,fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 20), // مسافة بين العمودين
                // الوقت
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isArabic ? 'الوقت:' : 'Time:',
                        style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold, color: Color.fromARGB(
                            150, 189, 10, 102)),
                      ),
                      Text(
                        time,
                        style: TextStyle(fontSize: 16, color: Colors.black,fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 20), // مسافة بين العمودين
                // الوقت
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isArabic ? 'السعر:' : 'Price:',
                        style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold, color: Color.fromARGB(
                            150, 189, 10, 102)),
                      ),
                      Text(
                        Price,
                        style: TextStyle(fontSize: 16, color: Colors.black,fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ],
            ),
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
        color: Color.fromARGB(230, 245, 249, 255),
        elevation: 5,
        margin: const EdgeInsets.only(bottom: 15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Text(
            note,
            style: TextStyle(fontSize: 17,fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}

const Color SecondryColor = Color.fromARGB(230, 196, 209, 219);
const Color primaryColor = Color.fromARGB(230, 41, 84, 115); // اللون الأساسي
