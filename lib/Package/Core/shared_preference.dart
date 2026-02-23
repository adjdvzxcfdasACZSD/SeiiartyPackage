import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreference{
  static String userLoggedKey = "userLogged";
  static String firebaseTokenKey = "firebaseToken";


  static Future<void> sharedPreferencesSetListDynamic(String key, List<dynamic> value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String valueJson = jsonEncode(value);
    prefs.setString(key, valueJson);
  }

  static Future<List<dynamic>> sharedPreferencesGetListDynamic(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? valueJson = prefs.getString(key);
    if (valueJson == null) return [];
    List<dynamic> list = json.decode(valueJson) as List;
    return list;
  }

  static Future<void> sharedPreferencesSetDynamic(String key, dynamic value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String valueJson = jsonEncode(value);
    prefs.setString(key, valueJson);
  }

  static Future<dynamic> sharedPreferencesGetDynamic(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? valueJson = prefs.getString(key);
    if (valueJson == null) return null;
    dynamic list = json.decode(valueJson);
    return list;
  }

  static Future<void> sharedPreferencesSetString(String key, String value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(key, value);
  }

  static Future<String?> sharedPreferencesGetString(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? value = prefs.getString(key);
    if (value == null) return null;
    return value;
  }

  static Future<void> sharedPreferencesSetInt(String key, int value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(key, value.toString());
  }

  static Future<int?> sharedPreferencesGetInt(String key) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? value = prefs.getString(key);
      if (value == null) return null;

      int clinicId=int.parse(value);
      return clinicId;
    }catch(e){
      return null;
    }
  }

  static Future<void> sharedPreferencesSetBool(String key, bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(key, value.toString());
  }

  static Future<bool?> sharedPreferencesGetBool(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? value = prefs.getString(key);
    if (value == null) return null;
    return bool.parse(value);
  }
}