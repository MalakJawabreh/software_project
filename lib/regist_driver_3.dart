import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:intl/intl.dart';
import 'package:project1/submit_register.dart';

class DriverLicenseUpload extends StatefulWidget {
  @override
  _DriverLicenseUploadState createState() => _DriverLicenseUploadState();
}

class _DriverLicenseUploadState extends State<DriverLicenseUpload> {
  File? _selectedImage;
  String _expirationDate = '';
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
      String pattern = r'EXP.*?(\d{2}/\d{2}/\d{4})'; // "EXP" متبوعًا بتاريخ بصيغة MM/DD/YYYY
      RegExp expRegEx = RegExp(pattern, caseSensitive: false); // غير حساس لحالة الأحرف

      // البحث في النصوص المستخرجة
      for (TextBlock block in recognizedText.blocks) {
        for (TextLine line in block.lines) {
          if (line.text.toUpperCase().contains('EXP')) {
            final match = expRegEx.firstMatch(line.text);
            if (match != null) {
              expirationText = match.group(1)!; // استخراج التاريخ
              break;
            }
          }
        }
        if (expirationText.isNotEmpty) break;
      }

      setState(() {
        _expirationDate = expirationText.isEmpty
            ? 'Expiration date not found.'
            : expirationText;
      });

      // التحقق من صلاحية التاريخ
      if (expirationText.isNotEmpty) {
        try {
          DateFormat format = DateFormat('MM/dd/yyyy');
          DateTime expirationDate = format.parse(expirationText);
          DateTime currentDate = DateTime.now();

          if (expirationDate.isBefore(currentDate)) {
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
              'Expiration Date: $_expirationDate',
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