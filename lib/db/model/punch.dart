import 'dart:convert';

import 'package:captain/db/model/personnel.dart';
import 'package:captain/db/model/product.dart';

/// Defines punch db.model
class Punch {
  static const String COLLECTION_NAME = "punch";

  /// Defines key values to extract from a map
  static const String ID = "id";
  static const String ID_FS = "idFs";
  static const String EMPLOYEE = "employee";
  static const String PRODUCT = "product";
  static const String TYPE = "type";
  static const String WEIGHT = "weight";
  static const String NOTE = "note";
  static const String FIRST_MODIFIED = "firstModified";
  static const String LAST_MODIFIED = "lastModified";

  String id;
  String idFS;
  Personnel employee;
  Product product;
  String type; // in/out
  num weight;
  String note;
  DateTime firstModified;
  DateTime lastModified;

  Punch({this.id, this.idFS, this.employee, this.product, this.type, this.weight, this.note, this.firstModified, this.lastModified});

  /// Converts Model to Map
  static Map<String, dynamic> toMap(Punch punch) {
    return punch == null
        ? null
        : {
            ID: punch.id,
            ID_FS: punch.idFS,
            EMPLOYEE: jsonEncode(Personnel.toMap(punch.employee)),
            PRODUCT: jsonEncode(Product.toMap(punch.product)),
            TYPE: punch.type,
            WEIGHT: punch.weight,
            NOTE: punch.note,
            FIRST_MODIFIED: punch.firstModified.toIso8601String(),
            LAST_MODIFIED: punch.lastModified.toIso8601String()
          };
  }

  /// Converts Map to Model
  static Punch toModel(dynamic map) {
    return map == null
        ? null
        : Punch(
            id: map[ID],
            idFS: map[ID_FS],
            employee: Personnel.toModel(map[EMPLOYEE]),
            product: Product.toModel(jsonDecode(map[PRODUCT])),
            type: map[TYPE],
            weight: map[WEIGHT],
            note: map[NOTE],
            firstModified: DateTime.parse(map[FIRST_MODIFIED]),
            lastModified: DateTime.parse(map[LAST_MODIFIED]));
  }

  /// Changes List of Map to List of Model
  static List<Punch> toModelList(List<dynamic> maps) {
    List<Punch> modelList = [];
    maps.forEach((dynamic map) {
      modelList.add(toModel(map));
    });
    return modelList;
  }

  /// Changes List of Model to List of Map
  static List<Map<String, dynamic>> toMapList(List<Punch> models) {
    List<Map<String, dynamic>> mapList = [];
    models == null
        ? []
        : models.forEach((Punch model) {
            mapList.add(toMap(model));
          });
    return mapList;
  }
}
