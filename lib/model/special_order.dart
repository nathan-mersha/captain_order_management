import 'package:captain/model/personnel.dart';
import 'package:captain/model/product.dart';

/// Defines specialOrder model
class SpecialOrder {
  static const String COLLECTION_NAME = "specialOrder";

  /// Defines key values to extract from a map
  static const String SPECIAL_ORDER_ID = "specialOrderId";
  static const String EMPLOYEE = "employee";
  static const String CUSTOMER = "customer";
  static const String PRODUCTS = "products";
  static const String TOTAL_AMOUNT = "totalAmount";
  static const String ADVANCE_PAYMENT = "advancePayment";
  static const String REMAINING_PAYMENT = "remainingPayment";
  static const String PAID_IN_FULL = "paidInFull";
  static const String NOTE = "note";
  static const String FIRST_MODIFIED = "firstModified";
  static const String LAST_MODIFIED = "lastModified";

  String specialOrderId;
  Personnel employee;
  Personnel customer;
  List<Product> products;
  num totalAmount;
  num advancePayment;
  num remainingPayment;
  bool paidInFull;
  String note;
  DateTime firstModified;
  DateTime lastModified;

  SpecialOrder({
    this.specialOrderId,
    this.employee,
    this.customer,
    this.products,
    this.totalAmount,
    this.advancePayment,
    this.remainingPayment,
    this.paidInFull,
    this.note,
    this.firstModified,
    this.lastModified
  });

  /// Converts Model to Map
  static Map<String, dynamic> toMap(SpecialOrder specialOrder) {
    return {
      SPECIAL_ORDER_ID: specialOrder.specialOrderId,
      EMPLOYEE: Personnel.toMap(specialOrder.employee),
      CUSTOMER: Personnel.toMap(specialOrder.customer),
      PRODUCTS: Product.toMapList(specialOrder.products),
      TOTAL_AMOUNT: specialOrder.totalAmount,
      ADVANCE_PAYMENT: specialOrder.advancePayment,
      REMAINING_PAYMENT: specialOrder.remainingPayment,
      PAID_IN_FULL: specialOrder.paidInFull,
      NOTE: specialOrder.note,
      FIRST_MODIFIED: specialOrder.firstModified,
      LAST_MODIFIED: specialOrder.lastModified
    };
  }

  /// Converts Map to Model
  static SpecialOrder toModel(dynamic map) {
    return SpecialOrder(
        specialOrderId: map[SPECIAL_ORDER_ID],
        employee: Personnel.toModel(map[EMPLOYEE]),
        customer: Personnel.toModel(map[CUSTOMER]),
        products: Product.toModelList(map[PRODUCTS]),
        totalAmount: map[TOTAL_AMOUNT],
        advancePayment: map[ADVANCE_PAYMENT],
        remainingPayment: map[REMAINING_PAYMENT],
        paidInFull: map[PAID_IN_FULL],
        note: map[NOTE],
        firstModified: map[FIRST_MODIFIED],
        lastModified: map[LAST_MODIFIED]);
  }

  /// Changes List of Map to List of Model
  static List<SpecialOrder> toModelList(List<dynamic> maps) {
    List<SpecialOrder> modelList = [];
    maps.forEach((dynamic map) {
      modelList.add(toModel(map));
    });
    return modelList;
  }

  /// Changes List of Model to List of Map
  static List<Map<String, dynamic>> toMapList(List<SpecialOrder> models) {
    List<Map<String, dynamic>> mapList = [];
    models.forEach((SpecialOrder model) {
      mapList.add(toMap(model));
    });
    return mapList;
  }
}
