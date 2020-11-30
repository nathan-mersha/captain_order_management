import 'package:captain/app_builder.dart';
import 'package:captain/db/dal/message.dart';
import 'package:captain/db/dal/normal_order.dart';
import 'package:captain/db/dal/personnel.dart';
import 'package:captain/db/dal/product.dart';
import 'package:captain/db/dal/punch.dart';
import 'package:captain/db/dal/returned_order.dart';
import 'package:captain/db/dal/special_order.dart';
import 'package:captain/db/model/message.dart';
import 'package:captain/db/model/normal_order.dart';
import 'package:captain/db/model/personnel.dart';
import 'package:captain/db/model/product.dart';
import 'package:captain/db/model/punch.dart';
import 'package:captain/db/model/returned_order.dart';
import 'package:captain/db/shared_preference/c_shared_preference.dart';
import 'package:captain/page/product/create_product.dart';
import 'package:captain/route.dart';
import 'package:captain/rsr/kapci/colors.dart';
import 'package:captain/rsr/kapci/messages.dart';
import 'package:captain/rsr/kapci/normal_order.dart';
import 'package:captain/rsr/kapci/personnels.dart';
import 'package:captain/rsr/kapci/punch.dart';
import 'package:captain/rsr/kapci/returned_order.dart';
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
    seed();
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

  seed() async {
//    await seedMessages();
//    await seedNormalOrder();
//    await seedPersonnel();
//    await seedPunch();
    await seedReturnedOrder();
//    await seedProducts();
  }

  // todo delete after seed and export
  Future<bool> seedMessages() async {
    List datas = await MessageDAL.find();
    if (datas.length == 0) {
      MessagesSeed.VALUES.forEach((Map<String, String> element) {
        Message message = Message.toModel(element);
        MessageDAL.create(message);
      });
    }
    return true;
  }

  // todo delete after seed and export
  Future<bool> seedNormalOrder() async {
    List datas = await NormalOrderDAL.find();
    if (datas.length == 0) {
      NormalOrderSeed.VALUES.forEach((Map<String, dynamic> element) {
        NormalOrder normalOrder = NormalOrder.toModel(element);
        NormalOrderDAL.create(normalOrder);
      });
    }

    return true;
  }

  // todo delete after seed and export
  Future<bool> seedPersonnel() async {
    List datas = await PersonnelDAL.find();
    if (datas.length == 0) {
      PersonnelSeed.VALUES.forEach((Map<String, dynamic> element) {
        Personnel personnel = Personnel.toModel(element);
        PersonnelDAL.create(personnel);
      });
    }

    return true;
  }

  // todo delete after seed and export
  Future<bool> seedPunch() async {
    List datas = await PunchDAL.find();
    if (datas.length == 0) {
      PunchSeed.VALUES.forEach((Map<String, dynamic> element) {
        Punch punch = Punch.toModel(element);
        PunchDAL.create(punch);
      });
    }

    return true;
  }

  // todo delete after seed and export
  Future<bool> seedReturnedOrder() async {
    await ReturnedOrderDAL.delete();
    List datas = await ReturnedOrderDAL.find();

    if (datas.length == 0) {
      ReturnedOrderSeed.VALUES.forEach((Map<String, dynamic> element) {
        ReturnedOrder returnedOrder = ReturnedOrder.toModel(element);
        ReturnedOrderDAL.create(returnedOrder);
      });
    }
    return true;
  }

  // todo delete after seed and export
  Future<bool> seedProducts() async {
    List datas = await ProductDAL.find();

    if (datas.length == 0) {
      KapciColors.VALUES.forEach((Map<String, dynamic> element) {
        Product product;
        if (element["item"] == "paint") {
          product = Product(
              name: element["product"],
              type: "Paint",
              unitPrice: num.parse(element["price"]),
              colorValue: Color.fromARGB(100, int.parse(element["red"]), int.parse(element["green"]), int.parse(element["blue"])).value.toString(),
              manufacturer: element["manufacture"],
              paintType: element["paint line"] == "metallic" ? "Metalic" : "Auto-Cryl",
              unitOfMeasurement: element["measurment"],
              lastModified: DateTime.now(),
              firstModified: DateTime.now(),
              isGallonBased: element["measurment"] == "gallon" ? true : false);
        } else {
          product = Product(
              name: element["product"],
              type: "others",
              unitPrice: 0,
              colorValue: "-",
              manufacturer: element["manufacture"],
              paintType: "-",
              unitOfMeasurement: element["measurment"],
              lastModified: DateTime.now(),
              firstModified: DateTime.now(),
              isGallonBased: element["measurment"] == "gallon" ? true : false);
        }

        ProductDAL.create(product);
      });
    }

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
