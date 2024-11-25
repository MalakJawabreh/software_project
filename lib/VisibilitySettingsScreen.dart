import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'language_provider.dart';

class VisibilitySettingsScreen extends StatefulWidget {
  @override
  _VisibilitySettingsScreenState createState() =>
      _VisibilitySettingsScreenState();
}

class _VisibilitySettingsScreenState extends State<VisibilitySettingsScreen> {
  String _selectedOption = "Everyone"; // القيمة الافتراضية

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
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              ListTile(
                leading: const Icon(
                  Icons.public,
                  color: primaryColor,
                  size: 27, // حجم الأيقونة أكبر
                ),
                title: Text(
                  isArabic ? 'الجميع' : 'Everyone',
                  style: const TextStyle(
                    color: primaryColor,
                    fontWeight: FontWeight.w500,
                    fontSize: 18, // حجم الخط أكبر
                  ),
                ),
                trailing: Radio<String>(
                  value: 'Everyone',
                  groupValue: _selectedOption,
                  activeColor: primaryColor,
                  onChanged: (value) {
                    setState(() {
                      _selectedOption = value!;
                    });
                  },
                ),
                onTap: () {
                  setState(() {
                    _selectedOption = 'Everyone';
                  });
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.female,
                  color: primaryColor,
                  size: 35, // حجم الأيقونة أكبر
                ),
                title: Text(
                  isArabic ? 'الإناث فقط' : 'Females only',
                  style: const TextStyle(
                    color: primaryColor,
                    fontWeight: FontWeight.w500,
                    fontSize: 18, // حجم الخط أكبر
                  ),
                ),
                trailing: Radio<String>(
                  value: 'Females only',
                  groupValue: _selectedOption,
                  activeColor: primaryColor,
                  onChanged: (value) {
                    setState(() {
                      _selectedOption = value!;
                    });
                  },
                ),
                onTap: () {
                  setState(() {
                    _selectedOption = 'Females only';
                  });
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.male,
                  color: primaryColor,
                  size: 35, // حجم الأيقونة أكبر
                ),
                title: Text(
                  isArabic ? 'الذكور فقط' : 'Males only',
                  style: const TextStyle(
                    color: primaryColor,
                    fontWeight: FontWeight.w500,
                    fontSize: 18, // حجم الخط أكبر
                  ),
                ),
                trailing: Radio<String>(
                  value: 'Males only',
                  groupValue: _selectedOption,
                  activeColor: primaryColor,
                  onChanged: (value) {
                    setState(() {
                      _selectedOption = value!;
                    });
                  },
                ),
                onTap: () {
                  setState(() {
                    _selectedOption = 'Males only';
                  });
                },
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  print("Selected option: $_selectedOption");
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(200, 60), // الحجم الأدنى للزر
                  padding: const EdgeInsets.symmetric(
                      horizontal: 30, vertical: 15), // زيادة الحشوة الداخلية
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10), // حواف مستديرة
                  ),
                ),
                child: Text(
                  isArabic ? 'حفظ' : 'Save',
                  style: const TextStyle(
                    fontSize: 20, // حجم النص أكبر
                    fontWeight: FontWeight.bold,
                    color: SecondryColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

const Color SecondryColor = Color.fromARGB(230, 196, 209, 219);
const Color primaryColor = Color.fromARGB(230, 41, 84, 115);
