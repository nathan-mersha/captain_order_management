import 'dart:convert';

import 'package:captain/db/model/personnel.dart';
import 'package:captain/db/model/product.dart';

/// Defines returnedOrder db.model
class ReturnedOrder {
  static const String COLLECTION_NAME = "returnedOrder";

  /// Defines key values to extract from a map
  static const String ID = "id";
  static const String ID_FS = "idFs";
  static const String EMPLOYEE = "employee";
  static const String CUSTOMER = "customer";
  static const String PRODUCT = "product";
  static const String COUNT = "count";
  static const String NOTE = "note";
  static const String FIRST_MODIFIED = "firstModified";
  static const String LAST_MODIFIED = "lastModified";

  String id;
  String idFS;
  Personnel employee;
  Personnel customer;
  Product product;
  num count;
  String note;
  DateTime firstModified;
  DateTime lastModified;

  ReturnedOrder({this.id, this.idFS, this.employee, this.customer, this.product, this.count, this.note, this.firstModified, this.lastModified});

  /// Converts Model to Map
  static Map<String, dynamic> toMap(ReturnedOrder returnedOrder) {
    return returnedOrder == null
        ? null
        : {
            ID: returnedOrder.id,
            ID_FS: returnedOrder.idFS,
            EMPLOYEE: jsonEncode(Personnel.toMap(returnedOrder.employee)),
            CUSTOMER: jsonEncode(Personnel.toMap(returnedOrder.customer)),
            PRODUCT: jsonEncode(Product.toMap(returnedOrder.product)),
            COUNT: returnedOrder.count,
            NOTE: returnedOrder.note,
            FIRST_MODIFIED: returnedOrder.firstModified.toIso8601String(),
            LAST_MODIFIED: returnedOrder.lastModified.toIso8601String()
          };
  }

  /// Converts Map to Model
  static ReturnedOrder toModel(dynamic map) {
    return map == null
        ? null
        : ReturnedOrder(
            id: map[ID],
            idFS: map[ID_FS],
            employee: Personnel.toModel(jsonDecode(map[EMPLOYEE])),
            customer: Personnel.toModel(jsonDecode(map[CUSTOMER])),
            product: Product.toModel(jsonDecode(map[CUSTOMER])),
            count: map[COUNT],
            note: map[NOTE],
            firstModified: DateTime.parse(map[FIRST_MODIFIED]),
            lastModified: DateTime.parse(map[LAST_MODIFIED]));
  }

  /// Changes List of Map to List of Model
  static List<ReturnedOrder> toModelList(List<dynamic> maps) {
    List<ReturnedOrder> modelList = [];
    maps.forEach((dynamic map) {
      modelList.add(toModel(map));
    });
    return modelList;
  }

  /// Changes List of Model to List of Map
  static List<Map<String, dynamic>> toMapList(List<ReturnedOrder> models) {
    List<Map<String, dynamic>> mapList = [];
    models == null
        ? []
        : models.forEach((ReturnedOrder model) {
            mapList.add(toMap(model));
          });
    return mapList;
  }
}
