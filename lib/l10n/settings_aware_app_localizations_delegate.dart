import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_localizations.dart';
import 'app_localizations_en.dart';
import 'app_localizations_am.dart';
import 'app_localizations_om.dart';

class SettingsAwareAppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const SettingsAwareAppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => true;

  @override
  Future<AppLocalizations> load(Locale locale) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString('user_settings');
      String lang = 'English';
      if (jsonString != null) {
        final map = json.decode(jsonString) as Map<String, dynamic>;
        lang = (map['language'] ?? 'English').toString();
      }

      final lower = lang.trim().toLowerCase();
      if (lower.contains('om') || lower.contains('orom') || lower.contains('afaan')) {
        return AppLocalizationsOm();
      }
      if (lower.contains('am') || lower.contains('amh') || lower.contains('amharic')) {
        return AppLocalizationsAm();
      }
      return AppLocalizationsEn();
    } catch (_) {
      return AppLocalizationsEn();
    }
  }

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppLocalizations> old) => true;
}
