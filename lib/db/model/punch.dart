import 'package:captain/db/model/personnel.dart';
import 'package:captain/db/model/product.dart';

/// Defines punch db.model
class Punch {
  static const String COLLECTION_NAME = "punch";

  /// Defines key values to extract from a map
  static const String PUNCH_ID = "punchId";
  static const String EMPLOYEE = "employee";
  static const String PRODUCT = "product";
  static const String TYPE = "type";
  static const String WEIGHT = "weight";
  static const String NOTE = "note";
  static const String FIRST_MODIFIED = "firstModified";
  static const String LAST_MODIFIED = "lastModified";

  String punchId;
  Personnel employee;
  Product product;
  String type; // in/out
  String weight;
  String note;
  DateTime firstModified;
  DateTime lastModified;

  Punch({
    this.punchId,
    this.employee,
    this.product,
    this.type,
    this.weight,
    this.note,
    this.firstModified, 
    this.lastModified
  });

  /// Converts Model to Map
  static Map<String, dynamic> toMap(Punch punch) {
    return {
      PUNCH_ID: punch.punchId,
      EMPLOYEE: Personnel.toMap(punch.employee),
      PRODUCT: Product.toMap(punch.product),
      TYPE: punch.type,
      WEIGHT: punch.weight,
      NOTE: punch.note,
      FIRST_MODIFIED: punch.firstModified,
      LAST_MODIFIED: punch.lastModified
    };
  }

  /// Converts Map to Model
  static Punch toModel(dynamic map) {
    return Punch(
        punchId: map[PUNCH_ID],
        employee: Personnel.toModel(map[EMPLOYEE]),
        product: Product.toModel(map[PRODUCT]),
        type: map[TYPE],
        weight: map[WEIGHT],
        note: map[NOTE],
        firstModified: map[FIRST_MODIFIED],
        lastModified: map[LAST_MODIFIED]);
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
    models.forEach((Punch model) {
      mapList.add(toMap(model));
    });
    return mapList;
  }
}
