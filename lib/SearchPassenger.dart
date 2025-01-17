import 'package:flutter/material.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:provider/provider.dart';
import 'language_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'config.dart';
import 'dart:async';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'TripDetailsScreen.dart';

class SearchTripsPage extends StatefulWidget {
  final String emailP;
  final String nameP;
  final String phoneP;
  @override
  _SearchTripsPageState createState() => _SearchTripsPageState();
  const SearchTripsPage({required this.emailP,required this.nameP,required this.phoneP, super.key});


}

class _SearchTripsPageState extends State<SearchTripsPage> {

  final TextEditingController _departureController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _driverNameController = TextEditingController(); // حقل اسم السائق الجديد

  final TextEditingController _driverRatingController =
  TextEditingController();

  String? _selectedCarBrand;
  TimeOfDay? _selectedTime;
  DateTime? _selectedDate;
  List<String> _cities = [
    'Nablus', 'Ramallah', 'Jerusalem', 'Hebron', 'Gaza', 'Jenin', 'Tulkarm', 'Bethlehem', 'Qalqilya', 'Tubas',
    'Salfit', 'Jericho', 'Rafah', 'Deir al-Balah', 'Khan Younis', 'Zababdeh', 'Baqa al-Sharqiya', 'Balata', 'Saffa',
    'Dura', 'Bani Na’im', 'Acre', 'Haifa', 'Jaffa', 'Ramla', 'Lod', 'Safed', 'Tiberias', 'Beit Shean',
    'Nazareth', 'Umm al-Fahm', 'Tayibe', 'Kafr Qasim', 'Kafr Kanna', 'Arraba', 'Sakhnin', 'Deir al-Asad',
    'Beit Jann', 'Mi’ilya', 'al-Bi’na', 'Yarka', 'Jadeidi-Makr', 'Shefa-Amr', 'Tur’an', 'Arraba al-Batouf',
    'Kafr Yasif', 'Deir Hanna', 'Eilabun', 'al-Mazra’a', 'Dabburiya', 'al-Maghar', 'Reineh', 'Kuseife',
    'Tel as-Sabi', 'Hura', 'Ar’arat an-Naqab', 'Shaqib al-Salam', 'Rahat', 'al-Qastal', 'Ein Karem', 'Silwan',
    'Shuafat', 'al-Issawiya', 'Beit Safafa', 'Sheikh Jarrah', 'Beit Hanina', 'At-Tur', 'Anata', 'Abu Dis',
    'Al-Eizariya', 'Birzeit', 'al-Mughayyir', 'Sinjil', 'Turmus Ayya', 'Rantis', 'Nabi Saleh', 'Beit Rima',
    'Deir Ghassaneh', 'al-Ubeidiya', 'Beit Sahour', 'Beit Jala', 'Husan', 'al-Khader', 'al-Arroub', 'al-Fawwar',
    'Sa’ir', 'Yatta', 'as-Samu’' , 'ash-Shuyukh', 'Bani Suheila', 'Abasan al-Kabira', 'Abasan al-Saghira',
    'Beit Hanoun', 'Beit Lahiya', 'Jabalia', 'Jabalia Camp', 'Beach Camp (Shati)', 'Nuseirat Camp',
    'Bureij Camp', 'Maghazi Camp', 'Dheisheh Camp', 'al-Arroub Camp', 'al-Far’a Camp',
    'Jenin Camp', 'Nur Shams Camp', 'Tulkarm Camp', 'Balata Camp', 'Askar Camp', 'Aqabat Jaber Camp',
    'Ein as-Sultan Camp','Hebron City Center','Rafidia','Birzeit University'
  ];

// تحويل أسماء المدن للعربية إذا كانت اللغة العربية مفعلة

