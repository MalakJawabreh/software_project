import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class SimpleMapScreen extends StatefulWidget {
  @override
  _SimpleMapScreenState createState() => _SimpleMapScreenState();
}

class _SimpleMapScreenState extends State<SimpleMapScreen> {
  final MapController _mapController = MapController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Simple Map with Zoom'),
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              center: LatLng(31.7683, 35.2137),
              zoom: 10.0,
            ),
            children: [
              TileLayer(
                urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                subdomains: ['a', 'b', 'c'],
              ),
            ],
          ),
          Positioned(
            bottom: 50,
            right: 10,
            child: Column(
              children: [
                // Zoom In Button
                ElevatedButton(
                  onPressed: () {
                    _mapController.move(
                      _mapController.center,
                      _mapController.zoom + 1,
                    );
                  },
                  child: const Text("Zoom In"),
                ),
                const SizedBox(height: 10),
                // Zoom Out Button
                ElevatedButton(
                  onPressed: () {
                    _mapController.move(
                      _mapController.center,
                      _mapController.zoom - 1,
                    );
                  },
                  child: const Text("Zoom Out"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
