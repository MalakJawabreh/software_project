import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'language_provider.dart';


String formatDate(String dateTime) {
  final parsedDate = DateTime.parse(dateTime);
  return DateFormat('dd MMMM yyyy').format(parsedDate);
}

class TripDetailsScreen extends StatefulWidget {
  final String emailP;
  final String nameP;
  final String phoneP;
  final Map<String, dynamic> trip;

  const TripDetailsScreen({
    Key? key,
    required this.emailP,
    required this.nameP,
    required this.phoneP,
    required this.trip,
  }) : super(key: key);
  @override
  _TripDetailsScreenState createState() => _TripDetailsScreenState();
}

class _TripDetailsScreenState extends State<TripDetailsScreen> {
  List<int> selectedSeats = [];
  List<String> notes = [];

  @override
  void initState() {
    super.initState();
    print('Email: ${widget.emailP}');
    print('Name: ${widget.nameP}');
    print('Phone: ${widget.phoneP}');
    selectedSeats = List.filled(widget.trip.length, 1);
    notes = List.filled(widget.trip.length, ''); //
  }




  @override
  Widget build(BuildContext context) {
    final trip = widget.trip; // الوصول إلى بيانات الرحلة من الـ widget
    final languageProvider = Provider.of<LanguageProvider>(context);
    final isArabic = languageProvider.isArabic;
    return Scaffold(
      appBar: AppBar(
        //title: Text('Trip Details'),
        title: Text(isArabic ? "تفاصيل الرحلة" : "Trip Details", style: TextStyle(
            color: Colors.grey[700],
            fontWeight: FontWeight.bold// لون رمادي غامق
        )),
        backgroundColor:SecondryColor2,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
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
                            crossAxisAlignment: CrossAxisAlignment.start,
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
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
                                              color: Colors.green,
                                              fontWeight: FontWeight.bold,
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
                                              color: Colors.orange,
                                              fontWeight: FontWeight.bold,
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
                                color: Colors.pink, size: 20),
                            SizedBox(width: 4),
                            Text(
                              '${formatDate(trip['date'])}',
                              style: TextStyle(color: Colors.black, fontSize: 16),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Icon(Icons.access_time, color: Colors.pink, size: 20),
                            SizedBox(width: 4),
                            Text(
                              '${trip['time'] ?? 'N/A'}',
                              style: TextStyle(color: Colors.black, fontSize: 16),
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
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        onChanged: (value) {
                          setState(() {
                            notes[0] = value; // حفظ الملاحظات
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
                ),
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
                                  if (selectedSeats[0] > 1) {
                                    selectedSeats[0]--;
                                  }
                                });
                              },
                              color: Colors.red,
                            ),
                            Text(
                              '${selectedSeats[0]}', // عرض عدد المقاعد المحددة
                              style: TextStyle(fontSize: 16),
                            ),
                            IconButton(
                              icon: Icon(Icons.add_circle_outline),
                              onPressed: () {
                                setState(() {
                                  if (selectedSeats[0] < (trip['maxPassengers'] ?? 1)) {
                                    selectedSeats[0]++;
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
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
                                'Booked ${selectedSeats[0]} seat(s) for trip from ${trip['from']} to ${trip['to']}');
                            print('Notes: ${notes[0]}');
                            // يمكنك إضافة منطق الحجز هنا
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
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
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
// يمكنك استخدام هذا الكود مع توفير Trip في متغير trip الذي يحتوي على بيانات الرحلة.
const Color SecondryColor = Color.fromARGB(230, 196, 209, 219);
//const Color SecondryColor2 = Color.fromARGB(230, 95, 190, 200);
const Color SecondryColor2 = Color.fromARGB(230, 130, 167, 175);
const Color complementaryPink = Color.fromARGB(230, 255, 153, 180);
const Color analogousPink = Color.fromARGB(230, 230, 100, 140);
const Color triadicPink = Color.fromARGB(230, 245, 115, 165);
const Color softPink = Color.fromARGB(230, 250, 170, 200);



const Color primaryColor = Color.fromARGB(230, 41, 84, 115); // اللون الأساسي
const Color primaryColor2 = Color.fromARGB(230, 20, 60, 115);