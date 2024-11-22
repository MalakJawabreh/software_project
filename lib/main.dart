import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'onbording_screen.dart';

void main() {
  runApp(MyApp());
  //aya new commit
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light.copyWith(
    statusBarColor: Colors.transparent, // شفاف لتقليل التداخل
    statusBarIconBrightness: Brightness.dark, // تغيير الأيقونات لتكون داكنة
  ));
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Locale _locale = Locale('en', 'US'); // تعيين اللغة الافتراضية

  void _changeLanguage(String languageCode) {
    setState(() {
      _locale = languageCode == 'en' ? Locale('en', 'US') : Locale('ar', 'EG');
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      locale: _locale, // استخدام locale الجديد
      supportedLocales: [
        Locale('en', 'US'),
        Locale('ar', 'EG'),
      ],
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      home: OnboardingScreen(locale: _locale, changeLanguage: _changeLanguage), // تمرير اللغة للـ OnboardingScreen
    );
  }
}