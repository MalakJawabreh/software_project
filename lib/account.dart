import 'package:flutter/material.dart';
import 'package:project1/personalDetails.dart';

import 'ChangePasswordPage.dart';

class AccountsCenterPage extends StatefulWidget {
  @override
  final String username;
  final String email;

  const AccountsCenterPage({required this.username,required this.email, Key? key})
      : super(key: key);

  _AccountsCenterPageState createState() => _AccountsCenterPageState();
}

class _AccountsCenterPageState extends State<AccountsCenterPage> {
  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Colors.blue; // لون أساسي مشابه لتصميم Meta

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Accounts Center',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(16),
              color: Colors.grey.shade100,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Column(
                      children: [
                        Icon(Icons.link, size: 40, color: primaryColor),
                        SizedBox(height: 8),
                        Text(
                          'Manage your connected experiences and account\nsettings across Meta technologies like Facebook, Instagram and Meta Horizon.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.black87),
                        ),
                        SizedBox(height: 8),
                        TextButton(
                          onPressed: () {},
                          child: Text('Learn more', style: TextStyle(color: primaryColor)),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16),
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Row(
                      children: [
                        // CircleAvatar(
                        //   //backgroundColor: Colors.grey,
                        //   radius: 24,
                        // ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            widget.username,
                            style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Account settings',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
            ),
            ListTile(
              leading: Icon(Icons.security, color: primaryColor),
              title: Text('Password and security',style: TextStyle( fontSize: 18),),
              trailing: Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChangePasswordPage(
                    ),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.person, color: primaryColor),
              title: Text('Personal details',style: TextStyle( fontSize: 18),),
              trailing: Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PersonalDetailsPage(
                      email:widget.email,
                    ),
                  ),
                );

              },
            ),
            ListTile(
              leading: Icon(Icons.info, color: primaryColor),
              title: Text('Your information and permissions',style: TextStyle( fontSize: 18),),
              trailing: Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }
}
