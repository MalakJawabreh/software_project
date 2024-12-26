import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'config.dart';
import 'currentlocation.dart';
import 'driver_data_model.dart';

class PersonalDetailsPage extends StatefulWidget {
  @override
  final String email;

  const PersonalDetailsPage({required this.email, Key? key})
      : super(key: key);

  _PersonalDetailsPageState createState() => _PersonalDetailsPageState();
}

class _PersonalDetailsPageState extends State<PersonalDetailsPage> {

  late DriverDataModel driverData = Provider.of<DriverDataModel>(context, listen: false);
  late Map<String, dynamic> userDetails; // لتخزين تفاصيل المستخدم

  @override
  void initState() {
    super.initState();
    // استدعاء الـ API عند فتح الصفحة
    _getUserDetails();
  }
  // دالة لاستدعاء الـ API وجلب بيانات المستخدم
  Future<void> _getUserDetails() async {
    final emails = widget.email; // الحصول على الإيميل من الـ widget

    try {
      final response = await http.get(Uri.parse('$getuser?email=$emails'));


      if (response.statusCode == 200) {
        setState(() {
          userDetails = json.decode(response.body)['user'];
        });
      } else {
        // يمكنك إضافة رسالة خطأ هنا إذا لزم الأمر
        print('Failed to load user details');
      }
    } catch (error) {

      print('Error: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Colors.blue; // اللون الأساسي
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Personal details',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Our App uses this information to verify your identity and to keep our community safe. You decide what personal details you make visible to others.',
                style: TextStyle(color: Colors.grey[600], fontSize: 16),
              ),
            ),
            Divider(),
            ListTile(
              title: Text(
                'Contact info',
                style: TextStyle(color:Color.fromARGB(230, 41, 84, 115),fontWeight: FontWeight.bold, fontSize: 19),
              ),
              subtitle: Text('${userDetails['email']}\n${userDetails['phoneNumber']}',style: TextStyle(color:Colors.black,fontSize: 16),),
              trailing: Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                // إضافة الإجراء المطلوب عند النقر
              },
            ),
            Divider(),
            if (userDetails['role'] == 'Driver') ...[
              ListTile(
                title: Text(
                  'Vehicle Information',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(230, 41, 84, 115),
                  ),
                ),
                //carNumber
                subtitle: Text('${userDetails['carType']}\n${userDetails['carNumber']}',style: TextStyle(color:Colors.black,fontSize: 16),),
                trailing: Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  // إضافة الإجراء المطلوب عند النقر
                },
              ),
              Divider(),
              ListTile(
                title: Text(
                  'License Images',
                  style: TextStyle(fontSize:19,fontWeight: FontWeight.bold,color:Color.fromARGB(230, 41, 84, 115),),
                ),
                trailing: Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  // إضافة الإجراء المطلوب عند النقر
                },
              ),
              Divider(),
            ],
            ListTile(
              title: Text(
                'Live Location',
                style: TextStyle(color:Color.fromARGB(230, 41, 84, 115),fontSize:19,fontWeight: FontWeight.bold),
              ),
              trailing: Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CurrentLocationPage(
                      email:widget.email,
                    ),
                  ),
                );
                // إضافة الإجراء المطلوب عند النقر
              },
            ),
            // if(driverData.location != null)
            // Text('location: ${driverData.location},visible:${driverData.visible}'),


          ],
        ),
      ),
    );
  }
}
