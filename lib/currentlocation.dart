import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import 'config.dart';
import 'driver_data_model.dart';

class CurrentLocationPage extends StatefulWidget {
  @override

  final String email;

  const CurrentLocationPage({required this.email, Key? key})
      : super(key: key);

  _CurrentLocationPageState createState() => _CurrentLocationPageState();
}

class _CurrentLocationPageState extends State<CurrentLocationPage> {
  Position? currentPosition;
  String locationName = "Unknown location";
  late MapController _mapController;  // Declare the MapController
  LatLng? currentLatLng;
  bool isVisible=false;  // الحالة الأولية لظهور/اختفاء
  late DriverDataModel driverDataModel; // تعريف المتغير

  @override
  void initState() {
    super.initState();
    _mapController = MapController();  // Initialize MapController here
    _getCurrentLocation();
    // الحصول على قيمة الرؤية (visibility) من الموديل
    driverDataModel = Provider.of<DriverDataModel>(context, listen: false);
    // تهيئة القيمة الافتراضية استنادًا إلى البيانات من الموديل
    bool? visibility = driverDataModel.getVisibilitylocation(widget.email);
    if (visibility != null) {
      isVisible = visibility; // تعيين القيمة المستردة كقيمة افتراضية
    }
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        locationName = "Location services are disabled.";
      });
      return;
    }

    // Check location permissions
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          locationName = "Location permissions are denied.";
        });
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() {
        locationName = "Location permissions are permanently denied.";
      });
      return;
    }

    // Get the current position
    currentPosition = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    // Get the city name from coordinates
    final address = await getCityNameFromCoordinates(currentPosition!.latitude, currentPosition!.longitude);
    if (address != null) {
      setState(() {
        locationName = address;
        currentLatLng = LatLng(currentPosition!.latitude, currentPosition!.longitude);
        updatelocation();
      });
      // Move the map to the user's location
      _mapController.move(currentLatLng!, 15.0); // Move the map to current location with zoom level 15
    } else {
      setState(() {
        locationName = "Unable to determine location.";
      });
    }
  }

  Future<void> updatelocation() async {

    print('Email: ${widget.email}');
    if (widget.email == null || widget.email.isEmpty) {
      print('Email is missing!');
      return;
    }
    try {
      // Create the request body as JSON
      final requestBody = {
        'email': widget.email,
        'location': locationName,
      };

      // Send the request and get the response
      final response = await http.post(
        Uri.parse(update_location),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        // Successfully updated the profile picture
        print('update location');
      } else {
        // Handle error
        print('Failed to update location.');
      }
    } catch (e) {
      print('Error updating location: $e');
    }
  }

  Future<String?> getCityNameFromCoordinates(double latitude, double longitude) async {
    final apiKey = '4cbb8668001845be989c1f7242ee3746'; // Your OpenCage API key
    final url = 'https://api.opencagedata.com/geocode/v1/json?q=$latitude+$longitude&key=$apiKey';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['results'].isNotEmpty) {
          final components = data['results'][0]['components'];
          final city = components['city'] ?? components['town'] ?? components['village'] ?? components['suburb'] ?? 'Unknown location';
          return city;
        }
      }
    } catch (e) {
      print("Error fetching data: $e");
    }
    return null;
  }

  void setlocation(String email,bool visible) {
      Provider.of<DriverDataModel>(context, listen: false).setLocation(
        email,
       locationName,
        visible,
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        //title: const Text('Current Location'),
      ),
      body: Stack(
        children: [
          // الخريطة
          FlutterMap(
            mapController: _mapController, // Using the initialized mapController
            options: MapOptions(
              center: currentLatLng ?? LatLng(0.0, 0.0), // Default to a placeholder
              zoom: 13.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                subdomains: ['a', 'b', 'c'],
              ),
              if (currentLatLng != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: currentLatLng!,
                      builder: (context) => Icon(Icons.location_on, size: 40.0, color: Colors.red),
                    ),
                  ],
                ),
            ],
          ),
          // الكارد أسفل الخريطة
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min, // تصغير العمود ليتناسب مع المحتوى
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // العنوان مع الأيقونة
                      Row(
                        children: [
                          Icon(Icons.location_on, color: Colors.red, size: 27),
                          const SizedBox(width: 8),
                          Text(
                            'Current Location',
                            style: TextStyle(
                              fontSize: 22.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12), // مسافة بين العنوان وبقية المحتوى
                      // اسم الموقع مع الزر
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              locationName,
                              style: TextStyle(fontSize: 20.0),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                isVisible = !isVisible; // عكس الحالة
                                setlocation(widget.email, isVisible);
                              });
                              // طباعة الحالة على الكونسول
                              if (isVisible) {
                                print("Visible: $locationName"); // طباعة اسم الموقع إذا كان مرئيًا
                              } else {
                                print("Not Visible");
                              }

                              print("Selected visible: $isVisible");
                              driverDataModel.setVisibilitylocation(widget.email, isVisible);

                              // التحقق من القيمة التي تم حفظها
                              final savedVisibilitylocation = driverDataModel.getVisibilitylocation(widget.email);
                              print(
                                  "Saved visibility:  $savedVisibilitylocation for email: ${widget.email}");
                            },
                            child: AnimatedContainer(
                              duration: Duration(milliseconds: 300),
                              width: 70,
                              height: 30,
                              padding: EdgeInsets.all(3),
                              decoration: BoxDecoration(
                                color: isVisible ? Colors.green : Colors.red, // تغيير اللون بناءً على الحالة
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Stack(
                                children: [
                                  Align(
                                    alignment: !isVisible ? Alignment.centerLeft : Alignment.centerRight,
                                    child: Container(
                                      width: 24,
                                      height: 24,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }


}
