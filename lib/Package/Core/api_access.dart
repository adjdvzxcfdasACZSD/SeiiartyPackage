import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';
import '../Widget/loading_overlay.dart';
import 'app_theme.dart';
import 'enums.dart';

class ApiAccess {
  static String baseUrl = "https://seiiarty.tamam.ly";


  static Future<dynamic> connectApi(
      dynamic classSend,
      String url, {
        BuildContext? context,
        bool? viewLoadingProcess,
        String? tokenToRegisterOrReset,
      }) async {
    viewLoadingProcess ??= true;
    var bodyEncode = "";

    // Show loading if context provided and viewLoadingProcess is true
    if (context != null && viewLoadingProcess) {
      LoadingOverlay.show(context);
    }

    try {
      bodyEncode = jsonEncode(classSend);

      if (kDebugMode) {
        print("${AppTheme.colorCyan}#@#@#@#@#@#@#@#@ URL #@#@#@#@#@#@#@#@${AppTheme.colorReset}");
        print("${AppTheme.colorCyan}$url${AppTheme.colorReset}");
        print("${AppTheme.colorYellow}#@#@#@#@#@#@#@#@ body #@#@#@#@#@#@#@#@${AppTheme.colorReset}");
        print("${AppTheme.colorYellow}$bodyEncode${AppTheme.colorReset}");
      }

      Dio dio = Dio(
        BaseOptions(
          baseUrl: baseUrl + url,
          connectTimeout: const Duration(seconds: 20),
          receiveTimeout: const Duration(seconds: 60),
          headers: {HttpHeaders.contentTypeHeader: "application/json"},
        ),
      );

      Response response = await dio.post("", data: jsonEncode(classSend));

      if (kDebugMode) {
        print("${AppTheme.colorGreen}*************** URL ***************${AppTheme.colorReset}");
        print("${AppTheme.colorGreen}$url${AppTheme.colorReset}");
        print("${AppTheme.colorBlue}*************** body ***************${AppTheme.colorReset}");
        print("${AppTheme.colorBlue}$bodyEncode${AppTheme.colorReset}");
        print("${AppTheme.colorMagenta}*************** statusCode ***************${AppTheme.colorReset}");
        if (response.data is List) {
          print("${AppTheme.colorMagenta}${response.statusCode} length == ${response.data.length}${AppTheme.colorReset}");
        } else {
          print("${AppTheme.colorMagenta}${response.statusCode}${AppTheme.colorReset}");
        }
        print("${AppTheme.colorGreen}*************** data ***************${AppTheme.colorReset}");
        print("${AppTheme.colorGreen}${response.data}${AppTheme.colorReset}");
      }

      return response.data;

    } on DioException catch (e) {
      if (kDebugMode) {
        print('${AppTheme.colorRed} XXXXXXXXXXX connectApi <><><> Error <><><> XXXXXXXXXXX${AppTheme.colorReset}');
        print('${AppTheme.colorRed}$e${AppTheme.colorReset}');
        print('${AppTheme.colorRed} XXXXXXXXXXX connectApi <><><> Error Det <><><> XXXXXXXXXXX${AppTheme.colorReset}');
        if (e.response != null) print('${AppTheme.colorRed}${e.response?.data}${AppTheme.colorReset}');
        print("${AppTheme.colorYellow}*************** body ***************${AppTheme.colorReset}");
        print("${AppTheme.colorYellow}$bodyEncode${AppTheme.colorReset}");
      }

      if (e.response == null) rethrow;

      int statusCode = int.parse(e.response!.statusCode.toString());

      if (statusCode == 423) {
        if (kDebugMode) print(e.response!.data);
      }

    } finally {
      // Always hide — whether success or error
      if (context != null && viewLoadingProcess) {
        LoadingOverlay.hide();
      }
    }
  }


  static Future<dynamic> delete(BuildContext context, UserData userData) async {
    dynamic response = await connectApi(userData, "/Auth/Delete", context: context);
    return response[0];
  }

  static Future<dynamic> verifyOTP(BuildContext context, UserToVerifyOTP userToVerifyOTP) async {
    dynamic response = await connectApi(userToVerifyOTP, "/Auth/VerifyOTP", context: context);
    return response;
  }

  static Future<dynamic> sendOTP(BuildContext context, UserToSendOTP userToSendOTP) async {
    dynamic response = await connectApi(userToSendOTP, "/Auth/SendOTP", context: context);
    return response;
  }

  static Future<dynamic> getPing(BuildContext context, int id, {bool? viewLoadingProcess}) async {
    dynamic response = await connectApi(null, "/Main/Ping", context: context, viewLoadingProcess: viewLoadingProcess);
    return response;
  }

  static Future<dynamic> execStoredProcedure(BuildContext context, Request tamaRequest, {bool? viewLoadingProcess}) async {
    dynamic response = await connectApi(
      tamaRequest,
      "/Main/ExecStoredProcedure",
      context: context,
      viewLoadingProcess: viewLoadingProcess,
    );
    return response;
  }

  static Future<dynamic> execCmd(RequestCmd tamaRequestCmd, {BuildContext? context, bool? viewLoadingProcess}) async {
    dynamic response = await connectApi(
      tamaRequestCmd,
      "/Main/ExecCmd",
      context: context,
      viewLoadingProcess: viewLoadingProcess,
    );
    return response;
  }

