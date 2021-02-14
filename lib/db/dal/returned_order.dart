import 'dart:async';
import 'dart:convert';

import 'package:captain/db/dal/normal_order.dart';
import 'package:captain/db/model/product.dart';
import 'package:captain/db/model/returned_order.dart';
import 'package:sqflite/sqflite.dart';
import 'package:captain/global.dart' as global;
import 'package:uuid/uuid.dart';

class ReturnedOrderDAL {
  static const String TABLE_NAME = ReturnedOrder.COLLECTION_NAME;

  static String createTable = "CREATE TABLE $TABLE_NAME (" +
      "${ReturnedOrder.ID} TEXT," +
      "${ReturnedOrder.ID_FS} TEXT," +
      "${ReturnedOrder.EMPLOYEE} TEXT," +
      "${ReturnedOrder.CUSTOMER} TEXT," +
      "${ReturnedOrder.PRODUCT} TEXT," +
      "${ReturnedOrder.COUNT} INTEGER," +
      "${ReturnedOrder.NOTE} TEXT," +
      "${ReturnedOrder.FIRST_MODIFIED} TEXT," +
      "${ReturnedOrder.LAST_MODIFIED} TEXT" +
      ")";

  static Future<ReturnedOrder> create(ReturnedOrder returnedOrder) async {
    // updating first and last modified stamps.
    var uuid = Uuid();
    returnedOrder.id = uuid.hashCode.toString();
    returnedOrder.firstModified = DateTime.now();
    returnedOrder.lastModified = DateTime.now();

    Map<String, dynamic> returnedOrderMapped = ReturnedOrder.toMap(returnedOrder);
    returnedOrderMapped[ReturnedOrder.EMPLOYEE] = returnedOrder.employee == null ? null : returnedOrder.employee.id;
    returnedOrderMapped[ReturnedOrder.CUSTOMER] = returnedOrder.customer == null ? null : returnedOrder.customer.id;
    
    // Get a reference to the database.
    await global.db.insert(TABLE_NAME, returnedOrderMapped,
        conflictAlgorithm: ConflictAlgorithm.replace);
    return returnedOrder;
  }

  /// where : "id = ?"
  /// whereArgs : [2]
  static Future<List<ReturnedOrder>> find(
      {String where, dynamic whereArgs}) async {
    final List<Map<String, dynamic>> maps = where == null
        ? await global.db
            .query(TABLE_NAME, orderBy: "${ReturnedOrder.LAST_MODIFIED} DESC")
        : await global.db.query(TABLE_NAME,
            where: where,
            whereArgs: whereArgs,
            orderBy: "${ReturnedOrder.LAST_MODIFIED} DESC");


    List<ReturnedOrder> parsedList = [];
    final c = new Completer<List<ReturnedOrder>>();
    
    maps.forEach((Map<String, dynamic> element) async{
      ReturnedOrder returnedOrder = ReturnedOrder(
        id: element[ReturnedOrder.ID],
        idFS: element[ReturnedOrder.ID_FS],
        employee :  await NormalOrderDAL.getPersonnel(element[ReturnedOrder.EMPLOYEE]),
        customer :  await NormalOrderDAL.getPersonnel(element[ReturnedOrder.CUSTOMER]),
        product: Product.toModel(jsonDecode(element[ReturnedOrder.PRODUCT])),
        count: element[ReturnedOrder.COUNT],
        note: element[ReturnedOrder.NOTE],
        firstModified: DateTime.parse(element[ReturnedOrder.FIRST_MODIFIED]),
        lastModified: DateTime.parse(element[ReturnedOrder.LAST_MODIFIED]),
      );
      parsedList.add(returnedOrder);
      if(maps.length == parsedList.length){
        c.complete(parsedList);
      }
    });

    return c.future;
   
  }

  /// where : "id = ?"
  /// whereArgs : [2]
  static Future<void> update(
      {String where, dynamic whereArgs, ReturnedOrder returnedOrder}) async {
    returnedOrder.lastModified = DateTime.now();
    await global.db.update(TABLE_NAME, ReturnedOrder.toMap(returnedOrder),
        where: where, whereArgs: whereArgs);
  }

  /// where : "id = ?"
  /// whereArgs : [2]
  static Future<void> delete({String where, dynamic whereArgs}) async {
    await global.db.delete(
      TABLE_NAME,
      where: where,
      whereArgs: whereArgs,
    );
  }
}
