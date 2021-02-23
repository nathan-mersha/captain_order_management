import 'dart:async';
import 'dart:convert';

import 'package:captain/db/dal/normal_order.dart';
import 'package:captain/db/dal/personnel.dart';
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

    Map<String, dynamic> returnedOrderMapped = ReturnedOrder.toMap(returnedOrder);
    returnedOrderMapped[ReturnedOrder.EMPLOYEE] = returnedOrder.employee == null ? null : returnedOrder.employee.id;
    returnedOrderMapped[ReturnedOrder.CUSTOMER] = returnedOrder.customer == null ? null : returnedOrder.customer.id;

    // Get a reference to the database.
    await global.db.insert(TABLE_NAME, returnedOrderMapped, conflictAlgorithm: ConflictAlgorithm.replace);
    return returnedOrder;
  }

  static Future<List<ReturnedOrder>> find({String where, List<dynamic> whereArgs}) async {
    String statement = "SELECT "
        "$TABLE_NAME.${ReturnedOrder.ID} AS $TABLE_NAME${ReturnedOrder.ID},"
        "$TABLE_NAME.${ReturnedOrder.ID_FS} AS $TABLE_NAME${ReturnedOrder.ID_FS},"
        "$TABLE_NAME.${ReturnedOrder.EMPLOYEE} AS $TABLE_NAME${ReturnedOrder.EMPLOYEE},"
        "$TABLE_NAME.${ReturnedOrder.CUSTOMER} AS $TABLE_NAME${ReturnedOrder.CUSTOMER},"
        "$TABLE_NAME.${ReturnedOrder.PRODUCT} AS $TABLE_NAME${ReturnedOrder.PRODUCT},"
        "$TABLE_NAME.${ReturnedOrder.COUNT} AS $TABLE_NAME${ReturnedOrder.COUNT},"
        "$TABLE_NAME.${ReturnedOrder.NOTE} AS $TABLE_NAME${ReturnedOrder.NOTE},"
        "$TABLE_NAME.${ReturnedOrder.FIRST_MODIFIED} AS $TABLE_NAME${ReturnedOrder.FIRST_MODIFIED},"
        "$TABLE_NAME.${ReturnedOrder.LAST_MODIFIED} AS $TABLE_NAME${ReturnedOrder.LAST_MODIFIED},"
        // populating customer
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
        "${Personnel.CUSTOMER}.${Personnel.LAST_MODIFIED} AS ${Personnel.CUSTOMER}${Personnel.LAST_MODIFIED},"
        // populating employee
        "${Personnel.EMPLOYEE}.${Personnel.ID} AS ${Personnel.EMPLOYEE}${Personnel.ID},"
        "${Personnel.EMPLOYEE}.${Personnel.ID_FS} AS ${Personnel.EMPLOYEE}${Personnel.ID_FS},"
        "${Personnel.EMPLOYEE}.${Personnel.CONTACT_IDENTIFIER} AS ${Personnel.EMPLOYEE}${Personnel.CONTACT_IDENTIFIER},"
        "${Personnel.EMPLOYEE}.${Personnel.NAME} AS ${Personnel.EMPLOYEE}${Personnel.NAME},"
        "${Personnel.EMPLOYEE}.${Personnel.PHONE_NUMBER} AS ${Personnel.EMPLOYEE}${Personnel.PHONE_NUMBER},"
        "${Personnel.EMPLOYEE}.${Personnel.EMAIL} AS ${Personnel.EMPLOYEE}${Personnel.EMAIL},"
        "${Personnel.EMPLOYEE}.${Personnel.ADDRESS} AS ${Personnel.EMPLOYEE}${Personnel.ADDRESS},"
        "${Personnel.EMPLOYEE}.${Personnel.ADDRESS_DETAIL} AS ${Personnel.EMPLOYEE}${Personnel.ADDRESS_DETAIL},"
        "${Personnel.EMPLOYEE}.${Personnel.TYPE} AS ${Personnel.EMPLOYEE}${Personnel.TYPE},"
        "${Personnel.EMPLOYEE}.${Personnel.PROFILE_IMAGE} AS ${Personnel.EMPLOYEE}${Personnel.PROFILE_IMAGE},"
        "${Personnel.EMPLOYEE}.${Personnel.NOTE} AS ${Personnel.EMPLOYEE}${Personnel.NOTE},"
        "${Personnel.EMPLOYEE}.${Personnel.FIRST_MODIFIED} AS ${Personnel.EMPLOYEE}${Personnel.FIRST_MODIFIED},"
        "${Personnel.EMPLOYEE}.${Personnel.LAST_MODIFIED} AS ${Personnel.EMPLOYEE}${Personnel.LAST_MODIFIED} "
        "FROM $TABLE_NAME "
        "LEFT JOIN ${PersonnelDAL.TABLE_NAME} AS ${Personnel.CUSTOMER} ON $TABLE_NAME.${ReturnedOrder.CUSTOMER}=${Personnel.CUSTOMER}.${Personnel.ID} "
        "LEFT JOIN ${PersonnelDAL.TABLE_NAME} AS ${Personnel.EMPLOYEE} ON $TABLE_NAME.${ReturnedOrder.EMPLOYEE}=${Personnel.EMPLOYEE}.${Personnel.ID} "
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

      Personnel employee = Personnel(
        id: list[i]["${Personnel.EMPLOYEE}${Personnel.ID}"],
        idFS: list[i]["${Personnel.EMPLOYEE}${Personnel.ID_FS}"],
        contactIdentifier: list[i]["${Personnel.EMPLOYEE}${Personnel.CONTACT_IDENTIFIER}"],
        name: list[i]["${Personnel.EMPLOYEE}${Personnel.NAME}"],
        phoneNumber: list[i]["${Personnel.EMPLOYEE}${Personnel.PHONE_NUMBER}"],
        email: list[i]["${Personnel.EMPLOYEE}${Personnel.EMAIL}"],
        address: list[i]["${Personnel.EMPLOYEE}${Personnel.ADDRESS}"],
        addressDetail: list[i]["${Personnel.EMPLOYEE}${Personnel.ADDRESS_DETAIL}"],
        type: list[i]["${Personnel.EMPLOYEE}${Personnel.TYPE}"],
        profileImage: list[i]["${Personnel.EMPLOYEE}${Personnel.PROFILE_IMAGE}"],
        note: list[i]["${Personnel.EMPLOYEE}${Personnel.NOTE}"],
        firstModified: list[i]["${Personnel.EMPLOYEE}${Personnel.FIRST_MODIFIED}"] == null ? null : DateTime.parse(list[i]["${Personnel.EMPLOYEE}${Personnel.FIRST_MODIFIED}"]),
        lastModified: list[i]["${Personnel.EMPLOYEE}${Personnel.LAST_MODIFIED}"] == null ? null : DateTime.parse(list[i]["${Personnel.EMPLOYEE}${Personnel.LAST_MODIFIED}"]),
      );

      ReturnedOrder returnedOrder = ReturnedOrder(
        id: list[i]["$TABLE_NAME${ReturnedOrder.ID}"],
        idFS: list[i]["$TABLE_NAME${ReturnedOrder.ID_FS}"],
        employee: employee,
        customer: customer,
        product: Product.toModel(jsonDecode(list[i]["$TABLE_NAME${ReturnedOrder.PRODUCT}"])),
        count: list[i]["$TABLE_NAME${ReturnedOrder.COUNT}"],
        note: list[i]["$TABLE_NAME${ReturnedOrder.NOTE}"],
        firstModified: list[i]["$TABLE_NAME${ReturnedOrder.FIRST_MODIFIED}"] == null ? null : DateTime.parse(list[i]["$TABLE_NAME${ReturnedOrder.FIRST_MODIFIED}"]),
        lastModified: list[i]["$TABLE_NAME${ReturnedOrder.LAST_MODIFIED}"] == null ? null : DateTime.parse(list[i]["$TABLE_NAME${ReturnedOrder.LAST_MODIFIED}"]),
      );

      return returnedOrder;
    });
  }

  /// where : "id = ?"
  /// whereArgs : [2]
  static Future<void> update({String where, dynamic whereArgs, ReturnedOrder returnedOrder}) async {
    returnedOrder.lastModified = DateTime.now();

    Map<String, dynamic> returnedOrderMapped = ReturnedOrder.toMap(returnedOrder);
    returnedOrderMapped[ReturnedOrder.EMPLOYEE] = returnedOrder.employee == null ? null : returnedOrder.employee.id;
    returnedOrderMapped[ReturnedOrder.CUSTOMER] = returnedOrder.customer == null ? null : returnedOrder.customer.id;

    await global.db.update(TABLE_NAME, returnedOrderMapped, where: where, whereArgs: whereArgs);
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
