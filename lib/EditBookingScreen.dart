import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'config.dart';

class EditBookingScreen extends StatefulWidget {
  final dynamic booking;

  const EditBookingScreen({required this.booking, super.key});

  @override
  _EditBookingScreenState createState() => _EditBookingScreenState();
}

class _EditBookingScreenState extends State<EditBookingScreen> {
  late TextEditingController seatController;
  late TextEditingController noteController;
  bool isLoading = false;
  bool isSuccess = false;

  @override
  void initState() {
    super.initState();
    seatController = TextEditingController(text: widget.booking['seat'].toString());
    noteController = TextEditingController(text: widget.booking['Note'] ?? '');
  }

  @override
  void dispose() {
    seatController.dispose();
    noteController.dispose();
    super.dispose();
  }

  Future<void> saveChanges() async {
    if (seatController.text.isEmpty || int.tryParse(seatController.text) == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please enter a valid seat count')));
      return;
    }

    final updatedBooking = {
      'seat': int.parse(seatController.text),
      'Note': noteController.text,
    };

    setState(() {
      isLoading = true;
      isSuccess = false;
    });

    try {
      final response = await http.put(
        Uri.parse('$update_booking/${widget.booking['_id']}'),
        body: json.encode(updatedBooking),
        headers: {'Content-Type': 'application/json'},
      );

      setState(() {
        isLoading = false;
      });

      if (response.statusCode == 200) {
        setState(() {
          isSuccess = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Booking updated successfully')));

        // إضافة تأخير قبل الانتقال
        Future.delayed(Duration(seconds: 3), () {
          Navigator.pop(context, updatedBooking);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to update booking: ${response.statusCode}')));
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error updating booking: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Edit Booking',
          style: TextStyle(),

        ),
        backgroundColor: SecondryColor,
        elevation: 0, // إزالة الظل للـ AppBar
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // حقل "عدد المقاعد"
              Container(
                decoration: BoxDecoration(
                  color:  Colors.white60,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: analogousPink.withOpacity(0.6),
                      spreadRadius: 2,
                      blurRadius: 5,
                    ),
                  ],
                ),
                child: TextField(
                  controller: seatController,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Seat Count',
                    labelStyle: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.black54,
                    ),
                    contentPadding:
                    EdgeInsets.symmetric(vertical: 17, horizontal: 20),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                      BorderSide(color: analogousPink, width: 2),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                          color: Colors.grey.shade300, width: 1.5),
                    ),
                    filled: true,
                    fillColor: Colors.white60,
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
              SizedBox(height: 20),

              // حقل "الملاحظات"
              Container(
                decoration: BoxDecoration(
                  color:  Colors.white60,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: analogousPink.withOpacity(0.6),
                      spreadRadius: 2,
                      blurRadius: 5,
                    ),
                  ],
                ),
                child: TextField(
                  controller: noteController,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Note',
                    labelStyle: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: primaryColor,
                    ),
                    contentPadding:
                    EdgeInsets.symmetric(vertical: 17, horizontal: 20),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                      BorderSide(color: analogousPink, width: 2),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                          color: Colors.grey.shade300, width: 1.5),
                    ),
                    filled: true,
                    fillColor:  Colors.white60,
                  ),
                  maxLines: 4,
                ),
              ),
              SizedBox(height: 20),

              // زر الحفظ
              isLoading
                  ? CircularProgressIndicator(
                color: primaryColor,
              )
                  : isSuccess
                  ? Column(
                children: [
                  Image.asset('imagess/done.gif',
                      height: 200, width: 100),
                  SizedBox(height: 20),
                  Text(
                    'Booking updated successfully!',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: SecondryColor2,
                    ),
                  ),
                ],
              )
                  : Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: triadicPink.withOpacity(0.5),
                      blurRadius: 12,
                      spreadRadius: 2,
                      offset: Offset(0, 6),
                    ),
                  ],
                ),
                child: ElevatedButton.icon(
                  onPressed: saveChanges,
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, 55),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    backgroundColor: SecondryColor,
                    padding: EdgeInsets.symmetric(
                        vertical: 15, horizontal: 20),
                  ),
                  icon: Icon(
                    Icons.save,
                    size: 24,
                    color:analogousPink,
                  ),
                  label: Text(
                    'Save Changes',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: analogousPink,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

const Color SecondryColor = Color.fromARGB(230, 196, 209, 219);
const Color SecondryColor2 = Color.fromARGB(230, 130, 167, 175);
const Color complementaryPink = Color.fromARGB(230, 255, 153, 180);
const Color analogousPink = Color.fromARGB(230, 230, 100, 140);
const Color triadicPink = Color.fromARGB(230, 245, 115, 165);
const Color softPink = Color.fromARGB(230, 250, 170, 200);
const Color primaryColor = Color.fromARGB(230, 41, 84, 115);
const Color primaryColor2 = Color.fromARGB(230, 20, 60, 115);