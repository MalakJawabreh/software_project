import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class IncomeOverview extends StatefulWidget {
  final List<dynamic> completedTrips;

  IncomeOverview({required this.completedTrips});

  @override
  _IncomeOverviewState createState() => _IncomeOverviewState();
}

class _IncomeOverviewState extends State<IncomeOverview> {
  List<Map<String, dynamic>> groupedData = [];
  String? selectedDate; // التاريخ المختار (null يعني عرض الكل)

  @override
  void initState() {
    super.initState();
    groupTripsByDate();
  }

  // تجميع الرحلات حسب التاريخ
  void groupTripsByDate() {
    final Map<String, List<Map<String, dynamic>>> tripsByDate = {};
    for (var trip in widget.completedTrips) {
      final date = trip['date']; // افترض أن التاريخ موجود بتنسيق String مثل "YYYY-MM-DD"
      if (!tripsByDate.containsKey(date)) {
        tripsByDate[date] = [];
      }
      tripsByDate[date]?.add(trip);
    }

    setState(() {
      groupedData = tripsByDate.entries.map((entry) {
        final date = entry.key;
        final trips = entry.value;
        final totalIncome = trips.fold<double>(0, (sum, trip) => sum + (trip['currentPassengers'] * trip['price']));
        return {
          'date': date,
          'totalIncome': totalIncome,
          'totalTrips': trips.length,
        };
      }).toList();
    });
  }

  // تعديل دالة التصفية
  void filterByDate(String date) {
    setState(() {
      selectedDate = date;

      // التأكد من تطابق التنسيق
      groupedData = groupedData.where((data) {
        final parsedDate = DateTime.parse(data['date']); // تحويل التاريخ في البيانات إلى DateTime
        final formattedDate = DateFormat('yyyy-MM-dd').format(parsedDate); // تنسيق التاريخ
        return formattedDate == date; // مقارنة التاريخين
      }).toList();
    });
  }

  // إعادة ضبط التصفية
  void resetFilter() {
    setState(() {
      selectedDate = null;
      groupTripsByDate();
    });
  }

  // دالة تنسيق التاريخ
  String formatDate(String date) {
    DateTime parsedDate = DateTime.parse(date);
    return DateFormat('yyyy-MM-dd').format(parsedDate);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Earnings Report',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(230, 24, 83, 131),
          ),
        ),
        backgroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.contact_support,size: 23, color: Color.fromARGB(230, 24, 83, 131)),
            onPressed: () {
              // هنا تضع الكود الذي سيحدث عند الضغط على الأيقونة
              print('Search icon pressed');
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // أيقونة التاريخ في أعلى البودي
          Padding(
            padding: const EdgeInsets.all(5.0),
            child: Align(
              alignment: Alignment.topRight,
              child: IconButton(
                icon: Icon(Icons.calendar_today, color: Color.fromARGB(230, 24, 83, 131)),
                onPressed: () async {
                  // فتح التقويم واختيار التاريخ
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );

                  if (pickedDate != null) {
                    String formattedDate = DateFormat('yyyy-MM-dd').format(pickedDate);
                    filterByDate(formattedDate); // تصفية البيانات
                  }
                },
              ),
            ),
          ),
          // إذا تم تحديد تاريخ فإن زر إعادة التصفية سيظهر
          if (selectedDate != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: IconButton(
                icon: Icon(Icons.clear, color: Colors.red),
                onPressed: resetFilter,
              ),
            ),
          // عرض البيانات في قائمة
          groupedData.isEmpty
              ? Center(
            child: Text(
              "No data available for the selected date.",
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          )
              : Expanded(
            child: ListView.builder(
              itemCount: groupedData.length,
              itemBuilder: (context, index) {
                final data = groupedData[index];
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: BorderSide(color: Colors.grey.shade500, width: 1),
                  ),
                  color: Colors.white,
                  shadowColor: Color.fromARGB(230, 41, 84, 115),
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.calendar_today, color: Color.fromARGB(230, 24, 83, 131), size: 24),
                            SizedBox(width: 8),
                            Text(
                              "${formatDate(data['date'])}",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color.fromARGB(230, 70, 149, 47),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.directions_car, color: Color.fromARGB(230, 24, 83, 131), size: 24),
                            SizedBox(width: 8),
                            Text(
                              "${data['totalTrips']} Trips",
                              style: TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.attach_money, color: Color.fromARGB(230, 24, 83, 131), size: 24),
                            SizedBox(width: 8),
                            Text(
                              "${data['totalIncome'].toStringAsFixed(2)} ILS",
                              style: TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.w500,
                                color: Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
