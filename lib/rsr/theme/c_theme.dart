import 'package:captain/db/shared_preference/c_shared_preference.dart';
import 'package:flutter/material.dart';

class CTheme {
  static const String TSEHAY = "TSEHAY";
  static const String BERTUKAN = "BERTUKAN";
  static const String WEYNE = "WEYNE";
  static const String BUNA = "BUNA";
  static const String WEHA = "WEHA";
  static const String KETEL = "KETEL";

  static const String primaryColor = "primaryColor";
  static const String primaryColorLight = "primaryColorLight";
  static const String accentColor = "accentColor";

  static const THEME_MAP = {
    TSEHAY: {primaryColor: Color(0xffd4aa00), primaryColorLight: Color(0xffe8aa00), accentColor: Color(0xff00a287)},
    BERTUKAN: {primaryColor: Color(0xffff6600), primaryColorLight: Color(0xffff9900), accentColor: Color(0xff104ba9)},
    WEYNE: {primaryColor: Color(0xff6100b5), primaryColorLight: Color(0xff6100ce), accentColor: Color(0xffa00074)},
    BUNA: {primaryColor: Color(0xff502d16), primaryColorLight: Color(0xff784421), accentColor: Color(0xff1d4413)},
    WEHA: {primaryColor: Color(0xff003399), primaryColorLight: Color(0xff3366cc), accentColor: Color(0xffe66400)},
    KETEL: {primaryColor: Color(0xff669900), primaryColorLight: Color(0xff99cc33), accentColor: Color(0xffa00074)},
  };

  static ThemeData getTheme() {
    CSharedPreference cSP = GetCSPInstance.cSharedPreference;
    String currentTheme = cSP.currentTheme;

    Color primary = THEME_MAP[currentTheme][primaryColor];
    Color primaryLight = THEME_MAP[currentTheme][primaryColorLight];
    Color accent = THEME_MAP[currentTheme][accentColor];
    return ThemeData(
      primaryColor: primary,
      primaryColorLight: primaryLight,
      accentColor: accent,
      selectedRowColor: primaryLight,
      backgroundColor: Color(0xfff2f2f2),
      buttonColor: primary,
      inputDecorationTheme: InputDecorationTheme(focusColor: primary, labelStyle: TextStyle(fontSize: 11,), hintStyle: TextStyle(fontSize: 11)),

      buttonTheme: ButtonThemeData(buttonColor: primary,textTheme: ButtonTextTheme.primary,),
      fontFamily: "Nunito",
    );
  }
}
