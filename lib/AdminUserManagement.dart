import 'package:flutter/material.dart';
import 'Adminallusers.dart'; // استيراد صفحة All Users
import 'AdminDriverspage.dart';
import 'AdminPassengerpage.dart';

class UserManagementPage extends StatefulWidget {
  @override
  _UserManagementPageState createState() => _UserManagementPageState();
}

class _UserManagementPageState extends State<UserManagementPage> {
  int _currentPageIndex = 0; // المؤشر لتحديد الصفحة النشطة

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'User Management',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                offset: Offset(2.0, 2.0),
                blurRadius: 4.0,
                color: Colors.pinkAccent,
              ),
              Shadow(
                offset: Offset(-2.0, -2.0),
                blurRadius: 4.0,
                color: Colors.pinkAccent,
              ),
            ],
          ),
        ),
        leading: _currentPageIndex != 0
            ? IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            setState(() {
              _currentPageIndex = 0; // العودة للصفحة الرئيسية
            });
          },
        )
            : null,
      ),
      body: IndexedStack(
        index: _currentPageIndex,
        children: [
          _buildMainGrid(context), // الصفحة الرئيسية
          AllUsersPage(),         // صفحة All Users
          AllDriversPage(),       // صفحة Drivers
          AllPassengersPage(),    // صفحة Passengers
        ],
      ),
    );
  }

  Widget _buildMainGrid(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: GridView.count(
        crossAxisCount: 3,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        children: [
          _buildCategoryCard(
            'All Users',
            Icons.group,
            'imagess/p21.png',
            Colors.white,
            1, // الفهرس الخاص بـ "All Users"
          ),
          _buildCategoryCard(
            'Drivers',
            Icons.directions_car,
            'imagess/driver.png',
            Colors.white,
            2, // الفهرس الخاص بـ "Drivers"
          ),
          _buildCategoryCard(
            'Passengers',
            Icons.person,
            'imagess/aya2.png',
            Colors.white,
            3, // الفهرس الخاص بـ "Passengers"
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(String label, IconData icon, String imagePath, Color categoryColor, int pageIndex) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentPageIndex = pageIndex; // تغيير الصفحة النشطة
        });
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          image: DecorationImage(
            image: AssetImage(imagePath),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.5),
              BlendMode.darken,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            splashColor: categoryColor.withOpacity(0.6),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    icon,
                    size: 40,
                    color: categoryColor,
                  ),
                  SizedBox(height: 10),
                  Text(
                    label,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: categoryColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
