import 'package:captain/app_builder.dart';
import 'package:captain/db/dal/message.dart';
import 'package:captain/db/dal/normal_order.dart';
import 'package:captain/db/dal/personnel.dart';
import 'package:captain/db/dal/product.dart';
import 'package:captain/db/dal/punch.dart';
import 'package:captain/db/dal/returned_order.dart';
import 'package:captain/db/dal/special_order.dart';
import 'package:captain/db/model/product.dart';
import 'package:captain/db/shared_preference/c_shared_preference.dart';
import 'package:captain/page/product/create_product.dart';
import 'package:captain/route.dart';
import 'package:captain/rsr/kapci/colors.dart';
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
    await PermissionHandler().requestPermissions([PermissionGroup.contacts, PermissionGroup.phone, PermissionGroup.storage, PermissionGroup.sms, PermissionGroup.camera]);
  }

  Future initializeSharedPreference() async {
    global.cSP = await SharedPreferences.getInstance();
    global.db = await createTable();
    await seedPaintProducts();
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

  String getUnitOfMeasurement(String unit) {
    if (unit.toLowerCase() == "package") {
      return CreateProductViewState.PACKAGE;
    } else if (unit.toLowerCase() == "liter") {
      return CreateProductViewState.LITER;
    } else if (unit.toLowerCase() == "gallon") {
      return CreateProductViewState.GALLON;
    } else if (unit.toLowerCase() == "piece") {
      return CreateProductViewState.PIECE;
    } else {
      return CreateProductViewState.LITER;
    }
  }

  String getPaintType(String paintType) {
    if (paintType.toLowerCase() == "metallic") {
      return CreateProductViewState.METALIC;
    } else if (paintType.toLowerCase() == "auto cryl") {
      return CreateProductViewState.AUTO_CRYL;
    } else if (paintType.toLowerCase() == "kapcibase 670") {
      // metalic
      return CreateProductViewState.METALIC;
    } else if (paintType.toLowerCase() == "kapcicryl 660") {
      // auto cryl
      return CreateProductViewState.AUTO_CRYL;
    } else {
      return CreateProductViewState.METALIC;
    }
  }

  num getUnitPrice(String paintType) {
    if (paintType.toLowerCase() == "metallic") {
      return 800;
    } else if (paintType.toLowerCase() == "auto cryl") {
      return 950;
    } else if (paintType.toLowerCase() == "kapcibase 670") {
      // metalic
      return 800;
    } else if (paintType.toLowerCase() == "kapcicryl 660") {
      // auto cryl
      return 950;
    } else {
      return 0;
    }
  }

  Future<bool> seedPaintProducts() async {
    CSharedPreference cSP = GetCSPInstance.cSharedPreference;
    bool paintProductSeeded = cSP.paintProductSeeded;
    /// No product has been seeded.
    if (!paintProductSeeded) {
      KapciColors.VALUES.forEach((Map<String, String> paintValue) async {
        Product paint;

        if (paintValue["item"].toLowerCase() == "paint") {
          paint = Product(
              type: CreateProductViewState.PAINT,
              isGallonBased: paintValue["measurement"].toLowerCase() == "gallon" ? true : false,
              unitOfMeasurement: getUnitOfMeasurement(paintValue["measurement"]),
              paintType: getPaintType(paintValue["PaintLine"] ?? "-"),
              name: paintValue["Name"].toLowerCase().toString().trim(),
              manufacturer: paintValue["MANUFACTURE"].toLowerCase(),
              unitPrice: getUnitPrice(paintValue["PaintLine"] ?? "-"),
              colorValue: Color.fromARGB(100, int.parse(paintValue["Red"]), int.parse(paintValue["Green"]), int.parse(paintValue["Blue"])).value.toString());
        } else {
          paint = Product(
            type: CreateProductViewState.OTHER_PRODUCTS,
            unitOfMeasurement: getUnitOfMeasurement(paintValue["measurement"]),
            name: paintValue["Name"].toLowerCase().toString().trim(),
            manufacturer: paintValue["MANUFACTURE"].toLowerCase(),
            unitPrice: 0,
          );
        }

        await createPaint(paint);
      });
      cSP.paintProductSeeded = true;
      return true;
    }

    /// Paint product already seeded.
    else {
      return true;
    }
  }

  Future<bool> createPaint(Product product) async {
    // Create product local db
    await ProductDAL.create(product);
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
          Image.asset(
            "assets/images/captain_icon.png",
            height: 120,
            width: 120,
          ),
          SizedBox(
            height: 20,
          ),
          SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(
              strokeWidth: 1,
              backgroundColor: Colors.white,
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Text(
            "initializing captain",
            textDirection: TextDirection.ltr,
            style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600),
          ),
          SizedBox(
            height: 5,
          ),
          Text(
            "populating db ...",
            textDirection: TextDirection.ltr,
            style: TextStyle(
              color: Colors.white,
              fontSize: 9,
            ),
          ),
        ],
      ),
      color: Colors.deepPurple,
    );
  }
}
