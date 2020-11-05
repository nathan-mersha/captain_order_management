import 'package:captain/db/model/personnel.dart';
import 'package:captain/db/model/product.dart';

/// Defines normalOrder db.model
class NormalOrder {
  static const String COLLECTION_NAME = "normalOrder";

  /// Defines key values to extract from a map
  static const String ID = "id";
  static const String ID_FS = "idFs";
  static const String EMPLOYEE = "employee";
  static const String CUSTOMER = "customer";
  static const String PAINT_ORDER = "paintOrder";
  static const String OTHER_PRODUCTS = "otherProducts";
  static const String VOLUME = "volume";
  static const String TOTAL_AMOUNT = "totalAmount";
  static const String ADVANCE_PAYMENT = "advancePayment";
  static const String REMAINING_PAYMENT = "remainingPayment";
  static const String PAID_IN_FULL = "paidInFull";
  static const String STATUS = "status";
  static const String USER_NOTIFIED = "userNotified";
  static const String FIRST_MODIFIED = "firstModified";
  static const String LAST_MODIFIED = "lastModified";

  String id;
  String idFS;
  Personnel employee;
  Personnel customer;
  Product paintOrder;
  List<Product> otherProducts;
  num volume;
  num totalAmount;
  num advancePayment;
  num remainingPayment;
  bool paidInFull;
  String status;
  bool userNotified;
  DateTime firstModified;
  DateTime lastModified;

  NormalOrder(
      {this.id,
      this.idFS,
      this.employee,
      this.customer,
      this.paintOrder,
      this.otherProducts,
      this.volume,
      this.totalAmount,
      this.advancePayment,
      this.remainingPayment,
      this.paidInFull,
      this.status,
      this.userNotified,
      this.firstModified,
      this.lastModified});

  /// Converts Model to Map
  static Map<String, dynamic> toMap(NormalOrder normalOrder) {
    return normalOrder == null
        ? null
        : {
            ID: normalOrder.id,
            ID_FS: normalOrder.idFS,
            EMPLOYEE: normalOrder.employee == null ? null : Personnel.toMap(normalOrder.employee),
            CUSTOMER: normalOrder.customer == null ? null : Personnel.toMap(normalOrder.customer),
            PAINT_ORDER: normalOrder.paintOrder == null ? null : Product.toMap(normalOrder.paintOrder),
            OTHER_PRODUCTS: normalOrder.otherProducts == null ? null : Product.toMapList(normalOrder.otherProducts),
            VOLUME: normalOrder.volume,
            TOTAL_AMOUNT: normalOrder.totalAmount,
            ADVANCE_PAYMENT: normalOrder.advancePayment,
            REMAINING_PAYMENT: normalOrder.remainingPayment,
            PAID_IN_FULL: normalOrder.paidInFull,
            STATUS: normalOrder.status,
            USER_NOTIFIED: normalOrder.userNotified,
            FIRST_MODIFIED: normalOrder.firstModified.toIso8601String(),
            LAST_MODIFIED: normalOrder.lastModified.toIso8601String()
          };
  }

  /// Converts Map to Model
  static NormalOrder toModel(dynamic map) {
    return map == null
        ? null
        : NormalOrder(
            id: map[ID],
            idFS: map[ID_FS],
            employee: Personnel.toModel(map[EMPLOYEE]),
            customer: Personnel.toModel(map[CUSTOMER]),
            paintOrder: Product.toModel(map[PAINT_ORDER]),
            otherProducts: Product.toModelList(map[OTHER_PRODUCTS]),
            volume: map[VOLUME],
            totalAmount: map[TOTAL_AMOUNT],
            advancePayment: map[ADVANCE_PAYMENT],
            remainingPayment: map[REMAINING_PAYMENT],
            paidInFull: map[PAID_IN_FULL],
            status: map[STATUS],
            userNotified: map[USER_NOTIFIED],
            firstModified: DateTime(map[FIRST_MODIFIED]),
            lastModified: DateTime(map[LAST_MODIFIED]));
  }

  /// Changes List of Map to List of Model
  static List<NormalOrder> toModelList(List<dynamic> maps) {
    List<NormalOrder> modelList = [];
    maps.forEach((dynamic map) {
      modelList.add(toModel(map));
    });
    return modelList;
  }

  /// Changes List of Model to List of Map
  static List<Map<String, dynamic>> toMapList(List<NormalOrder> models) {
    List<Map<String, dynamic>> mapList = [];
    models.forEach((NormalOrder model) {
      mapList.add(toMap(model));
    });
    return mapList;
  }
}
