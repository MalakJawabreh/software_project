import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'language_provider.dart';

class BlockedContactsScreen extends StatefulWidget {
  @override
  _BlockedContactsScreenState createState() => _BlockedContactsScreenState();
}

class _BlockedContactsScreenState extends State<BlockedContactsScreen> {
  List<String> blockedContacts = [];
  final TextEditingController contactController = TextEditingController();
  String contactType = "name"; // Default to 'name' for input type selection

  @override
  void initState() {
    super.initState();
    loadBlockedContacts();
  }

  Future<void> saveBlockedContacts() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('blockedContacts', blockedContacts);
  }

  Future<void> loadBlockedContacts() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      blockedContacts = prefs.getStringList('blockedContacts') ?? [];
    });
  }

  void addContact(String contact) {
    if (contact.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            Provider.of<LanguageProvider>(context, listen: false).isArabic
                ? 'الرجاء إدخال بيانات صحيحة'
                : 'Please enter valid data',
          ),
        ),
      );
      return;
    }
    if (blockedContacts.contains(contact)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            Provider.of<LanguageProvider>(context, listen: false).isArabic
                ? 'جهة الاتصال مضافة مسبقًا'
                : 'Contact already blocked',
          ),
        ),
      );
      return;
    }
    setState(() {
      blockedContacts.add(contact);
    });
    saveBlockedContacts();
    contactController.clear();
  }

  Future<void> confirmDelete(int index) async {
    bool? confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          Provider.of<LanguageProvider>(context, listen: false).isArabic
              ? 'تأكيد الحذف'
              : 'Confirm Deletion',
        ),
        content: Text(
          Provider.of<LanguageProvider>(context, listen: false).isArabic
              ? 'هل أنت متأكد من حذف جهة الاتصال؟'
              : 'Are you sure you want to delete this contact?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              Provider.of<LanguageProvider>(context, listen: false).isArabic
                  ? 'إلغاء'
                  : 'Cancel',
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              Provider.of<LanguageProvider>(context, listen: false).isArabic
                  ? 'حذف'
                  : 'Delete',
            ),
          ),
        ],
      ),
    );
    if (confirm ?? false) {
      setState(() {
        blockedContacts.removeAt(index);
      });
      saveBlockedContacts();
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
          style: const TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
        ),
        backgroundColor: primaryColor,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isArabic ? 'أضف جهة الاتصال المحظورة' : 'Add Blocked Contact',
              style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: primaryColor),
            ),
            const SizedBox(height: 20),

            // Selection for contact type (Name or Number)
            Row(
              children: [
                Radio<String>(
                  value: 'name',
                  groupValue: contactType,
                  onChanged: (value) {
                    setState(() {
                      contactType = value!;
                    });
                  },
                  activeColor: accentColor,
                ),
                Text(
                  isArabic ? 'الاسم' : 'Name',
                  style: TextStyle(color: primaryColor),
                ),
                const SizedBox(width: 20),
                Radio<String>(
                  value: 'number',
                  groupValue: contactType,
                  onChanged: (value) {
                    setState(() {
                      contactType = value!;
                    });
                  },
                  activeColor: accentColor,
                ),
                Text(
                  isArabic ? 'الرقم' : 'Number',
                  style: TextStyle(color: primaryColor),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // TextField for adding contact (name or number)
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.grey[100],
              ),
              child: TextField(
                controller: contactController,
                decoration: InputDecoration(
                  labelText: contactType == 'name'
                      ? (isArabic ? 'إضافة الاسم' : 'Add Name')
                      : (isArabic ? 'إضافة الرقم' : 'Add Number'),
                  labelStyle: TextStyle(color: primaryColor),
                  hintText: contactType == 'name'
                      ? (isArabic ? 'أدخل اسم جهة الاتصال' : 'Enter contact name')
                      : (isArabic ? 'أدخل رقم جهة الاتصال' : 'Enter contact number'),
                  hintStyle: TextStyle(color: Colors.grey),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.add, color: primaryColor),
                    onPressed: () {
                      addContact(contactController.text);
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                ),
                keyboardType: contactType == 'number'
                    ? TextInputType.phone
                    : TextInputType.text,
              ),
            ),
            const SizedBox(height: 20),

            // Blocked contacts list
            Expanded(
              child: ListView.separated(
                separatorBuilder: (context, index) => Divider(color: Colors.grey),
                itemCount: blockedContacts.length,
                itemBuilder: (context, index) {
                  return Dismissible(
                    key: Key(blockedContacts[index]),
                    onDismissed: (direction) {
                      confirmDelete(index);
                    },
                    background: Container(
                      color: Colors.redAccent,
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    child: Card(
                      margin: const EdgeInsets.symmetric(vertical: 10),
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 15),
                        title: Text(
                          blockedContacts[index],
                          style: const TextStyle(
                            color: primaryColor,
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                          ),
                        ),
                        trailing: IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            confirmDelete(index);
                          },
                        ),
                      ),
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

const Color primaryColor = Color(0xFF296873); // Color from your previous design
const Color accentColor = Color(0xFF00796B); // Accent color for action items like buttons
const Color secondaryColor = Color(0xFFE1F5FE); // A lighter background color for cards and inputs
