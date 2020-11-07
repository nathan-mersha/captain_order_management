import 'package:captain/db/model/personnel.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';
import 'package:captain/global.dart' as global;


class PersonnelDAL {
  static const String TABLE_NAME = Personnel.COLLECTION_NAME;

  static String createTable = "CREATE TABLE $TABLE_NAME (" +
      "${Personnel.ID} TEXT," +
      "${Personnel.ID_FS} TEXT," +
      "${Personnel.CONTACT_IDENTIFIER} TEXT," +
      "${Personnel.NAME} TEXT," +
      "${Personnel.PHONE_NUMBER} TEXT," +
      "${Personnel.EMAIL} TEXT," +
      "${Personnel.ADDRESS} TEXT," +
      "${Personnel.ADDRESS_DETAIL} TEXT," +
      "${Personnel.TYPE} TEXT," +
      "${Personnel.PROFILE_IMAGE} BLOB," +
      "${Personnel.NOTE} TEXT," +
      "${Personnel.FIRST_MODIFIED} TEXT," +
      "${Personnel.LAST_MODIFIED} TEXT" +
      ")";

  static Future<Personnel> create(Personnel personnel) async {
    // updating first and last modified stamps.
    var uuid = Uuid();
    personnel.id = uuid.hashCode.toString();
    personnel.firstModified = DateTime.now();
    personnel.lastModified = DateTime.now();

    // Get a reference to the database.
    await global.db.insert(TABLE_NAME, Personnel.toMap(personnel), conflictAlgorithm: ConflictAlgorithm.replace);
    return personnel;
  }

  /// where : "id = ?"
  /// whereArgs : [2]
  static Future<List<Personnel>> find({String where, dynamic whereArgs}) async {
    final List<Map<String, dynamic>> maps = where == null
        ? await global.db.query(
            TABLE_NAME,
          )
        : await global.db.query(TABLE_NAME, where: where, whereArgs: whereArgs,orderBy: "${Personnel.LAST_MODIFIED} DESC");

    return List.generate(maps.length, (i) {
      return Personnel(
          id: maps[i][Personnel.ID],
          idFS: maps[i][Personnel.ID_FS],
          contactIdentifier: maps[i][Personnel.CONTACT_IDENTIFIER],
          name: maps[i][Personnel.NAME],
          phoneNumber: maps[i][Personnel.PHONE_NUMBER],
          email: maps[i][Personnel.EMAIL],
          address: maps[i][Personnel.ADDRESS],
          addressDetail: maps[i][Personnel.ADDRESS_DETAIL],
          type: maps[i][Personnel.TYPE],
          profileImage: maps[i][Personnel.PROFILE_IMAGE],
          note: maps[i][Personnel.NOTE],
          firstModified: DateTime.parse(maps[i][Personnel.FIRST_MODIFIED]),
          lastModified: DateTime.parse(maps[i][Personnel.LAST_MODIFIED]));
    });
  }

  /// where : "id = ?"
  /// whereArgs : [2]
  static Future<void> update({String where, dynamic whereArgs, Personnel personnel}) async {
    personnel.lastModified = DateTime.now();
    await global.db.update(TABLE_NAME, Personnel.toMap(personnel), where: where, whereArgs: whereArgs);
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
