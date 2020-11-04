import 'package:captain/db/model/personnel.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:captain/global.dart' as global;
import 'package:uuid/uuid.dart';

class PersonnelDAL {
  static const String TABLE_NAME = Personnel.COLLECTION_NAME;


  static Future<Database> getDatabase() async {
    String createTable =
        "CREATE TABLE $TABLE_NAME (" +
            "${Personnel.ID} TEXT," + // TODO : change for all
            "${Personnel.ID_FS} TEXT," +
            "${Personnel.CONTACT_IDENTIFIER} TEXT," +
            "${Personnel.NAME} TEXT," +
            "${Personnel.PHONE_NUMBER} TEXT," +
            "${Personnel.EMAIL} TEXT," +
            "${Personnel.ADDRESS} TEXT," +
            "${Personnel.ADDRESS_DETAIL} TEXT," +
            "${Personnel.TYPE} TEXT," +
            "${Personnel.PROFILE_IMAGE} BLOG," +
            "${Personnel.NOTE} TEXT," +
            "${Personnel.FIRST_MODIFIED} TEXT," +
            "${Personnel.LAST_MODIFIED} TEXT" +
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

  static Future<Personnel> create(Personnel personnel) async { // todo : chanbe for all
    // updating first and last modified stamps.
    var uuid = Uuid(); // todo : change for all
    personnel.id = uuid.hashCode.toString(); // todo : change for all
    personnel.firstModified = DateTime.now();
    personnel.lastModified = DateTime.now();

    // Get a reference to the database.
    final Database db = await getDatabase();

    await db.insert(TABLE_NAME, Personnel.toMap(personnel), conflictAlgorithm: ConflictAlgorithm.replace);
    return personnel; // todo : change for all
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
        idFS: maps[i][Personnel.ID_FS],
        contactIdentifier: maps[i][Personnel.CONTACT_IDENTIFIER],
        name: maps[i][Personnel.NAME],
        phoneNumber: maps[i][Personnel.PHONE_NUMBER],
        email: maps[i][Personnel.EMAIL],
        address: maps[i][Personnel.ADDRESS],
        addressDetail: maps[i][Personnel.ADDRESS_DETAIL],
        type: maps[i][Personnel.TYPE],
        profileImage: maps[i][Personnel.PROFILE_IMAGE],
        note: maps[i][Personnel.NOTE],
        firstModified: DateTime.parse(maps[i][Personnel.FIRST_MODIFIED]), // todo : change for all
        lastModified: DateTime.parse(maps[i][Personnel.LAST_MODIFIED]), // todo : change for all
      );
    });
  }

  /// where : "id = ?"
  /// whereArgs : [2]
  static Future<void> update({String where, dynamic whereArgs, Personnel personnel}) async {
    personnel.lastModified = DateTime.now();
    final Database db = await getDatabase();
    await db.update(TABLE_NAME, Personnel.toMap(personnel), where: where, whereArgs: whereArgs);
  }

  /// where : "id = ?"
  /// whereArgs : [2]
  static Future<void> delete({String where, dynamic whereArgs}) async {
    final Database db = await getDatabase();
    await db.delete(
      TABLE_NAME,
      where: where,
      whereArgs: whereArgs,
    );
  }
}
