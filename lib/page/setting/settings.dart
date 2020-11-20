import 'package:captain/page/developer/developer.dart';
import 'package:captain/page/setting/menu/admin_password.dart';
import 'package:captain/page/setting/menu/customer_notification.dart';
import 'package:captain/page/setting/menu/developer.dart';
import 'package:captain/page/setting/menu/export.dart';
import 'package:captain/page/setting/menu/import.dart';
import 'package:captain/page/setting/menu/lock_features.dart';
import 'package:captain/page/setting/menu/main_password.dart';
import 'package:captain/page/setting/menu/theme.dart';
import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  // Defining keys
  static const String NAME = "NAME";
  static const String ICON = "ICON";
  static const String DESCRIPTION = "DESCRIPTION";
  static const String CHILD = "CHILD";

  static const int LOCK_FEATURES = 1;
  static const int THEME = 2;
  static const int MAIN_PASSWORD = 3;
  static const int ADMIN_PASSWORD = 4;
  static const int CUSTOMER_NOTIFICATION = 5;
  static const int EXPORT = 6;
  static const int IMPORT = 7;
  static const int DEVELOPER = 8;

  int selectedMenuIndex = LOCK_FEATURES;

  List menus = [
    {NAME: "Lock Features", ICON: Icons.security, DESCRIPTION: "lock the features available only for admin", CHILD: LockFeaturesSettings()},
    {NAME: "Theme", ICON: Icons.style, DESCRIPTION: "change styling of your application", CHILD: ThemeSettings()},
    {NAME: "Main Password", ICON: Icons.lock_open, DESCRIPTION: "set main password to lock the application", CHILD: MainPasswordSettings()},
    {NAME: "Admin Password", ICON: Icons.admin_panel_settings, DESCRIPTION: "lock the features available only for admin", CHILD: AdminPasswordSettings()},
    {NAME: "Customer Notification", ICON: Icons.notification_important, DESCRIPTION: "Notify customer customers when order is completed", CHILD: CustomerNotificationSettings()},
    {NAME: "Export", ICON: Icons.arrow_forward, DESCRIPTION: "Export your database for future restore", CHILD: ExportSettings()},
    {NAME: "Import", ICON: Icons.arrow_back, DESCRIPTION: "Import your database and restore your content", CHILD: ImportSettings()},
    {NAME: "Developer", ICON: Icons.code, DESCRIPTION: "Who was the software developed by", CHILD: DeveloperSettings()},
  ];
  @override
  Widget build(BuildContext context) {
    return Container(
        height: 645,
        child: Row(
          children: [
            Expanded(
                flex: 3,
                child: Container(
                  child: Card(
                    child: ListView.builder(
                      itemCount: menus.length,
                      itemBuilder: (context, index) {
                        return Container(
                          color: selectedMenuIndex == index ? Colors.black.withOpacity(0.07) : Colors.white,
                          child: ListTile(
                            leading: Container(
                              padding: EdgeInsets.only(left: 10),
                              child: Icon(
                                menus[index][ICON],
                                color: Colors.black54,
                                size: selectedMenuIndex == index ? 20 : 16,
                              ),
                            ),
                            title: Text(
                              menus[index][NAME],
                              style: TextStyle(color: Colors.black54, fontSize: selectedMenuIndex == index ? 14 : 13, fontWeight: selectedMenuIndex == index ? FontWeight.w800 : FontWeight.w100),
                            ),
                            subtitle: Text(menus[index][DESCRIPTION], style: TextStyle(fontSize: selectedMenuIndex == index ? 12 : 11),),
                            trailing: Container(
                              padding: EdgeInsets.only(right: 10),
                              child: Icon(
                                Icons.navigate_next,
                                color: Colors.black54,
                                size: selectedMenuIndex == index ? 16 : 13,
                              ),
                            ),
                            onTap: () {
                              setState(() {
                                selectedMenuIndex = index;
                              });
                            },
                          ),
                        );
                      },
                    ),
                  ),
                )),
            SizedBox(
              width: 10,
            ),
            Expanded(flex: 2, child: Card(child: menus[selectedMenuIndex][CHILD],)),
          ],
        ));
  }
}
