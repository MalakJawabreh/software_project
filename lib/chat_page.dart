import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'chatservice.dart';
import 'config.dart';
import 'package:http/http.dart' as http;

class ChatPage extends StatefulWidget {
  final String currentUserEmail; // البريد الإلكتروني للمستخدم الحالي
  final String currentUserName; // البريد الإلكتروني للمستخدم الحالي
  final String recevuserName;
  final String recevEmail;

  const ChatPage({
    required this.currentUserEmail,
    required this.currentUserName,
    required this.recevuserName,
    required this.recevEmail,
    Key? key,
  }) : super(key: key);

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final Chatservice _chatservice = Chatservice();

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

  void sendMessage() async {
    if (_messageController.text.trim().isNotEmpty) {
      await _chatservice.sendMessage(
        widget.currentUserEmail,
        widget.currentUserName, // هنا تضع اسم المرسل
        widget.recevEmail,
        widget.recevuserName, // هنا تضع اسم المستقبل
        _messageController.text,
      );
      _messageController.clear();
    } else {
      print("Message is empty");
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            // استخدام FutureBuilder للحصول على صورة البروفايل
            FutureBuilder<String?>(
              future: fetchProfilePicture(widget.recevEmail),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircleAvatar(
                    radius: 20,
                    child: Icon(Icons.person),
                  );
                }

                if (snapshot.hasError) {
                  return const CircleAvatar(
                    radius: 20,
                    child: Icon(Icons.person),
                  );
                }

                final profilePicture = snapshot.data;
                return CircleAvatar(
                  radius: 20,
                  backgroundImage: profilePicture != null
                      ? MemoryImage(base64Decode(profilePicture))
                      : const AssetImage('assets/default_profile_picture.png') as ImageProvider, // صورة افتراضية
                );
              },
            ),
            const SizedBox(width: 10),
            Text(widget.recevuserName,style:TextStyle(fontSize:23,fontWeight:FontWeight.w700)), // اسم المستخدم
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.call), // أيقونة الاتصال
            onPressed: () {
              // قم بتحديد الإجراء المطلوب عند الضغط على الزر
              print("Call button pressed");
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _buildMessageList(),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: "Type a message",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: sendMessage,
                  child: const CircleAvatar(
                    child: Icon(Icons.send),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageList() {
    return StreamBuilder(
      stream: _chatservice.getMessages(
        widget.currentUserEmail,
        widget.recevEmail,
      ),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        return ListView(
          children: snapshot.data!.docs
              .map((document) => _buildMessageItem(document))
              .toList(),
        );
      },
    );
  }

  Widget _buildMessageItem(DocumentSnapshot document) {
    Map<String, dynamic> data = document.data() as Map<String, dynamic>;

    String senderName = data['senderName'] ?? 'Unknown sender';
    String message = data['message'] ?? 'No message';

    bool isCurrentUser = (data['senderEmail'] == widget.currentUserEmail);

    var alignment = isCurrentUser ? Alignment.centerRight : Alignment.centerLeft;
    var backgroundColor = isCurrentUser ? Colors.blue : Colors.grey[300];
    var textColor = isCurrentUser ? Colors.white : Colors.black;

    return Container(
      alignment: alignment,
      margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      child: Column(
        crossAxisAlignment:
        isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          // رسالة النص داخل الحاوية
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(isCurrentUser ? 12 : 0),
                topRight: Radius.circular(isCurrentUser ? 0 : 12),
                bottomLeft: const Radius.circular(12),
                bottomRight: const Radius.circular(12),
              ),
            ),
            child: Text(
              message,
              style: TextStyle(
                color: textColor,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(height: 5),
          // عرض اسم المرسل
          Text(
            senderName,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
