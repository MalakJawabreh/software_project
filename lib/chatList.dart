import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'chat_page.dart';
import 'chatservice.dart';
import 'config.dart';
import 'package:http/http.dart' as http;


class ChatListPage extends StatelessWidget {
  final String currentUserEmail;
  final String currentUserName;

  const ChatListPage({required this.currentUserEmail,required this.currentUserName});

  Future<String?> fetchProfilePicture(String email) async {
    try {
      final url = Uri.parse('$getuser?email=$email');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['status'] == true) {
          return data['user']['profilePicture'] as String?;
        } else {
          throw Exception(data['error'] ?? 'Error fetching user details');
        }
      } else {
        throw Exception('Failed to fetch user details');
      }
    } catch (e) {
      print("Error: $e");
      return null;
    }
  }


  @override
  Widget build(BuildContext context) {
    final Chatservice _chatservice = Chatservice();

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center, // لجعل العنوان في المنتصف
          children: [
            const Text(
              'Chats',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.create_outlined, size: 30), // أيقونة إنشاء رسالة جديدة
            onPressed: () {
              // أضف الإجراء المطلوب عند الضغط على أيقونة إنشاء الرسالة الجديدة
              print("Create new message");
            },
          ),
        ],
      ),
      body: StreamBuilder(
        stream: _chatservice.getChatRooms(currentUserEmail),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final chatRooms = snapshot.data!.docs;

          if (chatRooms.isEmpty) {
            return const Center(
              child: Text('No chats available'),
            );
          }

          return ListView.builder(
            itemCount: chatRooms.length,
            itemBuilder: (context, index) {
              final chatRoom = chatRooms[index];
              final participants = List<String>.from(chatRoom['participants']);
              final lastMessage = chatRoom['lastMessage'] ?? 'No messages yet';

              // تحويل الطابع الزمني إلى وقت مقروء
              final Timestamp? lastMessageTimestamp = chatRoom['lastMessageTimestamp'];
              final String formattedTime = lastMessageTimestamp != null
                  ? DateFormat('hh:mm a').format(lastMessageTimestamp.toDate())
                  : '';

              // تحديد البريد الإلكتروني للمستخدم الآخر
              final otherUser = participants.firstWhere((email) => email != currentUserEmail);

              // تحديد اسم المستخدم الآخر بناءً على البريد الإلكتروني للطرف الآخر
              final otherUserName = otherUser == chatRoom['recevEmail']
                  ? chatRoom['recevName']
                  : chatRoom['senderName'];

              // جلب صورة الملف الشخصي للمستقبل (receiver)
              Future<String?> profilePictureUrl = fetchProfilePicture(otherUser);

              return FutureBuilder<String?>(
                future: profilePictureUrl,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
                      leading: const CircleAvatar(
                        radius: 30,
                        child: Icon(Icons.person),
                      ),
                      title: Text(otherUserName, style: TextStyle(fontWeight:FontWeight.w800,fontSize: 20)),
                      subtitle: Text(lastMessage, style: TextStyle(fontSize: 16, color: Colors.grey[600])),
                      trailing: Text(formattedTime, style: const TextStyle(fontSize: 14, color: Colors.grey)),
                    );
                  }

                  if (snapshot.hasError) {
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
                      leading: const CircleAvatar(
                        radius: 30,
                        child: Icon(Icons.person),
                      ),
                      title: Text(otherUserName, style: const TextStyle(fontWeight:FontWeight.w800,fontSize: 20)),
                      subtitle: Text(lastMessage, style: TextStyle(fontSize: 16, color: Colors.grey[600])),
                      trailing: Text(formattedTime, style: const TextStyle(fontSize: 14, color: Colors.grey)),
                    );
                  }

                  final profilePicture = snapshot.data;
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
                    leading: CircleAvatar(
                      radius: 25,
                      backgroundImage: profilePicture != null
                          ? MemoryImage(base64Decode(profilePicture))
                          : const AssetImage('assets/default_profile_picture.png') as ImageProvider, // صورة افتراضية إذا كانت الصورة غير متوفرة
                    ),
                    title: Text(otherUserName, style: const TextStyle(fontWeight:FontWeight.w700,fontSize: 20)),
                    subtitle: Text(lastMessage, style: TextStyle(fontSize: 16, color: Colors.grey[600])),
                    trailing: Text(formattedTime, style: const TextStyle(fontSize: 14, color: Colors.grey)),
                    onTap: () {
                      print(chatRoom.data());  // هذا سيساعدك في رؤية الهيكل الكامل للبيانات المسترجعة
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatPage(
                            recevuserName: otherUserName, // مرر الاسم هنا
                            recevEmail: otherUser,
                            currentUserEmail: currentUserEmail,
                            currentUserName: currentUserName,
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}