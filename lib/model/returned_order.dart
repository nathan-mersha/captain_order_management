import 'package:captain/model/personnel.dart';
import 'package:captain/model/product.dart';

/// Defines returnedOrder model
class ReturnedOrder {
  static const String COLLECTION_NAME = "returnedOrder";

  /// Defines key values to extract from a map
  static const String RETURNED_ORDER_ID = "returnedOrderId";
  static const String EMPLOYEE = "employee";
  static const String CUSTOMER = "customer";
  static const String PRODUCT = "product";
  static const String COUNT = "count";
  static const String NOTE = "note";
  static const String FIRST_MODIFIED = "firstModified";
  static const String LAST_MODIFIED = "lastModified";

  String returnedOrderId;
  Personnel employee;
  Personnel customer;
  Product product;
  num count;
  String note;
  DateTime firstModified;
  DateTime lastModified;

  ReturnedOrder({
    this.returnedOrderId,
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
    return {
      RETURNED_ORDER_ID: returnedOrder.returnedOrderId,
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
    return ReturnedOrder(
        returnedOrderId: map[RETURNED_ORDER_ID],
        employee: Personnel.toModel(map[EMPLOYEE]),
        customer: Personnel.toModel(map[CUSTOMER]),
        product: Product.toModel(map[PRODUCT]),
        count: map[COUNT],
        note: map[NOTE],
        firstModified: map[FIRST_MODIFIED],
        lastModified: map[LAST_MODIFIED]);
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