import 'dart:convert';

import 'package:captain/db/dal/personnel.dart';
import 'package:captain/db/model/personnel.dart';
import 'package:captain/db/model/product.dart';
import 'package:flutter/material.dart';

/// Defines normalOrder db.model
class NormalOrder with ChangeNotifier {
  static const String COLLECTION_NAME = "normalOrder";

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
  static const String STATUS = "status";
  static const String USER_NOTIFIED = "userNotified";
  static const String FIRST_MODIFIED = "firstModified";
  static const String LAST_MODIFIED = "lastModified";

  String id;
  String idFS;
  Personnel employee;
  Personnel customer;
  List<Product> products; // Collection of paint and other products
  num totalAmount;
  num advancePayment;
  num remainingPayment;
  bool paidInFull;
  String status; // open,closed
  bool userNotified;
  DateTime firstModified;
  DateTime lastModified;

  NormalOrder(
      {this.id,
      this.idFS,
      this.employee,
      this.customer,
      this.products,
      this.totalAmount,
      this.advancePayment = 0,
      this.remainingPayment,
      this.paidInFull,
      this.status,
      this.userNotified,
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
  static Map<String, dynamic> toMap(NormalOrder normalOrder) {
    return normalOrder == null
        ? null
        : {
            ID: normalOrder.id,
            ID_FS: normalOrder.idFS,
            EMPLOYEE: normalOrder.employee == null ? null : normalOrder.employee.id,
            CUSTOMER: normalOrder.customer == null ? null : normalOrder.customer.id,
            PRODUCTS: jsonEncode(Product.toMapList(normalOrder.products)),
            TOTAL_AMOUNT: normalOrder.totalAmount,
            ADVANCE_PAYMENT: normalOrder.advancePayment,
            REMAINING_PAYMENT: normalOrder.remainingPayment,
            PAID_IN_FULL: normalOrder.paidInFull,
            STATUS: normalOrder.status,
            USER_NOTIFIED: normalOrder.userNotified,
            FIRST_MODIFIED: normalOrder.firstModified == null ? DateTime.now().toIso8601String() : normalOrder.firstModified.toIso8601String(),
            LAST_MODIFIED: normalOrder.lastModified == null ? DateTime.now().toIso8601String() : normalOrder.lastModified.toIso8601String()
          };
  }

  /// Converts Map to Model
  static Future<NormalOrder> toModel(dynamic map) async {
    String where = "${Personnel.ID} = ?";
    List<String> whereArgsEmployee = [Personnel.toModel(map[EMPLOYEE]).id]; // Querying employee by id
    List<String> whereArgsCustomer = [Personnel.toModel(map[CUSTOMER]).id]; // Querying customer by id
    List<Personnel> employees = await PersonnelDAL.find(where: where, whereArgs: whereArgsEmployee);
    List<Personnel> customers = await PersonnelDAL.find(where: where, whereArgs: whereArgsCustomer);

    return map == null
        ? null
        : NormalOrder(
            id: map[ID],
            idFS: map[ID_FS],
            employee: employees.isEmpty ? null : employees.first,
            customer: customers.isEmpty ? null : customers.first,
            products: Product.toModelList(jsonDecode(map[PRODUCTS])),
            totalAmount: map[TOTAL_AMOUNT],
            advancePayment: map[ADVANCE_PAYMENT],
            remainingPayment: map[REMAINING_PAYMENT],
            paidInFull: map[PAID_IN_FULL],
            status: map[STATUS],
            userNotified: map[USER_NOTIFIED],
            firstModified: DateTime.parse(map[FIRST_MODIFIED]),
            lastModified: DateTime.parse(map[LAST_MODIFIED]));
  }

  /// Changes List of Map to List of Model
  static Future<List<NormalOrder>> toModelList(List<dynamic> maps) async {
    List<NormalOrder> modelList = [];
    maps.forEach((dynamic map) async {
      modelList.add(await toModel(map));
    });
    return modelList;
  }

  /// Changes List of Model to List of Map
  static List<Map<String, dynamic>> toMapList(List<NormalOrder> models) {
    List<Map<String, dynamic>> mapList = [];
    models == null
        ? []
        : models.forEach((NormalOrder model) {
            mapList.add(toMap(model));
          });
    return mapList;
  }
}
