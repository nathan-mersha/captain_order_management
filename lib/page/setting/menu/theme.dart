import 'package:captain/app_builder.dart';
import 'package:captain/db/shared_preference/c_shared_preference.dart';
import 'package:captain/rsr/theme/c_theme.dart';
import 'package:captain/widget/c_snackbar.dart';
import 'package:flutter/material.dart';

class ThemeSettings extends StatefulWidget {
  @override
  _ThemeSettingsState createState() => _ThemeSettingsState();
}

class _ThemeSettingsState extends State<ThemeSettings> {
  CSharedPreference cSP = GetCSPInstance.cSharedPreference;

  static const String NAME = "NAME";
  static const String DESCRIPTION = "DESCRIPTION";
  static const String KEY = "KEY";
  static const String COLOR = "COLOR";

  List menus = [
    {
      NAME: "Tshey",
      DESCRIPTION: "Sun based theme",
      KEY: CTheme.TSEHAY,
      COLOR: CTheme.THEME_MAP[CTheme.TSEHAY][CTheme.primaryColor]
    },
    {
      NAME: "Bertukan",
      DESCRIPTION: "Orange based theme",
      KEY: CTheme.BERTUKAN,
      COLOR: CTheme.THEME_MAP[CTheme.BERTUKAN][CTheme.primaryColor]
    },
    {
      NAME: "Weyne",
      DESCRIPTION: "Wine based theme",
      KEY: CTheme.WEYNE,
      COLOR: CTheme.THEME_MAP[CTheme.WEYNE][CTheme.primaryColor]
    },
    {
      NAME: "Buna",
      DESCRIPTION: "Coffee based theme",
      KEY: CTheme.BUNA,
      COLOR: CTheme.THEME_MAP[CTheme.BUNA][CTheme.primaryColor]
    },
    {
      NAME: "Weha",
      DESCRIPTION: "Water based theme",
      KEY: CTheme.WEHA,
      COLOR: CTheme.THEME_MAP[CTheme.WEHA][CTheme.primaryColor]
    },
    {
      NAME: "Ketel",
      DESCRIPTION: "Leaf based theme",
      KEY: CTheme.KETEL,
      COLOR: CTheme.THEME_MAP[CTheme.KETEL][CTheme.primaryColor]
    },
    {
      NAME: "Lelit",
      DESCRIPTION: "Night based theme",
      KEY: CTheme.LELIT,
      COLOR: CTheme.THEME_MAP[CTheme.LELIT][CTheme.primaryColor]
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      child: ListView.builder(
        itemCount: menus.length,
        itemBuilder: (context, index) {
          return Container(
            color: cSP.currentTheme == menus[index][KEY]
                ? Colors.black.withOpacity(0.07)
                : Colors.white,
            child: GestureDetector(
              child: ListTile(
                leading: Icon(
                  Icons.invert_colors,
                  color: menus[index][COLOR],
                ),
                title: Text(
                  menus[index][NAME],
                  style: TextStyle(fontSize: 13),
                ),
                subtitle: Text(
                  menus[index][DESCRIPTION],
                  style: TextStyle(fontSize: 11),
                ),
              ),
              onTap: () {
                cSP.currentTheme = menus[index][KEY];
                AppBuilder.of(context).rebuild();
                CNotifications.showSnackBar(
                    context, "Successfuly changed theme", "success", () {},
                    backgroundColor: Theme.of(context).primaryColor);
              },
            ),
          );
        },
      ),
    );
  }
}
