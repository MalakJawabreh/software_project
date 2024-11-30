import 'package:flutter/material.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:provider/provider.dart';
import 'language_provider.dart';





class SearchTripsPage extends StatefulWidget {
  @override
  _SearchTripsPageState createState() => _SearchTripsPageState();

}

class _SearchTripsPageState extends State<SearchTripsPage> {

  final TextEditingController _departureController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _passengerCountController =
  TextEditingController();
  final TextEditingController _driverRatingController =
  TextEditingController();

  String? _selectedCarBrand;
  TimeOfDay? _selectedTime;
  DateTime? _selectedDate;
  List<String> _cities = [
    'Nablus', 'Ramallah', 'Jerusalem', 'Hebron', 'Gaza', 'Jenin', 'Tulkarm', 'Bethlehem', 'Qalqilya', 'Nablus',
    'Tubas', 'Salfit', 'Jericho', 'Ariha', 'Rafah', 'Deir al-Balah', 'Khan Younis', 'Zababdeh', 'Baqa al-Sharqiya',
    'Balata', 'Saffa', 'Dura', 'Bani Na’im'
  ];

// تحويل أسماء المدن للعربية إذا كانت اللغة العربية مفعلة

  List<String> _citiesArabic = [
    'نابلس', 'رام الله', 'القدس', 'الخليل', 'غزة', 'جنين', 'طولكرم', 'بيت لحم', 'قلقيلية', 'نابلس',
    'طوباس', 'سلفيت', 'أريحا', 'رفح', 'دير البلح', 'خان يونس', 'زببدة', 'باقة الشرقية',
    'بلعة', 'صفا', 'دورا', 'بني نعيم'
  ];

  List<String> _carBrands = [
    'Toyota', 'Honda', 'Ford', 'BMW', 'Mercedes', 'Chevrolet', 'Nissan', 'Audi', 'Volkswagen', 'Hyundai',
    'Kia', 'Lexus', 'Mazda', 'Subaru', 'Porsche', 'Jaguar', 'Land Rover', 'Chrysler', 'Tesla', 'Mitsubishi', 'Skoda'
  ];

// قائمة الفلاتر المتاحة
  List<String> _filterOptions = ['Price', 'Car Type', 'Passengers', 'Time', 'Date', 'Driver Rating'];

// الفلاتر باللغة العربية
  List<String> _filterOptionsArabic = ['السعر', 'نوع السيارة', 'الركاب', 'الوقت', 'التاريخ', 'تقييم السائق'];



  // المتغير لتخزين الفلاتر المختارة
  List<String> _selectedFilters = [];

  ScrollController _scrollController = ScrollController();  // ScrollController

