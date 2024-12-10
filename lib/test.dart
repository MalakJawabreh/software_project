import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'package:intl/intl.dart';
import 'config.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';


class TestPage extends StatefulWidget {
  @override
  final String emailP;
  final String nameP;
  final String phoneP;
  _TestPageState createState() => _TestPageState();
  const TestPage({required this.emailP,required this.nameP,required this.phoneP, super.key});

}

class _TestPageState extends State<TestPage> {
  List<dynamic> trips = [];
  List<int> selectedSeats = [];
  List<String> notes = []; // لتخزين الملاحظات

  @override
  void initState() {
    super.initState();

    fetchTrips().then((_) {
      updateTripsBasedOnTime();
      selectedSeats = List.filled(trips.length, 1);
      notes = List.filled(trips.length, ''); // لتخزين الملاحظات بشكل افتراضي فارغ
    });

    Timer.periodic(Duration(seconds: 20), (timer) {
      updateTripsBasedOnTime();
    });
  }



  Future<void> fetchTrips() async {
    try {
      final response = await http.get(Uri.parse(all_trip));

      if (response.statusCode == 200) {
        final List<dynamic> tripList = json.decode(response.body)['trips'];
        setState(() {
          trips = tripList;
          selectedSeats = List.filled(trips.length, 1);
          notes = List.filled(trips.length, ''); // تهيئة الملاحظات
        });
      } else {
        throw Exception('Failed to load trips');
      }
    } catch (e) {
      print('Error: $e');
    }
  }
  void _showMessage(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10), // لإعطاء الزوايا شكل دائري
          ),
          title: Text(
            'Notification',
            style: TextStyle(fontSize: 20, color: analogousPink),
          ),
          content: Text(
            message,
            style: TextStyle(fontSize: 16),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("OK", style: TextStyle(color:analogousPink)),
            ),
          ],
        );
      },
    );
  }

  Future<void> bookTrip(int index) async {
    try {
      final trip = trips[index];
      final bookingData = {
        'nameP': widget.nameP,
        'from': trip['from'],
        'to': trip['to'],
        'date': trip['date'],
        'time': trip['time'],
      };

      // تحقق إذا كان المستخدم قد حجز بالفعل نفس الرحلة
      final existingBooking = trips.where((t) {
        return t['from'] == bookingData['from'] &&
            t['to'] == bookingData['to'] &&
            t['date'] == bookingData['date'] &&
            t['time'] == bookingData['time'] &&
            t['nameP'] == bookingData['nameP'];
      }).toList();

      if (existingBooking.isNotEmpty) {
        _showMessage(context, "You have already booked this trip.");
        return;
      }

      // تحقق إذا كان هناك تعارض في المواعيد
      final conflictingBooking = trips.where((t) {
        return t['date'] == bookingData['date'] &&
            t['time'] == bookingData['time'] &&
            t['nameP'] == bookingData['nameP'];
      }).toList();

      if (conflictingBooking.isNotEmpty) {
        _showMessage(context, "You cannot book two trips at the same time.");
        return;
      }

      final response = await http.post(
        Uri.parse(book_trip),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'nameP': widget.nameP,
          'EmailP': widget.emailP,
          'nameD': trip['name'],
          'EmailD': trip['driverEmail'],
          'phoneNumberP': widget.phoneP,
          'phoneNumberD': trip['phoneNumber'],
          'from': trip['from'],
          'to': trip['to'],
          'price': trip['price'],
          'date': trip['date'],
          'time': trip['time'],
          'Note': notes[index],
          'seat': selectedSeats[index],
        }),
      );

      // إذا كانت الاستجابة ناجحة، عرض رسالة النجاح
      if (response.statusCode == 201) {
        _showMessage(context, "Booking successful!");
        print('Trip booked successfully');
      }
     /* else if (response.statusCode == 500) {
        _showMessage(context, "Booking successful!");
        print('Trip booked successfully');
      }*/
      else {
        _showMessage(context, "Failed to book trip: ${response.body}");
      }
    } catch (e) {
      print('Error: $e');
      _showMessage(context, "An error occurred. Please try again.");
    }
  }



  void updateTripsBasedOnTime() {
    final now = DateTime.now();
    final dateFormat = DateFormat("yyyy-MM-ddTHH:mm:ss.SSS'Z' h:mm a");

    setState(() {
      trips.removeWhere((trip) {
        try {
          final dateTime = dateFormat.parse(
              trip['date'] + ' ' + trip['time'], true).toLocal();
          if (dateTime.isBefore(now)) {
            return true;
          }
        } catch (e) {
          print('Error parsing date: $e');
        }
        return false;
      });
    });
  }

  String formatDate(String dateTime) {
    final parsedDate = DateTime.parse(dateTime);
    return DateFormat('dd MMMM yyyy').format(parsedDate);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'All Trips',
          style: TextStyle(
            color: Colors.grey[700],
            fontWeight: FontWeight.bold// لون رمادي غامق
          ),
        ),
        backgroundColor:SecondryColor2,
      ),
      body: trips.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 80,
              color: primaryColor,
            ),
            SizedBox(height: 16),
            Text(
              'No trips available at the moment.',
              style: TextStyle(
                  fontSize: 18,
                  color: primaryColor,
                  fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      )
          : ListView.builder(
        itemCount: trips.length,
        itemBuilder: (context, index) {
          final trip = trips[index];

          if (selectedSeats.length <= index) {
            return SizedBox();
          }

          return Padding(
            padding: const EdgeInsets.symmetric(
                vertical: 8.0, horizontal: 16.0),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.teal.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.directions_car,
                            color:primaryColor2,
                            size: 40,
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      'Driver: ${trip['name'] ?? 'N/A'}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                        color:primaryColor2,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Icon(
                                    Icons.phone,
                                    color: primaryColor2,
                                    size: 18,
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    '${trip['phoneNumber'] ?? 'N/A'}',
                                    style: TextStyle(
                                      color: Colors.grey[700],
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8),
                              Row(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: [
                                  Column(
                                    children: [
                                      Container(
                                        width: 16,
                                        height: 16,
                                        decoration: BoxDecoration(
                                          color: Colors.green,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      CustomPaint(
                                        size: Size(1, 40),
                                        painter: DashedLinePainter(),
                                      ),
                                      Icon(
                                        Icons.location_on,
                                        color: Colors.orange,
                                        size: 24,
                                      ),
                                    ],
                                  ),
                                  SizedBox(width: 6),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        RichText(
                                          text: TextSpan(
                                            style: TextStyle(
                                              fontSize: 16,
                                            ),
                                            children: [
                                              TextSpan(
                                                text: 'From: ',
                                                style: TextStyle(
                                                  color: Colors.green, // اللون الأخضر للنص الثابت
                                                  fontWeight: FontWeight.bold
                                                ),
                                              ),
                                              TextSpan(
                                                text: '${trip['from']}',
                                                style: TextStyle(
                                                  color: Colors.black,
                                                    fontWeight: FontWeight.bold,
                                                  fontSize: 13,

                                                ),
                                              ),
                                            ],
                                          ),
                                        ),

                                        SizedBox(height: 38),
                                        RichText(
                                          text: TextSpan(
                                            style: TextStyle(
                                              fontSize: 16,
                                            ),
                                            children: [
                                              TextSpan(
                                                text: 'To: ',
                                                style: TextStyle(
                                                    color: Colors.orange, // اللون الأخضر للنص الثابت
                                                    fontWeight: FontWeight.bold
                                                ),
                                              ),
                                              TextSpan(
                                                text: '${trip['to']}',
                                                style: TextStyle(
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 13,

                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Divider(color: Colors.grey),
                    SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.calendar_today,
                                    color: analogousPink, size: 20),
                                SizedBox(width: 4),
                                Text(
                                  '${formatDate(trip['date'])}',
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 16),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Icon(Icons.access_time,
                                    color:analogousPink, size: 20),
                                SizedBox(width: 4),
                                Text(
                                  '${trip['time'] ?? 'N/A'}',
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 16),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Price: ${trip['price']}',
                              style: TextStyle(
                                  color: primaryColor,
                                  fontWeight: FontWeight.bold,fontSize: 16),
                            ),

                            Text(
                              'Seats: ${trip['maxPassengers'] ?? 'N/A'}',
                              style: TextStyle(
                                  color: primaryColor,
                                  fontWeight: FontWeight.bold,fontSize: 16),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    // حقل الملاحظات
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            onChanged: (value) {
                              setState(() {
                                notes[index] = value;
                              });
                            },
                            decoration: InputDecoration(
                              labelText: 'Enter notes',
                              hintText: 'Any special requests or notes?',
                              labelStyle: TextStyle(
                                color:primaryColor2, // تغيير لون الـ label (النص الذي يظهر فوق الـ TextField)
                              ),
                              hintStyle: TextStyle(
                                color:SecondryColor2, // تغيير لون الـ hint (النص الذي يظهر في الداخل عندما لا يتم الكتابة)
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: primaryColor2, // تغيير لون الحدود
                                  width: 2, // تحديد سمك الحدود
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: softPink, // تغيير لون الحدود عند التركيز (عندما يكون الـ TextField نشطًا)
                                  width: 2,
                                ),
                              ),
                            ),
                            maxLines: 3,
                          ),
                        ),
                      ],
                    )
                    ,
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [],
                          ),
                        ),
                        Column(
                          children: [
                            Row(
                              children: [
                                IconButton(
                                  icon: Icon(Icons.remove_circle_outline),
                                  onPressed: () {
                                    setState(() {
                                      if (selectedSeats[index] > 1) {
                                        selectedSeats[index]--;
                                      }
                                    });
                                  },
                                  color: Colors.red,
                                ),
                                Text(
                                  '${selectedSeats[index]}',
                                  style: TextStyle(fontSize: 16),
                                ),
                                IconButton(
                                  icon: Icon(Icons.add_circle_outline),
                                  onPressed: () {
                                    setState(() {
                                      if (selectedSeats[index] <
                                          (trip['maxPassengers'] ?? 1)) {
                                        selectedSeats[index]++;
                                      } else {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(
                                                'Cannot book more than ${trip['maxPassengers']} seats.'),
                                            duration: Duration(seconds: 2),
                                          ),
                                        );
                                      }
                                    });
                                  },
                                  color: Colors.green,
                                ),
                              ],
                            ),
                            ElevatedButton(
                              onPressed: () {
                                print(
                                    'Booked ${selectedSeats[index]} seat(s) for trip from ${trip['from']} to ${trip['to']}');
                                print('Notes: ${notes[index]}'); // عرض الملاحظات
                                bookTrip(index);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryColor2,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                                child: Text(
                                  'Book Now',
                                  style: TextStyle(
                                    color: triadicPink,
                                  ),
                                )
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class DashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey
      ..strokeWidth = 1;

    const dashWidth = 4;
    const dashSpace = 4;
    double startY = 0;

    while (startY < size.height) {
      canvas.drawLine(
        Offset(0, startY),
        Offset(0, startY + dashWidth),
        paint,
      );
      startY += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
const Color SecondryColor = Color.fromARGB(230, 196, 209, 219);
//const Color SecondryColor2 = Color.fromARGB(230, 95, 190, 200);
const Color SecondryColor2 = Color.fromARGB(230, 130, 167, 175);
const Color complementaryPink = Color.fromARGB(230, 255, 153, 180);
const Color analogousPink = Color.fromARGB(230, 230, 100, 140);
const Color triadicPink = Color.fromARGB(230, 245, 115, 165);
const Color softPink = Color.fromARGB(230, 250, 170, 200);



const Color primaryColor = Color.fromARGB(230, 41, 84, 115); // اللون الأساسي
const Color primaryColor2 = Color.fromARGB(230, 20, 60, 115);