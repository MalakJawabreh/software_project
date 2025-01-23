import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'config.dart';

class AddBookingPage extends StatefulWidget {
  @override
  _AddBookingPageState createState() => _AddBookingPageState();
}

class _AddBookingPageState extends State<AddBookingPage> {
  final _formKey = GlobalKey<FormState>();
  final _driverEmailController = TextEditingController();
  final _passengerNameController = TextEditingController();
  final _passengerEmailController = TextEditingController();
  final _passengerPhoneController = TextEditingController();
  List<Map<String, dynamic>> trips = [];
  Map<String, dynamic>? selectedTrip;

  TextEditingController fromController = TextEditingController();
  TextEditingController toController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  TextEditingController seatsController = TextEditingController();
  TextEditingController driverNameController = TextEditingController();
  TextEditingController dateController = TextEditingController();
  TextEditingController timeController = TextEditingController();
  TextEditingController requestedSeatsController = TextEditingController();


  // دالة استدعاء الـ API عند إدخال ايميل السائق
  Future<void> _getDriverTrips() async {
    try {
      final driverEmail = _driverEmailController.text;
      final fetchedTrips = await fetchDriverTrips(driverEmail);
      setState(() {
        trips = fetchedTrips;
      });
    } catch (e) {
      // التعامل مع الأخطاء هنا مثل عدم وجود إيميل السائق أو مشاكل الاتصال
      print('Error: $e');
    }
  }


  Future<List<Map<String, dynamic>>> fetchDriverTrips(String driverEmail) async {

    final response = await http.get(Uri.parse('$driver_trips?driverEmail=$driverEmail'));

    if (response.statusCode == 200) {
      // استرجاع الرحلات في حال كانت الاستجابة ناجحة
      final data = json.decode(response.body);
      if (data['status'] == true) {
        List trips = data['trips'];
        return List<Map<String, dynamic>>.from(trips);
      } else {
        throw Exception('Failed to load trips');
      }
    } else {
      throw Exception('Failed to load trips');
    }
  }

  Future<void> _createBooking() async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        final bookingData = {

          'nameP':  _passengerNameController.text,
          'EmailP': _passengerEmailController.text,
          'EmailD': _driverEmailController.text,
          'phoneNumberP': _passengerPhoneController.text,
          'phoneNumberD': selectedTrip?['phoneNumber'],
          'nameD': selectedTrip?['name'],
          'from': selectedTrip?['from'],
          'to': selectedTrip?['to'],
          'price':selectedTrip?['price'],
          'date': selectedTrip?['date'],
          'time': selectedTrip?['time'],
          'carBrand':selectedTrip?['carBrand'],
          'seat':int.tryParse(requestedSeatsController.text) ?? 0,
        };

