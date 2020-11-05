import 'package:captain/db/model/returned_order.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:captain/global.dart' as global;
import 'package:uuid/uuid.dart';

class ReturnedOrderDAL {
  static const String TABLE_NAME = ReturnedOrder.COLLECTION_NAME;

  static Future<Database> getDatabase() async {
    String createTable = "CREATE TABLE $TABLE_NAME (" +
        "${ReturnedOrder.ID} TEXT," +
        "${ReturnedOrder.ID_FS} TEXT," +
        "${ReturnedOrder.EMPLOYEE} BLOB," +
        "${ReturnedOrder.CUSTOMER} BLOB," +
        "${ReturnedOrder.PRODUCT} BLOB," +
        "${ReturnedOrder.COUNT} INTEGER," +
        "${ReturnedOrder.NOTE} TEXT," +
        "${ReturnedOrder.FIRST_MODIFIED} TEXT," +
        "${ReturnedOrder.LAST_MODIFIED} TEXT" +
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

  static Future<ReturnedOrder> create(ReturnedOrder returnedOrder) async {
    // updating first and last modified stamps.
    var uuid = Uuid();
    returnedOrder.id = uuid.hashCode.toString();
    returnedOrder.firstModified = DateTime.now();
    returnedOrder.lastModified = DateTime.now();

    // Get a reference to the database.
    final Database db = await getDatabase();
    int val = await db.insert(TABLE_NAME, ReturnedOrder.toMap(returnedOrder), conflictAlgorithm: ConflictAlgorithm.replace);
    return val == 1 ? returnedOrder : null;
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
        idFS: maps[i][ReturnedOrder.ID_FS],
        employee: maps[i][ReturnedOrder.EMPLOYEE],
        customer: maps[i][ReturnedOrder.CUSTOMER],
        product: maps[i][ReturnedOrder.PRODUCT],
        count: maps[i][ReturnedOrder.COUNT],
        note: maps[i][ReturnedOrder.NOTE],
        firstModified: DateTime.parse(maps[i][ReturnedOrder.FIRST_MODIFIED]),
        lastModified: DateTime.parse(maps[i][ReturnedOrder.LAST_MODIFIED]),
      );
    });
  }

  /// where : "id = ?"
  /// whereArgs : [2]
  static Future<void> update({String where, dynamic whereArgs, ReturnedOrder returnedOrder}) async {
    returnedOrder.lastModified = DateTime.now();
    final Database db = await getDatabase();
    await db.update(TABLE_NAME, ReturnedOrder.toMap(returnedOrder), where: where, whereArgs: whereArgs);
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
