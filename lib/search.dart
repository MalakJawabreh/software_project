import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:project1/searchinfo.dart';
import 'package:intl/intl.dart'; // لاستعمال تنسيق التاريخ

class SetDestinationPage extends StatefulWidget {
  @override
  _SetDestinationPageState createState() => _SetDestinationPageState();
}

class _SetDestinationPageState extends State<SetDestinationPage> {
  TextEditingController _fromController = TextEditingController();
  TextEditingController _toController = TextEditingController();
  TextEditingController _dateController = TextEditingController(); // حقل التاريخ
  int maxPassengers = 1; // عدد الركاب الافتراضي

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

  Future<void> _selectDate(BuildContext context) async {
    DateTime initialDate = DateTime.now();
    DateTime firstDate = DateTime(2024);
    DateTime lastDate = DateTime(2025);

    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );

    if (pickedDate != null && pickedDate != initialDate) {
      setState(() {
        _dateController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
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
                        prefixIcon: Icon(
                          Icons.location_on,
                          color: Color.fromARGB(230, 149, 117, 84),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24),
              ...fromItems.map((e) => ListTile(
                leading: const Icon(Icons.place),
                title: Text(e.properties!.name!),
                onTap: () {
                  _fromController.text = e.properties!.name!;
                  setState(() {
                    fromItems.clear();
                  });
                },
              )).toList(),
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
                        prefixIcon: Icon(
                          Icons.location_on,
                          color: Color.fromARGB(230, 149, 117, 84),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24),
              ...toItems.map((e) => ListTile(
                leading: const Icon(Icons.place),
                title: Text(e.properties!.name!),
                onTap: () {
                  _toController.text = e.properties!.name!;
                  setState(() {
                    toItems.clear();
                  });
                },
              )).toList(),
              SizedBox(height: 24),
              // حقل Max Passengers مع أزرار زيادة ونقصان
              Row(
                children: [
                  Text(
                    'Max Passengers',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(230, 12, 46, 78),
                    ),
                  ),
                  SizedBox(width: 16),
                  Text(
                    maxPassengers.toString(),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(230, 12, 46, 78),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.remove, color: Color.fromARGB(230, 12, 46, 78)),
                    onPressed: () {
                      if (maxPassengers > 1) {
                        setState(() {
                          maxPassengers--;
                        });
                      }
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.add, color: Color.fromARGB(230, 12, 46, 78)),
                    onPressed: () {
                      setState(() {
                        maxPassengers++;
                      });
                    },
                  ),
                ],
              ),
              SizedBox(height: 24),
              // حقل Date
              Row(
                children: [
                  SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _dateController,
                      decoration: InputDecoration(
                        hintText: 'Select Date',
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
                        prefixIcon: Icon(
                          Icons.calendar_today,
                          color: Color.fromARGB(230, 149, 117, 84),
                        ),
                      ),
                      onTap: () => _selectDate(context),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
