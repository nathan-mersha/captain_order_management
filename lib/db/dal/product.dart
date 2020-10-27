import 'package:captain/db/model/product.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:captain/global.dart' as global;

class ProductDAL {
  static const String TABLE_NAME = Product.COLLECTION_NAME;


  static Future<Database> getDatabase() async {
    String createTable =
        "CREATE TABLE $TABLE_NAME (" +
            "${Product.ID} INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL," +
            "${Product.NAME} TEXT," +
            "${Product.TYPE} TEXT," +
            "${Product.UNIT_OF_MEASUREMENT} TEXT," +
            "${Product.UNIT_PRICE} REAL," +
            "${Product.COLOR_VALUE} TEXT," +
            "${Product.PAINT_TYPE} TEXT," +
            "${Product.MANUFACTURER} TEXT," +
            "${Product.IS_GALLON_BASED} BLOB," +
            "${Product.NOTE} TEXT," +
            "${Product.QUANTITY_IN_CART} INTEGER," +
            "${Product.SUB_TOTAL} REAL," +
            "${Product.DELIVERED} BLOB," +
            "${Product.FIRST_MODIFIED} BLOB," +
            "${Product.LAST_MODIFIED} BLOB" +
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

  static Future<void> create(Product normalOrder) async {
    // updating first and last modified stamps.
    normalOrder.firstModified = DateTime.now();
    normalOrder.lastModified = DateTime.now();

    // Get a reference to the database.
    final Database db = await getDatabase();
    await db.insert(TABLE_NAME, Product.toMap(normalOrder), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  /// where : "id = ?"
  /// whereArgs : [2]
  static Future<List<Product>> find({String where, dynamic whereArgs}) async {
    final Database db = await getDatabase();
    final List<Map<String, dynamic>> maps = where == null
        ? await db.query(
      TABLE_NAME,
    )
        : await db.query(TABLE_NAME, where: where, whereArgs: whereArgs);

    return List.generate(maps.length, (i) {
      return Product(
        id: maps[i][Product.ID],
        name: maps[i][Product.NAME],
        type: maps[i][Product.TYPE],
        unitOfMeasurement: maps[i][Product.UNIT_OF_MEASUREMENT],
        unitPrice: maps[i][Product.UNIT_PRICE],
        colorValue: maps[i][Product.COLOR_VALUE],
        paintType: maps[i][Product.PAINT_TYPE],
        manufacturer: maps[i][Product.MANUFACTURER],
        isGallonBased: maps[i][Product.IS_GALLON_BASED],
        note: maps[i][Product.NOTE],
        quantityInCart: maps[i][Product.QUANTITY_IN_CART],
        subTotal: maps[i][Product.SUB_TOTAL],
        delivered: maps[i][Product.DELIVERED],
        firstModified: maps[i][Product.FIRST_MODIFIED],
        lastModified: maps[i][Product.LAST_MODIFIED],
      );
    });
  }

  /// where : "id = ?"
  /// whereArgs : [2]
  static Future<void> update({String where, dynamic whereArgs, Product normalOrder}) async {
    normalOrder.lastModified = DateTime.now();
    final Database db = await getDatabase();
    await db.update(TABLE_NAME, Product.toMap(normalOrder), where: where, whereArgs: whereArgs);
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
