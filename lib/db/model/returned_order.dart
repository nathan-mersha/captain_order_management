import 'package:captain/db/model/personnel.dart';
import 'package:captain/db/model/product.dart';

/// Defines returnedOrder db.model
class ReturnedOrder {
  static const String COLLECTION_NAME = "returnedOrder";

  /// Defines key values to extract from a map
  static const String ID = "id";
  static const String EMPLOYEE = "employee";
  static const String CUSTOMER = "customer";
  static const String PRODUCT = "product";
  static const String COUNT = "count";
  static const String NOTE = "note";
  static const String FIRST_MODIFIED = "firstModified";
  static const String LAST_MODIFIED = "lastModified";

  int id;
  Personnel employee;
  Personnel customer;
  Product product;
  num count;
  String note;
  DateTime firstModified;
  DateTime lastModified;

  ReturnedOrder({
    this.id,
    this.employee,
    this.customer,
    this.product,
    this.count,
    this.note,
    this.firstModified,
    this.lastModified
  });

  /// Converts Model to Map
  static Map<String, dynamic> toMap(ReturnedOrder returnedOrder) {
    return returnedOrder == null ? null : {
      ID: returnedOrder.id,
      EMPLOYEE: Personnel.toMap(returnedOrder.employee),
      CUSTOMER: Personnel.toMap(returnedOrder.customer),
      PRODUCT: Product.toMap(returnedOrder.product),
      COUNT: returnedOrder.count,
      NOTE: returnedOrder.note,
      FIRST_MODIFIED: returnedOrder.firstModified,
      LAST_MODIFIED: returnedOrder.lastModified
    };
  }

  /// Converts Map to Model
  static ReturnedOrder toModel(dynamic map) {
    return map == null ? null : ReturnedOrder(
        id: map[ID],
        employee: Personnel.toModel(map[EMPLOYEE]),
        customer: Personnel.toModel(map[CUSTOMER]),
        product: Product.toModel(map[PRODUCT]),
        count: map[COUNT],
        note: map[NOTE],
        firstModified: DateTime(map[FIRST_MODIFIED]),
        lastModified: DateTime(map[LAST_MODIFIED])
    );
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
    models.forEach((ReturnedOrder model) {
      mapList.add(toMap(model));
    });
    return mapList;
  }
}
