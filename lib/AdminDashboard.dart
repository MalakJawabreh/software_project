import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'AdminBookhingMang.dart';
import 'AdminComplaintManagement.dart';
import 'AdminPassengerpage.dart';
import 'AdminUserManagement.dart';
import 'AdminDriverspage.dart';
import 'Adminallusers.dart';
import 'AdminTripManagement.dart';
import 'package:http/http.dart' as http;

import 'config.dart';


class AdminDashboardPage extends StatefulWidget {

  final String token;

  const AdminDashboardPage({required this.token});

  @override
  _AdminDashboardPageState createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  int _selectedIndex = 0;
  bool _isSidebarCollapsed = false;
  late String adminName;
  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    adminName = _extractAdminName(widget.token);
    _pages = [
      DashboardOverviewPage(adminName: adminName,token: widget.token),
      UserManagementPage(token: widget.token),
      AdminTripManagementPage(),
      BookingsPage(),
      ComplaintsPage(),
      PlaceholderWidget('General Settings'),
    ];
  }
  String _extractAdminName(String token) {
    try {
      final decodedToken = JwtDecoder.decode(token);
      return decodedToken['name'] ?? 'Admin'; // تأكد من أن الحقل "name" موجود في التوكن
    } catch (e) {
      return 'Admin';
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          _buildSidebar(),
          Expanded(
            child: _pages[_selectedIndex],
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar() {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      width: _isSidebarCollapsed ? 70 : 250,
      constraints: BoxConstraints(minWidth: 70, maxWidth: 250),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.black, Colors.pinkAccent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.pinkAccent.withOpacity(0.2),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 15,
                  backgroundColor: Colors.pink,
                  child: Icon(Icons.admin_panel_settings, color: Colors.white, size: 15),
                ),
                if (!_isSidebarCollapsed) SizedBox(width: 8),
                if (!_isSidebarCollapsed)
                  Flexible(
                    child: Text(
                      'Admin Panel',
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              children: [
                _buildCustomDrawerItem(Icons.dashboard, 'Dashboard Overview', 0),
                Divider(color: Colors.grey[700]),
                _buildCustomDrawerItem(Icons.people, 'User Management', 1),
                _buildCustomDrawerItem(Icons.directions_car, 'Trip Management', 2),
                _buildCustomDrawerItem(Icons.event, 'Bookings Management', 3),
                _buildCustomDrawerItem(Icons.report_problem, 'Complaint Management', 4),
                _buildCustomDrawerItem(Icons.settings, 'General Settings', 5),
              ],
            ),
          ),
          Divider(color: Colors.grey[700]),
          IconButton(
            icon: Icon(
              _isSidebarCollapsed ? Icons.arrow_forward_ios : Icons.arrow_back_ios,
              color: Colors.white,
            ),
            onPressed: () {
              setState(() {
                _isSidebarCollapsed = !_isSidebarCollapsed;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCustomDrawerItem(IconData icon, String title, int index) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      decoration: _selectedIndex == index
          ? BoxDecoration(
        color: Colors.pinkAccent.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8.0),
      )
          : null,
      child: ListTile(
        leading: Icon(
          icon,
          color: _selectedIndex == index ? Colors.pinkAccent : Colors.grey[400],
          size: 20,
        ),
        title: _isSidebarCollapsed
            ? null
            : Text(
          title,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: _selectedIndex == index ? Colors.pinkAccent : Colors.grey[300],
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        onTap: () {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}

class DashboardOverviewPage extends StatelessWidget {
  final String adminName;
  final String token; // أضف التوكن هنا


  const DashboardOverviewPage({required this.adminName,required this.token});

  Future<int> fetchActiveUsers() async {
    try {
      final response = await http.get(Uri.parse(count_user));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['totalUsers'];
      } else {
        throw Exception('Failed to load active users');
      }
    } catch (e) {
      print('Error fetching active users: $e');
      throw e;
    }
  }

  Future<int> fetchTripStatistics() async {
    try {
      // إرسال الطلب
      final response = await http.get(
        Uri.parse(getTripStatistics),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      // التحقق من حالة الاستجابة
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body); // تحليل الاستجابة إلى JSON
        if (data['status'] == true && data['stats'] != null) {
          return data['stats']['totalTrips'] ?? 0; // إرجاع عدد الرحلات أو 0 إذا لم تكن موجودة
        } else {
          throw Exception('Failed to parse trip statistics');
        }
      } else {
        throw Exception('Failed to fetch trip statistics: ${response.body}');
      }
    } catch (error) {
      print('Error fetching trip statistics: $error');
      throw error; // إرسال الخطأ للتعامل معه في أماكن أخرى
    }
  }


// الدالة لجلب عدد الحجوزات الجديدة
  Future<int> fetchNewBookingsCount() async {
    try {
      // إرسال الطلب
      final response = await http.get(
        Uri.parse(BookingsCountByDate),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      // التحقق من حالة الاستجابة
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body); // تحليل الاستجابة إلى JSON
        if (data['status'] == true && data['count'] != null) {
          return data['count'] ?? 0; // إرجاع عدد الحجوزات أو 0 إذا لم تكن موجودة
        } else {
          throw Exception('Failed to parse new bookings count');
        }
      } else {
        throw Exception('Failed to fetch new bookings count: ${response.body}');
      }
    } catch (error) {
      print('Error fetching new bookings count: $error');
      throw error; // إرسال الخطأ للتعامل معه في أماكن أخرى
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hello, $adminName',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              int crossAxisCount = constraints.maxWidth > 600 ? 4 : 2;
              return GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.5,
                ),
                itemCount: 4,
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  final cards = [
                    FutureBuilder<int>(
                      future: fetchActiveUsers(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return DashboardCard(
                            title: 'Active Users',
                            value: 'Loading...',
                            color: Colors.pink,
                            icon: Icons.people,
                          );
                        } else if (snapshot.hasError) {
                          return DashboardCard(
                            title: 'Active Users',
                            value: 'Error',
                            color: Colors.pink,
                            icon: Icons.people,
                          );
                        } else {
                          return DashboardCard(
                            title: 'Active Users',
                            value: '${snapshot.data}',
                            color: Colors.pink,
                            icon: Icons.people,
                          );
                        }
                      },
                    ),
                    FutureBuilder<int>(
                      future: fetchTripStatistics(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return DashboardCard(
                            title: 'All Trips',
                            value: 'Loading...',
                            color: Colors.green,
                            icon: Icons.car_crash,
                          );
                        } else if (snapshot.hasError) {
                          return DashboardCard(
                            title: 'All Trips',
                            value: 'Error',
                            color: Colors.green,
                            icon: Icons.car_crash,
                          );
                        } else {
                          return DashboardCard(
                            title: 'All Trips',
                            value: '${snapshot.data}',
                            color: Colors.green,
                            icon: Icons.car_crash,
                          );
                        }
                      },
                    ),
                    DashboardCard(
                      title: 'Pending Complaints',
                      value: '12',
                      color: Colors.red,
                      icon: Icons.report_problem,
                    ),
                    FutureBuilder<int>(
                      future: fetchNewBookingsCount(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return DashboardCard(
                            title: 'Current Booking',
                            value: 'Loading...',
                            color: Colors.orange,
                            icon: Icons.book_online,
                          );
                        } else if (snapshot.hasError) {
                          return DashboardCard(
                            title: 'Current Booking',
                            value: 'Error',
                            color: Colors.orange,
                            icon: Icons.book_online,
                          );
                        } else {
                          return DashboardCard(
                            title: 'Current Booking',
                            value: '${snapshot.data}',
                            color: Colors.orange,
                            icon: Icons.book_online,
                          );
                        }
                      },
                    ),
                  ];
                  return cards[index];
                },
              );
            },
          ),
          SizedBox(height: 16),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: GenderPieChartWidget(),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: PieChartWidget(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class GenderPieChartWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'User Gender Distribution',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Expanded(
              child: PieChart(
                PieChartData(
                  sections: [
                    PieChartSectionData(
                      color: Colors.blue, // اللون المخصص للذكور
                      value: 70,
                      title: '70%',
                      radius: 50,
                      titleStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    PieChartSectionData(
                      color: Colors.pink, // اللون المخصص للإناث
                      value: 30,
                      title: '30%',
                      radius: 50,
                      titleStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),
            // Adding a category explanation
            Row(
              children: [
                _buildCategoryIndicator(Colors.blue, 'Male Users'),
                SizedBox(width: 16),
                _buildCategoryIndicator(Colors.pink, 'Female Users'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryIndicator(Color color, String label) {
    return Row(
      children: [
        CircleAvatar(
          radius: 8,
          backgroundColor: color,
        ),
        SizedBox(width: 4),
        Text(label, style: TextStyle(fontSize: 14, color: Colors.black)),
      ],
    );
  }
}


class PieChartWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Trips Categories',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Expanded(
              child: PieChart(
                PieChartData(
                  sections: [
                    PieChartSectionData(
                      color: Colors.pink,
                      value: 40,
                      title: '40%',
                      radius: 50,
                      titleStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    PieChartSectionData(
                      color: Colors.red,
                      value: 30,
                      title: '30%',
                      radius: 50,
                      titleStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    PieChartSectionData(
                      color: Colors.green,
                      value: 20,
                      title: '20%',
                      radius: 50,
                      titleStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),
            // Adding a category explanation
            Row(
              children: [
                _buildCategoryIndicator(Colors.pink, 'Completed Trips'),
                SizedBox(width: 16),
                _buildCategoryIndicator(Colors.red, 'Cancelled Trips'),
                SizedBox(width: 16),
                _buildCategoryIndicator(Colors.green, 'Upcoming Trips'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryIndicator(Color color, String label) {
    return Row(
      children: [
        CircleAvatar(
          radius: 8,
          backgroundColor: color,
        ),
        SizedBox(width: 4),
        Text(label, style: TextStyle(fontSize: 14, color: Colors.black)),
      ],
    );
  }
}

class DashboardCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;
  final IconData icon;

  const DashboardCard({
    required this.title,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: color, size: 20),
                Row(
                  children: [
                    Text('Daily', style: TextStyle(color: Colors.grey, fontSize: 12)),
                    SizedBox(width: 8),
                    Icon(Icons.more_vert, color: Colors.grey, size: 16),
                  ],
                ),
              ],
            ),
            SizedBox(height: 10),
            Text(
              title,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Spacer(),
            LayoutBuilder(
              builder: (context, constraints) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        value,
                        style: TextStyle(
                          fontSize: constraints.maxWidth > 300 ? 20 : 16,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}


class PlaceholderWidget extends StatelessWidget {
  final String title;

  const PlaceholderWidget(this.title);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        title,
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
    );
  }
}