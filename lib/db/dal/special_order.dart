import 'dart:async';
import 'dart:convert';

import 'package:captain/db/dal/normal_order.dart';
import 'package:captain/db/dal/personnel.dart';
import 'package:captain/db/model/personnel.dart';
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

  static Future<List<SpecialOrder>> find({String where, List<dynamic> whereArgs}) async {
    String statement = "SELECT "
        "$TABLE_NAME.${SpecialOrder.ID} AS $TABLE_NAME${SpecialOrder.ID},"
        "$TABLE_NAME.${SpecialOrder.ID_FS} AS $TABLE_NAME${SpecialOrder.ID_FS},"
        "$TABLE_NAME.${SpecialOrder.EMPLOYEE} AS $TABLE_NAME${SpecialOrder.EMPLOYEE},"
        "$TABLE_NAME.${SpecialOrder.CUSTOMER} AS $TABLE_NAME${SpecialOrder.CUSTOMER},"
        "$TABLE_NAME.${SpecialOrder.PRODUCTS} AS $TABLE_NAME${SpecialOrder.PRODUCTS},"
        "$TABLE_NAME.${SpecialOrder.TOTAL_AMOUNT} AS $TABLE_NAME${SpecialOrder.TOTAL_AMOUNT},"
        "$TABLE_NAME.${SpecialOrder.ADVANCE_PAYMENT} AS $TABLE_NAME${SpecialOrder.ADVANCE_PAYMENT},"
        "$TABLE_NAME.${SpecialOrder.REMAINING_PAYMENT} AS $TABLE_NAME${SpecialOrder.REMAINING_PAYMENT},"
        "$TABLE_NAME.${SpecialOrder.PAID_IN_FULL} AS $TABLE_NAME${SpecialOrder.PAID_IN_FULL},"
        "$TABLE_NAME.${SpecialOrder.NOTE} AS $TABLE_NAME${SpecialOrder.NOTE},"
        "$TABLE_NAME.${SpecialOrder.FIRST_MODIFIED} AS $TABLE_NAME${SpecialOrder.FIRST_MODIFIED},"
        "$TABLE_NAME.${SpecialOrder.LAST_MODIFIED} AS $TABLE_NAME${SpecialOrder.LAST_MODIFIED},"
        "${Personnel.CUSTOMER}.${Personnel.ID} AS ${Personnel.CUSTOMER}${Personnel.ID},"
        "${Personnel.CUSTOMER}.${Personnel.ID_FS} AS ${Personnel.CUSTOMER}${Personnel.ID_FS},"
        "${Personnel.CUSTOMER}.${Personnel.CONTACT_IDENTIFIER} AS ${Personnel.CUSTOMER}${Personnel.CONTACT_IDENTIFIER},"
        "${Personnel.CUSTOMER}.${Personnel.NAME} AS ${Personnel.CUSTOMER}${Personnel.NAME},"
        "${Personnel.CUSTOMER}.${Personnel.PHONE_NUMBER} AS ${Personnel.CUSTOMER}${Personnel.PHONE_NUMBER},"
        "${Personnel.CUSTOMER}.${Personnel.EMAIL} AS ${Personnel.CUSTOMER}${Personnel.EMAIL},"
        "${Personnel.CUSTOMER}.${Personnel.ADDRESS} AS ${Personnel.CUSTOMER}${Personnel.ADDRESS},"
        "${Personnel.CUSTOMER}.${Personnel.ADDRESS_DETAIL} AS ${Personnel.CUSTOMER}${Personnel.ADDRESS_DETAIL},"
        "${Personnel.CUSTOMER}.${Personnel.TYPE} AS ${Personnel.CUSTOMER}${Personnel.TYPE},"
        "${Personnel.CUSTOMER}.${Personnel.PROFILE_IMAGE} AS ${Personnel.CUSTOMER}${Personnel.PROFILE_IMAGE},"
        "${Personnel.CUSTOMER}.${Personnel.NOTE} AS ${Personnel.CUSTOMER}${Personnel.NOTE},"
        "${Personnel.CUSTOMER}.${Personnel.FIRST_MODIFIED} AS ${Personnel.CUSTOMER}${Personnel.FIRST_MODIFIED},"
        "${Personnel.CUSTOMER}.${Personnel.LAST_MODIFIED} AS ${Personnel.CUSTOMER}${Personnel.LAST_MODIFIED} "
        "FROM $TABLE_NAME "
        "LEFT JOIN ${PersonnelDAL.TABLE_NAME} AS ${Personnel.CUSTOMER} ON $TABLE_NAME.${SpecialOrder.CUSTOMER}=${Personnel.CUSTOMER}.${Personnel.ID} "
        "${where == null ? "" : "WHERE $where"}";

    var list = await global.db.rawQuery(statement, whereArgs);

    return List.generate(list.length, (i) {
      Personnel customer = Personnel(
        id: list[i]["${Personnel.CUSTOMER}${Personnel.ID}"],
        idFS: list[i]["${Personnel.CUSTOMER}${Personnel.ID_FS}"],
        contactIdentifier: list[i]["${Personnel.CUSTOMER}${Personnel.CONTACT_IDENTIFIER}"],
        name: list[i]["${Personnel.CUSTOMER}${Personnel.NAME}"],
        phoneNumber: list[i]["${Personnel.CUSTOMER}${Personnel.PHONE_NUMBER}"],
        email: list[i]["${Personnel.CUSTOMER}${Personnel.EMAIL}"],
        address: list[i]["${Personnel.CUSTOMER}${Personnel.ADDRESS}"],
        addressDetail: list[i]["${Personnel.CUSTOMER}${Personnel.ADDRESS_DETAIL}"],
        type: list[i]["${Personnel.CUSTOMER}${Personnel.TYPE}"],
        profileImage: list[i]["${Personnel.CUSTOMER}${Personnel.PROFILE_IMAGE}"],
        note: list[i]["${Personnel.CUSTOMER}${Personnel.NOTE}"],
        firstModified: list[i]["${Personnel.CUSTOMER}${Personnel.FIRST_MODIFIED}"] == null ? null : DateTime.parse(list[i]["${Personnel.CUSTOMER}${Personnel.FIRST_MODIFIED}"]),
        lastModified: list[i]["${Personnel.CUSTOMER}${Personnel.LAST_MODIFIED}"] == null ? null : DateTime.parse(list[i]["${Personnel.CUSTOMER}${Personnel.LAST_MODIFIED}"]),
      );

      SpecialOrder specialOrder = SpecialOrder(
        id: list[i]["$TABLE_NAME${SpecialOrder.ID}"],
        idFS: list[i]["$TABLE_NAME${SpecialOrder.ID_FS}"],
        customer: customer,
        products: Product.toModelList(jsonDecode(list[i]["$TABLE_NAME${SpecialOrder.PRODUCTS}"])),
        totalAmount: list[i]["$TABLE_NAME${SpecialOrder.TOTAL_AMOUNT}"],
        advancePayment: list[i]["$TABLE_NAME${SpecialOrder.ADVANCE_PAYMENT}"],
        remainingPayment: list[i]["$TABLE_NAME${SpecialOrder.REMAINING_PAYMENT}"],
        paidInFull: list[i]["$TABLE_NAME${SpecialOrder.PAID_IN_FULL}"] == 1 ? true : false,
        note: list[i]["$TABLE_NAME${SpecialOrder.NOTE}"].toString(),
        firstModified: list[i]["$TABLE_NAME${SpecialOrder.FIRST_MODIFIED}"] == null ? null : DateTime.parse(list[i]["$TABLE_NAME${SpecialOrder.FIRST_MODIFIED}"]),
        lastModified: list[i]["$TABLE_NAME${SpecialOrder.LAST_MODIFIED}"] == null ? null : DateTime.parse(list[i]["$TABLE_NAME${SpecialOrder.LAST_MODIFIED}"]),
      );

      return specialOrder;
    });
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
