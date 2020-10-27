import 'package:captain/db/model/normal_order.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:captain/global.dart' as global;

class NormalOrderDAL {
  static const String TABLE_NAME = NormalOrder.COLLECTION_NAME;


  static Future<Database> getDatabase() async {
    String createTable =
        "CREATE TABLE $TABLE_NAME (" +
            "${NormalOrder.ID} INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL," +
            "${NormalOrder.EMPLOYEE} BLOB," +
            "${NormalOrder.CUSTOMER} BLOB," +
            "${NormalOrder.PAINT_ORDER} BLOB," +
            "${NormalOrder.OTHER_PRODUCTS} BLOB," +
            "${NormalOrder.VOLUME} REAL," +
            "${NormalOrder.TOTAL_AMOUNT} REAL," +
            "${NormalOrder.ADVANCE_PAYMENT} REAL," +
            "${NormalOrder.REMAINING_PAYMENT} REAL," +
            "${NormalOrder.PAID_IN_FULL} BLOB," +
            "${NormalOrder.STATUS} TEXT," +
            "${NormalOrder.USER_NOTIFIED} BLOB," +
            "${NormalOrder.FIRST_MODIFIED} BLOB," +
            "${NormalOrder.LAST_MODIFIED} BLOB" +
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

  static Future<void> create(NormalOrder normalOrder) async {
    // updating first and last modified stamps.
    normalOrder.firstModified = DateTime.now();
    normalOrder.lastModified = DateTime.now();

    // Get a reference to the database.
    final Database db = await getDatabase();
    await db.insert(TABLE_NAME, NormalOrder.toMap(normalOrder), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  /// where : "id = ?"
  /// whereArgs : [2]
  static Future<List<NormalOrder>> find({String where, dynamic whereArgs}) async {
    final Database db = await getDatabase();
    final List<Map<String, dynamic>> maps = where == null
        ? await db.query(
      TABLE_NAME,
    )
        : await db.query(TABLE_NAME, where: where, whereArgs: whereArgs);

    return List.generate(maps.length, (i) {
      return NormalOrder(
        id: maps[i][NormalOrder.ID],
        employee: maps[i][NormalOrder.EMPLOYEE],
        customer: maps[i][NormalOrder.CUSTOMER],
        paintOrder: maps[i][NormalOrder.PAINT_ORDER],
        otherProducts: maps[i][NormalOrder.OTHER_PRODUCTS],
        volume: maps[i][NormalOrder.VOLUME],
        totalAmount: maps[i][NormalOrder.TOTAL_AMOUNT],
        advancePayment: maps[i][NormalOrder.ADVANCE_PAYMENT],
        remainingPayment: maps[i][NormalOrder.REMAINING_PAYMENT],
        paidInFull: maps[i][NormalOrder.PAID_IN_FULL],
        status: maps[i][NormalOrder.STATUS],
        userNotified: maps[i][NormalOrder.USER_NOTIFIED],
        firstModified: maps[i][NormalOrder.FIRST_MODIFIED],
        lastModified: maps[i][NormalOrder.LAST_MODIFIED],
      );
    });
  }

  /// where : "id = ?"
  /// whereArgs : [2]
  static Future<void> update({String where, dynamic whereArgs, NormalOrder normalOrder}) async {
    normalOrder.lastModified = DateTime.now();
    final Database db = await getDatabase();
    await db.update(TABLE_NAME, NormalOrder.toMap(normalOrder), where: where, whereArgs: whereArgs);
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
