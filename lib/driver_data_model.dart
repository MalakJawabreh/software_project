import 'package:flutter/foundation.dart';
import 'dart:io';

class DriverDataModel with ChangeNotifier {

  String? fullName;
  String? email;
  String? password;
  String? phoneNumber;
  String? gender;
  String? role;
  String? carNumber;
  String? carType;

  // بيانات السيارة
  String? carMake;
  String? plateNumber;

  // خرسانة للمستخدمين
  static Map<String, List<UserLocation>> _userLocations = {};

  // إضافة إشعار جديد للمستخدم بناءً على البريد الإلكتروني
   void setLocation(String email, String location, bool visible) {
    // إذا كان البريد الإلكتروني غير موجود، نقوم بإضافته مع قائمة جديدة
    if (_userLocations[email] == null) {
      _userLocations[email] = [];
    }

    // إضافة الموقع الجديد
    _userLocations[email]!.add(UserLocation(location: location, visible: visible));
  }

  // الحصول على الموقع الحالي للمستخدم بناءً على البريد الإلكتروني
  String? getLocationByEmail(String email) {
    // التحقق إذا كان هناك مواقع مسجلة لهذا البريد الإلكتروني
    if (_userLocations[email] != null && _userLocations[email]!.isNotEmpty) {
      // إذا كان هناك مواقع، نعود بالموقع الأول (أو الأخير إذا أردت)
      return _userLocations[email]!.last.location; // أو يمكنك استخدام first إذا كنت تريد الموقع الأول
    }
    return null; // إذا لم يكن هناك مواقع مسجلة، نعيد null
  }

  // تخزين الرؤية للمستخدمين
  static Map<String, UserVisibility> _userVisibility = {};

// إضافة أو تحديث الرؤية للمستخدم بناءً على البريد الإلكتروني
  void setVisibility(String email, String visibility) {
    _userVisibility[email] = UserVisibility(visibility: visibility);
  }
// استرجاع نوع الرؤية بناءً على البريد الإلكتروني
  String? getVisibilityByEmail(String email) {
    if (_userVisibility.containsKey(email)) {
      return _userVisibility[email]!.visibility;
    }
    return null; // إذا لم يكن هناك رؤية مسجلة
  }
  // تخزين الرؤية للمستخدمين
  static Map<String, UserVisibilitylocation> _userVisibilitylocation = {};

  void setVisibilitylocation(String email, bool visibilitylocation) {
    _userVisibilitylocation[email] = UserVisibilitylocation(visibilitylocation: visibilitylocation);
  }

  bool? getVisibilitylocation(String email) {
    if (_userVisibilitylocation.containsKey(email)) {
      return _userVisibilitylocation[email]!.visibilitylocation;
    }
    return null; // إذا لم يكن هناك رؤية مسجلة
  }

  late String location;
  late String emailuser;
  late bool visible = false;

  // بيانات التأمين
  String? insuranceExpirationDate;
  File? InsuranceImage;

  // بيانات الرخصة
  String? licenseExpirationDate;
  File? licenseImage;

  // صورة البروفايل
  File? profileImage;

  // تحديث بيانات السائق
  void setUser({
    required String fullName,
    required String email,
    required String password,
    required String phoneNumber,
    required String gender,
    required String role,
  }) {
    this.fullName = fullName;
    this.email = email;
    this.password = password;
    this.phoneNumber = phoneNumber;
    this.gender = gender;
    this.role = role;
    notifyListeners();
  }

  // تحديث بيانات السيارة
  void setCarDetails({
    required String carMake,
    required String plateNumber,
  }) {
    this.carMake = carMake;
    this.plateNumber = plateNumber;
    notifyListeners();
  }


  // تحديث بيانات التأمين
  void setInsuranceDetails({
    required String expirationDate,
    required File? InsuranceImage,
  }) {
    this.insuranceExpirationDate = expirationDate;
    this.InsuranceImage = InsuranceImage;
    notifyListeners();
  }

  // تحديث بيانات الرخصة
  void setLicenseDetails({
    required String expirationDate,
    required File? licenseImage,

  }) {
    this.licenseExpirationDate = expirationDate;
    this.licenseImage = licenseImage;
    notifyListeners();
  }

  // تحديث صورة البروفايل
  void setProfileImage(File image) {
    this.profileImage = image;
    notifyListeners();
  }


}

// كائن لتخزين بيانات الموقع والحالة
class UserLocation {
  String location;
  bool visible;

  UserLocation({
    required this.location,
    required this.visible,
  });
}

class UserVisibility {
  final String visibility; // نوع الرؤية: Everyone, Females only, Males only

  UserVisibility({required this.visibility});
}


class UserVisibilitylocation {
  final bool visibilitylocation; // نوع الرؤية: Everyone, Females only, Males only

  UserVisibilitylocation({required this.visibilitylocation});
}
