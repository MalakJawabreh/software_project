import 'package:flutter/material.dart';

class LanguageSelectionPage extends StatelessWidget {
  final Function(Locale) onLanguageSelected;

  LanguageSelectionPage({required this.onLanguageSelected});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          Localizations.localeOf(context).languageCode == 'en'
              ? "Select Language"
              : "اختر اللغة",
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            Localizations.localeOf(context).languageCode == 'en'
                ? "Choose your preferred language:"
                : "اختر اللغة التي تفضلها:",
            style: TextStyle(fontSize: 20),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => onLanguageSelected(Locale('en')),
            child: Text("English"),
          ),
          ElevatedButton(
            onPressed: () => onLanguageSelected(Locale('ar')),
            child: Text("العربية"),
          ),
        ],
      ),
    );
  }
}
