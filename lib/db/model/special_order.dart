import 'dart:convert';

import 'package:captain/db/model/personnel.dart';
import 'package:captain/db/model/product.dart';
import 'package:flutter/material.dart';

/// Defines specialOrder db.model
class SpecialOrder with ChangeNotifier {
  static const String COLLECTION_NAME = "specialOrder";

  /// Defines key values to extract from a map
  static const String ID = "id";
  static const String ID_FS = "idFs";
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

  String id;
  String idFS;
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

  SpecialOrder(
      {this.id,
      this.idFS,
      this.employee,
      this.customer,
      this.products,
      this.totalAmount,
      this.advancePayment = 0,
      this.remainingPayment,
      this.paidInFull,
      this.note,
      this.firstModified,
      this.lastModified});

  addProduct(Product product) {
    products.add(product);
    calculatePaymentInfo();
  }

  removeProduct(Product product) {
    products.remove(product);
    calculatePaymentInfo();
  }

  calculatePaymentInfo() {
    num totalAmount = 0;
    products.forEach((Product product) {
      num subTotal = product.quantityInCart * product.unitPrice;
      totalAmount += subTotal;
    });
    this.totalAmount = totalAmount;
    this.remainingPayment = this.totalAmount - this.advancePayment;
    if (remainingPayment == 0) {
      this.paidInFull = true;
      this.advancePayment = this.totalAmount;
    } else {
      this.paidInFull = false;
    }
    notifyListeners();
  }

  /// Converts Model to Map
  static Map<String, dynamic> toMap(SpecialOrder specialOrder) {
    return specialOrder == null
        ? null
        : {
            ID: specialOrder.id,
            ID_FS: specialOrder.idFS,
            EMPLOYEE: jsonEncode(Personnel.toMap(specialOrder.employee)),
            CUSTOMER: jsonEncode(Personnel.toMap(specialOrder.customer)),
            PRODUCTS: jsonEncode(Product.toMapList(specialOrder.products)),
            TOTAL_AMOUNT: specialOrder.totalAmount,
            ADVANCE_PAYMENT: specialOrder.advancePayment,
            REMAINING_PAYMENT: specialOrder.remainingPayment,
            PAID_IN_FULL: specialOrder.paidInFull,
            NOTE: specialOrder.note,
            FIRST_MODIFIED: specialOrder.firstModified.toIso8601String(),
            LAST_MODIFIED: specialOrder.lastModified.toIso8601String()
          };
  }

  /// Converts Map to Model
  static SpecialOrder toModel(dynamic map) {
    return map == null
        ? null
        : SpecialOrder(
            id: map[ID],
            idFS: map[ID_FS],
            employee: Personnel.toModel(jsonDecode(map[EMPLOYEE])),
            customer: Personnel.toModel(jsonDecode(map[CUSTOMER])),
            products: Product.toModelList(jsonDecode(map[PRODUCTS])),
            totalAmount: map[TOTAL_AMOUNT],
            advancePayment: map[ADVANCE_PAYMENT],
            remainingPayment: map[REMAINING_PAYMENT],
            paidInFull: map[PAID_IN_FULL],
            note: map[NOTE],
            firstModified: DateTime.parse(map[FIRST_MODIFIED]),
            lastModified: DateTime.parse(map[LAST_MODIFIED]));
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
    models == null
        ? []
        : models.forEach((SpecialOrder model) {
            mapList.add(toMap(model));
          });
    return mapList;
  }
}
