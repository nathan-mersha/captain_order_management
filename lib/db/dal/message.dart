import 'package:captain/db/model/message.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:captain/global.dart' as global;
import 'package:uuid/uuid.dart';

class MessageDAL {
  static const String TABLE_NAME = Message.COLLECTION_NAME;

  
  static Future<Database> getDatabase() async {
    String createTable =
        "CREATE TABLE $TABLE_NAME (" +
            "${Message.ID} TEXT," +
            "${Message.ID_FS} TEXT," +
            "${Message.RECIPIENT} TEXT," +
            "${Message.BODY} TEXT," +
            "${Message.FIRST_MODIFIED} TEXT," +
            "${Message.LAST_MODIFIED} TEXT" +
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

  static Future<Message> create(Message message) async {
    // updating first and last modified stamps.
    var uuid = Uuid();
    message.id = uuid.hashCode.toString();
    message.firstModified = DateTime.now();
    message.lastModified = DateTime.now();

    // Get a reference to the database.
    final Database db = await getDatabase();
    int val = await db.insert(TABLE_NAME, Message.toMap(message), conflictAlgorithm: ConflictAlgorithm.replace);
    return val == 1 ? message : null;
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
        idFS: maps[i][Message.ID_FS],
        recipient: maps[i][Message.RECIPIENT],
        body: maps[i][Message.BODY],
        firstModified: DateTime.parse(maps[i][Message.FIRST_MODIFIED]),
        lastModified: DateTime.parse(maps[i][Message.LAST_MODIFIED]),
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
