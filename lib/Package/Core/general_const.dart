import 'package:flutter/material.dart';

class AppValues {
  String version;
  String appUrl;

  AppValues(this.version, this.appUrl);
}

class GeneralConstant {
  static String appName = "Seiiarty";
  static AppValues appValues = AppValues("", "");
  static Widget? homeScreen;
  static Widget? loginScreen;
  static Widget? addScreen;
  static dynamic userLogged;
  static String firebaseToken = "";
  static dynamic setupTable;
  static String unknownError = "Unknown error";
  static String noInternetConnectionError = "No internet connection";
  static String privacyPolicyUrl = "";
  static bool isConnected = false;
  static bool darkTheme = true;
  static String baseUrl = "https://Seiiarty.tamam.ly";
}
