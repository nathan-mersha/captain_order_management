import 'package:captain/db/model/message.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:captain/global.dart' as global;

class MessageDAL {
  static const String TABLE_NAME = Message.COLLECTION_NAME;

  
  static Future<Database> getDatabase() async {
    String createTable =
        "CREATE TABLE $TABLE_NAME (" +
            "${Message.ID} TEXT PRIMARY KEY AUTOINCREMENT NOT NULL," +
            "${Message.RECIPIENT} TEXT," +
            "${Message.BODY} TEXT," +
            "${Message.FIRST_MODIFIED} BLOB," +
            "${Message.LAST_MODIFIED} BLOB" +
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

  static Future<void> create(Message message) async {
    // updating first and last modified stamps.
    message.firstModified = DateTime.now();
    message.lastModified = DateTime.now();

    // Get a reference to the database.
    final Database db = await getDatabase();
    await db.insert(TABLE_NAME, Message.toMap(message), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  /// where : "id = ?"
  /// whereArgs : [2]
  static Future<List<Message>> find({String where, dynamic whereArgs}) async {
    final Database db = await getDatabase();
    final List<Map<String, dynamic>> maps = where == null
        ? await db.query(
      TABLE_NAME,
    )
        : await db.query(TABLE_NAME, where: where, whereArgs: whereArgs);

    return List.generate(maps.length, (i) {
      return Message(
        id: maps[i][Message.ID],
        recipient: maps[i][Message.RECIPIENT],
        body: maps[i][Message.BODY],
        firstModified: maps[i][Message.FIRST_MODIFIED],
        lastModified: maps[i][Message.LAST_MODIFIED],
      );
    });
  }

  /// where : "id = ?"
  /// whereArgs : [2]
  static Future<void> update({String where, dynamic whereArgs, Message message}) async {
    message.lastModified = DateTime.now();
    final Database db = await getDatabase();
    await db.update(TABLE_NAME, Message.toMap(message), where: where, whereArgs: whereArgs);
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