  List<String> _citiesArabic = [
    'نابلس', 'رام الله', 'القدس', 'الخليل', 'غزة', 'جنين', 'طولكرم', 'بيت لحم', 'قلقيلية', 'طوباس',
    'سلفيت', 'أريحا', 'رفح', 'دير البلح', 'خانيونس', 'الزبابدة', 'باقا الشرقية', 'بلاطة', 'صفا',
    'دورا', 'بني نعيم', 'عكا', 'حيفا', 'يافا', 'الرملة', 'اللد', 'صفد', 'طبريا', 'بيسان',
    'الناصرة', 'أم الفحم', 'الطيبة', 'كفر قاسم', 'كفر كنا', 'عرابة', 'سخنين', 'دير الأسد',
    'بيت جن', 'معليا', 'البعنة', 'يركا', 'جديدة-المكر', 'شفاعمرو', 'طرعان', 'عرابة البطوف',
    'كفر ياسيف', 'دير حنا', 'عيلبون', 'المزرعة', 'دبورية', 'المغار', 'الرينة', 'كسيفة',
    'تل السبع', 'حورة', 'عرعرة النقب', 'شقيب السلام', 'رهط', 'القسطل', 'عين كارم', 'سلوان',
    'شعفاط', 'العيسوية', 'بيت صفافا', 'الشيخ جراح', 'بيت حنينا', 'الطور', 'عناتا', 'أبو ديس',
    'العيزرية', 'بير زيت', 'المغير', 'سنجل', 'ترمسعيا', 'رنتيس', 'النبي صالح', 'بيت ريما',
    'دير غسانة', 'العبيدية', 'بيت ساحور', 'بيت جالا', 'حوسان', 'الخضر', 'العروب', 'الفوار',
    'سعير', 'يطا', 'السموع', 'الشيوخ', 'بني سهيلا', 'عبسان الكبيرة', 'عبسان الصغيرة',
    'بيت حانون', 'بيت لاهيا', 'جباليا', 'مخيم جباليا', 'مخيم الشاطئ', 'مخيم النصيرات',
    'مخيم البريج', 'مخيم المغازي', 'مخيم الدهيشة', 'مخيم العروب', 'مخيم الفارعة',
    'مخيم جنين', 'مخيم نور شمس', 'مخيم طولكرم', 'مخيم بلاطة', 'مخيم عسكر', 'مخيم عقبة جبر',
    'مخيم عين السلطان'
  ];

  List<String> _carBrands = [
    'Toyota', 'bmw','Honda', 'Ford', 'BMW', 'Mercedes', 'Chevrolet', 'Nissan', 'Audi', 'Volkswagen', 'Hyundai',
    'Kia', 'Lexus', 'Mazda', 'Subaru', 'Porsche', 'Jaguar', 'Land Rover', 'Chrysler', 'Tesla', 'Mitsubishi', 'Skoda'
  ];

// قائمة الفلاتر المتاحة
  List<String> _filterOptions = ['Price', 'Car Type', 'Time', 'Date', 'Driver Rating', 'Driver Name'];


// الفلاتر باللغة العربية
  List<String> _filterOptionsArabic = ['السعر', 'نوع السيارة', 'الوقت', 'التاريخ', 'تقييم السائق'];



  // المتغير لتخزين الفلاتر المختارة
  List<String> _selectedFilters = [];
  List<dynamic> _trips = [];

  String formatTimeWithAMPM(DateTime time) {
    // إذا كانت الساعة 24 أو أكبر، نعدلها إلى الساعة في تنسيق 12 ساعة مع AM/PM
    final format = DateFormat('hh:mm a'); // تنسيق 12 ساعة مع AM/PM
    return format.format(time);
  }

  ScrollController _scrollController = ScrollController();  // ScrollController

  @override
  void initState() {
    super.initState();
    // fetchFilteredTrips().then((_) {
    //   updateTripsBasedOnTime();
    // });
    // Timer.periodic(Duration(seconds: 20), (timer) {
    //   updateTripsBasedOnTime();
    // });
  }

