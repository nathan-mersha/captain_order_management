import 'dart:async';
import 'dart:convert';
import 'package:captain/db/dal/personnel.dart';
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
    /// Assigning customer and employee id reference than actual object
    Map<String, dynamic> normalOrderMapped = NormalOrder.toMap(normalOrder);
    normalOrderMapped[NormalOrder.CUSTOMER] = normalOrder.customer == null ? null : normalOrder.customer.id;
    normalOrderMapped[NormalOrder.EMPLOYEE] = normalOrder.employee == null ? null : normalOrder.employee.id;

    await global.db.insert(TABLE_NAME, normalOrderMapped, conflictAlgorithm: ConflictAlgorithm.replace);
    return normalOrder;
  }

  /// where : "id = ?"
  /// whereArgs : [2]
  static Future<List<NormalOrder>> find({String where, dynamic whereArgs}) async {
    final List<Map<String, dynamic>> maps = where == null
        ? await global.db.query(TABLE_NAME, orderBy: "${NormalOrder.LAST_MODIFIED} DESC")
        : await global.db.query(TABLE_NAME, where: where, whereArgs: whereArgs, orderBy: "${NormalOrder.LAST_MODIFIED} DESC");

    List<NormalOrder> parsedList = [];
    final c = Completer<List<NormalOrder>>();

    maps.forEach((Map<String, dynamic> element) async {
      NormalOrder normalOrder = NormalOrder(
        id: element[NormalOrder.ID],
        idFS: element[NormalOrder.ID_FS],
        employee: await getPersonnel(element[Personnel.EMPLOYEE]),
        customer: await getPersonnel(element[Personnel.CUSTOMER]),
        products: Product.toModelList(jsonDecode(element[NormalOrder.PRODUCTS])),
        totalAmount: element[NormalOrder.TOTAL_AMOUNT],
        advancePayment: element[NormalOrder.ADVANCE_PAYMENT],
        remainingPayment: element[NormalOrder.REMAINING_PAYMENT],
        paidInFull: element[NormalOrder.PAID_IN_FULL] == 1 ? true : false,
        status: element[NormalOrder.STATUS],
        userNotified: element[NormalOrder.USER_NOTIFIED] == 1 ? true : false,
        firstModified: DateTime.parse(element[NormalOrder.FIRST_MODIFIED]),
        lastModified: DateTime.parse(element[NormalOrder.LAST_MODIFIED]),
      );

      parsedList.add(normalOrder);
      if (maps.length == parsedList.length) {
        c.complete(parsedList);
      }
    });

    return c.future;
  }

  static Future<Personnel> getPersonnel(String id) async {
    if (id == null) {
      return null;
    } else {
      String where = "${Personnel.ID} = ?";
      List<String> whereArgs = [id];
      List<Personnel> personnel = await PersonnelDAL.find(where: where, whereArgs: whereArgs);
      return personnel.length > 0 ? personnel.first : null;
    }
  }

  /// where : "id = ?"
  /// whereArgs : [2]
  static Future<void> update({String where, dynamic whereArgs, NormalOrder normalOrder}) async {
    normalOrder.lastModified = DateTime.now();

    Map<String, dynamic> normalOrderMapped = NormalOrder.toMap(normalOrder);
    normalOrderMapped[NormalOrder.CUSTOMER] = normalOrder.customer == null ? null : normalOrder.customer.id;
    normalOrderMapped[NormalOrder.EMPLOYEE] = normalOrder.employee == null ? null : normalOrder.employee.id;

    await global.db.update(TABLE_NAME, normalOrderMapped, where: where, whereArgs: whereArgs);
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
