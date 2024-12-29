import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:project1/searchinfo.dart';
import 'package:intl/intl.dart'; // لاستعمال تنسيق التاريخ
import 'package:http/http.dart' as http ;
import 'package:numberpicker/numberpicker.dart';
import 'notifications_service.dart';


import 'config.dart';
import 'driver_dashboard.dart';

class SetDestinationPage extends StatefulWidget {
  final String email;
  final String name;
  final String phone;
  final String carType;
  const SetDestinationPage({required this.email,required this.name,required this.phone,required this.carType, super.key});
  @override
  _SetDestinationPageState createState() => _SetDestinationPageState();
}

class _SetDestinationPageState extends State<SetDestinationPage> {
  TextEditingController _fromController = TextEditingController();
  TextEditingController _toController = TextEditingController();
  TextEditingController _dateController = TextEditingController(); // حقل التاريخ
  TextEditingController _timeController = TextEditingController(); // حقل الوقت
  int maxPassengers = 1; // عدد الركاب الافتراضي
  TextEditingController _maxPassengersController = TextEditingController();
  TextEditingController _priceController = TextEditingController(); // حقل السعر
  String selectedCurrency = 'ILS'; // العملة الافتراضية

  void createTrip() async {
    if (_fromController.text.isNotEmpty &&
        _toController.text.isNotEmpty &&
        _dateController.text.isNotEmpty &&
        _timeController.text.isNotEmpty &&
        _maxPassengersController.text.isNotEmpty &&
        _priceController.text.isNotEmpty) {

      var regbody = {
        "name":widget.name,
        "driverEmail":widget.email,
        "phoneNumber":widget.phone,
        "from": _fromController.text,
        "to": _toController.text,
        "price": _priceController.text,
        "maxPassengers": _maxPassengersController.text,
        "date": _dateController.text,
        "time": _timeController.text,
        "carBrand":widget.carType,
      };

      var response = await http.post(Uri.parse(create_trip),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(regbody));

      var jsonResponse = jsonDecode(response.body);
      print(jsonResponse['status']);

      if (jsonResponse['status']) {
        NotificationService.addNotification(widget.email, 'Trip created successfully !');

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Trip Created Successfully!')),
        );
        // إعادة تحميل صفحة Driver
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Driver()), // تأكد من أن `Driver` هو اسم صفحة السائق
        );

      } else {
        print("Something Error");
      }
    }
    else {

    }
  }

  @override
  void initState() {
    super.initState();
    _maxPassengersController.text = maxPassengers.toString(); // تعيين القيمة الأولية في حقل الإدخال
  }


  List<Searchinfo> fromItems = [];
  List<Searchinfo> toItems = [];

  void placeAutoCompletedFrom(String val) async {
    await addressSugestion(val, 'from').then((value) {
      setState(() {
        fromItems = value;
      });
    });
  }

  void placeAutoCompletedTo(String val) async {
    await addressSugestion(val, 'to').then((value) {
      setState(() {
        toItems = value;
      });
    });
  }

  Future<List<Searchinfo>> addressSugestion(String address, String type) async {
    Response response = await Dio().get('https://photon.komoot.io/api/',
        queryParameters: {
          "q": address,
          "limit": 5,
          "bbox": "34.222,29.232,35.445,33.348", // مربعات تحديد دقيقة لفلسطين
        });

    final json = response.data;
    return (json['features'] as List)
        .map((e) => Searchinfo.fromJson(e))
        .toList();
  }

  Future<DateTime?> _selectDate(BuildContext context) async {
    return await showDatePicker(
      context: context,
      initialDate: DateTime.now(), // التاريخ الافتراضي
      firstDate: DateTime.now(),  // أول تاريخ متاح
      lastDate: DateTime(2100),   // آخر تاريخ متاح
    );
  }


  Future<void> _selectTime(BuildContext context) async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime != null) {
      setState(() {
        final period = pickedTime.period == DayPeriod.am ? 'AM' : 'PM';
        _timeController.text =
        '${pickedTime.hourOfPeriod}:${pickedTime.minute.toString().padLeft(
            2, '0')} $period';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(230, 213, 223, 235),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                alignment: Alignment.topCenter,
                children: [
                  Lottie.asset('animation/car.json', width: 380, height: 300),
                  Positioned(
                    top: 200,
                    left: 16.0,
                    child: Text(
                      'Create New Trip',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(230, 41, 84, 115),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 250,
                    left: 16.0,
                    child: Text(
                      '"Map Your Way, Design Your Trip"',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(230, 12, 46, 78),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              // حقل From
              Row(
                children: [
                  SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      onChanged: (val) {
                        if (val != '') {
                          placeAutoCompletedFrom(val);
                        } else {
                          fromItems.clear();
                          setState(() {});
                        }
                      },
                      controller: _fromController,
                      decoration: InputDecoration(
                        hintText: 'Enter Departure Location',
                        border: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.grey,
                            width: 2.5,
                          ),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: Color.fromARGB(230, 12, 46, 78),
                            width: 3.0,
                          ),
                        ),
                        prefixIcon: Padding(
                          padding: EdgeInsets.only(bottom: 8.0),
                          child: Icon(
                            Icons.location_on,
                            color: Color.fromARGB(230, 149, 117, 84),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24),
              ...fromItems
                  .map((e) =>
                  ListTile(
                    leading: const Icon(Icons.place),
                    title: Text(e.properties!.name!),
                    onTap: () {
                      _fromController.text = e.properties!.name!;
                      setState(() {
                        fromItems.clear();
                      });
                    },
                  ))
                  .toList(),
              SizedBox(height: 1),
              // حقل To
              Row(
                children: [
                  SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      onChanged: (val) {
                        if (val != '') {
                          placeAutoCompletedTo(val);
                        } else {
                          toItems.clear();
                          setState(() {});
                        }
                      },
                      controller: _toController,
                      decoration: InputDecoration(
                        hintText: 'Enter Destination Location',
                        border: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.grey,
                            width: 2.5,
                          ),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: Color.fromARGB(230, 12, 46, 78),
                            width: 3.0,
                          ),
                        ),
                        prefixIcon: Padding(
                          padding: EdgeInsets.only(bottom: 8.0),
                          child: Icon(
                            Icons.location_on,
                            color: Color.fromARGB(230, 149, 117, 84),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24),
              ...toItems
                  .map((e) =>
                  ListTile(
                    leading: const Icon(Icons.place),
                    title: Text(e.properties!.name!),
                    onTap: () {
                      _toController.text = e.properties!.name!;
                      setState(() {
                        toItems.clear();
                      });
                    },
                  ))
                  .toList(),
              SizedBox(height: 1),
              // حقل Date
              Row(
                children: [
                  SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _dateController,
                      decoration: InputDecoration(
                        hintText: 'Select Date',
                        border: InputBorder.none, // إزالة الخط السفلي
                        prefixIcon: Padding(
                          padding: EdgeInsets.only(bottom: 8.0),
                          child: Icon(
                            Icons.calendar_today,
                            color: Color.fromARGB(230, 149, 117, 84),
                          ),
                        ),
                      ),
                      onTap: () async {
                        // استدعاء _selectDate وتخزين النتيجة في selectedDate
                        final DateTime? selectedDate = await _selectDate(context);
                        // التحقق إذا كان التاريخ مختارًا
                        if (selectedDate != null) {
                          final now = DateTime.now();
                          if (selectedDate.isBefore(DateTime(now.year, now.month, now.day))) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Please select a date in the future.')),
                            );
                          } else {
                            // تحديث حقل النص بالتاريخ
                            _dateController.text = DateFormat('yyyy-MM-dd').format(selectedDate);
                          }
                        }
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 5),
              // حقل Time
              Row(
                children: [
                  SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _timeController,
                      decoration: InputDecoration(
                        hintText: 'Select Time',
                        border: InputBorder.none,
                        prefixIcon: Padding(
                          padding: EdgeInsets.only(bottom: 8.0),
                          child: Icon(
                            Icons.access_time,
                            color: Color.fromARGB(230, 149, 117, 84),
                          ),
                        ),
                      ),
                      onTap: () => _selectTime(context),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 5),

              Row(
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 10.0), // إضافة مسافة من اليسار
                    child: Text(
                      'Maximum Passengers: ',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold,color:Color.fromARGB(230, 12, 46, 78),),
                    ),
                  ),
                  SizedBox(width: 2),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 4.0),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.remove,color: Color.fromARGB(230, 149, 117, 84)),
                          onPressed: () {
                            setState(() {
                              if (maxPassengers > 1) {
                                maxPassengers--;
                                _maxPassengersController.text = maxPassengers.toString(); // تحديث القيمة في الحقل
                              }
                            });
                          },
                        ),
                        Container(
                          width: 30,
                          child: TextField(
                            controller: _maxPassengersController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(vertical: 5.0),
                            ),
                            style: TextStyle(
                              fontWeight: FontWeight.w400,
                              fontSize: 22,// جعل النص بولد
                              color: Color.fromARGB(230, 12, 46, 78),
                            ),
                            onChanged: (value) {
                              setState(() {
                                maxPassengers = int.tryParse(value) ?? 1; // إذا كانت القيمة غير صحيحة تعود للقيمة الافتراضية 1
                              });
                            },
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.add,color: Color.fromARGB(230, 149, 117, 84),),
                          onPressed: () {
                            setState(() {
                              if (maxPassengers < 100) {
                                maxPassengers++;
                                _maxPassengersController.text = maxPassengers.toString(); // تحديث القيمة في الحقل
                              }
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _priceController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: 'Enter Price per Passenger',
                        border: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.grey,
                            width: 2.5,
                          ),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: Color.fromARGB(230, 12, 46, 78),
                            width: 3.0,
                          ),
                        ),
                        prefixIcon: Padding(
                          padding: EdgeInsets.only(bottom: 8.0),
                          child: Icon(
                            Icons.attach_money,
                            color: Color.fromARGB(230, 149, 117, 84),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  DropdownButton<String>(
                    value: selectedCurrency,
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedCurrency = newValue!;
                      });
                    },
                    items: <String>['JOD', 'ILS']
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ],
              ),
              SizedBox(height: 26),
              Center(
                child:ElevatedButton(
                  onPressed: () async {
                    // تأخير صغير لمحاكاة عملية إنشاء الرحلة
                    await Future.delayed(Duration(seconds: 1));

                    // عرض حوار التأكيد
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          backgroundColor:Color.fromARGB(230, 221, 232, 246), // لون خلفية أزرق فاتح
                          title: Text(
                            'Confirm Trip Creation',
                            style: TextStyle(color:Color.fromARGB(230, 12, 46, 78),fontSize: 20,fontWeight: FontWeight.bold), // تغيير لون الخط إلى أزرق
                          ),
                          content: Text(
                            'Do you want to confirm the creation of this trip?',
                            style: TextStyle(color:Color.fromARGB(230, 12, 46, 78),fontSize: 18 ), // تغيير لون الخط إلى أخضر
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context); // إغلاق حوار التأكيد
                              },
                              child: Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () {
                                createTrip();
                                Navigator.pop(context);

                              },
                              child: Text('OK'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  child: Text('Create Trip'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromARGB(230, 80, 103, 124), // اللون الخلفي عند الضغط (أزرق فاتح)
                    foregroundColor: Colors.white, // اللون النص عند الضغط // اللون النص عند الضغط
                    padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 32.0),
                    textStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    minimumSize: Size(150, 40),
                  ),
                ),
              ),

              SizedBox(height: 10,),
              Center(
                child:ElevatedButton(
                  onPressed: () async {
                    await Future.delayed(Duration(seconds: 1));
                    Navigator.pop(context); // العودة إلى الصفحة السابقة
                  },
                  child: Text('Back'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromARGB(230, 80, 103, 124), // اللون الخلفي عند الضغط (أزرق فاتح)
                    foregroundColor: Colors.white, // اللون النص عند الضغط
                    padding: EdgeInsets.symmetric(vertical: 13.0, horizontal: 33.0),
                    textStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    minimumSize: Size(158, 40),
                  ),
                ),
              )

            ],
          ),
        ),
      ),
    );
  }
}
