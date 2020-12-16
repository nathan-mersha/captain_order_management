import 'package:captain/db/shared_preference/c_shared_preference.dart';
import 'package:captain/page/dashboard.dart';
import 'package:captain/page/login.dart';
import 'package:captain/page/system_locked/system_locked.dart';
import 'package:flutter/material.dart';

class CRoutes {
  static const String ROOT = "/";
  static const String LOGIN = "/login";
  static const String DASHBOARD = "/dashboard";

  var routes;
  CRoutes() {
//    ApiGlobalConfig.get();

    routes = {
      ROOT: (BuildContext context) {
        CSharedPreference cSP = GetCSPInstance.cSharedPreference;
        bool mainPasswordEnabled = cSP.mainPasswordEnabled;
        bool systemLocked = cSP.systemLocked;

        if (systemLocked) {
          return SystemLockedPage();
        } else if (mainPasswordEnabled) {
          return LoginPage();
        } else {
          return DashboardPage();
        }
      }, // Builds the first page (Login or Dashboard)
      LOGIN: (BuildContext context) => LoginPage(),
      DASHBOARD: (BuildContext context) => DashboardPage(),
    };
  }

  Widget buildFirstPage(BuildContext context, AsyncSnapshot snapshot) {
    if (snapshot.connectionState == ConnectionState.none &&
        snapshot.hasData == null) {
      return CircularProgressIndicator();
    } else if (snapshot.data == true) {
      return LoginPage();
    } else {
      return DashboardPage();
    }
  }
}
