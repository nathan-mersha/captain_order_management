import 'dart:convert';

import 'package:captain/db/model/personnel.dart';
import 'package:captain/db/model/product.dart';
import 'package:captain/db/model/returned_order.dart';
import 'package:sqflite/sqflite.dart';
import 'package:captain/global.dart' as global;
import 'package:uuid/uuid.dart';

class ReturnedOrderDAL {
  static const String TABLE_NAME = ReturnedOrder.COLLECTION_NAME;

  static String createTable = "CREATE TABLE $TABLE_NAME (" +
      "${ReturnedOrder.ID} TEXT," +
      "${ReturnedOrder.ID_FS} TEXT," +
      "${ReturnedOrder.EMPLOYEE} TEXT," +
      "${ReturnedOrder.CUSTOMER} TEXT," +
      "${ReturnedOrder.PRODUCT} TEXT," +
      "${ReturnedOrder.COUNT} INTEGER," +
      "${ReturnedOrder.NOTE} TEXT," +
      "${ReturnedOrder.FIRST_MODIFIED} TEXT," +
      "${ReturnedOrder.LAST_MODIFIED} TEXT" +
      ")";

  static Future<ReturnedOrder> create(ReturnedOrder returnedOrder) async {
    // updating first and last modified stamps.
    var uuid = Uuid();
    returnedOrder.id = uuid.hashCode.toString();
    returnedOrder.firstModified = DateTime.now();
    returnedOrder.lastModified = DateTime.now();

    // Get a reference to the database.
    await global.db.insert(TABLE_NAME, ReturnedOrder.toMap(returnedOrder), conflictAlgorithm: ConflictAlgorithm.replace);
    return returnedOrder;
  }

  /// where : "id = ?"
  /// whereArgs : [2]
  static Future<List<ReturnedOrder>> find({String where, dynamic whereArgs}) async {
    final List<Map<String, dynamic>> maps = where == null
        ? await global.db.query(
            TABLE_NAME,
          )
        : await global.db.query(TABLE_NAME, where: where, whereArgs: whereArgs,orderBy: "${ReturnedOrder.LAST_MODIFIED} DESC");

    print("Query returned orders");
    print("maps length : ${maps.length}");
    return List.generate(maps.length, (i) {
      return ReturnedOrder(
        id: maps[i][ReturnedOrder.ID],
        idFS: maps[i][ReturnedOrder.ID_FS],
        employee: Personnel.toModel(jsonDecode(maps[i][ReturnedOrder.EMPLOYEE])),
        customer: Personnel.toModel(jsonDecode(maps[i][ReturnedOrder.CUSTOMER])),
        product: Product.toModel(jsonDecode(maps[i][ReturnedOrder.PRODUCT])),
        count: maps[i][ReturnedOrder.COUNT],
        note: maps[i][ReturnedOrder.NOTE],
        firstModified: DateTime.parse(maps[i][ReturnedOrder.FIRST_MODIFIED]),
        lastModified: DateTime.parse(maps[i][ReturnedOrder.LAST_MODIFIED]),
      );
    });
  }

  /// where : "id = ?"
  /// whereArgs : [2]
  static Future<void> update({String where, dynamic whereArgs, ReturnedOrder returnedOrder}) async {
    returnedOrder.lastModified = DateTime.now();
    await global.db.update(TABLE_NAME, ReturnedOrder.toMap(returnedOrder), where: where, whereArgs: whereArgs);
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
