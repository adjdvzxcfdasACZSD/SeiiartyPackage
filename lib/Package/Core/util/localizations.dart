import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;


class AppLocalizations {
  final Locale locale;

  AppLocalizations({required this.locale});

  static Map<String, dynamic>? _localisedValues;

  // Helper method to keep the code in the widgets concise
  // Localizations are accessed using an InheritedWidget "of" syntax
  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  // Static member to have a simple access to the delegate from the MaterialApp
  static const LocalizationsDelegate<AppLocalizations> delegate =
  _AppLocalizationsDelegate();

  Future load() async {
    // Load the language JSON file from the "lang" folder
    try {
      String jsonContent = await rootBundle.loadString("packages/tama_package/assets/values/${locale.languageCode}.json");

      _localisedValues = json.decode(jsonContent);
    }catch(e){
      if (kDebugMode) {
        print("Error loading localization file: $e");
      }
      _localisedValues = {};
    }

  }

  // This method will be called from every widget which needs a localized text
  String translate(String key) {
    return _localisedValues?[key] ?? "$key not found";
  }
}

// LocalizationsDelegate is a factory for a set of localized resources
// In this case, the localized strings will be gotten in an AppLocalizations object

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  // This delegate instance will never change (it doesn't even have fields!)
  // It can provide a constant constructor.
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'ar'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    // AppLocalizations class is where the JSON loading actually runs
    AppLocalizations localizations = AppLocalizations(locale: locale);
    await localizations.load();
    return localizations;
  }

  @override
  bool shouldReload(LocalizationsDelegate<AppLocalizations> old) => false;
}
