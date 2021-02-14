import 'dart:async';
import 'dart:convert';

import 'package:captain/db/dal/normal_order.dart';
import 'package:captain/db/model/personnel.dart';
import 'package:captain/db/model/product.dart';
import 'package:captain/db/model/punch.dart';
import 'package:sqflite/sqflite.dart';
import 'package:captain/global.dart' as global;
import 'package:uuid/uuid.dart';

class PunchDAL {
  static const String TABLE_NAME = Punch.COLLECTION_NAME;

  static String createTable = "CREATE TABLE $TABLE_NAME (" +
      "${Punch.ID} TEXT," +
      "${Punch.ID_FS} TEXT," +
      "${Punch.EMPLOYEE} TEXT," +
      "${Punch.PRODUCT} TEXT," +
      "${Punch.TYPE} TEXT," +
      "${Punch.WEIGHT} REAL," +
      "${Punch.NOTE} TEXT," +
      "${Punch.FIRST_MODIFIED} TEXT," +
      "${Punch.LAST_MODIFIED} TEXT" +
      ")";
  static Future<Punch> create(Punch punch) async {
    // updating first and last modified stamps.
    var uuid = Uuid();
    punch.id = uuid.hashCode.toString();
    punch.firstModified = DateTime.now();
    punch.lastModified = DateTime.now();

    Map<String, dynamic> punchMapped = Punch.toMap(punch);
    punchMapped[Punch.EMPLOYEE] = punch.employee == null ? null : punch.employee.id;
    
    // Get a reference to the database.
    await global.db.insert(TABLE_NAME, punchMapped,
        conflictAlgorithm: ConflictAlgorithm.replace);
    return punch;
  }

  /// where : "id = ?"
  /// whereArgs : [2]
  static Future<List<Punch>> find({String where, dynamic whereArgs}) async {
    final List<Map<String, dynamic>> maps = where == null
        ? await global.db
            .query(TABLE_NAME, orderBy: "${Punch.LAST_MODIFIED} DESC")
        : await global.db.query(TABLE_NAME,
            where: where,
            whereArgs: whereArgs,
            orderBy: "${Punch.LAST_MODIFIED} DESC");

    List<Punch> parsedList = [];
    final c = new Completer<List<Punch>>();

    maps.forEach((Map<String, dynamic> element) async{ 
      Punch punch = Punch(
        id: element[Punch.ID],
        idFS: element[Punch.ID_FS],
        employee : await NormalOrderDAL.getPersonnel(element[Personnel.EMPLOYEE]),
        product: Product.toModel(jsonDecode(element[Punch.PRODUCT])),
        type: element[Punch.TYPE],
        weight: element[Punch.WEIGHT],
        note: element[Punch.NOTE],
        firstModified: DateTime.parse(element[Punch.FIRST_MODIFIED]),
        lastModified: DateTime.parse(element[Punch.LAST_MODIFIED]),
      );

      parsedList.add(punch);
      if(maps.length == parsedList.length){
        c.complete(parsedList);
      }
    });

    return c.future;
    
  }

  /// where : "id = ?"
  /// whereArgs : [2]
  static Future<void> update(
      {String where, dynamic whereArgs, Punch punch}) async {
    punch.lastModified = DateTime.now();
    await global.db.update(TABLE_NAME, Punch.toMap(punch),
        where: where, whereArgs: whereArgs);
  }

  /// where : "id = ?"
  /// whereArgs : [2]
  static Future<void> delete({String where, dynamic whereArgs}) async {
    await global.db.delete(
      TABLE_NAME,
      where: where,
      whereArgs: whereArgs,
    );
  }
}
