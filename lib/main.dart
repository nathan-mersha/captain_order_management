import 'package:captain/app_builder.dart';
import 'package:captain/db/dal/message.dart';
import 'package:captain/db/dal/normal_order.dart';
import 'package:captain/db/dal/personnel.dart';
import 'package:captain/db/dal/product.dart';
import 'package:captain/db/dal/punch.dart';
import 'package:captain/db/dal/returned_order.dart';
import 'package:captain/db/dal/special_order.dart';
import 'package:captain/route.dart';
import 'package:captain/rsr/theme/c_theme.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
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
          if (projectSnap.data == true) {
            return AppBuilder(builder: (context) {
              return MaterialApp(title: "Captain", theme: CTheme.getTheme(), routes: CRoutes().routes);
            });
          } else {
            return LoadingApp();
          }
        },
        future: initializeSharedPreference());
  }

  requestPermissions() async {
    await PermissionHandler().requestPermissions([PermissionGroup.contacts, PermissionGroup.phone, PermissionGroup.storage, PermissionGroup.camera]);
  }

  Future initializeSharedPreference() async {
    global.cSP = await SharedPreferences.getInstance();
    global.db = await createTable();
    return true;
  }

  Future<Database> createTable() async {
    Database db = await openDatabase(
      join(await getDatabasesPath(), global.DB_NAME),
      onCreate: (db, version) async {
        // Create message table
        await db.execute(MessageDAL.createTable);
        await db.execute(NormalOrderDAL.createTable);
        await db.execute(PersonnelDAL.createTable);
        await db.execute(ProductDAL.createTable);
        await db.execute(PunchDAL.createTable);
        await db.execute(ReturnedOrderDAL.createTable);
        await db.execute(SpecialOrderDAL.createTable);
      },
      version: 1,
    );

    return db;
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
          Image.asset(
            "assets/images/captain_icon.png",
            height: 120,
            width: 120,
          ),
          SizedBox(
            height: 20,
          ),
          Text(
            "initializing captain",
            textDirection: TextDirection.ltr,
            style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600),
          ),
        ],
      ),
      color: Colors.deepPurple,
    );
  }
}
