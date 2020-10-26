import 'package:captain/db/shared_preference/c_shared_preference.dart';
import 'package:captain/rsr/theme/c_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:permission_handler/permission_handler.dart';


void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return MyAppState();
  }
}

class MyAppState extends State<MyApp> {
  // This widget is the root of your application.
//  static var routes;


  @override
  Widget build(BuildContext context) {
//    routes = HRoutes().routes;
    SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
    requestPermissions();

    return MaterialApp(
      title: "Captain",
      theme: CTheme.getTheme(),
//                    routes: routes
    );
  }



  requestPermissions() async {
    await PermissionHandler().requestPermissions([PermissionGroup.phone]);
    await PermissionHandler().requestPermissions([PermissionGroup.contacts]);
    await PermissionHandler().requestPermissions([PermissionGroup.storage]);
  }
}

