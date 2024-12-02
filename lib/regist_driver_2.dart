import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'package:project1/regist_driver_3.dart';

class VehicleInsuranceUpload extends StatefulWidget {
  @override
  _VehicleInsuranceUploadState createState() => _VehicleInsuranceUploadState();
}

class _VehicleInsuranceUploadState extends State<VehicleInsuranceUpload> {
  File? _selectedImage;

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

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
          crossAxisAlignment: CrossAxisAlignment.stretch,
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
                    border: Border.all(
                      color: Colors.orange, // تحديد لون الحدود البرتقالي
                      width: 2, // عرض الحدود
                    ),
                  ),
                  child: const Center(
                    child: Text(
                      '2', // نص فارغ داخل الدائرة
                      style: TextStyle(color: Colors.orange,fontSize: 20,fontWeight: FontWeight.bold), // يمكنك تحديد لون النص هنا إذا رغبت
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
                    border: Border.all(
                      color: Colors.orange, // تحديد لون الحدود البرتقالي
                      width: 2, // عرض الحدود
                    ),
                  ),
                  child: const Center(
                    child: Text(
                      '3', // نص فارغ داخل الدائرة
                      style: TextStyle(color: Colors.orange,fontSize: 20,fontWeight: FontWeight.bold), // يمكنك تحديد لون النص هنا إذا رغبت
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            const Text(
              'Step 2 of 3',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF616161)),
            ),
            const SizedBox(height: 20),
            const Text("Take a photo of your Vehicle Insurance",
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Color.fromARGB(230, 41, 84, 115)),
            ),
            const SizedBox(height: 10),
            SizedBox(height: 20,),
            if (_selectedImage == null)
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                    border: Border.all(color:Color.fromARGB(230, 41, 84, 115)),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.upload_file, size: 50, color: Colors.grey),
                        SizedBox(height: 8),
                        Text('Upload', style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ),
                ),
              )
            else
              Column(
                children: [
                  Image.file(
                    _selectedImage!,
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                ],
              ),
            SizedBox(height: 16),
            Text(
              'Submit this image if you think it\'s readable or tap on re-upload button to upload another one.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            SizedBox(height: 180),
            if (_selectedImage != null) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween, // لتوزيع الأزرار بالتساوي
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _pickImage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white, // لون الخلفية
                        foregroundColor:Color.fromARGB(230, 41, 84, 115), // لون النص
                        textStyle: TextStyle(
                          fontSize: 25, // حجم النص
                          fontWeight: FontWeight.bold, // سمك النص
                        ),
                        minimumSize: Size(double.infinity, 60), // الحد الأدنى للعرض والارتفاع
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero, // حواف مربعة
                          side: BorderSide(
                            color: Colors.grey, // لون السكني
                            width: 1, // سمك الحد
                          ),
                        ),
                      ),
                      child: Text('Re-upload', style: TextStyle(color:Color.fromARGB(230, 41, 84, 115),)),
                    ),
                  ),
                  SizedBox(width: 8), // المسافة بين الأزرار
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // Handle submit action here
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text('Image submitted successfully!'),
                        ));

                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => DriverLicenseUpload()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromARGB(230, 41, 84, 115), // لون الخلفية
                        foregroundColor: Colors.white, // لون النص
                        textStyle: TextStyle(
                          fontSize: 25, // حجم النص
                          fontWeight: FontWeight.bold, // سمك النص
                        ),
                        minimumSize: Size(double.infinity, 60), // الحد الأدنى للعرض والارتفاع
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero, // حواف مربعة
                        ),
                      ),
                      child: Text('Submit', style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              )
            ]
          ],
        ),
      ),
    );
  }
}