  static Future<dynamic> execDoSomeThings(BuildContext context, Request tamaRequest, {bool? viewLoadingProcess}) async {
    dynamic response = await connectApi(
      tamaRequest,
      "/Main/DoSomeThings",
      context: context,
      viewLoadingProcess: viewLoadingProcess,
    );
    return response;
  }

  static Future<dynamic> notification(BuildContext context, ApiNotification tamaNotification, {bool? viewLoadingProcess}) async {
    dynamic response = await connectApi(
      tamaNotification,
      "/Main/Notification",
      context: context,
      viewLoadingProcess: viewLoadingProcess,
    );
    return response;
  }
}

enum SqlDbType {
  BigInt,
  Binary,
  Bit,
  Char,
  Date,
  DateTime,
  DateTime2,
  DateTimeOffset,
  Decimal,
  Float,
  Image,
  Int,
  Money,
  NChar,
  NText,
  Numeric,
  NVarchar,
  Real,
  SmallDateTime,
  SmallInt,
  SmallMoney,
  Text,
  Time,
  Timestamp,
  TinyInt,
  UniqueIdentifier,
  VarBinary,
  Varchar,
  Variant,
  Xml,
}

extension SqlDbTypeExtension on SqlDbType {
  int get value {
    switch (this) {
      case SqlDbType.BigInt:
        return 0;
      case SqlDbType.Binary:
        return 1;
      case SqlDbType.Bit:
        return 2;
      case SqlDbType.Char:
        return 3;
      case SqlDbType.DateTime:
        return 4;
      case SqlDbType.Decimal:
        return 5;
      case SqlDbType.Float:
        return 6;
      case SqlDbType.Image:
        return 7;
      case SqlDbType.Int:
        return 8;
      case SqlDbType.Money:
        return 9;
      case SqlDbType.NChar:
        return 10;
      case SqlDbType.NText:
        return 11;
      case SqlDbType.NVarchar:
        return 12;
      case SqlDbType.Real:
        return 13;
      case SqlDbType.UniqueIdentifier:
        return 14;
      case SqlDbType.SmallDateTime:
        return 15;
      case SqlDbType.SmallInt:
        return 16;
      case SqlDbType.SmallMoney:
        return 17;
      case SqlDbType.Text:
        return 18;
      case SqlDbType.Timestamp:
        return 19;
      case SqlDbType.TinyInt:
        return 20;
      case SqlDbType.VarBinary:
        return 21;

      default:
        throw Exception('Unknown SqlDbType: $this');
    }
  }
}

class UserToSendOTP {
  String? phoneNumber;
  String? appSignature;
  int? validityInSeconds;
  int? otpForWhat;

  UserToSendOTP(this.phoneNumber, this.appSignature, this.validityInSeconds, {this.otpForWhat});

  Map<String, dynamic> toJson() => {
    'PhoneNumber': phoneNumber,
    'AppSignature': appSignature,
    'ValidityInSeconds': validityInSeconds,
    'OtpForWhat': otpForWhat,
  };
}

class UserToVerifyOTP {
  String? otpId;
  String? otpCode;

  UserToVerifyOTP(this.otpId, this.otpCode);

  Map<String, dynamic> toJson() => {'OtpId': otpId, 'OtpCode': otpCode};
}

class UserData {
  String phoneNumber;
  String? password;
  int? expiredTokenMinutes;
  String? phoneToken;

  UserData(this.phoneNumber, {this.password, this.expiredTokenMinutes, this.phoneToken});

  Map<String, dynamic> toJson() => {
    'PhoneNumber': phoneNumber,
    'Password': password,
    'ExpiredTokenMinutes': expiredTokenMinutes,
    'PhoneToken': phoneToken,
  };
}

class MsgRes {
  int? id;
  int msgId;
  String? msgAr;
  String? msgEn;
  String? data;

  MsgRes(this.id, this.msgId, this.msgAr, this.msgEn, this.data);

  Map<String, dynamic> toJson() => {'ID': id, 'MsgId': msgId, 'MsgAr': msgAr, 'MsgEn': msgEn, 'Data': data};
}

class ApiNotification {
  Notify notify;
  Map<String, String>? data;
  String? token;
  EnumNotificationType notificationType;

  ApiNotification(this.notify, this.notificationType, {this.data, this.token});

  Map<String, dynamic> toJson() => {
    'Notification': notify.toJson(),
    'Data': data,
    'Token': token,
    'NotificationType': notificationType.value,
  };
}

class Notify {
  String title;
  String body;
  String? imageUrl;

  Notify(this.title, this.body, {this.imageUrl});

  Map<String, dynamic> toJson() => {'Title': title, 'Body': body, 'ImageUrl': imageUrl};
}

class Request {
  String spName;
  List<Para>? paras;

  Request(this.spName, {this.paras});

  Map<String, dynamic> toJson() => {'SpName': spName, 'Paras': paras};
}

class RequestCmd {
  String cmd;

  RequestCmd(this.cmd);

  Map<String, dynamic> toJson() => {'Cmd': cmd};
}

class Para {
  String name;
  String value;
  SqlDbType dataType;

  Para(this.name, this.value, this.dataType);

  Map<String, dynamic> toJson() => {'Name': name, 'Value': value, 'DataType': dataType.value};
}
