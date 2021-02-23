import 'dart:async';
import 'dart:convert';
import 'package:captain/db/dal/personnel.dart';
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
    await global.db.insert(TABLE_NAME, punchMapped, conflictAlgorithm: ConflictAlgorithm.replace);
    return punch;
  }

  static Future<List<Punch>> find({String where, List<dynamic> whereArgs}) async {
    String statement = "SELECT "
        "$TABLE_NAME.${Punch.ID} AS $TABLE_NAME${Punch.ID},"
        "$TABLE_NAME.${Punch.ID_FS} AS $TABLE_NAME${Punch.ID_FS},"
        "$TABLE_NAME.${Punch.EMPLOYEE} AS $TABLE_NAME${Punch.EMPLOYEE},"
        "$TABLE_NAME.${Punch.PRODUCT} AS $TABLE_NAME${Punch.PRODUCT},"
        "$TABLE_NAME.${Punch.TYPE} AS $TABLE_NAME${Punch.TYPE},"
        "$TABLE_NAME.${Punch.WEIGHT} AS $TABLE_NAME${Punch.WEIGHT},"
        "$TABLE_NAME.${Punch.NOTE} AS $TABLE_NAME${Punch.NOTE},"
        "$TABLE_NAME.${Punch.FIRST_MODIFIED} AS $TABLE_NAME${Punch.FIRST_MODIFIED},"
        "$TABLE_NAME.${Punch.LAST_MODIFIED} AS $TABLE_NAME${Punch.LAST_MODIFIED},"
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
        "LEFT JOIN ${PersonnelDAL.TABLE_NAME} AS ${Personnel.EMPLOYEE} ON $TABLE_NAME.${Punch.EMPLOYEE}=${Personnel.EMPLOYEE}.${Personnel.ID} "
        "${where == null ? "" : "WHERE $where"}";

    List list = await global.db.rawQuery(statement, whereArgs);

    return List.generate(list.length, (i) {
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

      Punch punch = Punch(
        id: list[i]["$TABLE_NAME${Punch.ID}"],
        idFS: list[i]["$TABLE_NAME${Punch.ID_FS}"],
        employee: employee,
        product: Product.toModel(jsonDecode(list[i]["$TABLE_NAME${Punch.PRODUCT}"])),
        type: list[i]["$TABLE_NAME${Punch.TYPE}"],
        weight: list[i]["$TABLE_NAME${Punch.WEIGHT}"],
        note: list[i]["$TABLE_NAME${Punch.NOTE}"],
        firstModified: list[i]["$TABLE_NAME${Punch.FIRST_MODIFIED}"] == null ? null : DateTime.parse(list[i]["$TABLE_NAME${Punch.FIRST_MODIFIED}"]),
        lastModified: list[i]["$TABLE_NAME${Punch.LAST_MODIFIED}"] == null ? null : DateTime.parse(list[i]["$TABLE_NAME${Punch.LAST_MODIFIED}"]),
      );

      return punch;
    });
  }

  /// where : "id = ?"
  /// whereArgs : [2]
  static Future<void> update({String where, dynamic whereArgs, Punch punch}) async {
    punch.lastModified = DateTime.now();

    Map<String, dynamic> punchMapped = Punch.toMap(punch);
    punchMapped[Punch.EMPLOYEE] = punch.employee == null ? null : punch.employee.id;

    await global.db.update(TABLE_NAME, punchMapped, where: where, whereArgs: whereArgs);
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
