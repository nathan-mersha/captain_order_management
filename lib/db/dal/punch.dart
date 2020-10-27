import 'package:captain/db/model/punch.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:captain/global.dart' as global;

class PunchDAL {
  static const String TABLE_NAME = Punch.COLLECTION_NAME;


  static Future<Database> getDatabase() async {
    String createTable =
        "CREATE TABLE $TABLE_NAME (" +
            "${Punch.ID} INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL," +
            "${Punch.EMPLOYEE} BLOB," +
            "${Punch.PRODUCT} BLOB," +
            "${Punch.TYPE} TEXT," +
            "${Punch.WEIGHT} REAL," +
            "${Punch.NOTE} TEXT," +
            "${Punch.FIRST_MODIFIED} BLOB," +
            "${Punch.LAST_MODIFIED} BLOB" +
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

  static Future<void> create(Punch normalOrder) async {
    // updating first and last modified stamps.
    normalOrder.firstModified = DateTime.now();
    normalOrder.lastModified = DateTime.now();

    // Get a reference to the database.
    final Database db = await getDatabase();
    await db.insert(TABLE_NAME, Punch.toMap(normalOrder), conflictAlgorithm: ConflictAlgorithm.replace);
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
        employee: maps[i][Punch.EMPLOYEE],
        product: maps[i][Punch.PRODUCT],
        type: maps[i][Punch.TYPE],
        weight: maps[i][Punch.WEIGHT],
        note: maps[i][Punch.NOTE],
        firstModified: maps[i][Punch.FIRST_MODIFIED],
        lastModified: maps[i][Punch.LAST_MODIFIED],
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
