import 'package:flutter/material.dart';

import 'login.dart';

class WebPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // خلفية الصورة
          Positioned.fill(
            child: Image.asset(
              'imagess/web.jpg', // ضع هنا مسار الصورة التي تريد استخدامها
              fit: BoxFit.cover,
            ),
          ),
          // إضافة طبقة سوداء شفافة فوق الصورة
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.6), // اللون الأسود مع شفافية
            ),
          ),
          // المحتوى
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // اسم الجامعة في منتصف الصفحة
                Text(
                  "Wassalni Ma'ak",
                  style: TextStyle(
                    fontSize: 100,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(230, 215, 235, 250),
                    shadows: [
                      Shadow(
                        offset: Offset(2, 2),
                        blurRadius: 3,
                        color: Colors.black.withOpacity(0.5),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Make Your Life Easy',
                  style: TextStyle(
                    fontSize: 30,
                    color: Color.fromARGB(230, 109, 187, 246),
                    shadows: [
                      Shadow(
                        offset: Offset(2, 2),
                        blurRadius: 3,
                        color: Colors.black.withOpacity(0.5),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 40),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => Login()),
                    );
                  },
                  child: Text('Start Now',style: TextStyle(fontWeight: FontWeight.bold),),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromARGB(230, 215, 235, 250),
                    foregroundColor: Color.fromARGB(255, 158, 9, 56),
                    padding: EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                    textStyle: TextStyle(fontSize: 18),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
