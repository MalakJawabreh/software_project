import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';  // استيراد مكتبة intl
import 'package:url_launcher/url_launcher.dart';  // استيراد مكتبة url_launcher
import 'config.dart';  // استيراد ملف الكونفجر

class ComplaintsPage extends StatefulWidget {
  @override
  _ComplaintsPageState createState() => _ComplaintsPageState();
}

class _ComplaintsPageState extends State<ComplaintsPage> {
  List<dynamic> complaints = [];
  List<dynamic> filteredComplaints = [];  // لتخزين الشكاوى المفلترة
  TextEditingController searchController = TextEditingController(); // التحكم في شريط البحث

  @override
  void initState() {
    super.initState();
    _fetchComplaints();
  }

  // دالة لجلب الشكاوى من الـ API
  Future<void> _fetchComplaints() async {
    try {
      final response = await http.get(Uri.parse(getAllComplaints)); // استخدام الرابط من ملف الكونفجر

      if (response.statusCode == 200) {
        setState(() {
          complaints = json.decode(response.body)['data'];
          filteredComplaints = complaints;  // تعيين الشكاوى الأصلية في filteredComplaints
        });
      } else {
        _showError('Failed to load complaints');
      }
    } catch (e) {
      _showError('Error: $e');
    }
  }

  // دالة لعرض رسالة الخطأ
  void _showError(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error', style: TextStyle(color: Colors.red)),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  // دالة لتنسيق التاريخ
  String _formatDate(String dateString) {
    try {
      DateTime date = DateTime.parse(dateString);
      return DateFormat('yyyy-MM-dd – HH:mm').format(date);  // تنسيق التاريخ
    } catch (e) {
      return 'Invalid date';
    }
  }

  // دالة للتواصل مع المشتكي عبر واتساب
  Future<void> _contactViaWhatsApp(String phone) async {
    String message = 'Hello, your complaint is being processed. We will update you shortly.';
    String url = 'https://wa.me/970$phone?text=${Uri.encodeComponent(message)}';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch WhatsApp';
    }
  }

  // دالة للتواصل مع الشخص المشتكى عليه عبر واتساب
  Future<void> _contactReportedPersonViaWhatsApp(String phone) async {
    String message = 'Hello, we would like to inform you about the complaint filed against you. Please check your account for more details.';
    String url = 'https://wa.me/970$phone?text=${Uri.encodeComponent(message)}';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch WhatsApp';
    }
  }

  // دالة للبحث في الشكاوى بناءً على النص المدخل
  void _filterComplaints(String query) {
    if (query.isEmpty) {
      setState(() {
        filteredComplaints = complaints;  // إذا كان النص فارغاً، عرض جميع الشكاوى
      });
    } else {
      setState(() {
        filteredComplaints = complaints.where((complaint) {
          return complaint['complainantName'].toLowerCase().contains(query.toLowerCase()) ||
              complaint['complainantPhone'].toLowerCase().contains(query.toLowerCase()) ||
              complaint['complaintDetails'].toLowerCase().contains(query.toLowerCase());
        }).toList();
      });
    }
  }

  // دالة لحذف الشكوى
  /*Future<void> _deleteComplaint(String complaintId) async {
    try {
      final response = await http.delete(Uri.parse('$getComplaintById/$complaintId'));  // رابط الحذف من الـ API
      if (response.statusCode == 200) {
        setState(() {
          complaints.removeWhere((complaint) => complaint['id'] == complaintId);
          filteredComplaints.removeWhere((complaint) => complaint['id'] == complaintId);
        });
        _showError('Complaint deleted successfully');
      } else {
        _showError('Failed to delete complaint');
      }
    } catch (e) {
      _showError('Error: $e');
    }
  }*/

  // دالة لتحديد أن الشكوى تم حلها
/*  Future<void> _markAsResolved(String complaintId) async {
    try {
      final response = await http.patch(
        Uri.parse('$getComplaintById/$complaintId'),
        body: json.encode({'status': 'resolved'}),  // إرسال حالة الشكوى كـ "تم الحل"
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        setState(() {
          final complaint = complaints.firstWhere((complaint) => complaint['id'] == complaintId);
          complaint['status'] = 'resolved';  // تحديث حالة الشكوى محليًا
          filteredComplaints = complaints;  // إعادة تحميل الشكاوى المفلترة بعد التحديث
        });
        _showError('Complaint marked as resolved');
      } else {
        _showError('Failed to update complaint status');
      }
    } catch (e) {
      _showError('Error: $e');
    }
  }*/

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('All Complaints'),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(50),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: searchController,
              onChanged: _filterComplaints,  // كلما تغير النص في شريط البحث، يتم التصفية
              decoration: InputDecoration(
                hintText: 'Search complaints...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),  // جعل الزوايا مستديرة
                ),
                prefixIcon: Icon(Icons.search),
                contentPadding: EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
        ),
      ),
      body: filteredComplaints.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: filteredComplaints.length,
        itemBuilder: (context, index) {
          final complaint = filteredComplaints[index];
          return Card(
            margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            color: Colors.white,
            shadowColor: Colors.tealAccent,
            child: Padding(
              padding: EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // اسم المشتكي
                  Text(
                    'Complainant: ${complaint['complainantName']}',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Colors.teal),
                  ),
                  SizedBox(height: 5),
                  // البريد الإلكتروني و رقم الهاتف
                  Text(
                    'Email: ${complaint['complainantEmail']}',
                    style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                  ),
                  Text(
                    'Phone: ${complaint['complainantPhone']}',
                    style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                  ),
                  SizedBox(height: 10),
                  Divider(color: Colors.teal, thickness: 2),
                  SizedBox(height: 10),
                  // اسم الشخص المشتكى عليه
                  Text(
                    'Reported Person: ${complaint['reportedPersonName']}',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.blue),
                  ),
                  Text(
                    'Role: ${complaint['reportedPersonRole']}',
                    style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                  ),
                  Text(
                    'Phone: ${complaint['reportedPersonPhone']}',
                    style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                  ),
                  SizedBox(height: 10),
                  Divider(color: Colors.blue, thickness: 2),
                  SizedBox(height: 10),
                  // نوع الشكوى و التفاصيل
                  Text(
                    'Complaint Type: ${complaint['complaintType']}',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.deepOrange),
                  ),
                  Text(
                    'Details: ${complaint['complaintDetails']}',
                    style: TextStyle(fontSize: 16, color: Colors.black87),
                  ),
                  SizedBox(height: 10),
                  // عرض التاريخ
                  Text(
                    'Date: ${_formatDate(complaint['date'])}',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  SizedBox(height: 10),
                  // زر للتواصل مع المشتكي عبر واتساب

                  // زر للتواصل مع المشتكى عليه عبر واتساب
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  // زر للتواصل مع المشتكي
                  ElevatedButton(
                    onPressed: () {
                      _contactViaWhatsApp(complaint['complainantPhone']);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text('Contact Complainant'),
                  ),
                  // زر للتواصل مع المشتكى عليه
                  ElevatedButton(
                    onPressed: () {
                      _contactReportedPersonViaWhatsApp(complaint['reportedPersonPhone']);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text('Contact Reported Person'),
                  ),
                  // زر لحذف الشكوى
                  ElevatedButton(
                    onPressed: () {
                   //   _deleteComplaint(complaint['id']);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text('Delete Complaint'),
                  ),
                  // زر لتحديد أن الشكوى تم حلها
                  ElevatedButton(
                    onPressed: () {
                    //  _markAsResolved(complaint['id']);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text('Mark as Resolved'),
                  ),
            ],
          ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
