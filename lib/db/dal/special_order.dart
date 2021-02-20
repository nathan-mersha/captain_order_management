import 'dart:async';
import 'dart:convert';

import 'package:captain/db/dal/normal_order.dart';
import 'package:captain/db/model/product.dart';
import 'package:captain/db/model/special_order.dart';
import 'package:sqflite/sqflite.dart';
import 'package:captain/global.dart' as global;
import 'package:uuid/uuid.dart';

class SpecialOrderDAL {
  static const String TABLE_NAME = SpecialOrder.COLLECTION_NAME;

  static String createTable = "CREATE TABLE $TABLE_NAME (" +
      "${SpecialOrder.ID} TEXT," +
      "${SpecialOrder.ID_FS} TEXT," +
      "${SpecialOrder.EMPLOYEE} TEXT," +
      "${SpecialOrder.CUSTOMER} TEXT," +
      "${SpecialOrder.PRODUCTS} TEXT," +
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

    Map<String, dynamic> specialOrderMapped = SpecialOrder.toMap(specialOrder);
    specialOrderMapped[SpecialOrder.CUSTOMER] = specialOrder.customer == null ? null : specialOrder.customer.id;
    specialOrderMapped[SpecialOrder.EMPLOYEE] = specialOrder.employee == null ? null : specialOrder.employee.id;

    // Get a reference to the database.
    await global.db.insert(TABLE_NAME, specialOrderMapped, conflictAlgorithm: ConflictAlgorithm.replace);
    return specialOrder;
  }

  /// where : "id = ?"
  /// whereArgs : [2]
  static Future<List<SpecialOrder>> find({String where, dynamic whereArgs, bool populatePersonnel = true}) async {
    final List<Map<String, dynamic>> maps = where == null
        ? await global.db.query(TABLE_NAME, orderBy: "${SpecialOrder.LAST_MODIFIED} DESC")
        : await global.db.query(TABLE_NAME, where: where, whereArgs: whereArgs, orderBy: "${SpecialOrder.LAST_MODIFIED} DESC");

    List<SpecialOrder> parsedList = [];
    final c = Completer<List<SpecialOrder>>();

    maps.forEach((Map<String, dynamic> element) async {

      SpecialOrder specialOrder = SpecialOrder(
        id: element[SpecialOrder.ID],
        idFS: element[SpecialOrder.ID_FS],
        employee: populatePersonnel ? await NormalOrderDAL.getPersonnel(element[SpecialOrder.EMPLOYEE]) : null,
        customer: populatePersonnel ? await NormalOrderDAL.getPersonnel(element[SpecialOrder.CUSTOMER]) : null,
        products: Product.toModelList(jsonDecode(element[SpecialOrder.PRODUCTS])),
        totalAmount: element[SpecialOrder.TOTAL_AMOUNT],
        advancePayment: element[SpecialOrder.ADVANCE_PAYMENT],
        remainingPayment: element[SpecialOrder.REMAINING_PAYMENT],
        paidInFull: element[SpecialOrder.PAID_IN_FULL] == 1 ? true : false,
        note: element[SpecialOrder.NOTE].toString(),
        firstModified: DateTime.parse(element[SpecialOrder.FIRST_MODIFIED]),
        lastModified: DateTime.parse(element[SpecialOrder.LAST_MODIFIED]),
      );

      parsedList.add(specialOrder);
      if (maps.length == parsedList.length) {
        c.complete(parsedList);
      }
    });

    return c.future;
  }

  /// where : "id = ?"
  /// whereArgs : [2]
  static Future<void> update({String where, dynamic whereArgs, SpecialOrder specialOrder}) async {
    specialOrder.lastModified = DateTime.now();

    // saving reference id for customer and employee
    Map<String, dynamic> specialOrderMapped = SpecialOrder.toMap(specialOrder);
    specialOrderMapped[SpecialOrder.CUSTOMER] = specialOrder.customer == null ? null : specialOrder.customer.id;
    specialOrderMapped[SpecialOrder.EMPLOYEE] = specialOrder.employee == null ? null : specialOrder.employee.id;

    await global.db.update(TABLE_NAME, specialOrderMapped, where: where, whereArgs: whereArgs);
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
