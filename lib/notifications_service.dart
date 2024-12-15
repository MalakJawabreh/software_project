import 'package:flutter/material.dart';

class NotificationService {
  static Map<String, List<String>> _userNotifications = {}; // خرسانة للمستخدمين والملاحظات الخاصة بهم
  static Map<String, int> _userNotificationCount = {}; // عدد الإشعارات لكل مستخدم

  // إضافة إشعار جديد للمستخدم بناءً على البريد الإلكتروني
  static void addNotification(String email, String message) {
    if (!_userNotifications.containsKey(email)) {
      _userNotifications[email] = [];
      _userNotificationCount[email] = 0;
    }
    _userNotifications[email]!.add(message);
    _userNotificationCount[email] = (_userNotificationCount[email] ?? 0) + 1;
  }

  // مسح الإشعارات للمستخدم بناءً على البريد الإلكتروني
  static void clearNotifications(String email) {
    _userNotifications[email]?.clear();
    _userNotificationCount[email] = 0;
  }

  // الحصول على الإشعارات للمستخدم بناءً على البريد الإلكتروني
  static List<String>? getNotifications(String email) {
    return _userNotifications[email];
  }

  // الحصول على عدد الإشعارات للمستخدم بناءً على البريد الإلكتروني
  static int getNotificationCount(String email) {
    return _userNotificationCount[email] ?? 0;
  }
}
