import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'driver_dashboard.dart';
import 'driver_data_model.dart';
import 'theme_provider.dart'; // تأكد من استيراد ملف ThemeProvider بشكل صحيح
import 'onbording_screen.dart'; // تأكد من استيراد ملف OnboardingScreen بشكل صحيح
import 'language_provider.dart'; // استيراد الـ LanguageProvider
import 'package:firebase_core/firebase_core.dart'; // استيراد Firebase
void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // ضمان التهيئة الصحيحة للويدجت
  await Firebase.initializeApp(); // تهيئة Firebase
// إعداد Stripe

  Stripe.publishableKey ="pk_test_51QhdjdRtHpyhJq0TatCV5Bh2tDxu0rCmVQe9XhDGJ0OgK6RsIHjP579y9ovwusHnc6hPd5xxUBAoe60goiEP233v00pADsJo1U";
  await Stripe.instance.applySettings();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => LanguageProvider()), // LanguageProvider
        ChangeNotifierProvider(create: (context) => ThemeProvider()), // ThemeProvider
        ChangeNotifierProvider(create: (context) => DriverDataModel()), // DriverDataModel
      ],
      child: MyApp(),
    ),
  );
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
