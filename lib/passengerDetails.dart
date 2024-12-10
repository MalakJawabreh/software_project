import 'package:flutter/material.dart';

class PassengerDetailsPage extends StatelessWidget {
  final Map<String, dynamic> passenger;

  const PassengerDetailsPage({Key? key, required this.passenger})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // title: Text("Passenger Details"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // شريط الأيقونات
              SizedBox(height: 5),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildIconButton(Icons.call, "call", Colors.purple, () {}),
                  _buildIconButton(Icons.chat, "chat", Colors.purple, () {}),
                  _buildPopupMenuButton(),
                ],
              ),
              SizedBox(height: 35), // مسافة بين شريط الأيقونات والكارد
              // كارد تفاصيل الراكب
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Row(
                      //   children: [
                      //     CircleAvatar(
                      //       radius: 30,
                      //       backgroundImage: NetworkImage(
                      //           passenger['profileImage'] ?? 'https://via.placeholder.com/150'),
                      //     ),
                      //     SizedBox(width: 16),
                      //     Column(
                      //       crossAxisAlignment: CrossAxisAlignment.start,
                      //       children: [
                      //         Text(
                      //           passenger['nameP'],
                      //           style: TextStyle(
                      //             fontSize: 18,
                      //             fontWeight: FontWeight.bold,
                      //           ),
                      //         ),
                      //       ],
                      //     ),
                      //   ],
                      // ),
                      // Divider(height: 32),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "mobile",
                            style: TextStyle(
                              fontSize: 23,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  passenger['phoneNumberP'] ?? 'N/A',
                                  style: TextStyle(
                                      fontSize: 25, color: Colors.purple),
                                ),
                              ),
                            ],
                          ),
                          Divider(height: 32),
                          Text(
                            "username",
                            style: TextStyle(
                              fontSize: 23,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Row(
                            children: [
                              // Icon(Icons.location_on, color: Colors.red),
                              // SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  passenger['nameP'] ?? 'N/A',
                                  style: TextStyle(
                                      fontSize: 25, color: Colors.purple),
                                ),
                              ),
                            ],
                          ),
                          Divider(height: 30),
                          Text(
                            "location",
                            style: TextStyle(
                              fontSize: 23,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.location_on, color: Color.fromARGB(
                                  240, 38, 28, 44)),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  passenger['nameP'] ?? 'N/A',
                                  style: TextStyle(
                                      fontSize: 25, color: Colors.purple),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 30),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton.icon(
                            onPressed: () {},
                            icon: Icon(
                              Icons.share, size: 25, color: Colors.white,),
                            label: Text("Share Profile", style: TextStyle(
                                fontSize: 22, color: Colors.white),),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color.fromARGB(
                                  230, 104, 74, 115),),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIconButton(IconData icon, String label, Color color,
      VoidCallback onPressed) {
    return Column(
      children: [
        GestureDetector(
          onTap: onPressed,
          child: Container(
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            padding: EdgeInsets.all(12),
            child: Icon(icon, color: color, size: 28),
          ),
        ),
        SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(color: color, fontSize: 20),
        ),
      ],
    );
  }
  Widget _buildPopupMenuButton() {
    return Column(
      children: [
        PopupMenuButton<int>(
          icon: Container(
            decoration: BoxDecoration(
              color: Colors.purple.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            padding: EdgeInsets.all(12),
            child: Icon(Icons.more_horiz, color: Colors.purple, size: 28),
          ),
          onSelected: (int value) {
            // تنفيذ الإجراء المطلوب بناءً على الخيار المختار
            print("Option $value selected");
          },
          itemBuilder: (BuildContext context) => <PopupMenuEntry<int>>[
            PopupMenuItem<int>(
              value: 1,
              child: ListTile(
                leading: Icon(Icons.share),
                title: Text("Share Contact",style: TextStyle(fontSize: 20),),
              ),
            ),
            PopupMenuItem<int>(
              value: 2,
              child: ListTile(
                leading: Icon(Icons.clear),
                title: Text("Clear Messages",style: TextStyle(fontSize: 20),),
              ),
            ),
            PopupMenuItem<int>(
              value: 3,
              child: ListTile(
                leading: Icon(Icons.block, color: Colors.red),
                title: Text(
                  "Block User",
                  style: TextStyle(color: Colors.red,fontSize: 20,),),
                ),
              ),
          ],
        ),
        SizedBox(height: 0),
        Text(
          "more",
          style: TextStyle(color: Colors.purple, fontSize: 20),
        ),
      ],
    );
  }
}