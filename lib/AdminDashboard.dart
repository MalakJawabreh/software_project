import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:table_calendar/table_calendar.dart';
import 'AdminTripManagement.dart';
import 'AdminUserManagement.dart';
import 'AdminComplaintManagement.dart';
import 'AdminBookhingMang.dart';
void main() {
  runApp(AdminDashboardApp());
}

class AdminDashboardApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Color(0xFF121212),
        cardColor: Color(0xFF1E1E2C),
        primaryColor: Colors.pinkAccent,
      ),
      home: AdminDashboardPage(),
    );
  }
}

class AdminDashboardPage extends StatefulWidget {
  @override
  _AdminDashboardPageState createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  bool _isSidebarCollapsed = false;

  final List<Widget> _pages = [
    DashboardOverviewPage(),
    UserManagementPage(),
    AdminTripManagementPage(),
    BookingsPage(),
    ComplaintsPage(),
    GeneralSettingsPage(),
  ];

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
                _buildCustomDrawerItem(Icons.report_problem,'Complaint Management', 4),

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
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hello, Admin',
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
                          DashboardCard(
                            title: 'Total Users',
                            value: '1,245',
                            percentage: '+5%',
                            chart: _buildSampleChart(Colors.pink),
                            color: Colors.pink,
                            icon: Icons.people,
                          ),
                          DashboardCard(
                            title: 'Total Trips',
                            value: '320',
                            percentage: '+8%',
                            chart: _buildSampleChart(Colors.purple),
                            color: Colors.purple,
                            icon: Icons.directions_car,
                          ),
                          DashboardCard(
                            title: 'Pending Complaints',
                            value: '12',
                            percentage: '-3%',
                            chart: _buildSampleChart(Colors.red),
                            color: Colors.red,
                            icon: Icons.report_problem,
                          ),
                          DashboardCard(
                            title: 'Bookings',
                            value: '980',
                            percentage: '+12%',
                            chart: _buildSampleChart(Colors.orange),
                            color: Colors.orange,
                            icon: Icons.book_online,
                          ),
                        ];
                        return cards[index];
                      },
                    );
                  },
                ),
              ],
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: double.infinity,
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search...',
                      filled: true,
                      fillColor: Colors.black12,
                      prefixIcon: Icon(Icons.search, color: Colors.grey),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 8),
                Expanded( // هذا هو الحل الرئيسي لضمان عدم التجاوز
                  child: Container(
                    decoration: BoxDecoration(
                      color: Color(0xFF1E1E2C),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    padding: EdgeInsets.all(8.0),
                    child: TableCalendar(
                      firstDay: DateTime.utc(2020, 1, 1),
                      lastDay: DateTime.utc(2030, 12, 31),
                      focusedDay: DateTime.now(),
                      calendarStyle: CalendarStyle(
                        todayDecoration: BoxDecoration(
                          color: Colors.pink,
                          shape: BoxShape.circle,
                        ),
                        selectedDecoration: BoxDecoration(
                          color: Colors.purple,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),


        ],
      ),
    );
  }

  Widget _buildSampleChart(Color color) {
    return LineChart(
      LineChartData(
        gridData: FlGridData(show: false),
        titlesData: FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        minX: 0,
        maxX: 10,
        minY: 0,
        maxY: 10,
        lineBarsData: [
          LineChartBarData(
            spots: [
              FlSpot(0, 3),
              FlSpot(2, 5),
              FlSpot(4, 4),
              FlSpot(6, 7),
              FlSpot(8, 6),
              FlSpot(10, 8),
            ],
            isCurved: true,
            colors: [color],
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              colors: [color.withOpacity(0.3)],
            ),
          ),
        ],
      ),
    );
  }
}

class DashboardCard extends StatelessWidget {
  final String title;
  final String value;
  final String percentage;
  final Widget chart;
  final Color color;
  final IconData icon;

  const DashboardCard({
    required this.title,
    required this.value,
    required this.percentage,
    required this.chart,
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
            SizedBox(height: 10),
            Expanded(
              child: chart,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  value,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Text(
                  percentage,
                  style: TextStyle(
                    fontSize: 16,
                    color: percentage.startsWith('+') ? Colors.green : Colors.red,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}








class GeneralSettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'General Settings Page',
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
    );
  }
}
