import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CurrentLocationPage extends StatefulWidget {
  @override
  _CurrentLocationPageState createState() => _CurrentLocationPageState();
}

class _CurrentLocationPageState extends State<CurrentLocationPage> {
  Position? currentPosition;
  String locationName = "Unknown location";

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
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

    // استخدام OpenCage API للحصول على اسم المدينة
    final address = await getCityNameFromCoordinates(currentPosition!.latitude, currentPosition!.longitude);
    if (address != null) {
      setState(() {
        locationName = address;
      });
    } else {
      setState(() {
        locationName = "Unable to determine location.";
      });
    }
  }

  Future<String?> getCityNameFromCoordinates(double latitude, double longitude) async {
    final apiKey = '4cbb8668001845be989c1f7242ee3746';  // احصل على مفتاح API الخاص بك من opencagedata.com
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Current Location'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              locationName,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20.0),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _getCurrentLocation,
              child: Text("Get Current Location"),
            ),
          ],
        ),
      ),
    );
  }
}
