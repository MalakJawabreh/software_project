import 'package:flutter/material.dart';


class ApplicationSubmittedPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Driver Registration', style: TextStyle(color: Color.fromARGB(230, 41, 84, 115))),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 40, // عرض الدائرة
                  height: 40, // ارتفاع الدائرة
                  decoration: BoxDecoration(
                    shape: BoxShape.circle, // لتكون الشكل دائرة
                    color: Colors.orange, // تحديد اللون الخلفي (برتقالى)
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.check, // الأيقونة التي تريد عرضها
                      color: Colors.white, // تحديد لون الأيقونة (أبيض)
                      size: 24, // حجم الأيقونة
                    ),
                  ),
                ),
                SizedBox(width:5,),
                Container(
                  width: 100, // تحديد عرض الخط
                  height: 2, // تحديد سمك الخط
                  color: Colors.orange, // لون الخط
                ),
                SizedBox(width:5,),
                Container(
                  width: 40, // عرض الدائرة
                  height: 40, // ارتفاع الدائرة
                  decoration: BoxDecoration(
                    shape: BoxShape.circle, // لتكون الشكل دائرة
                    color: Colors.orange, // تحديد اللون الخلفي (برتقالى)
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.check, // الأيقونة التي تريد عرضها
                      color: Colors.white, // تحديد لون الأيقونة (أبيض)
                      size: 24, // حجم الأيقونة
                    ),
                  ),
                ),
                SizedBox(width:5,),
                Container(
                  width: 100, // تحديد عرض الخط
                  height: 2, // تحديد سمك الخط
                  color: Colors.orange, // لون الخط
                ),
                SizedBox(width:5,),
                Container(
                  width: 40, // عرض الدائرة
                  height: 40, // ارتفاع الدائرة
                  decoration: BoxDecoration(
                    shape: BoxShape.circle, // لتكون الشكل دائرة
                    color: Colors.orange, // تحديد اللون الخلفي (برتقالى)
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.check, // الأيقونة التي تريد عرضها
                      color: Colors.white, // تحديد لون الأيقونة (أبيض)
                      size: 24, // حجم الأيقونة
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 170,),
            Icon(
              Icons.check_circle_outline_rounded,
              size: 100,
              color: Colors.green,
            ),
            SizedBox(height: 20),
            Text(
              'Your application is submitted and is under review.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            SizedBox(height: 25),
            Text(
              'You will be notified with application status or check the status by going to Settings.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 19,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 150),
            SizedBox(
              width: double.infinity,
              child:ElevatedButton(
                onPressed: () {

                },
                style: ElevatedButton.styleFrom(
                  backgroundColor:Color.fromARGB(230, 41, 84, 115), // لون الخلفية (يمكنك تغييره)
                  foregroundColor: Colors.white, // لون النص
                  textStyle: TextStyle(
                    fontSize: 25, // حجم النص
                    fontWeight: FontWeight.bold, // سمك النص
                  ),
                  minimumSize: Size(double.infinity, 60), // الحد الأدنى للعرض والارتفاع (50 هو الارتفاع)
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero, // حواف مربعة (بدون انحناء)
                  ),
                ),
                child: const Text('Explore the App'),
              ),
            )
          ],
        ),
      ),
    );
  }
}
