import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'chat_page.dart';
import 'chatservice.dart';

class ChatListPage extends StatelessWidget {
  final String currentUserEmail;
  final String currentUserName;

  const ChatListPage({required this.currentUserEmail,required this.currentUserName});

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
              //final otherUser = participants.firstWhere((email) => email != currentUserEmail);

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

              return ListTile(
                contentPadding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
                leading: const CircleAvatar(
                  radius: 25,
                  child: Icon(Icons.person),
                ),
                title: Text(otherUserName, // عرض اسم المستقبل
                    style: const TextStyle(fontSize: 20)),
                subtitle: Text(lastMessage, style: TextStyle(fontSize: 16, color: Colors.grey[600])),
                trailing: Text(
                  formattedTime,
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
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
      ),
    );
  }
}