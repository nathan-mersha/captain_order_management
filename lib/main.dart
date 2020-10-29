import 'package:captain/api/api_global_config.dart';
import 'package:captain/app_builder.dart';
import 'package:captain/route.dart';
import 'package:captain/rsr/theme/c_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'global.dart' as global;

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
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
    SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.bottom]);
    requestPermissions();

    return FutureBuilder(
        builder: (context, projectSnap) {
          if (projectSnap.connectionState == ConnectionState.none && projectSnap.hasData == null) {
            return LoadingApp();
          } else {
            if (projectSnap.data == true) {
              return AppBuilder(builder: (context) {
                return MaterialApp(title: "Captain", theme : CTheme.getTheme(), routes: CRoutes().routes);
              });
            } else {
              return LoadingApp();
            }
          }
        },
        future: initializeSharedPreference());
  }

  requestPermissions() async {
    await PermissionHandler().requestPermissions([PermissionGroup.contacts, PermissionGroup.phone, PermissionGroup.storage]);
  }

  Future initializeSharedPreference() async{
    global.cSP = await SharedPreferences.getInstance();
    return true;
  }
}

class LoadingApp extends StatelessWidget {
  const LoadingApp({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          CircularProgressIndicator(
            strokeWidth: 3,
          ),
          SizedBox(
            height: 15,
          ),
          Text(
            "initializing captain",
            textDirection: TextDirection.ltr,
            style: TextStyle(color: Colors.deepPurpleAccent, fontSize: 15, fontWeight: FontWeight.w600),
          ),
          SizedBox(
            height: 5,
          ),
          Text(
            "populating db ...",
            textDirection: TextDirection.ltr,
            style: TextStyle(
              color: Colors.deepPurpleAccent,
              fontSize: 9,
            ),
          ),
        ],
      ),
      color: Colors.white,
    );
  }
}

