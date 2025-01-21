import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'dart:io';

import 'package:project1/regist_driver_3.dart';
import 'package:provider/provider.dart';

import 'driver_data_model.dart';
import 'no.dart';

class VehicleInsuranceUpload extends StatefulWidget {
  @override
  _VehicleInsuranceUploadState createState() => _VehicleInsuranceUploadState();
}

class _VehicleInsuranceUploadState extends State<VehicleInsuranceUpload> {
  File? _selectedImage;

  bool _isExpired2 = false;

  final ImagePicker _picker = ImagePicker();
  String extractedDate = "";
  String extractedcarbrand = "";
  String extractedcapacity = "";
  String extractedcarNumber = "";
  late final TextRecognizer _textRecognizer;

  @override
  void initState() {
    super.initState();
    _textRecognizer = GoogleMlKit.vision.textRecognizer();
  }

  Future<void> _pickImage0() async {
    // اختيار صورة من الجاليري
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);  // تخزين الصورة في متغير
      });
      await _extractTextFromImage0(image.path);
    }
  }

  Future<void> _extractTextFromImage0(String imagePath) async {
    final inputImage = InputImage.fromFilePath(imagePath);
    final RecognizedText recognizedText = await _textRecognizer.processImage(inputImage);

    // البحث عن كلمة "Expiry Date" واستخراج النص بالقرب منها
    String? foundDate = _extractDateFromText(recognizedText.text);
    print('hi $foundDate');
    String? extractedRegNo = _extractRegNo(recognizedText.text);
    String? extractedBrand = _extractBrand(recognizedText.text);
    String? extractedSeatingCap0 = _extractSeatingCap0(recognizedText.text);

    setState(() {
      extractedDate = foundDate ?? '';
      extractedcarbrand = extractedBrand ?? '';
      extractedcapacity = '5' ?? '';
      extractedcarNumber = extractedRegNo ?? '';
    });

    if (foundDate != null) {
      try {
        // محاولة تحويل النص المستخرج إلى DateTime باستخدام DateFormat
        DateTime expirationDate = DateFormat('dd/MM/yyyy').parseStrict(foundDate);
        print('Expiration date: $expirationDate');

        // التحقق إذا كان التاريخ قد انتهى
        if (expirationDate.isBefore(DateTime.now())) {
          _showExpirationDialog();
        }
      } catch (e) {
        print('Error parsing date: $e');
      }
    }
  }
  String? _extractRegNo(String text) {
    // البحث عن كلمة "Reg. No."
    final regNoIndex = text.toLowerCase().indexOf('reg. no.');
    if (regNoIndex != -1) {
      // استخراج النص بعد "Reg. No."
      String textAfterRegNo = text.substring(regNoIndex + 'Reg. No.'.length).trim();

      // محاولة استخراج الرقم من النص بعد "Reg. No."
      RegExp regNoPattern = RegExp(r'(\d{6,})'); // البحث عن رقم يتكون من 6 أرقام أو أكثر
      Match? match = regNoPattern.firstMatch(textAfterRegNo);

      if (match != null) {
        // العودة بالرقم المستخرج
        return match.group(0);
      }
    }
    return null;
  }

  String? _extractBrand(String text) {
    final seatingCapIndex = text.toLowerCase().indexOf('make of vehicle');
    if (seatingCapIndex != -1) {
      // استخراج النص الذي يلي "Make of vehicle" مباشرة
      String surroundingText = text.substring(seatingCapIndex + 'make of vehicle'.length).trim();

      // استخدام تعبير منتظم لاستخراج الكلمة الأولى
      final regex = RegExp(r'\S+'); // أي تسلسل من الأحرف غير الفارغة
      final match = regex.firstMatch(surroundingText);

      if (match != null) {
        print("أول كلمة بعد Make of vehicle: ${match.group(0)}");
        return match.group(0);
      }
    }
  }

  String? _extractSeatingCap0(String text) {

    final seatingCapIndex = text.toLowerCase().indexOf('cap');
    if (seatingCapIndex != -1) {
      // استخراج النص المحيط بـ "Seating Cap."
      String surroundingText = text.substring(seatingCapIndex, seatingCapIndex + 60);
      print("النص المحيط بـ Seating Cap.: $surroundingText");
    }
  }


  String? _extractDateFromText(String text) {
    // البحث عن كلمة "Expiry Date"
    final expiryIndex = text.toLowerCase().indexOf('expiry date');
    if (expiryIndex != -1) {
      // استخراج النص بعد "Expiry Date"
      String textAfterExpiry = text.substring(expiryIndex + 'Expiry Date'.length);

      // محاولة استخراج التاريخ من النص بعد "Expiry Date"
      RegExp datePattern = RegExp(r'(\d{1,2}/\d{1,2}/\d{4})|(\d{4}-\d{2}-\d{2})');
      Match? match = datePattern.firstMatch(textAfterExpiry);

      if (match != null) {
        // العودة بالتاريخ المستخرج
        return match.group(0);
      }
    }
    return null;
  }

  // دالة لعرض حوار التحذير
  void _showExpirationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor:Color.fromARGB(230, 234, 236, 239), // لون خلفية أزرق فاتح
          title: Row(
            children: [
              Icon(Icons.error_outline_outlined, color: Colors.red,size: 40,), // أيقونة الإكس الأحمر
              SizedBox(width: 8),
              Text('License Expired',style: TextStyle(fontSize: 26,fontWeight: FontWeight.bold),),
            ],
          ),
          content: Text(
            'Your Vehicle Insurance has expired. You cannot proceed with the registration process.',
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


  void saveInsuranceDetails() {
    if (_selectedImage != null && extractedDate.isNotEmpty) {
      Provider.of<DriverDataModel>(context, listen: false).setInsuranceDetails(
        expirationDate: extractedDate,
        InsuranceImage: _selectedImage,
      );
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
      body:SingleChildScrollView(
      child:Padding(
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
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color.fromARGB(230, 41, 84, 115)),
            ),
            const SizedBox(height: 10),
            if (_selectedImage == null)
              GestureDetector(
                onTap: _pickImage0,
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
                    height: 500,
                    fit: BoxFit.cover,
                  ),
                ],
              ),
            SizedBox(height: 16),
            Text(
              extractedDate.isNotEmpty
                  ? 'Expiry Date: $extractedDate'
                  : '',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 17, color: Colors.pink,fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            Text(
    extractedcarNumber.isNotEmpty
                  ? 'Car Number: $extractedcarNumber'
                  : '',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 17, color: Colors.pink,fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            Text(
    extractedcarbrand.isNotEmpty
                  ? 'Car Brand: $extractedcarbrand'
                  : '',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 17, color: Colors.pink,fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            Text(
    extractedcapacity.isNotEmpty
                  ? 'Seating Capacity: $extractedcapacity'
                  : '',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 17, color: Colors.pink,fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            if (_selectedImage != null) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.end, // لتوزيع الأزرار بالتساوي
                children: [
                  ElevatedButton(
                    onPressed: _pickImage0,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white, // لون الخلفية
                      foregroundColor: Color.fromARGB(230, 41, 84, 115), // لون النص
                      textStyle: TextStyle(
                        fontSize: 25, // حجم النص
                        fontWeight: FontWeight.bold, // سمك النص
                      ),
                      minimumSize: Size(150, 40), // تحديد العرض والارتفاع الثابتين
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30), // حواف مربعة
                        side: BorderSide(
                          color: Colors.grey, // لون السكني
                          width: 1, // سمك الحد
                        ),
                      ),
                    ),
                    child: Text(
                      'Re-upload',
                      style: TextStyle(color: Color.fromARGB(230, 41, 84, 115)),
                    ),
                  ),
                ],
              )
            ],
            SizedBox(height: 10,),

            SizedBox(height: 10,),
            if (_selectedImage != null) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.center, // لتوزيع الأزرار بالتساوي
                children: [
                  Align(
                    alignment: Alignment.center, // محاذاة الزر في المنتصف
                    child: ElevatedButton(
                      onPressed: () {
                        if (_isExpired2) {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                backgroundColor: Color.fromARGB(230, 234, 236, 239), // لون خلفية أزرق فاتح
                                title: Row(
                                  children: [
                                    Icon(Icons.close_outlined, color: Colors.red, size: 40), // أيقونة الإكس الأحمر
                                  ],
                                ),
                                content: Text(
                                  'Sorry! ,You cannot continue with the registration process.',
                                  style: TextStyle(color: Colors.black, fontSize: 22, fontWeight: FontWeight.bold),
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
                        } else {
                          // Handle submit action here
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text('Image submitted successfully!'),
                          ));

                          saveInsuranceDetails();
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => DriverLicenseUpload()),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromARGB(230, 41, 84, 115), // لون الخلفية
                        foregroundColor: Colors.white, // لون النص
                        textStyle: TextStyle(
                          fontSize: 25, // حجم النص
                          fontWeight: FontWeight.bold, // سمك النص
                        ),
                        minimumSize: Size(200, 60), // الحد الأدنى للعرض والارتفاع
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero, // حواف مربعة
                        ),
                      ),
                      child: Text('Submit', style: TextStyle(color: Colors.white)),
                    ),
                  )
                ],
              )
            ]
          ],
        ),
      ),
    ),
    );
  }
}