import 'package:captain/app_builder.dart';
import 'package:captain/db/shared_preference/c_shared_preference.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';


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
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    requestPermissions();

    return FutureBuilder(
        builder: (context, projectSnap) {
          if (projectSnap.connectionState == ConnectionState.none && projectSnap.hasData == null) {
            return LoadingApp();
          } else {
            if (projectSnap.data == true) {
              return AppBuilder(builder: (context) {
                return MaterialApp(
                    title: "Captain",
                    theme: HTheme.getTheme(themeType: HTheme.currentTheme),
//                    routes: routes
                );
              });
            } else {
              return LoadingApp();
            }
          }
        },
        future: setSPInitValues());
  }

  Future setSPInitValues() async {
    CSharedPreference cSP = GetCSPInstance.cSharedPreference;

    return hSP.get(HSharedPreference.LOCALE).then((value) {
      if (value == null) {
        HString.locale = "en";
      } else {
        HString.locale = value;
      }

      return hSP.get(HSharedPreference.THEME).then((value) {
        if (value == null) {
          HTheme.currentTheme = HTheme.warm;
        } else {
          HTheme.currentTheme = value;
        }
        return true;
      });
    });
  }

  requestPermissions() async {
    HAccessibility.requestPhoneContactPermission();
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
            backgroundColor: Color(HTheme.pink),
            strokeWidth: 3,
          ),
          SizedBox(
            height: 15,
          ),
          Text(
            "initializing Hisab application",
            textDirection: TextDirection.ltr,
            style: TextStyle(color: Color(HTheme.gray66), fontSize: 15, fontWeight: FontWeight.w600),
          ),
          SizedBox(
            height: 5,
          ),
          Text(
            "populating db ...",
            textDirection: TextDirection.ltr,
            style: TextStyle(
              color: Color(HTheme.gray99),
              fontSize: 9,
            ),
          ),
        ],
      ),
      color: Colors.white,
    );
  }
}
