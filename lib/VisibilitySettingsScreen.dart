import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'language_provider.dart';
import 'driver_data_model.dart'; // استيراد ملف الموديل

class VisibilitySettingsScreen extends StatefulWidget {
  @override
  final String email;
  const VisibilitySettingsScreen({required this.email, super.key});

  _VisibilitySettingsScreenState createState() =>
      _VisibilitySettingsScreenState();
}

class _VisibilitySettingsScreenState extends State<VisibilitySettingsScreen> {
  late DriverDataModel driverDataModel; // تعريف المتغير
  String _selectedOption = "Everyone"; // القيمة الافتراضية

  @override
  void initState() {
    super.initState();
    // الحصول على قيمة الرؤية (visibility) من الموديل
    driverDataModel = Provider.of<DriverDataModel>(context, listen: false);
    // تهيئة القيمة الافتراضية استنادًا إلى البيانات من الموديل
    String? visibility = driverDataModel.getVisibilityByEmail(widget.email);
    if (visibility != null) {
      _selectedOption = visibility; // تعيين القيمة المستردة كقيمة افتراضية
    }
  }
  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final isArabic = languageProvider.isArabic;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isArabic ? 'إعدادات الرؤية' : 'Visibility Settings',
          style: const TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
        ),
        backgroundColor: SecondryColor,
      ),
      body: Container(
        decoration: const BoxDecoration(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isArabic ? 'اختيارات الرؤية' : 'Visibility Options',
                style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: primaryColor),
              ),
              const SizedBox(height: 20),
              _buildOptionTile(
                icon: Icons.public,
                title: isArabic ? 'الجميع' : 'Everyone',
                value: 'Everyone',
              ),
              const Divider(),
              _buildOptionTile(
                icon: Icons.female,
                title: isArabic ? 'الإناث فقط' : 'Females only',
                value: 'Females only',
              ),
              const Divider(),
              _buildOptionTile(
                icon: Icons.male,
                title: isArabic ? 'الذكور فقط' : 'Males only',
                value: 'Males only',
              ),
              const SizedBox(height: 40),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    print("Selected option: $_selectedOption");
                    driverDataModel.setVisibility(widget.email, _selectedOption);

                    // التحقق من القيمة التي تم حفظها
                    final savedVisibility = driverDataModel.getVisibilityByEmail(widget.email);
                    print(
                        "Saved visibility:  $savedVisibility for email: ${widget.email}");
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(200, 60), // الحجم الأدنى للزر
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 15), // زيادة الحشوة الداخلية
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15), // حواف مستديرة
                    ),
                    elevation: 5, // تأثير الظل
                  ),
                  child: Text(
                    isArabic ? 'حفظ' : 'Save',
                    style: const TextStyle(
                      fontSize: 18, // حجم النص أكبر
                      fontWeight: FontWeight.bold,
                      color: SecondryColor,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // دالة بناء قائمة الخيارات
  Widget _buildOptionTile({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: primaryColor,
        size: 35, // حجم الأيقونة أكبر
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: primaryColor,
          fontWeight: FontWeight.w500,
          fontSize: 18, // حجم الخط أكبر
        ),
      ),
      trailing: Radio<String>(
        value: value,
        groupValue: _selectedOption,
        activeColor: primaryColor,
        onChanged: (newValue) {
          setState(() {
            _selectedOption = newValue!;
          });
        },
      ),
      onTap: () {
        setState(() {
          _selectedOption = value;
        });
      },
    );
  }
}

//const Color SecondryColor = Color.fromARGB(230, 196, 209, 219);
//const Color primaryColor = Color.fromARGB(230, 41, 84, 115);
const Color primaryColor = Color(0xFF296873); // Color from your previous design
const Color accentColor = Color(0xFF00796B); // Accent color for action items like buttons
const Color SecondryColor = Color(0xFFE1F5FE); // A lighter background color for cards and inputs

