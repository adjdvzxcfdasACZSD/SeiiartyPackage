import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppLanguage extends ChangeNotifier {
  Locale _appLocale = Locale("en");

  Locale get appLocal => _appLocale;

  fetchLocale() async {
    var prefs = await SharedPreferences.getInstance();
    // var prefs = di.sl<SharedPreferences>();
    if (prefs.getString('language_code') == null) {
      _appLocale =Locale("en");
      return Null;
    }
    _appLocale = Locale(prefs.getString('language_code') ?? 'ar');
    return Null;
  }

  void changeLanguage(Locale type) async {
    var prefs = await SharedPreferences.getInstance();
    switch (type.languageCode) {
      case "ar":
        {
          _appLocale = const Locale("ar");
          await prefs.setString('language_code', 'ar');
          await prefs.setString('countryCode', '');
        }
        break;
      case "en":
        {
          _appLocale = const Locale("en");
          await prefs.setString('language_code', 'en');
          await prefs.setString('countryCode', '');
        }
        break;
      case "device":
        {
          _appLocale = const Locale("device");
          await prefs.setString('language_code', 'device');
          await prefs.setString('countryCode', '');
        }
        break;
      default:
        {
          _appLocale = Locale("en");
          await prefs.setString('language_code', "en");
          await prefs.setString('countryCode', '');
        }
        break;
    }
    notifyListeners();
  }
}
