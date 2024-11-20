import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'login.dart';

class Passenger extends StatefulWidget {
  final String token;
  const Passenger({required this.token, super.key});

  @override
  State<Passenger> createState() => _PassengerState();
}

class _PassengerState extends State<Passenger> {
  late String email;

  @override
  void initState() {
    super.initState();
    Map<String, dynamic> jwtDecodedToken = JwtDecoder.decode(widget.token);
    email = jwtDecodedToken['email'];
  }

  void logout() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => Login()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "passenger",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Text(email),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: logout,
              child: Text("Logout"),
            ),
          ],
        ),
      ),
    );
  }
}

