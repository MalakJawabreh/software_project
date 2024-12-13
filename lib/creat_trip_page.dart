import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;

class RouteMapScreen extends StatefulWidget {
  final String fromLocation; // استقبال موقع البداية
  final String toLocation;   // استقبال موقع النهاية

  RouteMapScreen({required this.fromLocation, required this.toLocation});

  @override
  _RouteMapScreenState createState() => _RouteMapScreenState();
}

class _RouteMapScreenState extends State<RouteMapScreen> {
  final MapController _mapController = MapController();
  List<LatLng> routePoints = [];
  String estimatedTime = ''; // لتخزين الوقت المتوقع
  LatLng? startMarker; // لتحديد نقطة البداية
  LatLng? endMarker;   // لتحديد نقطة النهاية

  @override
  void initState() {
    super.initState();
    _fetchRouteFromLocations(widget.fromLocation, widget.toLocation);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Route Map with Geocoding'),
      ),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    center: LatLng(31.7683, 35.2137),
                    zoom: 10.0,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                      "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                      subdomains: ['a', 'b', 'c'],
                    ),
                    if (routePoints.isNotEmpty)
                      PolylineLayer(
                        polylines: [
                          Polyline(
                            points: routePoints,
                            color: Colors.blue,
                            strokeWidth: 4.0,
                          ),
                        ],
                      ),
                    if (startMarker != null)
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: startMarker!,
                            builder: (ctx) => Icon(
                              Icons.location_pin,
                              color: Colors.red,
                              size: 40,
                            ),
                          ),
                          if (endMarker != null)
                            Marker(
                              point: endMarker!,
                              builder: (ctx) => Icon(
                                Icons.location_pin,
                                color: Colors.green,
                                size: 40,
                              ),
                            ),
                        ],
                      ),
                  ],
                ),
                if (estimatedTime.isNotEmpty)
                  Positioned(
                    bottom: 10,
                    left: 10,
                    child: Card(
                      color: Colors.white,
                      elevation: 3,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Estimated Time: $estimatedTime',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ),
                Positioned(
                  bottom: 10,
                  right: 10,
                  child: Column(
                    children: [
                      FloatingActionButton(
                        heroTag: 'zoomIn',
                        onPressed: () {
                          _mapController.move(
                              _mapController.center, _mapController.zoom + 1);
                        },
                        child: Icon(Icons.zoom_in),
                      ),
                      SizedBox(height: 8),
                      FloatingActionButton(
                        heroTag: 'zoomOut',
                        onPressed: () {
                          _mapController.move(
                              _mapController.center, _mapController.zoom - 1);
                        },
                        child: Icon(Icons.zoom_out),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _fetchRouteFromLocations(
      String startLocation, String endLocation) async {
    try {
      final LatLng? startCoords = await _getCoordinatesFromLocation(startLocation);
      final LatLng? endCoords = await _getCoordinatesFromLocation(endLocation);

      if (startCoords == null || endCoords == null) {
        print("Failed to fetch coordinates for one or both locations.");
        return;
      }

      setState(() {
        startMarker = startCoords;
        endMarker = endCoords;
      });

      _fetchRoute(startCoords, endCoords);
    } catch (e) {
      print("Error fetching route: $e");
    }
  }

  Future<LatLng?> _getCoordinatesFromLocation(String location) async {
    final String apiKey = '4cbb8668001845be989c1f7242ee3746'; // ضع مفتاح Geocoding API هنا
    final String url =
        'https://api.opencagedata.com/geocode/v1/json?q=$location&key=$apiKey';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = data['results'];
        if (results.isNotEmpty) {
          final lat = results[0]['geometry']['lat'];
          final lng = results[0]['geometry']['lng'];
          return LatLng(lat, lng);
        }
      } else {
        print("Failed to fetch coordinates: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching coordinates: $e");
    }
    return null;
  }

  Future<void> _fetchRoute(LatLng start, LatLng end) async {
    final String apiKey = '5b3ce3597851110001cf624800fdd7843703422196060deab981b130'; // مفتاح OpenRouteService API
    final String url =
        'https://api.openrouteservice.org/v2/directions/driving-car?api_key=$apiKey&start=${start.longitude},${start.latitude}&end=${end.longitude},${end.latitude}';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final coordinates = data['features'][0]['geometry']['coordinates'];
        final properties = data['features'][0]['properties'];
        setState(() {
          routePoints = coordinates
              .map<LatLng>((coord) => LatLng(coord[1], coord[0]))
              .toList();
          estimatedTime = (properties['segments'][0]['duration'] / 60).toStringAsFixed(2) + ' mins';
        });
      } else {
        print('Failed to load route: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching route: $e');
    }
  }
}
