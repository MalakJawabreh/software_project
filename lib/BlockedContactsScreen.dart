import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'language_provider.dart';

class BlockedContactsScreen extends StatefulWidget {
  @override
  _BlockedContactsScreenState createState() => _BlockedContactsScreenState();
}

class _BlockedContactsScreenState extends State<BlockedContactsScreen> {
  final List<String> blockedContacts = [];
  final TextEditingController contactController = TextEditingController();

  void addContact(String contact) {
    if (contact.isNotEmpty) {
      setState(() {
        blockedContacts.add(contact);
      });
      contactController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final isArabic = languageProvider.isArabic;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isArabic ? 'جهات الاتصال المحظورة' : 'Blocked Contacts',
          style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
        ),
        backgroundColor: SecondryColor,

      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: contactController,
              decoration: InputDecoration(
                labelText: isArabic ? 'إضافة جهة اتصال' : 'Add Contact',
                labelStyle: TextStyle(color: primaryColor,fontSize: 17), // تغيير لون النص
                suffixIcon: IconButton(
                  icon: Icon(Icons.add),
                  onPressed: () {
                    addContact(contactController.text);
                  },
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: blockedContacts.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(
                      blockedContacts[index],
                      style: TextStyle(
                          color: primaryColor, // لون النص الأساسي
                          fontWeight: FontWeight.w500),
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        setState(() {
                          blockedContacts.removeAt(index);
                        });
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

const Color SecondryColor = Color.fromARGB(230, 196, 209, 219);
const Color primaryColor = Color.fromARGB(230, 41, 84, 115);
