import 'package:captain/db/model/special_order.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:captain/global.dart' as global;

class SpecialOrderDAL {
  static const String TABLE_NAME = SpecialOrder.COLLECTION_NAME;


  static Future<Database> getDatabase() async {
    String createTable =
        "CREATE TABLE $TABLE_NAME (" +
            "${SpecialOrder.ID} INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL," +
            "${SpecialOrder.EMPLOYEE} BLOB," +
            "${SpecialOrder.CUSTOMER} BLOB," +
            "${SpecialOrder.PRODUCTS} BLOB," +
            "${SpecialOrder.TOTAL_AMOUNT} REAL," +
            "${SpecialOrder.ADVANCE_PAYMENT} REAL," +
            "${SpecialOrder.REMAINING_PAYMENT} REAL," +
            "${SpecialOrder.PAID_IN_FULL} BLOB," +
            "${SpecialOrder.NOTE} TEXT," +
            "${SpecialOrder.FIRST_MODIFIED} BLOB," +
            "${SpecialOrder.LAST_MODIFIED} BLOB" +
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

  static Future<void> create(SpecialOrder normalOrder) async {
    // updating first and last modified stamps.
    normalOrder.firstModified = DateTime.now();
    normalOrder.lastModified = DateTime.now();

    // Get a reference to the database.
    final Database db = await getDatabase();
    await db.insert(TABLE_NAME, SpecialOrder.toMap(normalOrder), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  /// where : "id = ?"
  /// whereArgs : [2]
  static Future<List<SpecialOrder>> find({String where, dynamic whereArgs}) async {
    final Database db = await getDatabase();
    final List<Map<String, dynamic>> maps = where == null
        ? await db.query(
      TABLE_NAME,
    )
        : await db.query(TABLE_NAME, where: where, whereArgs: whereArgs);

    return List.generate(maps.length, (i) {
      return SpecialOrder(
        id: maps[i][SpecialOrder.ID],
        employee: maps[i][SpecialOrder.EMPLOYEE],
        customer: maps[i][SpecialOrder.CUSTOMER],
        products: maps[i][SpecialOrder.PRODUCTS],
        totalAmount: maps[i][SpecialOrder.TOTAL_AMOUNT],
        advancePayment: maps[i][SpecialOrder.ADVANCE_PAYMENT],
        remainingPayment: maps[i][SpecialOrder.REMAINING_PAYMENT],
        paidInFull: maps[i][SpecialOrder.PAID_IN_FULL],
        note: maps[i][SpecialOrder.NOTE],
        firstModified: maps[i][SpecialOrder.FIRST_MODIFIED],
        lastModified: maps[i][SpecialOrder.LAST_MODIFIED],
      );
    });
  }

  /// where : "id = ?"
  /// whereArgs : [2]
  static Future<void> update({String where, dynamic whereArgs, SpecialOrder normalOrder}) async {
    normalOrder.lastModified = DateTime.now();
    final Database db = await getDatabase();
    await db.update(TABLE_NAME, SpecialOrder.toMap(normalOrder), where: where, whereArgs: whereArgs);
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