  @override
  void initState() {
    super.initState();
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

  void _searchTrips() {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final isArabic = languageProvider.isArabic;
    List<String> activeFilters = [];

    if (_departureController.text.isNotEmpty) {
      activeFilters.add("From: ${_departureController.text}");
    }
    if (_destinationController.text.isNotEmpty) {
      activeFilters.add("To: ${_destinationController.text}");
    }
    if (_priceController.text.isNotEmpty && _selectedFilters.contains("Price")) {
      activeFilters.add("Price: ${_priceController.text}");
    }
    if (_selectedFilters.contains("Car Type") && _selectedCarBrand != null) {
      activeFilters.add("Car Type: $_selectedCarBrand");
    }
    if (_selectedFilters.contains("Passengers") && _passengerCountController.text.isNotEmpty) {
      activeFilters.add("Passengers: ${_passengerCountController.text}");
    }
    if (_selectedFilters.contains("Time") && _selectedTime != null) {
      activeFilters.add("Time: ${_selectedTime!.hour}:${_selectedTime!.minute}");
    }
    if (_selectedFilters.contains("Date") && _selectedDate != null) {
      activeFilters.add("Date: ${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}");
    }
    if (_selectedFilters.contains("Driver Rating") && _driverRatingController.text.isNotEmpty) {
      activeFilters.add("Driver Rating: ${_driverRatingController.text}");
    }

    // عرض النتائج في نافذة حوار
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Search Results"),
        content: Text(
          activeFilters.isNotEmpty
              ? "Filters Applied:\n${activeFilters.join('\n')}"
              : "No filters applied. Showing all trips.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              isArabic ? "موافق" : "OK", // تغيير النص بناءً على اللغة
              style: TextStyle(
                color: analogousPink, // لون النص
              ),
            ),
          ),
        ],
      ),
    );
  }

  // وظيفة حفظ الفلاتر
  void _saveFilters() {
    // يمكنك تخزين الفلاتر هنا
    final languageProvider = Provider.of<LanguageProvider>(context);
    final isArabic = languageProvider.isArabic;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Filters Saved"),
        content: Text("Filters have been saved successfully."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              isArabic ? "موافق" : "OK", // تغيير النص بناءً على اللغة
              style: TextStyle(
                color: analogousPink, // لون النص
              ),
            ),
          ),
        ],
      ),
    );
    print("Filters saved: $_selectedFilters");
  }

  // وظيفة إعادة التحميل
  void _reloadFilters() {
    setState(() {
      _selectedFilters.clear();
      _departureController.clear();
      _destinationController.clear();
      _priceController.clear();
      _passengerCountController.clear();
      _driverRatingController.clear();
      _selectedCarBrand = null;
      _selectedTime = null;
      _selectedDate = null;
    });
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
          color: Colors.white,
        )),
        backgroundColor: Colors.blueGrey,
        actions: [
          IconButton(
            icon: Icon(
              Icons.save,
              color: Colors.white, // تغيير لون الأيقونة إلى الأبيض
            ),
            onPressed: _saveFilters, // عند الضغط على زر الحفظ
          ),
          IconButton(
            icon: Icon(
              Icons.restore,
              color: Colors.white, // تغيير لون الأيقونة إلى الأبيض
            ),
            onPressed: _reloadFilters, // عند الضغط على زر إعادة التحميل
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
                  onConfirm: (results) {
                    setState(() {
                      _selectedFilters = List<String>.from(results);
                    });
                  },
                )
                ,

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
                if (_selectedFilters.contains(isArabic ?"الركاب":"Passengers"))
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: _buildTextField(_passengerCountController,isArabic ? "عدد الركاب" : "Number of Passengers", Icons.people),
                  ),

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

                // فلتر تقييم السائق
                if (_selectedFilters.contains(isArabic ?"تقييم السائق":"Driver Rating"))
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: _buildTextField(_driverRatingController,   isArabic ? "تقييم السائق (1-5)" : "Driver Rating (1-5)", Icons.star),
                  ),

                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _searchTrips,
                  child: Row(
                    mainAxisSize: MainAxisSize.min, // بحيث يكون الزر بحجم النص والأيقونة معًا
                    children: [

                      Text(
                        isArabic ? "بحث" : "Search", // إذا كانت اللغة العربية مفعلة، سيتم عرض "بحث" بدلاً من "Search"
                        style: TextStyle(
                          fontSize: 24, // زيادة حجم الخط
                          color: Colors.white, // تغيير اللون إلى أبيض
                        ),
                      ),

                      SizedBox(width: 10), // مساحة بين الأيقونة والنص

                      Icon(
                        Icons.search, // أيقونة البحث
                        color: Colors.white, // لون الأيقونة
                      ),
                    ],
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueGrey, // خلفية الزر
                    foregroundColor: Colors.white, // لون النص والأيقونة
                    padding: EdgeInsets.symmetric(vertical: 20, horizontal: 40), // إضافة padding أكبر
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30), // جعل الزر ذو حواف مدورة
                    ),
                    elevation: 10, // زيادة تأثير الظل
                    shadowColor: Colors.black.withOpacity(0.3), // تخصيص لون الظل
                  ),
                ),
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
    _passengerCountController.dispose();
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