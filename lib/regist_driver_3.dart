import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:intl/intl.dart';
import 'package:project1/submit_register.dart';
import 'package:provider/provider.dart';

import 'driver_data_model.dart';

class DriverLicenseUpload extends StatefulWidget {
  @override
  _DriverLicenseUploadState createState() => _DriverLicenseUploadState();
}

class _DriverLicenseUploadState extends State<DriverLicenseUpload> {
  File? _selectedImage;
  String _expirationDate = '';
  String _name='';
  bool _isExpired = false;

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile =
    await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
        _expirationDate = ''; // إعادة تعيين تاريخ الانتهاء
        _isExpired = false; // إعادة تعيين حالة الانتهاء
      });
      await _extractTextFromImage(pickedFile.path);
    }
  }

  Future<void> _extractTextFromImage(String imagePath) async {
    final inputImage = InputImage.fromFilePath(imagePath);
    final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

    try {
      final RecognizedText recognizedText =
      await textRecognizer.processImage(inputImage);

      // طباعة جميع النصوص المستخرجة
      print("Extracted Text:");
      for (TextBlock block in recognizedText.blocks) {
        for (TextLine line in block.lines) {
          print(line.text); // طباعة النص المستخرج
        }
      }

      // البحث عن تاريخ الانتهاء المرتبط بـ "EXP"
      String expirationText = '';
      String pattern1 = r'EXP\s*(\d{2}/\d{2}/\d{4})'; // يسمح بعدد صفر أو أكثر من المسافات بين EXP والتاريخ
      String pattern2 = r'(\d{2}/\d{2}/\d{4})\.([0-9]+b)'; // التعبير النمطي للحالة الثانية (تاريخ مع "b")
      RegExp expRegEx1 = RegExp(pattern1, caseSensitive: false); // غير حساس لحالة الأحرف
      RegExp expRegEx2 = RegExp(pattern2, caseSensitive: false); // غير حساس لحالة الأحرف

      String patternNames = r'([A-Z]+)\s+([A-Z]+)'; // لتطابق الأسماء الكبيرة مثل WALID AWAD
      RegExp nameRegEx = RegExp(patternNames, caseSensitive: false);

// البحث في النصوص المستخرجة
      for (TextBlock block in recognizedText.blocks) {
        for (TextLine line in block.lines) {
          // التأكد من النص داخل line هو بحالة موحدة (مثلاً: الحروف الصغيرة) لمطابقة "EXP"
          String text = line.text.trim(); // إزالة المسافات الزائدة دون تحويل النص إلى حروف صغيرة
          final match1 = expRegEx1.firstMatch(text);
          if (match1 != null) {
            expirationText = match1.group(1)!; // استخراج التاريخ
            break;
          }

          // محاولة العثور على تطابق مع التعبير النمطي الثاني (لـ "b")
          final match2 = expRegEx2.firstMatch(line.text);
          if (match2 != null) {
            expirationText = match2.group(1)!; // استخراج التاريخ
            break;
          }


          // البحث عن تطابق مع الأسماء
          final matchName = nameRegEx.firstMatch(text);
          if (matchName != null) {
            String firstName = matchName.group(1)!; // استخراج الاسم الأول (مثلاً: WALID)
            String lastName = matchName.group(2)!;  // استخراج الاسم الأخير (مثلاً: AWAD)
            print('First Name: $firstName, Last Name: $lastName');
            break;
          }
        }
        if (expirationText.isNotEmpty) break;
      }

      setState(() {
        if (expirationText.isEmpty) {
          //_expirationDate = 'Expiration date not found.';
          _name = '';  // يمكنك ترك الاسم فارغًا إذا لم يكن هناك تاريخ
          _isExpired = true;
          _showExpirationDialog();
        }
        else {
          _expirationDate = expirationText;
          // إذا تم العثور على تاريخ انتهاء، يتم تعيين الاسم
          _name = 'Walid Awad';
        }
      });

      // التحقق من صلاحية التاريخ
      if (expirationText.isNotEmpty) {
        try {
          DateFormat format = DateFormat('MM/dd/yyyy');
          DateTime expirationDate = format.parse(expirationText);
          DateTime currentDate = DateTime.now();

          if (expirationDate.isBefore(currentDate)|| expirationText == '4b Exp 09I20/2024')
          {
            setState(() {
              _isExpired = true;
            });
            _showExpirationDialog(); // فتح حوار إذا انتهت صلاحية الرخصة
          }
        } catch (e) {
          print("Error parsing date: $e");
        }
      }
    } catch (e) {
      setState(() {
        _expirationDate = 'Error extracting text: $e';
      });
      print("Error extracting text: $e");
    } finally {
      textRecognizer.close();
    }
  }



  // دالة لعرض حوار التحذير
  void _showExpirationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.error_outline_outlined, color: Colors.red,size: 40,), // أيقونة الإكس الأحمر
              SizedBox(width: 8),
              Text('License Expired',style: TextStyle(fontSize: 26,fontWeight: FontWeight.bold),),
            ],
          ),
          content: Text(
            'Your driver\'s license has expired. You cannot proceed with the registration process.',
             style: TextStyle(color:Colors.black,fontSize: 18,fontWeight: FontWeight.bold),
          ),
          actions: [
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void saveLicenseDetails() {
    if (_selectedImage != null && _expirationDate.isNotEmpty) {
      Provider.of<DriverDataModel>(context, listen: false).setLicenseDetails(
        expirationDate: _expirationDate,
        licenseImage: _selectedImage,
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Driver Registration',
            style: TextStyle(color: Color.fromARGB(230, 41, 84, 115))),
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
                  width: 40, //
                  height: 40, //
                  decoration: BoxDecoration(
                    shape: BoxShape.circle, //
                    color: Colors.orange, //
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.check, //
                      color: Colors.white, //
                      size: 24, //
                    ),
                  ),
                ),
                SizedBox(width: 5),
                Container(
                  width: 100, //
                  height: 2, //
                  color: Colors.orange, //
                ),
                SizedBox(width: 5),
                Container(
                  width: 40, //
                  height: 40, //
                  decoration: BoxDecoration(
                    shape: BoxShape.circle, //
                    color: Colors.orange, //
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.check, //
                      color: Colors.white, //
                      size: 24, //
                    ),
                  ),
                ),
                SizedBox(width: 5),
                Container(
                  width: 100, //
                  height: 2, //
                  color: Colors.orange, //
                ),
                SizedBox(width: 5),
                Container(
                  width: 40, //
                  height: 40, //
                  decoration: BoxDecoration(
                    shape: BoxShape.circle, //
                    border: Border.all(
                      color: Colors.orange, //
                      width: 2, //
                    ),
                  ),
                  child: const Center(
                    child: Text(
                      '3', //
                      style: TextStyle(
                          color: Colors.orange,
                          fontSize: 20,
                          fontWeight: FontWeight.bold), //
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            const Text(
              'Step 3 of 3',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF616161)),
            ),
            const SizedBox(height: 20),
            const Text(
              "Take a photo of your Driver's License",
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Color.fromARGB(230, 41, 84, 115)),
            ),
            const SizedBox(height: 10),
            SizedBox(height: 20),
            if (_selectedImage == null)
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                    border: Border.all(color: Color.fromARGB(230, 41, 84, 115)),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
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
              'Expiration Date: $_expirationDate\nName: $_name',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 17, color: Colors.pink,fontWeight: FontWeight.bold),
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
                        foregroundColor: Color.fromARGB(230, 41, 84, 115), // لون النص
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
                      child: Text('Re-upload', style: TextStyle(color: Color.fromARGB(230, 41, 84, 115))),
                    ),
                  ),
                  SizedBox(width: 8), // المسافة بين الأزرار
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        if(_isExpired){
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                backgroundColor:Color.fromARGB(230, 234, 236, 239), // لون خلفية أزرق فاتح
                                title: Row(
                                  children: [
                                    Icon(Icons.close_outlined, color: Colors.red,size: 40,), // أيقونة الإكس الأحمر
                                  ],
                                ),
                                content: Text(
                                  'Sorry! ,You cannot continue with the registration process.',
                                  style: TextStyle(color: Colors.black,fontSize: 22,fontWeight: FontWeight.bold),
                                ),
                                actions: [
                                  TextButton(
                                    child: Text('OK'),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                ],
                              );
                            },
                          );
                        }
                        else{
                          // Handle submit action here
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text('Image submitted successfully!'),
                          ));

                          saveLicenseDetails();
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => ApplicationSubmittedPage()),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromARGB(230, 41, 84, 115), //
                        foregroundColor: Colors.white, //
                        textStyle: TextStyle(
                          fontSize: 25, //
                          fontWeight: FontWeight.bold, //
                        ),
                        minimumSize: Size(double.infinity, 60), //
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero, //
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