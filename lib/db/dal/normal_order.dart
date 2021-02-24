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

  static Future<List<NormalOrder>> find({String where, List<dynamic> whereArgs}) async {
    String statement = "SELECT "
        "$TABLE_NAME.${NormalOrder.ID} AS $TABLE_NAME${NormalOrder.ID},"
        "$TABLE_NAME.${NormalOrder.ID_FS} AS $TABLE_NAME${NormalOrder.ID_FS},"
        "$TABLE_NAME.${NormalOrder.EMPLOYEE} AS $TABLE_NAME${NormalOrder.EMPLOYEE},"
        "$TABLE_NAME.${NormalOrder.CUSTOMER} AS $TABLE_NAME${NormalOrder.CUSTOMER},"
        "$TABLE_NAME.${NormalOrder.PRODUCTS} AS $TABLE_NAME${NormalOrder.PRODUCTS},"
        "$TABLE_NAME.${NormalOrder.TOTAL_AMOUNT} AS $TABLE_NAME${NormalOrder.TOTAL_AMOUNT},"
        "$TABLE_NAME.${NormalOrder.ADVANCE_PAYMENT} AS $TABLE_NAME${NormalOrder.ADVANCE_PAYMENT},"
        "$TABLE_NAME.${NormalOrder.REMAINING_PAYMENT} AS $TABLE_NAME${NormalOrder.REMAINING_PAYMENT},"
        "$TABLE_NAME.${NormalOrder.PAID_IN_FULL} AS $TABLE_NAME${NormalOrder.PAID_IN_FULL},"
        "$TABLE_NAME.${NormalOrder.STATUS} AS $TABLE_NAME${NormalOrder.STATUS},"
        "$TABLE_NAME.${NormalOrder.USER_NOTIFIED} AS $TABLE_NAME${NormalOrder.USER_NOTIFIED},"
        "$TABLE_NAME.${NormalOrder.FIRST_MODIFIED} AS $TABLE_NAME${NormalOrder.FIRST_MODIFIED},"
        "$TABLE_NAME.${NormalOrder.LAST_MODIFIED} AS $TABLE_NAME${NormalOrder.LAST_MODIFIED},"
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
        "LEFT JOIN ${PersonnelDAL.TABLE_NAME} AS ${Personnel.CUSTOMER} ON $TABLE_NAME.${NormalOrder.CUSTOMER}=${Personnel.CUSTOMER}.${Personnel.ID} "
        "LEFT JOIN ${PersonnelDAL.TABLE_NAME} AS ${Personnel.EMPLOYEE} ON $TABLE_NAME.${NormalOrder.EMPLOYEE}=${Personnel.EMPLOYEE}.${Personnel.ID} "
        "${where == null ? "" : "WHERE $where"}  ORDER BY $TABLE_NAME.${NormalOrder.LAST_MODIFIED} DESC";

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

      NormalOrder normalOrder = NormalOrder(
        id: list[i]["$TABLE_NAME${NormalOrder.ID}"],
        idFS: list[i]["$TABLE_NAME${NormalOrder.ID_FS}"],
        employee: employee,
        customer: customer,
        products: Product.toModelList(jsonDecode(list[i]["$TABLE_NAME${NormalOrder.PRODUCTS}"])),
        totalAmount: list[i]["$TABLE_NAME${NormalOrder.TOTAL_AMOUNT}"],
        advancePayment: list[i]["$TABLE_NAME${NormalOrder.ADVANCE_PAYMENT}"],
        remainingPayment: list[i]["$TABLE_NAME${NormalOrder.REMAINING_PAYMENT}"],
        paidInFull: list[i]["$TABLE_NAME${NormalOrder.PAID_IN_FULL}"] == 1 ? true : false,
        status: list[i]["$TABLE_NAME${NormalOrder.STATUS}"],
        userNotified: list[i]["$TABLE_NAME${NormalOrder.USER_NOTIFIED}"] == 1 ? true : false,
        firstModified: list[i]["$TABLE_NAME${NormalOrder.FIRST_MODIFIED}"] == null ? null : DateTime.parse(list[i]["$TABLE_NAME${NormalOrder.FIRST_MODIFIED}"]),
        lastModified: list[i]["$TABLE_NAME${NormalOrder.LAST_MODIFIED}"] == null ? null : DateTime.parse(list[i]["$TABLE_NAME${NormalOrder.LAST_MODIFIED}"]),
      );

      return normalOrder;
    });
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
