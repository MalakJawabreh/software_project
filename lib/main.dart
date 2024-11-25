import 'package:flutter/material.dart';
<<<<<<< HEAD
import 'package:provider/provider.dart';
=======
>>>>>>> e8bf6cf019488648af2a0ab0bd8063adfcc0ba6b
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'theme_provider.dart'; // تأكد من استيراد ملف ThemeProvider بشكل صحيح
import 'onbording_screen.dart'; // تأكد من استيراد ملف OnboardingScreen بشكل صحيح
import 'language_provider.dart'; // استيراد الـ LanguageProvider

void main() {
<<<<<<< HEAD
  runApp(

    ChangeNotifierProvider(
      create: (context) => LanguageProvider(), // إضافة LanguageProvider
      child: ChangeNotifierProvider(
        create: (context) => ThemeProvider(), // ThemeProvider
        child: MyApp(),
      ),
    ),

  );
=======
  runApp(MyApp());
  //aya new commit
>>>>>>> e8bf6cf019488648af2a0ab0bd8063adfcc0ba6b
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
  @override
  Widget build(BuildContext context) {
    return Consumer2<LanguageProvider, ThemeProvider>(
      builder: (context, languageProvider, themeProvider, child) {
        return Directionality(
          textDirection: languageProvider.locale.languageCode == 'ar'
              ? TextDirection.rtl
              : TextDirection.ltr,
          child: MaterialApp(
            locale: languageProvider.locale, // استخدام locale من LanguageProvider
            supportedLocales: [
              Locale('en', 'US'),
              Locale('ar', 'EG'),
            ],
            localizationsDelegates: [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            themeMode: themeProvider.themeMode, // تمكين وضع السمة (Light/Dark)
            theme: ThemeData.light(), // سمة الوضع الفاتح
            darkTheme: ThemeData.dark(), // سمة الوضع الداكن
            home: OnboardingScreen(
              locale: languageProvider.locale,
              changeLanguage: languageProvider.changeLanguage,
              changeTheme: themeProvider.toggleTheme,
            ),
          ),
        );
      },
    );
  }
}
