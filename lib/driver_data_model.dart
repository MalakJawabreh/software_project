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
