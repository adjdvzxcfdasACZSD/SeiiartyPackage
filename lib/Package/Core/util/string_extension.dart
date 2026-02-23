import '../util/localizations.dart';
import 'package:flutter/material.dart';

extension TranslateX on String{
  String translate (BuildContext context){
    return AppLocalizations.of(context)!.translate(this);
  }
}