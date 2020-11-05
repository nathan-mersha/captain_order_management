import 'package:captain/db/model/product.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:captain/global.dart' as global;
import 'package:uuid/uuid.dart';

class ProductDAL {
  static const String TABLE_NAME = Product.COLLECTION_NAME;

  static Future<Database> getDatabase() async {
    String createTable = "CREATE TABLE $TABLE_NAME (" +
        "${Product.ID} TEXT," +
        "${Product.ID_FS} TEXT," +
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
        "${Product.FIRST_MODIFIED} TEXT," +
        "${Product.LAST_MODIFIED} TEXT" +
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

  static Future<Product> create(Product product) async {
    // updating first and last modified stamps.
    var uuid = Uuid();
    product.id = uuid.hashCode.toString();
    product.firstModified = DateTime.now();
    product.lastModified = DateTime.now();

    // Get a reference to the database.
    final Database db = await getDatabase();
    int val = await db.insert(TABLE_NAME, Product.toMap(product), conflictAlgorithm: ConflictAlgorithm.replace);
    return val == 1 ? product : null;
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
        idFS: maps[i][Product.ID_FS],
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
        firstModified: DateTime.parse(maps[i][Product.FIRST_MODIFIED]),
        lastModified: DateTime.parse(maps[i][Product.LAST_MODIFIED]),
      );
    });
  }

  /// where : "id = ?"
  /// whereArgs : [2]
  static Future<void> update({String where, dynamic whereArgs, Product product}) async {
    product.lastModified = DateTime.now();
    final Database db = await getDatabase();
    await db.update(TABLE_NAME, Product.toMap(product), where: where, whereArgs: whereArgs);
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
