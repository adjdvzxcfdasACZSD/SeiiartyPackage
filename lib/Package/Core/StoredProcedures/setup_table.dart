
import 'package:flutter/material.dart';

import '../api_access.dart';

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