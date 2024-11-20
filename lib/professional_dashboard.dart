import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'login.dart';

class Professional extends StatefulWidget {
  final String token;
  const Professional({required this.token, super.key});

  @override
  State<Professional> createState() => _ProfessionalState();
}

class _ProfessionalState extends State<Professional> {
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
              "professional",
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