        final response = await http.post(
          Uri.parse('$book_trip'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode(bookingData),
        );

        if (response.statusCode == 200) {
          final responseData = json.decode(response.body);
          if (responseData['status'] == true) {
            // تم إنشاء الحجز بنجاح
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Booking created successfully!')),
            );
          } else {
            // خطأ في إنشاء الحجز
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(responseData['message'])),
            );
          }
        } else {
          throw Exception('Booking created successfully!');
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add Booking')),
      backgroundColor: Color(0xFF8BA8B1),

      body: Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Container(
            width: 650,
            child: Card(
            elevation: 5,
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: SingleChildScrollView( // تم إضافة SingleChildScrollView هنا
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // اسم الراكب
                      TextFormField(
                        controller: _passengerNameController,
                        decoration: InputDecoration(labelText: 'Passenger Name'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter passenger name';
                          }
                          return null;
                        },
                      ),
                      // ايميل الراكب
                      TextFormField(
                        controller: _passengerEmailController,
                        decoration: InputDecoration(labelText: 'Passenger Email'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter passenger email';
                          }
                          return null;
                        },
                      ),
                      // رقم الراكب
                      TextFormField(
                        controller: _passengerPhoneController,
                        decoration: InputDecoration(labelText: 'Passenger Phone'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter passenger phone';
                          }
                          return null;
                        },
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // ايميل السائق
                          TextFormField(
                            controller: _driverEmailController,
                            decoration: InputDecoration(labelText: 'Driver Email'),
                            onChanged: (value) {
                              if (value.isNotEmpty) {
                                _getDriverTrips(); // استدعاء الرحلات عند تغيير الإيميل
                              }
                            },
                          ),
                          // عرض الرحلات الخاصة بالسائق
                          if (trips.isNotEmpty)
                            DropdownButtonFormField<Map<String, dynamic>>(
                              decoration: InputDecoration(labelText: 'Select Trip'),
                              value: selectedTrip,
                              onChanged: (Map<String, dynamic>? newValue) {
                                setState(() {
                                  selectedTrip = newValue;
                                  fromController.text = newValue?['from'] ?? '';
                                  toController.text = newValue?['to'] ?? '';
                                  priceController.text = newValue?['price'].toString() ?? '';
                                  seatsController.text = newValue?['maxPassengers'].toString() ?? '';
                                  driverNameController.text = newValue?['name'] ?? '';
                                  dateController.text = newValue?['date'] ?? '';
                                  timeController.text = newValue?['time'] ?? '';
                                });
                              },
                              items: trips.map((trip) {
                                return DropdownMenuItem<Map<String, dynamic>>(
                                  value: trip,
                                  child: Text(
                                    '${trip['from']} → ${trip['to']} | Price: \$${trip['price']} | Seats: ${trip['maxPassengers']}',
                                  ),
                                );
                              }).toList(),
                            ),
                          SizedBox(height: 20),
                          // عرض الحقول النصية فقط إذا تم اختيار رحلة
                          if (selectedTrip != null) ...[
                            TextField(
                              controller: fromController,
                              decoration: InputDecoration(labelText: 'From'),
                              readOnly: true,
                            ),
                            TextField(
                              controller: toController,
                              decoration: InputDecoration(labelText: 'To'),
                              readOnly: true,
                            ),
                            TextField(
                              controller: priceController,
                              decoration: InputDecoration(labelText: 'Price'),
                              readOnly: true,
                            ),
                            TextField(
                              controller: seatsController,
                              decoration: InputDecoration(labelText: 'Max Seats'),
                              readOnly: true,
                            ),
                            TextField(
                              controller: driverNameController,
                              decoration: InputDecoration(labelText: 'Driver Name'),
                              readOnly: true,
                            ),
                            TextField(
                              controller: dateController,
                              decoration: InputDecoration(labelText: 'Date'),
                              readOnly: true,
                            ),
                            TextField(
                              controller: timeController,
                              decoration: InputDecoration(labelText: 'Time'),
                              readOnly: true,
                            ),
                            TextField(
                              controller: requestedSeatsController,
                              decoration: InputDecoration(labelText: 'Requested Seats'),
                              keyboardType: TextInputType.number,
                            ),
                            SizedBox(height: 20),
                          ],
                        ],
                      ),
                      // زر الحجز
                      ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState?.validate() ?? false) {
                            // هنا يتم تنفيذ عملية الحجز
                            _createBooking();
                            // يمكن إرسال البيانات إلى API لحفظ الحجز
                            print('Booking Added:');
                            print('Passenger Name: ${_passengerNameController.text}');
                            print('Passenger Email: ${_passengerEmailController.text}');
                            print('Passenger Phone: ${_passengerPhoneController.text}');
                            print('Driver Email: ${_driverEmailController.text}');
                            print('Selected Trip: $selectedTrip');
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xE6A4ACB3), // تغيير لون الخلفية إلى اللون السكني

                          foregroundColor: Colors.pink, // تغيير لون النص إلى الأبيض
                        ),
                        child: Text('Add Booking',
                          style: TextStyle(
                            fontSize: 18, // تغيير حجم الخط
                            fontWeight: FontWeight.bold, // جعل الخط عريض
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        ),
      ),
    );
  }
}

