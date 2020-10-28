import 'package:captain/db/model/normal_order.dart';
import 'package:captain/db/model/personnel.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:captain/global.dart' as global;

class PersonnelDAL {
  static const String TABLE_NAME = Personnel.COLLECTION_NAME;


  static Future<Database> getDatabase() async {
    String createTable =
        "CREATE TABLE $TABLE_NAME (" +
            "${Personnel.ID} INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL," +
            "${Personnel.NAME} TEXT," +
            "${Personnel.PHONE_NUMBER} TEXT," +
            "${Personnel.EMAIL} TEXT," +
            "${Personnel.ADDRESS} TEXT," +
            "${Personnel.ADDRESS_DETAIL} TEXT," +
            "${Personnel.TYPE} TEXT," +
            "${Personnel.PROFILE_IMAGE} REAL," +
            "${Personnel.NOTE} TEXT," +
            "${Personnel.FIRST_MODIFIED} BLOB," +
            "${Personnel.LAST_MODIFIED} BLOB" +
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

  static Future<void> create(Personnel normalOrder) async {
    // updating first and last modified stamps.
    normalOrder.firstModified = DateTime.now();
    normalOrder.lastModified = DateTime.now();

    // Get a reference to the database.
    final Database db = await getDatabase();
    await db.insert(TABLE_NAME, Personnel.toMap(normalOrder), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  /// where : "id = ?"
  /// whereArgs : [2]
  static Future<List<Personnel>> find({String where, dynamic whereArgs}) async {
    final Database db = await getDatabase();
    final List<Map<String, dynamic>> maps = where == null
        ? await db.query(
      TABLE_NAME,
    )
        : await db.query(TABLE_NAME, where: where, whereArgs: whereArgs);

    return List.generate(maps.length, (i) {
      return Personnel(
        id: maps[i][Personnel.ID],
        name: maps[i][Personnel.NAME],
        phoneNumber: maps[i][Personnel.PHONE_NUMBER],
        email: maps[i][Personnel.EMAIL],
        address: maps[i][Personnel.ADDRESS],
        addressDetail: maps[i][Personnel.ADDRESS_DETAIL],
        type: maps[i][Personnel.TYPE],
        profileImage: maps[i][Personnel.PROFILE_IMAGE],
        note: maps[i][Personnel.NOTE],
        firstModified: maps[i][Personnel.FIRST_MODIFIED],
        lastModified: maps[i][Personnel.LAST_MODIFIED],
      );
    });
  }

  /// where : "id = ?"
  /// whereArgs : [2]
  static Future<void> update({String where, dynamic whereArgs, Personnel normalOrder}) async {
    normalOrder.lastModified = DateTime.now();
    final Database db = await getDatabase();
    await db.update(TABLE_NAME, Personnel.toMap(normalOrder), where: where, whereArgs: whereArgs);
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