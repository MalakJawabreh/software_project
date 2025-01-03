import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'config.dart';

class AllPassengersPage extends StatefulWidget {
  @override
  _AllPassengersPageState createState() => _AllPassengersPageState();
}

class _AllPassengersPageState extends State<AllPassengersPage> {
  List<dynamic> Passengers = [];
  List<dynamic> filteredUsers = [];
  bool isLoading = true;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  Future<void> fetchUsers() async {
    try {
      final response = await http.get(Uri.parse(all_passenger));
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        setState(() {
          // التأكد أن 'users' ليست null أو فارغة
          Passengers = data['passengers'] != null ? List.from(data['passengers']) : [];
          filteredUsers = Passengers;
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load users');
      }
    } catch (error) {
      setState(() {
        isLoading = false;
      });
      print(error);
    }
  }


  Uint8List? decodeBase64(String base64String) {
    try {
      if (base64String.isNotEmpty) {
        return base64Decode(base64String);
      } else {
        return null;
      }
    } catch (e) {
      print("Error decoding Base64 string: $e");
      return null;
    }
  }

  void _viewImage(Uint8List imageBytes) {
    if (imageBytes.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ImageViewerPage(imageBytes: imageBytes),
        ),
      );
    }
  }

  void filterUsers(String query) {
    setState(() {
      searchQuery = query;
      filteredUsers = Passengers.where((user) {
        return user['fullName'] != null &&
            (user['fullName'].toLowerCase().contains(query.toLowerCase()) ||
                user['email'].toLowerCase().contains(query.toLowerCase()) ||
                user['role'].toLowerCase().contains(query.toLowerCase()) ||
                user['phoneNumber'].contains(query));
      }).toList();
    });
  }

  Widget buildUserCard(dynamic user) {
    Uint8List? profilePictureBytes = user['profilePicture'] != null
        ? decodeBase64(user['profilePicture'])
        : null;
    Uint8List? licensePictureBytes = user['licensePicture'] != null
        ? decodeBase64(user['licensePicture'])
        : null;
    Uint8List? insurancePictureBytes = user['InsurancePicture'] != null
        ? decodeBase64(user['InsurancePicture'])
        : null;

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 15, vertical: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      elevation: 8,
      color: Color(0xFFFFF3E0),
      shadowColor: Colors.pink.withOpacity(0.2),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                GestureDetector(
                  onTap: () {
                    if (profilePictureBytes != null && profilePictureBytes!.isNotEmpty) {
                      _viewImage(profilePictureBytes!);
                    }
                  },
                  child: CircleAvatar(
                    backgroundImage: profilePictureBytes != null && profilePictureBytes!.isNotEmpty
                        ? MemoryImage(profilePictureBytes!)
                        : null,
                    radius: 40,
                    backgroundColor: Colors.grey[200],
                    child: profilePictureBytes == null || profilePictureBytes!.isEmpty
                        ? Icon(Icons.person, size: 40, color: Colors.white)
                        : null,
                  ),
                ),
                SizedBox(width: 18),
                Text(
                  user['fullName'] ?? 'No Name',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF003366),
                  ),
                ),
                Spacer(),
                IconButton(
                  icon: Icon(Icons.edit, color: Colors.green),
                  onPressed: () {
                    _showEditUserDialog(user);
                  },
                ),
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    _deleteUser(user);
                  },
                ),
              ],
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Text(
                  'Email: ',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.pinkAccent),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    user['email'] ?? 'No Email',
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Text(
                  'Phone: ',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.pinkAccent),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    user['phoneNumber'] ?? 'No Phone Number',
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Text(
                  'Location: ',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.pinkAccent),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    user['location'] ?? 'Not provided',
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Text(
                  'Gender: ',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.pinkAccent),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    user['gender'] ?? 'No gender',
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Text(
                  'Role: ',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.pinkAccent),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    user['role'] ?? 'No Role',
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                ),
              ],
            ),
            if (licensePictureBytes != null && licensePictureBytes!.isNotEmpty) ...[
              SizedBox(height: 12),
              GestureDetector(
                onTap: () => _viewImage(licensePictureBytes!),
                child: Row(
                  children: [
                    Text(
                      'View License Image',
                      style: TextStyle(color: Colors.pinkAccent, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
            if (insurancePictureBytes != null && insurancePictureBytes!.isNotEmpty) ...[
              SizedBox(height: 12),
              GestureDetector(
                onTap: () => _viewImage(insurancePictureBytes!),
                child: Row(
                  children: [
                    Text(
                      'View Insurance Image',
                      style: TextStyle(color: Colors.pinkAccent, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
            SizedBox(height: 12),
            if (user['blockedUsers'] != null && user['blockedUsers'].isNotEmpty)
              Text('Blocked Users: ${user['blockedUsers'].length}', style: TextStyle(color: Colors.grey[700])),
          ],
        ),
      ),
    );
  }

  void _showEditUserDialog(dynamic user) {
    // محتوى نافذة التعديل
  }

  void _deleteUser(dynamic user) {
    // محتوى نافذة الحذف
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: InputDecoration(
                labelText: 'Search by Name, Email, Phone, or Role',
                labelStyle: TextStyle(color: Colors.pinkAccent),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                prefixIcon: Icon(Icons.search, color: Colors.pinkAccent),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.pinkAccent, width: 2),
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              onChanged: (query) {
                filterUsers(query);
              },
            ),
          ),
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : ListView.builder(
              itemCount: filteredUsers.length,
              itemBuilder: (context, index) {
                return buildUserCard(filteredUsers[index]);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class ImageViewerPage extends StatelessWidget {
  final Uint8List imageBytes;

  ImageViewerPage({required this.imageBytes});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Image Viewer'),
      ),
      body: Center(
        child: Image.memory(imageBytes),
      ),
    );
  }
}
