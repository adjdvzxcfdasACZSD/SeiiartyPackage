import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:seiiarty_package/Package/Core/shared_preference.dart';
import 'package:url_launcher/url_launcher.dart';

import 'app_theme.dart';
import 'common_Dialogs.dart';
import 'general_const.dart';

class GeneralFunctions {
  static dynamic ifMapOrNull(dynamic value, {dynamic whenEmpty}) {
    whenEmpty ??= "";
    if (value is Map || value == null) {
      return whenEmpty;
    }
    return value;
  }

  static String hashPassword(String password) {
    final bytes = utf8.encode(password);
    final hash = sha256.convert(bytes);
    return hash.toString();
  }

  static bool isValidLibyanPhone(String number) {
    if (number.length != 10) return false;
    return number.startsWith('091') || number.startsWith('092') || number.startsWith('093') || number.startsWith('094');
  }

  static void showSnackBar(BuildContext context, String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  static void cachedError(BuildContext context, Object e) {
    if (kDebugMode) {
      print("Unknown Error ==><><><><>===  $e");
      if (context.mounted) print(context.widget.runtimeType);
    }
    String message = "$e";
    if (message.length >= 4) message = message.substring(message.length - 4);

    if (message == "-401") {
      if (context.mounted) {
        CommonDialogs().snackBar(
          context,
          msg: "Token Expired, Please Enter Your Phone Number And Password To Login",
          color: AppTheme.msgSnackInfoColor,
        );
      }
      return;
    }
    if (context.mounted) CommonDialogs().snackBar(context);
  }

  static Widget loadingCenter({Color? color}) {
    color ??= AppTheme.mainColor;
    return Center(
      child: SizedBox(width: 30, height: 30, child: CircularProgressIndicator(color: color)),
    );
  }

  static Future<void> callPhone(BuildContext context, String phoneNumber) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    await launchUrl(launchUri);
  }

  static Future<void> launchLink(BuildContext context, String url) async {
    if (url == "") {
      CommonDialogs().snackBar(context, msg: "URL Is Empty");
      return;
    }
    if (Platform.isAndroid) {
      String encodedUrl = Uri.encodeFull(url);
      await launch(encodedUrl);
    } else {
      if (await canLaunch(url)) {
        await launch(url);
      }
    }
  }

  static Future<void> loadUserData(String screen, {bool getFirebaseToken = false}) async {
    if (getFirebaseToken) {
      GeneralConstant.firebaseToken = (await SharedPreference.sharedPreferencesGetString(SharedPreference.firebaseTokenKey))!;
    } else {
      GeneralConstant.userLogged ??= await SharedPreference.sharedPreferencesGetDynamic(SharedPreference.userLoggedKey);
      if (GeneralConstant.firebaseToken == "" || GeneralConstant.firebaseToken.isEmpty) {
        GeneralConstant.firebaseToken = (await SharedPreference.sharedPreferencesGetString(SharedPreference.firebaseTokenKey))!;
      }
    }

    if (kDebugMode) {
      print("${AppTheme.colorYellow}====================On $screen======================${AppTheme.colorReset}");
      print("${AppTheme.colorCyan}==========================================");
      print("userLogged value: ${GeneralConstant.userLogged}");
      print("firebaseToken value: ${GeneralConstant.firebaseToken}");
      print("==========================================${AppTheme.colorReset}");
    }
  }

  static String toSqlDate(DateTime dt) {
    return "${dt.year.toString().padLeft(4, '0')}-"
        "${dt.month.toString().padLeft(2, '0')}-"
        "${dt.day.toString().padLeft(2, '0')} "
        "${dt.hour.toString().padLeft(2, '0')}:"
        "${dt.minute.toString().padLeft(2, '0')}:"
        "${dt.second.toString().padLeft(2, '0')}";
  }
}
