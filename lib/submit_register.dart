import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'driver_data_model.dart';
import 'package:http/http.dart' as http ;
import 'config.dart';
import 'login.dart';


class ApplicationSubmittedPage extends StatefulWidget {
  @override
  _ApplicationSubmittedPageState createState() => _ApplicationSubmittedPageState();
}

class _ApplicationSubmittedPageState extends State<ApplicationSubmittedPage> {

  late DriverDataModel driverData;
  @override
  void initState() {
    super.initState();
    driverData = Provider.of<DriverDataModel>(context, listen: false);
  }

  void registerDriver() async {

    String? licenseImageBase64 = convertImageToBase64(driverData.licenseImage);
    String? InsuranceImageBase64 = convertImageToBase64(driverData.InsuranceImage);
    print(licenseImageBase64);
    print(InsuranceImageBase64);

    var regbody = {
          "fullName":driverData.fullName,
          "email": driverData.email,
          "password": driverData.password,
          "phoneNumber":driverData.phoneNumber,
          "gender": driverData.gender,
          "role": driverData.role,
          "carNumber":driverData.plateNumber,
          "carType": driverData.carMake,
          "licensePicture": licenseImageBase64,
          "InsurancePicture":InsuranceImageBase64,
        };

    print("Data sent to server: ${jsonEncode(regbody)}");

    var response = await http.post(Uri.parse(registeration),
            headers: {"Content-Type": "application/json"},
            body: jsonEncode(regbody));

    if (response.statusCode == 200) {
      var jsonResponse = jsonDecode(response.body);
      print("Response JSON: $jsonResponse");
      if (jsonResponse['status']) {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => Login()));
      } else {
        print("Error in registration: ${jsonResponse['message']}");
      }
    } else {
      print("Failed to register. Status code: ${response.statusCode}");
      print("Response body: ${response.body}");
    }
      }

  String? convertImageToBase64(File? imageFile) {
    if (imageFile == null) return null;

    try {
      List<int> imageBytes = imageFile.readAsBytesSync();
      String base64String = base64Encode(imageBytes);
      print("Base64 Encoded Image: $base64String");
      return base64String;
    } catch (e) {
      print("Error converting image to Base64: $e");
      return null;
    }
  }



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
                SizedBox(width: 5),
                Container(
                  width: 100, // تحديد عرض الخط
                  height: 2, // تحديد سمك الخط
                  color: Colors.orange, // لون الخط
                ),
                SizedBox(width: 5),
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
                SizedBox(width: 5),
                Container(
                  width: 100, // تحديد عرض الخط
                  height: 2, // تحديد سمك الخط
                  color: Colors.orange, // لون الخط
                ),
                SizedBox(width: 5),
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
            SizedBox(height: 170),
            Icon(
              Icons.check_circle_outline_rounded,
              size: 100,
              color: Colors.green,
            ),
            SizedBox(height: 20),
            if (driverData.licenseImage != null)
              Image.file(driverData.licenseImage!, height: 100, width: 100),
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
            // SizedBox(height: 3),
            // Text('Car Make: ${driverData.carMake}'),
            // SizedBox(height: 3),
            // Text('Plate Number: ${driverData.plateNumber}'),
            // SizedBox(height: 3),
            // Text('Insurance Expiration: ${driverData.insuranceExpirationDate}'),
            // SizedBox(height: 3),
            // Text('License Expiration: ${driverData.licenseExpirationDate}'),
            // SizedBox(height: 3),
            // Text('Full Name: ${driverData.fullName}'),
            // SizedBox(height: 3),
            // Text('Email: ${driverData.email}'),
            SizedBox(height: 25),
            Text(
              'You will be notified with application status or check the status by going to Settings.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 19,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 80),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  registerDriver();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromARGB(230, 41, 84, 115),
                  foregroundColor: Colors.white,
                  textStyle: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                  minimumSize: Size(double.infinity, 60),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero,
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
