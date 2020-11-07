import 'package:captain/db/model/special_order.dart';
import 'package:sqflite/sqflite.dart';
import 'package:captain/global.dart' as global;
import 'package:uuid/uuid.dart';

class SpecialOrderDAL {
  static const String TABLE_NAME = SpecialOrder.COLLECTION_NAME;

  static String createTable = "CREATE TABLE $TABLE_NAME (" +
      "${SpecialOrder.ID} TEXT," +
      "${SpecialOrder.ID_FS} TEXT," +
      "${SpecialOrder.EMPLOYEE} BLOB," +
      "${SpecialOrder.CUSTOMER} BLOB," +
      "${SpecialOrder.PRODUCTS} BLOB," +
      "${SpecialOrder.TOTAL_AMOUNT} REAL," +
      "${SpecialOrder.ADVANCE_PAYMENT} REAL," +
      "${SpecialOrder.REMAINING_PAYMENT} REAL," +
      "${SpecialOrder.PAID_IN_FULL} BLOB," +
      "${SpecialOrder.NOTE} TEXT," +
      "${SpecialOrder.FIRST_MODIFIED} TEXT," +
      "${SpecialOrder.LAST_MODIFIED} TEXT" +
      ")";

  static Future<SpecialOrder> create(SpecialOrder specialOrder) async {
    // updating first and last modified stamps.
    var uuid = Uuid();
    specialOrder.id = uuid.hashCode.toString();
    specialOrder.firstModified = DateTime.now();
    specialOrder.lastModified = DateTime.now();

    // Get a reference to the database.
    await global.db.insert(TABLE_NAME, SpecialOrder.toMap(specialOrder), conflictAlgorithm: ConflictAlgorithm.replace);
    return specialOrder;
  }

  /// where : "id = ?"
  /// whereArgs : [2]
  static Future<List<SpecialOrder>> find({String where, dynamic whereArgs}) async {
    final List<Map<String, dynamic>> maps = where == null
        ? await global.db.query(
            TABLE_NAME,
          )
        : await global.db.query(TABLE_NAME, where: where, whereArgs: whereArgs,orderBy: "${SpecialOrder.LAST_MODIFIED} DESC");

    return List.generate(maps.length, (i) {
      return SpecialOrder(
        id: maps[i][SpecialOrder.ID],
        idFS: maps[i][SpecialOrder.ID_FS],
        employee: maps[i][SpecialOrder.EMPLOYEE],
        customer: maps[i][SpecialOrder.CUSTOMER],
        products: maps[i][SpecialOrder.PRODUCTS],
        totalAmount: maps[i][SpecialOrder.TOTAL_AMOUNT],
        advancePayment: maps[i][SpecialOrder.ADVANCE_PAYMENT],
        remainingPayment: maps[i][SpecialOrder.REMAINING_PAYMENT],
        paidInFull: maps[i][SpecialOrder.PAID_IN_FULL],
        note: maps[i][SpecialOrder.NOTE],
        firstModified: DateTime.parse(maps[i][SpecialOrder.FIRST_MODIFIED]),
        lastModified: DateTime.parse(maps[i][SpecialOrder.LAST_MODIFIED]),
      );
    });
  }

  /// where : "id = ?"
  /// whereArgs : [2]
  static Future<void> update({String where, dynamic whereArgs, SpecialOrder specialOrder}) async {
    specialOrder.lastModified = DateTime.now();
    await global.db.update(TABLE_NAME, SpecialOrder.toMap(specialOrder), where: where, whereArgs: whereArgs);
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
