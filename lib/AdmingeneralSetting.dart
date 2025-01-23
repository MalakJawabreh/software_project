import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'config.dart';
import 'dart:convert';


class GeneralSetting extends StatefulWidget {
  @override
  final String token; // أضف التوكن هنا

  const GeneralSetting({required this.token});
  _GeneralSettingState createState() => _GeneralSettingState();
}

class _GeneralSettingState extends State<GeneralSetting> {
  bool _showAddAdminForm = false; // لتحديد ما إذا كان يجب عرض نموذج إضافة الأدمن

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  List<dynamic> admins = []; // لتخزين قائمة الأدمنز
  bool _isLoading = false; // لتحديد حالة التحميل
  bool _showAdmins = false; // لتحديد ما إذا كان يجب عرض قائمة الأدمنز


  // دالة لجلب قائمة الأدمنز
  Future<void> fetchAdmins(String token) async {
    setState(() {
      _isLoading = true; // بدء التحميل
    });

    try {
      final response = await http.get(
        Uri.parse('$getAdminn'), // استبدل بمسار الـ API الخاص بك
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          admins = data; // تحديث قائمة الأدمنز
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load admins')),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${error.toString()}')),
      );
    } finally {
      setState(() {
        _isLoading = false; // إنهاء التحميل
      });
    }
  }

  // دالة لحذف أدمن
  Future<void> deleteAdmin(String adminId,String token) async {
    try {
      final response = await http.delete(
        Uri.parse('$deleteAdminn/$adminId'), // استبدل بمسار الـ API الخاص بك
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          admins.removeWhere((admin) => admin['_id'] == adminId); // إزالة الأدمن من القائمة
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Admin deleted successfully')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete admin')),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${error.toString()}')),
      );
    }
  }

  Future<void> registerAdmin() async {
      try {
        final response = await http.post(
          Uri.parse('$registerAdminn'), // استبدل بمسار الـ API الخاص بك
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'name': _nameController.text,
            'email': _emailController.text,
            'password': _passwordController.text,
          }),
        );

        if (response.statusCode == 201) {
          // تم التسجيل بنجاح
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Admin registered successfully!')),
          );
        } else {
          // خطأ في التسجيل
          final responseData = json.decode(response.body);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(responseData['message'])),
          );
        }
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${error.toString()}')),
        );
      }

  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Page',style: TextStyle(
          color: Color(0xFF003366), // لون أزرق غامق
        ),),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // الفئة الأولى: Add Admin
            Card(
              color: Color(0xFFF1D9E1),// خلفية للكاليندر
              child: Column(
                children: [

                  // عنوان الفئة مع السهم
                  ListTile(
                    title: Text(
                      'Add Admin',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    trailing: Icon(
                      _showAddAdminForm ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                    ),
                    onTap: () {
                      setState(() {
                        _showAddAdminForm = !_showAddAdminForm; // تبديل حالة العرض
                      });
                    },
                  ),
                  // نموذج إضافة الأدمن (يظهر عند النقر على السهم)
                  if (_showAddAdminForm)
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          TextField(
                            controller: _nameController,
                            decoration: InputDecoration(
                              labelText: 'Name',
                              labelStyle: TextStyle(
                                color: Color(0xFF570520),// خلفية للكاليندر
                              ),
                              filled: true, // تفعيل تعبئة الخلفية
                              fillColor: Color(0xE6FFFFFF), // لون خلفية الحقل
                              border: OutlineInputBorder(
                                borderSide: BorderSide(color: Color(0xFF570520)), // لون الحدود
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Color(0xFF570520)), // لون الحدود عند التركيز
                              ),
                            ),
                          ),
                          SizedBox(height: 10),
                          TextField(
                            controller: _emailController,

                            decoration: InputDecoration(
                              labelText: 'Email',
                              labelStyle: TextStyle(
                                color: Color(0xFF570520),// خلفية للكاليندر
                              ),
                              filled: true, // تفعيل تعبئة الخلفية
                              fillColor: Color(0xE6FFFFFF), // لون خلفية الحقل
                              border: OutlineInputBorder(
                                borderSide: BorderSide(color: Color(0xFF570520)), // لون الحدود
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Color(0xFF570520)), // لون الحدود عند التركيز
                              ),
                            ),
                          ),
                          SizedBox(height: 10),
                          TextField(
                            obscureText: true,
                            controller: _passwordController,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              labelStyle: TextStyle(
                                color: Color(0xFF570520), // لون النص الخاص بالـ Label
                              ),
                              filled: true, // تفعيل تعبئة الخلفية
                              fillColor: Color(0xE6FFFFFF), // لون خلفية الحقل
                              border: OutlineInputBorder(
                                borderSide: BorderSide(color: Color(0xFF570520)), // لون الحدود
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Color(0xFF570520)), // لون الحدود عند التركيز
                              ),
                            ),
                          ),
                          SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: () {
                              registerAdmin();
                              // هنا يمكنك إضافة منطق إضافة الأدمن
                              // ScaffoldMessenger.of(context).showSnackBar(
                              //   SnackBar(content: Text('Admin Added Successfully!')),
                              // );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor:  Color(0xE6B2B8BD), // لون الخلفية
                              foregroundColor: Color(0xFF4E071E), // لون النص
                              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12), // التباعد الداخلي
                              textStyle: TextStyle(
                                fontSize: 16, // حجم النص
                                fontWeight: FontWeight.bold, // وزن النص
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8), // زوايا دائرية
                              ),
                            ),
                            child: Text('Add Admin'),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            SizedBox(height: 20),
            // الفئة الثانية: Show Admin
            Card(
              color: Color(0xFFF1D9E1), // خلفية الكارد
              child: ListTile(
                title: Text(
                  'Show Admin',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                trailing: IconButton(
                  icon: Icon(
                    _showAdmins ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                  ),
                  onPressed: () {
                    setState(() {
                      _showAdmins = !_showAdmins; // تبديل حالة العرض
                      if (_showAdmins) {
                        fetchAdmins(widget.token); // جلب قائمة الأدمنز عند عرضها
                      }
                    });
                  },
                ),
              ),
            ),
            if (_showAdmins) // عرض قائمة الأدمنز إذا كانت _showAdmins = true
              _isLoading
                  ? CircularProgressIndicator() // عرض مؤشر التحميل
                  : admins.isEmpty
                  ? Text('No admins found') // إذا كانت القائمة فارغة
                  : Expanded(
                child: ListView.builder(
                  itemCount: admins.length,
                  itemBuilder: (context, index) {
                    final admin = admins[index];
                    return Card(
                      color: Color(0xFFCCCACA), // لون خلفية الكارد

                      elevation: 2, // إضافة ظل
                      margin: EdgeInsets.symmetric(vertical: 4), // تباعد بين العناصر
                      child: ListTile(
                        tileColor: Color(0xFFCCCACA), // لون خلفية الـ ListTile
                        title: Text(
                          admin['name'] ?? 'No Name',
                          style: TextStyle(
                              color: Color(0xFF570520),
                              fontWeight: FontWeight.bold,
                              fontSize: 20),
                        ), // عرض اسم الأدمن

                        subtitle: Text(
                          admin['email'] ?? 'No Email',
                          style: TextStyle(color: Colors.black54), // لون النص الفرعي
                        ),
                        trailing: IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            deleteAdmin(admin['_id'], widget.token); // حذف الأدمن
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}