  Future<Map<String, dynamic>?> getAverageRating(String email) async {
    final String endpoint = '$average_rate/$email';

    try {
      final response = await http.get(Uri.parse(endpoint));
      if (response.statusCode == 200) {
        // تحويل الاستجابة إلى JSON
        return json.decode(response.body);
      } else if (response.statusCode == 404) {
        // لا توجد تقييمات
        print('No reviews found for this user');
        return null;
      } else {
        // طباعة أي خطأ آخر
        print('Error: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Exception: $e');
      return null;
    }
  }

  String formatTimeToAMPM(DateTime selectedTime) {
    final hour = selectedTime.hour;
    final minute = selectedTime.minute;
    final ampm = hour >= 12 ? 'PM' : 'AM';
    final hour12 = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    final formattedMinute = minute.toString().padLeft(2, '0'); // لضمان أن الدقائق تظهر بصيغة 2 خانات
    return '$hour12:$formattedMinute $ampm';
  }
  // دالة لتحويل TimeOfDay إلى DateTime
  DateTime convertTimeOfDayToDateTime(TimeOfDay timeOfDay) {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, timeOfDay.hour, timeOfDay.minute);
  }


  Future<void> fetchFilteredTrips(List<String> selectedFilters) async {
    try {
      // تحقق من الحقول قبل إرسال الطلب
      if (_departureController.text.isEmpty || _destinationController.text.isEmpty) {
        throw Exception("Both 'from' and 'to' fields must be filled.");
      }

      // إنشاء الفلاتر بناءً على الفلاتر الممرّرة
      Map<String, String> queryParameters = {
        'from': _departureController.text,
        'to': _destinationController.text,
      };

      // إضافة الفلاتر بناءً على الاختيارات
      if (_priceController.text.isNotEmpty && selectedFilters.contains('Price')) {
        queryParameters['maxPrice'] = _priceController.text;
      }

      if (_selectedCarBrand != null && selectedFilters.contains('Car Type')) {
        queryParameters['carBrand'] = _selectedCarBrand!;
      }

      if (_selectedTime != null && selectedFilters.contains('Time')) {
        queryParameters['time'] = formatTimeToAMPM(convertTimeOfDayToDateTime(_selectedTime!));
      }

      if (_selectedDate != null && selectedFilters.contains('Date')) {
        queryParameters['date'] = "${_selectedDate?.toIso8601String()}+00:00";
      }

      if (_driverRatingController.text.isNotEmpty && selectedFilters.contains('Driver Rating')) {
        queryParameters['driverRating'] = _driverRatingController.text;
      }

      if (_driverNameController.text.isNotEmpty && selectedFilters.contains('Driver Name')) {
        queryParameters['name'] = _driverNameController.text;
      }

      // إرسال الطلب
      final Uri url = Uri.parse(filtered_trips).replace(queryParameters: queryParameters);

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> fetchedTrips = json.decode(response.body)['trips'];

        // إذا كان فلتر التقييم مفعلاً، يتم ترتيب الرحلات حسب التقييم من الأعلى إلى الأدنى
        if (selectedFilters.contains('Driver Rating')) {
          fetchedTrips.sort((a, b) {
            double ratingA = double.tryParse(a['averageRating'].toString()) ?? 0.0;
            double ratingB = double.tryParse(b['averageRating'].toString()) ?? 0.0;
            return ratingB.compareTo(ratingA); // ترتيب التقييم من الأعلى إلى الأدنى
          });
        }

        // إذا كان فلتر السعر مفعلاً، يتم ترتيب الرحلات حسب السعر بشكل تصاعدي
        if (selectedFilters.contains('Price')) {
          fetchedTrips.sort((a, b) => a['price'].compareTo(b['price']));
        }

        setState(() {
          _trips = fetchedTrips;
        });

        print("Trips fetched successfully: ${fetchedTrips.length} trips found.");
      } else {
        throw Exception('Failed to fetch trips: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
      _showMessage("Failed to fetch trips. Please try again.");
    }
  }



  void _searchTrips(List<String> selectedFilters) async {
    try {
      // التحقق من الحقول قبل تنفيذ البحث
      if (_departureController.text.isEmpty || _destinationController.text.isEmpty) {
        _showMessage("Please enter both departure and destination.");
        return; // إيقاف التنفيذ إذا كانت الحقول فارغة
      }

      // تنفيذ البحث باستخدام الفلاتر المختارة
      await fetchFilteredTrips(selectedFilters);

      // إذا كانت القائمة فارغة، يمكن عرض رسالة للمستخدم
      if (_trips.isEmpty) {
        _showMessage("No trips found matching your criteria.");
        return;
      }
    } catch (e) {
      print('Error in _searchTrips: $e');
      _showMessage("Failed to fetch trips. Please try again.");
    }
  }


  void updateTripsBasedOnTime() {
    final now = DateTime.now();
    final dateFormat = DateFormat("yyyy-MM-ddTHH:mm:ss.SSS'Z' h:mm a");

    setState(() {
      _trips.removeWhere((trip) {
        try {
          final dateTime = dateFormat.parse(
              trip['date'] + ' ' + trip['time'], true).toLocal();
          if (dateTime.isBefore(now)) {
            return true;
          }
        } catch (e) {
          print('Error parsing date: $e');
        }
        return false;
      });
    });
  }

  String formatDate(String dateTime) {
    final parsedDate = DateTime.parse(dateTime);
    return DateFormat('dd MMMM yyyy').format(parsedDate);
  }



  void _selectTime(BuildContext context) async {

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: analogousPink, // اللون الأساسي للوقت المختار
            colorScheme: ColorScheme.light().copyWith(
              primary:analogousPink, // تخصيص اللون الأساسي (الوقت المحدد)
              secondary:analogousPink, // تخصيص اللون الثانوي (عند التفاعل مع الأزرار)
            ),
            buttonTheme: ButtonThemeData(
              buttonColor:analogousPink, // تخصيص لون خلفية الأزرار
              textTheme: ButtonTextTheme.primary, // تخصيص لون النص في الأزرار
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }




  void _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor:analogousPink, // تحديد اللون الأساسي (التواريخ المختارة)
            colorScheme: ColorScheme.light().copyWith(
              primary: analogousPink, // اللون الأساسي (الزر الذي يحتوي على التواريخ المحددة)
              secondary:analogousPink, // اللون الثانوي عند التفاعل
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor:analogousPink), // تحديد لون النص
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  // وظيفة حفظ الفلاتر
  Future<void> _saveFiltersToPreferences() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString("departure", _departureController.text);
    await prefs.setString("destination", _destinationController.text);
    await prefs.setString("price", _priceController.text);
    await prefs.setString("carBrand", _selectedCarBrand ?? "");
    await prefs.setString("driverName", _driverNameController.text);

    await prefs.setString(
        "time",
        _selectedTime != null
            ? "${_selectedTime!.hour}:${_selectedTime!.minute}"
            : "");
    await prefs.setString(
        "date",
        _selectedDate != null
            ? "${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}"
            : "");
    await prefs.setString("driverRating", _driverRatingController.text);
    await prefs.setStringList("filters", _selectedFilters);

    _showMessage("Filters saved successfully!");
  }

  Future<void> _loadFiltersFromPreferences() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      _departureController.text = prefs.getString("departure") ?? "";
      _destinationController.text = prefs.getString("destination") ?? "";
      _priceController.text = prefs.getString("price") ?? "";
      _selectedCarBrand = prefs.getString("carBrand");
      _driverNameController.text = prefs.getString("driverName") ?? "";


      final timeString = prefs.getString("time");
      if (timeString != null && timeString.isNotEmpty) {
        final timeParts = timeString.split(":");
        _selectedTime = TimeOfDay(
            hour: int.parse(timeParts[0]), minute: int.parse(timeParts[1]));
      } else {
        _selectedTime = null;
      }

      final dateString = prefs.getString("date");
      if (dateString != null && dateString.isNotEmpty) {
        final dateParts = dateString.split("/");
        _selectedDate = DateTime(
          DateTime.now().year,
          int.parse(dateParts[1]),
          int.parse(dateParts[0]),
        );
      } else {
        _selectedDate = null;
      }

      _driverRatingController.text = prefs.getString("driverRating") ?? "";
      _selectedFilters = prefs.getStringList("filters") ?? [];
    });

    _showMessage("Filters loaded successfully!");
  }

  Future<void> _clearFiltersFromPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    setState(() {
      _departureController.clear();
      _destinationController.clear();
      _priceController.clear();
      _selectedCarBrand = null;
      _selectedTime = null;
      _selectedDate = null;
      _driverRatingController.clear();
      _selectedFilters.clear();
      _driverNameController.clear();

    });

    _showMessage("Filters cleared successfully!");
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  double calculateDialogHeight(List<String> options) {
    const double optionHeight = 50.0; // ارتفاع كل خيار
    const double buttonHeight = 60.0; // ارتفاع أزرار الموافقة والإلغاء
    const double maxDialogHeight = 400.0; // الحد الأقصى للارتفاع
    final double calculatedHeight = options.length * optionHeight + buttonHeight;
    return calculatedHeight > maxDialogHeight ? maxDialogHeight : calculatedHeight;
  }


  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final isArabic = languageProvider.isArabic;
    List<String> cities = isArabic ? _citiesArabic : _cities;
    List<String> filterOptions = isArabic ? _filterOptionsArabic : _filterOptions;
    return Scaffold(
      appBar: AppBar(
        title: Text(isArabic ? "البحث عن الرحلات" : "Search Trips", style: TextStyle(
            color: Colors.blueGrey,
            fontSize: 26,
            fontWeight: FontWeight.bold
        )),
        backgroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(
              Icons.save,
              color: Colors.blueGrey,
            ),
            onPressed: _saveFiltersToPreferences,
          ),
          IconButton(
            icon: Icon(
              Icons.restore,
              color: Colors.blueGrey,
            ),
            onPressed: _loadFiltersFromPreferences,
          ),
          IconButton(
            icon: Icon(Icons.delete,
              color: Colors.blueGrey,            ),
            onPressed: _clearFiltersFromPreferences,
          ),

        ],
      ),
      body: Scrollbar( // Remove isAlwaysShown property
        controller: _scrollController,  // Attach ScrollController
        child: SingleChildScrollView(
          controller: _scrollController,  // Attach controller here as well
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _buildAutoCompleteTextField(_departureController, isArabic ? "منطقة المغادرة" : "Departure Area"),
                _buildAutoCompleteTextField(_destinationController, isArabic ? "الوجهة" : "Destination"),
                SizedBox(height: 16),

                // Dropdown متعدد الاختيارات للفلاتر
                MultiSelectDialogField(
                  items: (isArabic ? _filterOptionsArabic : _filterOptions)  // تحديد الفلاتر بناءً على اللغة
                      .map((e) => MultiSelectItem<String>(e, e))
                      .toList(),
                  title: Text(isArabic ? "اختيار الفلاتر" : "Select Filters"),
                  selectedColor: triadicPink,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                    border: Border.all(color: Colors.blueGrey),
                  ),
                  buttonIcon: Icon(
                    Icons.filter_list,
                    color: triadicPink,
                  ),
                  buttonText: Text(
                    isArabic ? "اختيار الفلاتر" : "Select Filters",
                    style: TextStyle(color: Colors.blueGrey),
                  ),
                  cancelText: Text(
                    isArabic ? "إلغاء" : "CANCEL",
                    style: TextStyle(color: triadicPink), // لون النص في زر الإلغاء
                  ),
                  confirmText: Text(
                    isArabic ? "موافق" : "OK",
                    style: TextStyle(color:triadicPink), // لون النص في زر الموافقة
                  ),
                  dialogHeight: calculateDialogHeight(isArabic ? _filterOptionsArabic : _filterOptions),
                  onConfirm: (results) {
                    setState(() {
                      _selectedFilters = List<String>.from(results);
                      print("الفلاتر المختارة: $_selectedFilters"); // طباعة الفلاتر المختارة
                    });
                  },
                ),
                // فلتر نوع السيارة
                if (_selectedFilters.contains(isArabic ? "نوع السيارة" : "Car Type"))
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: DropdownButtonFormField<String>(
                      value: _selectedCarBrand,
                      items: _carBrands
                          .map((car) => DropdownMenuItem(
                        value: car,
                        child: Text(car),
                      ))
                          .toList(),
                      onChanged: (value) => setState(() {
                        _selectedCarBrand = value;
                      }),
                      decoration: InputDecoration(
                        labelText: isArabic ? "نوع السيارة" : "Car Type", //
                        prefixIcon: Icon(Icons.directions_car,color: triadicPink,),
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),

                // فلتر السعر
                if (_selectedFilters.contains(isArabic ? "السعر" : "Price"))
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: _buildTextField(_priceController, isArabic ? "السعر" : "Maximum Price", Icons.attach_money),
                  ),

                // فلتر عدد الركاب


                // فلتر الوقت
                if (_selectedFilters.contains(isArabic ? "الوقت" :"Time"))
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            _selectedTime == null
                                ? (isArabic ? "الوقت المفضل: أي وقت" : "Preferred Time: Any time")
                                : (isArabic
                                ? "الوقت المفضل: ${_selectedTime!.hour}:${_selectedTime!.minute}"
                                : "Preferred Time: ${_selectedTime!.hour}:${_selectedTime!.minute}"),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.access_time,color: triadicPink,),
                          onPressed: () => _selectTime(context),
                        ),
                      ],
                    ),
                  ),
                // فلتر التاريخ
                if (_selectedFilters.contains(isArabic ?"التاريخ":"Date"))
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            _selectedDate == null
                                ? (isArabic ? "التاريخ المفضل: أي تاريخ" : "Preferred Date: Any date")
                                : (isArabic
                                ? "التاريخ المفضل: ${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}"
                                : "Preferred Date: ${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}"),
                          ),

                        ),
                        IconButton(
                          icon: Icon(Icons.calendar_today,color: triadicPink,),
                          onPressed: () => _selectDate(context),
                        ),
                      ],
                    ),
                  ),
