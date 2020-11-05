import 'package:captain/db/model/normal_order.dart';
import 'package:captain/db/model/punch.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:captain/global.dart' as global;
import 'package:uuid/uuid.dart';

class PunchDAL {
  static const String TABLE_NAME = Punch.COLLECTION_NAME;


  static Future<Database> getDatabase() async {
    String createTable =
        "CREATE TABLE $TABLE_NAME (" +
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

    final database = openDatabase(
      join(await getDatabasesPath(), global.DB_NAME),
      onCreate: (db, version) {
        return db.execute(createTable);
      },
      version: 1,
    );

    return database;
  }

  static Future<Punch> create(Punch punch) async {
    // updating first and last modified stamps.
    var uuid = Uuid();
    punch.id = uuid.hashCode.toString();
    punch.firstModified = DateTime.now();
    punch.lastModified = DateTime.now();

    // Get a reference to the database.
    final Database db = await getDatabase();
    int val = await db.insert(TABLE_NAME, Punch.toMap(punch), conflictAlgorithm: ConflictAlgorithm.replace);
    return val == 1 ? punch : null;
  }

  /// where : "id = ?"
  /// whereArgs : [2]
  static Future<List<Punch>> find({String where, dynamic whereArgs}) async {
    final Database db = await getDatabase();
    final List<Map<String, dynamic>> maps = where == null
        ? await db.query(
      TABLE_NAME,
    )
        : await db.query(TABLE_NAME, where: where, whereArgs: whereArgs);

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
    final Database db = await getDatabase();
    await db.update(TABLE_NAME, Punch.toMap(normalOrder), where: where, whereArgs: whereArgs);
  }

  /// where : "id = ?"
  /// whereArgs : [2]
  static Future<void> delete(String where, dynamic whereArgs) async {
    final Database db = await getDatabase();
    await db.delete(
      TABLE_NAME,
      where: where,
      whereArgs: whereArgs,
    );
  }
}
