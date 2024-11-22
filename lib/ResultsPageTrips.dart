import 'package:flutter/material.dart';

class Trip {
  final String destination;
  final double price;
  final String time;
  final int seats;
  final double rating;

  Trip({
    required this.destination,
    required this.price,
    required this.time,
    required this.seats,
    required this.rating,
  });
}

final List<Trip> allTrips = [
  Trip(destination: "Ramallah", price: 30, time: "Morning", seats: 3, rating: 4.5),
  Trip(destination: "Jerusalem", price: 25, time: "Afternoon", seats: 4, rating: 4.2),
  Trip(destination: "Nablus", price: 20, time: "Evening", seats: 5, rating: 4.8),
];

class ResultsPage extends StatelessWidget {
  final List<Trip> trips;

  const ResultsPage({required this.trips, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Available Trips"),
        backgroundColor: Color.fromARGB(230, 41, 84, 115),
      ),
      body: trips.isEmpty
          ? Center(child: Text("No trips found", style: TextStyle(fontSize: 18)))
          : ListView.builder(
        itemCount: trips.length,
        itemBuilder: (context, index) {
          final trip = trips[index];
          return Card(
            margin: EdgeInsets.all(10),
            child: ListTile(
              title: Text(trip.destination),
              subtitle: Text("Price: \$${trip.price}, Time: ${trip.time}, Seats: ${trip.seats}, Rating: ${trip.rating}"),
            ),
          );
        },
      ),
    );
  }
}