// داخل الكود الأساسي
                if (_selectedFilters.contains(isArabic ? "اسم السائق" : "Driver Name"))
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: _buildTextField(
                      _driverNameController, // TextEditingController لاسم السائق
                      isArabic ? "اسم السائق" : "Driver Name", // النص الظاهر بناءً على اللغة
                      Icons.person, // أيقونة الشخص
                    ),
                  ),

                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    _searchTrips(_selectedFilters); // استدعاء الدالة مع تمرير الفلاتر
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min, // بحيث يكون الزر بحجم النص والأيقونة معًا
                    children: [
                      Text(
                        isArabic ? "بحث" : "Search", // إذا كانت اللغة العربية مفعلة، سيتم عرض "بحث" بدلاً من "Search"
                        style: TextStyle(
                          fontSize: 22, // زيادة حجم الخط
                          color: Colors.white, // تغيير اللون إلى أبيض
                        ),
                      ),
                      SizedBox(width: 2), // مساحة بين الأيقونة والنص
                      Icon(
                        Icons.search, // أيقونة البحث
                        color: Colors.white, // لون الأيقونة
                      ),
                    ],
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueGrey,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 5, horizontal:10 ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 10,
                    shadowColor: Colors.black.withOpacity(0.3),
                  ),
                ),
                // عرض نتائج الرحلات هنا
                if (_trips.isNotEmpty)
                  SizedBox(height: 16),
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(), // لمنع التمرير داخل القائمة
                  itemCount: _trips.length,
                  itemBuilder: (context, index) {
                    final trip = _trips[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => TripDetailsScreen(trip: trip,emailP:widget.emailP,nameP: widget.nameP,phoneP:widget.phoneP,)),
                        );
                      },
                      child: Card(
                        color:Color.fromARGB(230, 217, 230, 241), // تحديد اللون الأسود للكارد
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        margin: EdgeInsets.symmetric(vertical: 8.0),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.teal.withOpacity(0.2),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.directions_car,
                                      color: primaryColor2,
                                      size: 40,
                                    ),
                                  ),
                                  SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [

                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween, // لتوزيع العناصر بين النصوص
                                          children: [
                                            Text(
                                              '${trip['name']}',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18,
                                                color: Color.fromARGB(
                                                    230, 4, 49, 81),
                                              ),
                                            ),
                                            FutureBuilder<Map<String, dynamic>?>(
                                              future: getAverageRating(trip['driverEmail']), // استدعاء دالة الحصول على التقييم
                                              builder: (context, snapshot) {
                                                if (snapshot.connectionState == ConnectionState.waiting) {
                                                  return Text(
                                                    'Loading...',
                                                    style: TextStyle(
                                                      fontSize: 18,
                                                      color: Color.fromARGB(230, 24, 83, 131),
                                                    ),
                                                  );
                                                } else if (snapshot.hasError) {
                                                  return Text(
                                                    'Error: ${snapshot.error}',
                                                    style: TextStyle(
                                                      fontSize: 18,
                                                      color: Color.fromARGB(230, 24, 83, 131),
                                                    ),
                                                  );
                                                } else if (snapshot.hasData) {
                                                  // تحويل قيمة التقييم من String إلى double
                                                  final averageRating = snapshot.data?['averageRating'];
                                                  if (averageRating != null) {
                                                    double rating = double.tryParse(averageRating.toString()) ?? 0.0;

                                                    int fullStars = rating.floor(); // النجوم الممتلئة
                                                    int halfStars = (rating - fullStars) >= 0.5 ? 1 : 0; // النجوم نصف الممتلئة
                                                    int emptyStars = 5 - fullStars - halfStars; // النجوم الفارغة

                                                    return Row(
                                                      children: [
                                                        // النجوم
                                                        Row(
                                                          children: [
                                                            for (int i = 0; i < fullStars; i++)
                                                              Icon(Icons.star, color: Colors.amber, size: 20),
                                                            for (int i = 0; i < halfStars; i++)
                                                              Icon(Icons.star_half, color: Colors.amber, size: 20),
                                                            for (int i = 0; i < emptyStars; i++)
                                                              Icon(Icons.star_border, color: Colors.amber, size: 20),
                                                          ],
                                                        ),
                                                        SizedBox(width: 8), // مسافة بين النجوم والرقم
                                                        // التقييم كرقم
                                                        // Text(
                                                        //   '$rating', // عرض التقييم كرقم
                                                        //   style: TextStyle(
                                                        //     fontSize: 18,
                                                        //     fontWeight: FontWeight.bold,
                                                        //     color: Color.fromARGB(230, 24, 83, 131),
                                                        //   ),
                                                        // ),
                                                      ],
                                                    );
                                                  } else {
                                                    return Row(
                                                      children: [
                                                        for (int i = 0; i < 5; i++)
                                                          Icon(Icons.star_border, color: Colors.amber, size: 20),
                                                      ],
                                                    );
                                                  }
                                                } else {
                                                  return Row(
                                                    children: [
                                                      for (int i = 0; i < 5; i++)
                                                        Icon(Icons.star_border, color: Colors.amber, size: 20),
                                                    ],
                                                  );
                                                }

                                              },
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 4),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween, // لتوزيع العناصر بين النصوص
                                          children: [
                                            Text.rich(
                                              TextSpan(
                                                children: [
                                                  TextSpan(
                                                    text: '${trip['from']} ', // النص الأول (من)
                                                    style: TextStyle(
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 16,
                                                      color: Color.fromARGB(
                                                          230, 50, 49, 49),
                                                    ),
                                                  ),
                                                  TextSpan(
                                                    text: 'to ', // كلمة "to" بلون مختلف
                                                    style: TextStyle(
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 16,
                                                      color: Colors.red, // تغيير اللون هنا
                                                    ),
                                                  ),
                                                  TextSpan(
                                                    text: '${trip['to']}',
                                                    style: TextStyle(
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 16,
                                                      color: Color.fromARGB(
                                                          230, 50, 49, 49),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Text(
                                              'Price: ${trip['price']}',
                                              style: TextStyle(
                                                color: Colors.grey[700],
                                                fontSize: 16,
                                              ),
                                            ),
                                          ],
                                        )

                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              Divider(color: Colors.grey),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.calendar_today, color: analogousPink),
                                      SizedBox(width: 4),
                                      Text(
                                        formatDate(trip['date']),
                                        style: TextStyle(color: Colors.black),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Icon(Icons.access_time, color: analogousPink),
                                      SizedBox(width: 4),
                                      Text(
                                        trip['time'] ?? 'N/A',
                                        style: TextStyle(color: Colors.black),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
                if (_trips.isEmpty)
                  Text(
                    isArabic ? "لم يتم العثور على رحلات" : "No trips found.",
                    style: TextStyle(
                      fontSize: 18,  // حجم الخط
                      fontWeight: FontWeight.bold,  // جعل الخط عريض
                      color: SecondryColor2,  // لون النص
                      shadows: [
                        Shadow(
                          offset: Offset(1.5, 1.5),  // اتجاه الظل
                          blurRadius: 3.0,  // تأثير ضبابي للظل
                          color: Colors.grey.withOpacity(0.5),  // لون الظل
                        ),
                      ],
                    ),
                  )

              ],
            ),
          ),
        ),
      ),
    );
  }
  Widget _buildTextField(

      TextEditingController controller, String label, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon,color:triadicPink ,),
          border: OutlineInputBorder(),
        ),
      ),
    );
  }

  // إضافة التكميل التلقائي في الحقول
  Widget _buildAutoCompleteTextField(TextEditingController controller, String label) {
    // الحصول على القيمة الحالية للغة
    final languageProvider = Provider.of<LanguageProvider>(context);
    final isArabic = languageProvider.isArabic;

    // تحديد قائمة المدن بناءً على اللغة
    List<String> cities = isArabic ? _citiesArabic : _cities;

    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: Autocomplete<String>(
        optionsBuilder: (TextEditingValue textEditingValue) {
          if (textEditingValue.text.isEmpty) {
            return const Iterable<String>.empty();
          } else {
            // تصفية المدن التي تبدأ بالحرف المدخل
            return cities.where((city) =>
                city.toLowerCase().startsWith(textEditingValue.text.toLowerCase()));
          }
        },
        onSelected: (String selectedCity) {
          controller.text = selectedCity;  // تعيين المدينة المحددة في الـ TextField
        },
        fieldViewBuilder: (BuildContext context, TextEditingController controller,
            FocusNode focusNode, VoidCallback onEditingComplete) {
          return TextFormField(
            controller: controller,
            focusNode: focusNode,
            decoration: InputDecoration(
              labelText: label,
              prefixIcon: Icon(Icons.location_on, color: triadicPink),
              border: OutlineInputBorder(),
            ),
            onEditingComplete: onEditingComplete,
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _departureController.dispose();
    _destinationController.dispose();
    _priceController.dispose();
    _driverRatingController.dispose();
    _driverRatingController.dispose();
    _scrollController.dispose(); // Dispose the ScrollController
    super.dispose();
  }
}


const Color SecondryColor = Color.fromARGB(230, 196, 209, 219);
//const Color SecondryColor2 = Color.fromARGB(230, 95, 190, 200);
const Color SecondryColor2 = Color.fromARGB(230, 130, 167, 175);
const Color complementaryPink = Color.fromARGB(230, 255, 153, 180);
const Color analogousPink = Color.fromARGB(230, 230, 100, 140);
const Color triadicPink = Color.fromARGB(230, 245, 115, 165);
const Color softPink = Color.fromARGB(230, 250, 170, 200);



const Color primaryColor = Color.fromARGB(230, 41, 84, 115); // اللون الأساسي
const Color primaryColor2 = Color.fromARGB(230, 20, 60, 115); //