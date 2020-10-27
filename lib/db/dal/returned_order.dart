import 'package:captain/db/model/returned_order.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:captain/global.dart' as global;

class ReturnedOrderDAL {
  static const String TABLE_NAME = ReturnedOrder.COLLECTION_NAME;


  static Future<Database> getDatabase() async {
    String createTable =
        "CREATE TABLE $TABLE_NAME (" +
            "${ReturnedOrder.ID} INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL," +
            "${ReturnedOrder.EMPLOYEE} BLOB," +
            "${ReturnedOrder.CUSTOMER} BLOB," +
            "${ReturnedOrder.PRODUCT} BLOB," +
            "${ReturnedOrder.COUNT} INTEGER," +
            "${ReturnedOrder.NOTE} TEXT," +
            "${ReturnedOrder.FIRST_MODIFIED} BLOB," +
            "${ReturnedOrder.LAST_MODIFIED} BLOB" +
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

  static Future<void> create(ReturnedOrder normalOrder) async {
    // updating first and last modified stamps.
    normalOrder.firstModified = DateTime.now();
    normalOrder.lastModified = DateTime.now();

    // Get a reference to the database.
    final Database db = await getDatabase();
    await db.insert(TABLE_NAME, ReturnedOrder.toMap(normalOrder), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  /// where : "id = ?"
  /// whereArgs : [2]
  static Future<List<ReturnedOrder>> find({String where, dynamic whereArgs}) async {
    final Database db = await getDatabase();
    final List<Map<String, dynamic>> maps = where == null
        ? await db.query(
      TABLE_NAME,
    )
        : await db.query(TABLE_NAME, where: where, whereArgs: whereArgs);

    return List.generate(maps.length, (i) {
      return ReturnedOrder(
        id: maps[i][ReturnedOrder.ID],
        employee: maps[i][ReturnedOrder.EMPLOYEE],
        customer: maps[i][ReturnedOrder.CUSTOMER],
        product: maps[i][ReturnedOrder.PRODUCT],
        count: maps[i][ReturnedOrder.COUNT],
        note: maps[i][ReturnedOrder.NOTE],
        firstModified: maps[i][ReturnedOrder.FIRST_MODIFIED],
        lastModified: maps[i][ReturnedOrder.LAST_MODIFIED],
      );
    });
  }

  /// where : "id = ?"
  /// whereArgs : [2]
  static Future<void> update({String where, dynamic whereArgs, ReturnedOrder normalOrder}) async {
    normalOrder.lastModified = DateTime.now();
    final Database db = await getDatabase();
    await db.update(TABLE_NAME, ReturnedOrder.toMap(normalOrder), where: where, whereArgs: whereArgs);
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
