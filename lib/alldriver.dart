import 'dart:convert'; // لإستخدام base64Decode
import 'dart:typed_data'; // لإستخدام Uint8List
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'DriverDetailsBooking.dart';
import 'config.dart';

class DriverListPage extends StatefulWidget {
  @override
  _DriverListPageState createState() => _DriverListPageState();
}

class _DriverListPageState extends State<DriverListPage> {
  List<dynamic> drivers = [];
  List<dynamic> filteredDrivers = [];
  bool isLoading = true;
  String errorMessage = "";
  TextEditingController searchController = TextEditingController(); // إضافة Controller للبحث

  @override
  void initState() {
    super.initState();
    fetchDrivers();
    searchController.addListener(() {
      filterDrivers();
    });
  }

  // Function to fetch drivers from the API
  Future<void> fetchDrivers() async {

    try {
      final response = await http.get(Uri.parse(all_driver));

      if (response.statusCode == 200) {
        setState(() {
          drivers = json.decode(response.body)['drivers'];
          filteredDrivers = List.from(drivers); // نسخ السائقين إلى قائمة جديدة
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
          errorMessage = "Error fetching data!";
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = "Error: $e";
      });
    }
  }

  // تحويل صورة base64 إلى بايتات
  Uint8List decodeBase64ToImage(String base64String) {
    return base64Decode(base64String);
  }

  // دالة لتصفية السائقين بناءً على الحرف الأول من الاسم
  void filterDrivers() {
    String query = searchController.text.toLowerCase();
    setState(() {
      filteredDrivers = drivers.where((driver) {
        // التحقق إذا كان الاسم يبدأ بالحرف المدخل
        return driver['fullName'].toLowerCase().startsWith(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Driver Friends",style: TextStyle(fontSize:24,color: Color.fromARGB(230, 20, 60, 115),),),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(60.0),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: "Search for a driver...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  borderSide: BorderSide(color:Color.fromARGB(230, 20, 60, 115),),
                ),
                suffixIcon: Icon(Icons.search),
              ),
            ),
          ),
        ),
      ),

      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
          ? Center(child: Text(errorMessage))
          : Padding(
        padding: const EdgeInsets.only(top: 20.0), // المسافة من الأعلى
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // إضافة النص "People you may know"
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text(
                "People you may know",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            // عرض قائمة السائقين
            Expanded(
              child: ListView.builder(
                itemCount: filteredDrivers.length,
                itemBuilder: (context, index) {
                  String? base64Image = filteredDrivers[index]['profilePicture'];
                  Uint8List imageBytes;

                  if (base64Image != null && base64Image.isNotEmpty) {
                    imageBytes = decodeBase64ToImage(base64Image);
                  } else {
                    imageBytes = Uint8List(0); // في حالة عدم وجود صورة، استخدم Icon افتراضي
                  }
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                    child: Row(
                      children: [
                        // صورة البروفايل
                        CircleAvatar(
                          backgroundImage: base64Image != null && base64Image.isNotEmpty
                              ? MemoryImage(imageBytes)
                              : null,
                          radius: 30,
                          child: base64Image == null || base64Image.isEmpty
                              ? Icon(Icons.person, size: 30, color: Colors.white)
                              : null,
                          backgroundColor: base64Image == null || base64Image.isEmpty
                              ? Colors.grey
                              : Colors.transparent,
                        ),
                        SizedBox(width: 16), // مسافة بين الصورة والمعلومات
                        // المعلومات والزر
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // الاسم والموقع
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    filteredDrivers[index]['fullName'],
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    filteredDrivers[index]['location'] ?? '',
                                    style: TextStyle(color: Colors.grey, fontSize: 14),
                                  ),
                                ],
                              ),
                              // الزر
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => DriverDetailsScreen(
                                          name:filteredDrivers[index]['fullName'],
                                          email:filteredDrivers[index]['email'],
                                          phoneNumber:filteredDrivers[index]['phoneNumber']
                                      ),
                                    ),
                                  );
                                },
                                child: Text("View Profile",style: TextStyle(fontSize: 16),),
                                style: ElevatedButton.styleFrom(
                                  padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 3.0), // تقليل القيمة العمودية
                                  backgroundColor: Color.fromARGB(230, 22, 64, 118),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(7), // جعل الحدود مستقيمة
                                  ),
                                  minimumSize: Size(0, 28), // تعيين حد أدنى للطول (اختياري)
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );

                },
              ),
            ),
          ],
        ),
      ),

    );
  }
}
