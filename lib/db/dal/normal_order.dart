import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:captain/db/dal/personnel.dart';
import 'package:captain/db/model/normal_order.dart';
import 'package:captain/db/model/personnel.dart';
import 'package:captain/db/model/product.dart';
import 'package:flutter/material.dart';
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
  static Future<List<NormalOrder>> find({String where, dynamic whereArgs, bool populatePersonnel = true}) async {
    DateTime start  = DateTime.now();
    DateTime end;
    final List<Map<String, dynamic>> maps = where == null
        ? await global.db.query(TABLE_NAME, orderBy: "${NormalOrder.LAST_MODIFIED} DESC")
        : await global.db.query(TABLE_NAME, where: where, whereArgs: whereArgs, orderBy: "${NormalOrder.LAST_MODIFIED} DESC");

    List<NormalOrder> parsedList = [];
    final c = Completer<List<NormalOrder>>();

    maps.forEach((Map<String, dynamic> element) async {
      NormalOrder normalOrder = NormalOrder(
        id: element[NormalOrder.ID],
        idFS: element[NormalOrder.ID_FS],
        // employee: populatePersonnel ? await getPersonnel(element[Personnel.EMPLOYEE]) : null,
        customer: populatePersonnel ? await getPersonnel(element[Personnel.CUSTOMER]) : null,
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
        end = DateTime.now();
        int durationTaken = DateTimeRange(start: start, end: end).duration.inSeconds;
        print("Duration to execute query of ${maps.length} normal orders took : $durationTaken seconds, populate is : ${populatePersonnel}");
      }
    });

    return c.future;
  }

  static Future<List<NormalOrder>> rawFindInnerJoin() async{
    DateTime start  = DateTime.now();
    DateTime end;
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

        "${PersonnelDAL.TABLE_NAME}.${Personnel.ID} AS ${PersonnelDAL.TABLE_NAME}${Personnel.ID},"
        "${PersonnelDAL.TABLE_NAME}.${Personnel.ID_FS} AS ${PersonnelDAL.TABLE_NAME}${Personnel.ID_FS},"
        "${PersonnelDAL.TABLE_NAME}.${Personnel.CONTACT_IDENTIFIER} AS ${PersonnelDAL.TABLE_NAME}${Personnel.CONTACT_IDENTIFIER},"
        "${PersonnelDAL.TABLE_NAME}.${Personnel.NAME} AS ${PersonnelDAL.TABLE_NAME}${Personnel.NAME},"
        "${PersonnelDAL.TABLE_NAME}.${Personnel.PHONE_NUMBER} AS ${PersonnelDAL.TABLE_NAME}${Personnel.PHONE_NUMBER},"
        "${PersonnelDAL.TABLE_NAME}.${Personnel.EMAIL} AS ${PersonnelDAL.TABLE_NAME}${Personnel.EMAIL},"
        "${PersonnelDAL.TABLE_NAME}.${Personnel.ADDRESS} AS ${PersonnelDAL.TABLE_NAME}${Personnel.ADDRESS},"
        "${PersonnelDAL.TABLE_NAME}.${Personnel.ADDRESS_DETAIL} AS ${PersonnelDAL.TABLE_NAME}${Personnel.ADDRESS_DETAIL},"
        "${PersonnelDAL.TABLE_NAME}.${Personnel.TYPE} AS ${PersonnelDAL.TABLE_NAME}${Personnel.TYPE},"
        "${PersonnelDAL.TABLE_NAME}.${Personnel.PROFILE_IMAGE} AS ${PersonnelDAL.TABLE_NAME}${Personnel.PROFILE_IMAGE},"
        "${PersonnelDAL.TABLE_NAME}.${Personnel.NOTE} AS ${PersonnelDAL.TABLE_NAME}${Personnel.NOTE},"
        "${PersonnelDAL.TABLE_NAME}.${Personnel.FIRST_MODIFIED} AS ${PersonnelDAL.TABLE_NAME}${Personnel.FIRST_MODIFIED},"
        "${PersonnelDAL.TABLE_NAME}.${Personnel.FIRST_MODIFIED} AS ${PersonnelDAL.TABLE_NAME}${Personnel.FIRST_MODIFIED} "

        "FROM $TABLE_NAME "
        "JOIN ${PersonnelDAL.TABLE_NAME} AS customer ON $TABLE_NAME.${NormalOrder.CUSTOMER}=${PersonnelDAL.TABLE_NAME}.${Personnel.ID} "
        "JOIN ${PersonnelDAL.TABLE_NAME} AS employee ON $TABLE_NAME.${NormalOrder.EMPLOYEE}=${PersonnelDAL.TABLE_NAME}.${Personnel.ID} "

    ;

    String all = "SELECT * FROM $TABLE_NAME";
    print("Sql statement is : --------- ");
    log(statement);
    print("Sql statement end");
    var list = await global.db.rawQuery(statement);
    log(list[0].toString());
    end = DateTime.now();
    int durationTaken = DateTimeRange(start: start, end: end).duration.inSeconds;
    print("inner join ---- > Duration to execute query of ${list.length} normal orders took : $durationTaken seconds,}");
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
