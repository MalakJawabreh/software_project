import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'message.dart';

class Chatservice extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> sendMessage(
      String senderEmail, String senderName, String recevEmail, String recevName, String message) async {
    final Timestamp timestamp = Timestamp.now();

    // إنشاء الرسالة مع الأسماء
    Message newMessage = Message(
      senderEmail: senderEmail,
      senderName: senderName, // إضافة اسم المرسل
      recevEmail: recevEmail,
      recevName: recevName, // إضافة اسم المستقبل
      timestamp: timestamp,
      message: message,
    );

    // تحديد chatRoomId بناءً على البريد الإلكتروني
    List<String> emails = [senderEmail, recevEmail];
    emails.sort();
    String chatRoomId = emails.join("_");

    // إضافة الرسالة إلى المجموعة الفرعية
    await _firestore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .add(newMessage.toMap());

    // تحديث بيانات chat_room
    await _firestore.collection('chat_rooms').doc(chatRoomId).set({
      'participants': emails, // المشاركون في الدردشة
      'lastMessage': message, // آخر رسالة
      'lastMessageTimestamp': timestamp, // وقت آخر رسالة
      'senderName': senderName,  // تخزين اسم المرسل
      'recevName': recevName,    // تخزين اسم المستقبل
      'recevEmail': recevEmail,
      'senderEmail': senderEmail,
    }, SetOptions(merge: true)); // التحديث بدلاً من الكتابة فوق البيانات
  }

  // استرجاع الرسائل من مجموعة chat_rooms
  Stream<QuerySnapshot> getMessages(String senderEmail, String recevEmail) {
    List<String> emails = [senderEmail, recevEmail];
    emails.sort();
    String chatRoomId = emails.join("_");

    return _firestore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots();
  }

  // استرجاع قائمة المحادثات الخاصة بالمستخدم الحالي
  Stream<QuerySnapshot> getChatRooms(String currentUserEmail) {
    return _firestore.collection('chat_rooms').where('participants', arrayContains: currentUserEmail).snapshots();
  }
}
