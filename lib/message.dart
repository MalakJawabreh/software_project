import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String senderEmail;
  final String senderName; // اسم المرسل
  final String recevEmail;
  final String recevName; // اسم المستقبل
  final String message;
  final Timestamp timestamp;

  Message({
    required this.senderEmail,
    required this.senderName,  // إضافة اسم المرسل
    required this.recevEmail,
    required this.recevName,  // إضافة اسم المستقبل
    required this.message,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'senderEmail': senderEmail,
      'senderName': senderName, // إضافة اسم المرسل
      'recevEmail': recevEmail,
      'recevName': recevName, // إضافة اسم المستقبل
      'message': message,
      'timestamp': timestamp,
    };
  }
}

