import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'app_theme.dart';
import 'general_const.dart';
import 'general_function.dart';

class CommonDialogs {
  void snackBar(BuildContext context, {String? msg, Color? color}) {
    color ??= AppTheme.dangerColor;
    msg ??= GeneralConstant.unknownError;
    final snackBar = SnackBar(
        duration: Duration(seconds: 2),
        backgroundColor: color,
        content: Text(msg));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  static showToast(BuildContext context, String msg) {
    Fluttertoast.showToast(
        msg: msg,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.grey[700],
        textColor: Colors.white,
        fontSize: 18.0);
  }

  loadingDialog(BuildContext context) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              GeneralFunctions.loadingCenter(),
              const SizedBox(
                height: 20,
              ),
              Text(
                'Please wait ...',
              ),
            ],
          ),
        );
      },
    );
  }

  Future<bool> msgBox(BuildContext context, String message) async {
    return await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Text(
            message,
            style: const TextStyle(fontSize: 16, height: 1.8),
            // textAlign: TextAlign.left,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: Text(
                'Ok',
              ),
            ),
          ],
        );
      },
    );
  }
  void showDialogYesNo(BuildContext context,{required Color btnColor,required String title,required String content,required String btnText,required VoidCallback onYes,required Icon icon, VoidCallback? onNo}) {
    onNo ??= () {
        Navigator.pop(context);
      };
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.darkCardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            icon,
            SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Text(
          content,
          style: TextStyle(color: AppTheme.grey, fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: onNo,
            child: Text('إلغاء', style: TextStyle(color: AppTheme.grey)),
          ),
          TextButton(
            onPressed: onYes,
            style: TextButton.styleFrom(
              backgroundColor: btnColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: Text(
                btnText,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }


  void showDialogSuccessOperation(
      BuildContext context, String title, String message,
      {VoidCallback? onOk, bool notTranslateMsg = false}) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: onOk,
              child: Text('Ok'),
            ),
          ],
        );
      },
    );
  }
}
