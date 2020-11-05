import 'package:captain/rsr/locale/lang/en.dart';
import 'package:captain/rsr/locale/lang/et_am.dart';
import 'package:flutter/material.dart';

class CString {
  static const String ENGLISH_LC = "en";
  static const String AMHARIC_LC = "et_am";

  // Default locale setup
  static String locale = ENGLISH_LC;

  /// default lang
  static Map<String, Map<String, String>> _localizedValues = {
    ENGLISH_LC: EN.val,
    AMHARIC_LC: ET_AM.val,
  };

  static CString of(BuildContext context) {
    return Localizations.of<CString>(context, CString);
  }

  static String get(key, {firstCap = false, lcl}) {
    String localeVal = lcl == null ? locale : lcl;

    String val = _localizedValues[localeVal][key];

    if (firstCap) {
      return val == null || val == "" ? '${_localizedValues[ENGLISH_LC][key][0].toUpperCase()}${_localizedValues[ENGLISH_LC][key].substring(1)}' : '${val[0].toUpperCase()}${val.substring(1)}';
    } else {
      return val == null || val == "" ? _localizedValues[ENGLISH_LC][key] : val;
    }
  }
}
