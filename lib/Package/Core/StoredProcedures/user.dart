
import '../api_access.dart';
import '../general_const.dart';
import '../general_function.dart';
import '../insert_classes.dart';
import 'package:flutter/material.dart';

import '../phone_number_formatter.dart';
import '../shared_preference.dart';

class SpUser {
  // ── GET ─────────────────────────────────────────────────
  static Future<dynamic> get({
    BuildContext? context,
    int?          id,
    String?       phoneNo,
    int?          excludeStoreId,   // ← NEW: exclude users already in this store
    bool          viewLoadingProcess = true,
    bool          withDeletionDate   = false,
  }) async {
    String    cmd;
    dynamic   result;

    // ── Get single user by ID ──────────────────────────────
    if (id != null) {
      cmd = withDeletionDate
          ? "SELECT * FROM [User] WHERE ID = $id"
          : "SELECT * FROM [User] WHERE ID = $id AND DeletionDate IS NULL";

      result = await ApiAccess.execCmd(RequestCmd(cmd), context: context);
      if (result == null) return "User not found";
      return result[0];
    }

    // ── Get user by phone ──────────────────────────────────
    else if (phoneNo != null) {
      final formatted = PhoneNumberFormatter.formatLibyanPhone(phoneNo);
      cmd = withDeletionDate
          ? "SELECT * FROM [User] WHERE PhoneNumber = '$formatted'"
          : "SELECT * FROM [User] WHERE PhoneNumber = '$formatted' AND DeletionDate IS NULL";

      result = await ApiAccess.execCmd(
        RequestCmd(cmd),
        context:            context,
        viewLoadingProcess: false,
      );
      if (result == null) return null;
      return result.length == 1 ? result[0] : null;
    }

    // ── Get ALL users ──────────────────────────────────────
    else {
      final List<String> conditions = [];

      if (!withDeletionDate) conditions.add("[User].DeletionDate IS NULL");

      // exclude users who are already active managers of the given store
      if (excludeStoreId != null) {
        conditions.add(
          "[User].ID NOT IN ("
              "  SELECT UserId FROM StoreUser"
              "  WHERE StoreId = $excludeStoreId"
              "  AND DeletionDate IS NULL"
              ")",
        );
      }

      final String where = conditions.isEmpty
          ? ""
          : "WHERE ${conditions.join(' AND ')}";

      cmd = "SELECT * FROM [User] $where";

      result = await ApiAccess.execCmd(
        RequestCmd(cmd),
        context:            context,
        viewLoadingProcess: viewLoadingProcess,
      );

      if (result == null) return "No users found";
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
