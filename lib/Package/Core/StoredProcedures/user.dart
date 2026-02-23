
import '../../../Package/Core/api_access.dart';
import '../../../Package/Core/shared_preference.dart';
import '../general_const.dart';
import '../general_function.dart';
import '../insert_classes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import '../phone_number_formatter.dart';

class SpUser {
  static Future<dynamic> get({
    BuildContext? context,
    int? id,
    String? phoneNo,
    bool viewLoadingProcess = true,
    bool withDeletionDate = false,
  }) async {
    String cmd = "";
    dynamic result;

    // Get single user by ID
    if (id != null) {
      cmd = "SELECT * FROM [User] WHERE Id = $id And DeletionDate IS NULL";

      if (withDeletionDate) {
        cmd = "SELECT * FROM [User] WHERE Id = $id";
      }

      result = await ApiAccess.execCmd(RequestCmd(cmd), context: context);
      if (result == null) {
        return "User not found";
      }
      return result[0];
    }
    // Get user by phone and password (login)
    else if (phoneNo != null) {
      cmd =
          "SELECT * FROM [User] WHERE PhoneNumber = '${PhoneNumberFormatter.formatLibyanPhone(phoneNo)}' And DeletionDate IS NULL";
      if (withDeletionDate) {
        cmd = "SELECT * FROM [User] WHERE PhoneNumber = '${PhoneNumberFormatter.formatLibyanPhone(phoneNo)}'";
      }
      result = await ApiAccess.execCmd(RequestCmd(cmd), context: context, viewLoadingProcess: false);
      if (result == null) {
        if (kDebugMode) {
          print("Phone number or password not correct");
        }
        return null;
      } else if (result.length == 1) {
        return result[0];
      } else {
        return null;
      }
    }
    // Get all users
    else {
      cmd = "SELECT * FROM [User] where DeletionDate IS NULL";
      if (withDeletionDate) {
        cmd = "SELECT * FROM [User]";
      }
      result = await ApiAccess.execCmd(RequestCmd(cmd), context: context);
      if (result == null) {
        return "No users found";
      }
      return result;
    }
  }

  // INSERT - Create new user
  static Future<dynamic> insert(InsUser userDet, BuildContext context) async {
    String now = DateTime.now().toString();
    now = now.split(".")[0];

    String cmd =
        "INSERT INTO [User] (FullName, PhoneNumber, Password, FirebaseToken, CreationDate) VALUES ('${userDet.name}', '${userDet.phoneNumber}', '${userDet.password}', '${userDet.firebaseToken}', '$now')";

    return await ApiAccess.execCmd(RequestCmd(cmd), context: context);
  }

  // UPDATE - Update existing user
  static Future<dynamic> update({
    BuildContext? context,
    bool viewLoadingProcess = true,
    int? id,
    String? phoneNumber,
    String? fullName,
    String? password,
    String? fireBaseToken,
    DateTime? lastLogin,
    bool? admin,
    DateTime? deletionDate,
    bool? removeDeletionDate,
  }) async {
    // Build the SET parts dynamically
    final List<String> setParts = [];
    String nullWord = "NULL";
    if (phoneNumber != null) setParts.add("PhoneNumber  = '$phoneNumber'");
    if (fullName != null) setParts.add("FullName     = '${fullName.trim()}'");
    if (password != null) setParts.add("Password     = '$password'");
    if (fireBaseToken != null) setParts.add("FirebaseToken= '$fireBaseToken'");
    if (lastLogin != null) setParts.add("LastLogin    = '${GeneralFunctions.toSqlDate(lastLogin)}'");
    if (admin != null) setParts.add("Admin        = ${admin ? 1 : 0}");
    if (deletionDate != null) {setParts.add("DeletionDate = '${GeneralFunctions.toSqlDate(deletionDate)}'");}
    if (removeDeletionDate == true) {setParts.add("DeletionDate = $nullWord");}

    // Nothing to update
    if (setParts.isEmpty) return null;

    // Use provided id, otherwise fall back to the logged-in user's ID
    final int targetId = id ?? GeneralConstant.userLogged["ID"];

    final String updCmd = "UPDATE [User] SET ${setParts.join(', ')} WHERE ID = $targetId";

    dynamic res = await ApiAccess.execCmd(RequestCmd(updCmd), context: context, viewLoadingProcess: viewLoadingProcess);

    // Refresh the cached logged-in user if needed
    if(deletionDate == null){
      if (GeneralConstant.userLogged != null) {
        dynamic user = await SpUser.get(id: GeneralConstant.userLogged["ID"]);
        if (GeneralFunctions.ifMapOrNull(user, whenEmpty: null) != null) {
          GeneralConstant.userLogged = user;
          await SharedPreference.sharedPreferencesSetDynamic(SharedPreference.userLoggedKey, GeneralConstant.userLogged);
        }
      }
    }


    return res;
  }

  // DELETE - Remove user
  static Future<dynamic> delete({required int id, BuildContext? context}) async {
    String cmd = "DELETE FROM [User] WHERE Id = $id";

    return await ApiAccess.execCmd(RequestCmd(cmd), context: context);
  }
}
