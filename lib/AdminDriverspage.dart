import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'config.dart';

class AllDriversPage extends StatefulWidget {
  @override
  _AllDriversPageState createState() => _AllDriversPageState();
}

class _AllDriversPageState extends State<AllDriversPage> {
  List<dynamic> drivers = [];
  List<dynamic> filteredDrivers = [];
  bool isLoading = true;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    fetchDrivers();
  }

  Future<void> fetchDrivers() async {
    try {
      final response = await http.get(Uri.parse(all_driver)); // استخدم الرابط المناسب للسائقين
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        setState(() {
          drivers = data['drivers'];
          filteredDrivers = drivers;
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load drivers');
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

  void filterDrivers(String query) {
    setState(() {
      searchQuery = query;
      filteredDrivers = drivers.where((driver) {
        return driver['fullName'] != null &&
            (driver['fullName'].toLowerCase().contains(query.toLowerCase()) ||
                driver['email'].toLowerCase().contains(query.toLowerCase()) ||
                driver['phoneNumber'].contains(query)); // البحث حسب رقم الهاتف
      }).toList();
    });
  }

  Widget buildDriverCard(dynamic driver) {
    Uint8List? profilePictureBytes = driver['profilePicture'] != null
        ? decodeBase64(driver['profilePicture'])
        : null;
    Uint8List? licensePictureBytes = driver['licensePicture'] != null
        ? decodeBase64(driver['licensePicture'])
        : null;
    Uint8List? insurancePictureBytes = driver['InsurancePicture'] != null
        ? decodeBase64(driver['InsurancePicture'])
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
                  driver['fullName'] ?? 'No Name',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF003366), // لون أزرق غامق
                  ),
                ),
                Spacer(),
                // أيقونة التعديل
                IconButton(
                  icon: Icon(Icons.edit, color: Colors.green),
                  onPressed: () {
                    _showEditDriverDialog(driver); // استدعاء دالة التعديل
                  },
                ),
                // أيقونة الحذف
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    _deleteDriver(driver); // استدعاء دالة الحذف
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
                    driver['email'] ?? 'No Email',
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
                    driver['phoneNumber'] ?? 'No Phone Number',
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
                    driver['gender'] ?? 'No Gender',
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Text(
                  'Car Type: ',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.pinkAccent),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    driver['carType'] ?? 'No Car Type',
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Text(
                  'Car Number: ',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.pinkAccent),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    driver['carNumber'] ?? 'No Car Number',
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
          ],
        ),
      ),
    );
  }

  void _showEditDriverDialog(dynamic driver) {
    final fullNameController = TextEditingController(text: driver['fullName']);
    final emailController = TextEditingController(text: driver['email']);
    final phoneController = TextEditingController(text: driver['phoneNumber']);
    final passwordController = TextEditingController(); // حقل كلمة السر

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          backgroundColor: Color(0xFFF7F7F7), // خلفية فاتحة
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Edit Driver',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A237E),
                  ),
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: fullNameController,
                  decoration: InputDecoration(
                    labelText: 'Full Name',
                    labelStyle: TextStyle(color: Color(0xFF1A237E)),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF1A237E), width: 2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF1A237E)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    hintText: 'Enter full name',
                    hintStyle: TextStyle(color: Colors.grey),
                  ),
                ),
                SizedBox(height: 12),
                TextFormField(
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    labelStyle: TextStyle(color: Color(0xFF1A237E)),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF1A237E), width: 2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF1A237E)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    hintText: 'Enter email address',
                    hintStyle: TextStyle(color: Colors.grey),
                  ),
                ),
                SizedBox(height: 12),
                TextFormField(
                  controller: phoneController,
                  decoration: InputDecoration(
                    labelText: 'Phone Number',
                    labelStyle: TextStyle(color: Color(0xFF1A237E)),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF1A237E), width: 2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF1A237E)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    hintText: 'Enter phone number',
                    hintStyle: TextStyle(color: Colors.grey),
                  ),
                ),
                SizedBox(height: 12),
                TextFormField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'New Password',
                    labelStyle: TextStyle(color: Color(0xFF1A237E)),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF1A237E), width: 2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF1A237E)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    hintText: 'Enter new password',
                    hintStyle: TextStyle(color: Colors.grey),
                  ),
                ),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        final updatedDriver = {
                          'fullName': fullNameController.text,
                          'email': emailController.text,
                          'phoneNumber': phoneController.text,
                          'password': passwordController.text.isNotEmpty
                              ? passwordController.text
                              : driver['password'],
                        };

                        Navigator.pop(context);
                      },
                      child: Text('Save Changes'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _deleteDriver(dynamic driver) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Are you sure?"),
          content: Text("Do you want to delete this driver?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("Yes"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("No"),
            ),
          ],
        );
      },
    );
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
                labelText: 'Search by Name, Email, or Phone',
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
                filterDrivers(query);
              },
            ),
          ),
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : ListView.builder(
              itemCount: filteredDrivers.length,
              itemBuilder: (context, index) {
                return buildDriverCard(filteredDrivers[index]);
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
