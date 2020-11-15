import 'dart:convert';

import 'package:captain/db/model/normal_order.dart';
import 'package:captain/db/model/personnel.dart';
import 'package:captain/db/model/product.dart';
import 'package:sqflite/sqflite.dart';
import 'package:captain/global.dart' as global;
import 'package:uuid/uuid.dart';

class NormalOrderDAL {
  static const String TABLE_NAME = NormalOrder.COLLECTION_NAME;

  static String createTable = "CREATE TABLE $TABLE_NAME (" +
      "${NormalOrder.ID} TEXT," +
      "${NormalOrder.ID_FS} TEXT," +
      "${NormalOrder.EMPLOYEE} TEXT," +
      "${NormalOrder.CUSTOMER} TEXT," +
      "${NormalOrder.PRODUCTS} TEXT," +
      "${NormalOrder.TOTAL_AMOUNT} REAL," +
      "${NormalOrder.ADVANCE_PAYMENT} REAL," +
      "${NormalOrder.REMAINING_PAYMENT} REAL," +
      "${NormalOrder.PAID_IN_FULL} BLOB," +
      "${NormalOrder.STATUS} TEXT," +
      "${NormalOrder.USER_NOTIFIED} BLOB," +
      "${NormalOrder.FIRST_MODIFIED} TEXT," +
      "${NormalOrder.LAST_MODIFIED} TEXT" +
      ")";

  static Future<NormalOrder> create(NormalOrder normalOrder) async {
    // updating first and last modified stamps.
    var uuid = Uuid();
    normalOrder.id = uuid.hashCode.toString();
    normalOrder.firstModified = DateTime.now();
    normalOrder.lastModified = DateTime.now();

    // Get a reference to the database.
    await global.db.insert(TABLE_NAME, NormalOrder.toMap(normalOrder), conflictAlgorithm: ConflictAlgorithm.replace);
    return normalOrder;
  }

  /// where : "id = ?"
  /// whereArgs : [2]
  static Future<List<NormalOrder>> find({String where, dynamic whereArgs}) async {
    final List<Map<String, dynamic>> maps = where == null
        ? await global.db.query(
            TABLE_NAME,
          )
        : await global.db.query(TABLE_NAME, where: where, whereArgs: whereArgs, orderBy: "${NormalOrder.LAST_MODIFIED} DESC");

    return List.generate(maps.length, (i) {
      return NormalOrder(
        id: maps[i][NormalOrder.ID],
        idFS: maps[i][NormalOrder.ID_FS],
        employee: Personnel.toModel(jsonDecode(maps[i][NormalOrder.EMPLOYEE])),
        customer: Personnel.toModel(jsonDecode(maps[i][NormalOrder.CUSTOMER])),
        products: Product.toModelList(jsonDecode(maps[i][NormalOrder.PRODUCTS])),
        totalAmount: maps[i][NormalOrder.TOTAL_AMOUNT],
        advancePayment: maps[i][NormalOrder.ADVANCE_PAYMENT],
        remainingPayment: maps[i][NormalOrder.REMAINING_PAYMENT],
        paidInFull: maps[i][NormalOrder.PAID_IN_FULL] == 1 ? true : false,
        status: maps[i][NormalOrder.STATUS],
        userNotified: maps[i][NormalOrder.USER_NOTIFIED] == 1 ? true : false,
        firstModified: DateTime.parse(maps[i][NormalOrder.FIRST_MODIFIED]),
        lastModified: DateTime.parse(maps[i][NormalOrder.LAST_MODIFIED]),
      );
    });
  }

  /// where : "id = ?"
  /// whereArgs : [2]
  static Future<void> update({String where, dynamic whereArgs, NormalOrder normalOrder}) async {
    normalOrder.lastModified = DateTime.now();
    await global.db.update(TABLE_NAME, NormalOrder.toMap(normalOrder), where: where, whereArgs: whereArgs);
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
