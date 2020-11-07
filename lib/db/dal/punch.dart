import 'package:captain/db/model/punch.dart';
import 'package:sqflite/sqflite.dart';
import 'package:captain/global.dart' as global;
import 'package:uuid/uuid.dart';

class PunchDAL {
  static const String TABLE_NAME = Punch.COLLECTION_NAME;

  static String createTable = "CREATE TABLE $TABLE_NAME (" +
      "${Punch.ID} TEXT," +
      "${Punch.ID_FS} TEXT," +
      "${Punch.EMPLOYEE} BLOB," +
      "${Punch.PRODUCT} BLOB," +
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

    // Get a reference to the database.
    await global.db.insert(TABLE_NAME, Punch.toMap(punch), conflictAlgorithm: ConflictAlgorithm.replace);
    return punch;
  }

  /// where : "id = ?"
  /// whereArgs : [2]
  static Future<List<Punch>> find({String where, dynamic whereArgs}) async {
    final List<Map<String, dynamic>> maps = where == null
        ? await global.db.query(
            TABLE_NAME,
          )
        : await global.db.query(TABLE_NAME, where: where, whereArgs: whereArgs, orderBy: "${Punch.LAST_MODIFIED} DESC");

    return List.generate(maps.length, (i) {
      return Punch(
        id: maps[i][Punch.ID],
        idFS: maps[i][Punch.ID_FS],
        employee: maps[i][Punch.EMPLOYEE],
        product: maps[i][Punch.PRODUCT],
        type: maps[i][Punch.TYPE],
        weight: maps[i][Punch.WEIGHT],
        note: maps[i][Punch.NOTE],
        firstModified: DateTime.parse(maps[i][Punch.FIRST_MODIFIED]),
        lastModified: DateTime.parse(maps[i][Punch.LAST_MODIFIED]),
      );
    });
  }

  /// where : "id = ?"
  /// whereArgs : [2]
  static Future<void> update({String where, dynamic whereArgs, Punch normalOrder}) async {
    normalOrder.lastModified = DateTime.now();
    await global.db.update(TABLE_NAME, Punch.toMap(normalOrder), where: where, whereArgs: whereArgs);
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
