import '../../../Package/Core/api_access.dart';
import 'package:flutter/material.dart';

class SpSetupTable{
  static Future<dynamic> get(BuildContext context) async {
    String cmd = "Select * from SetupTable";
    if (cmd.isNotEmpty) {
      return await ApiAccess.connectApi(

        RequestCmd(cmd),
        "/Main/ExecCmd",
        viewLoadingProcess: false,
      );
    }}
}