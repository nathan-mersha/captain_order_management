import 'dart:io';

import 'package:captain/db/dal/personnel.dart';
import 'package:captain/db/dal/product.dart';
import 'package:captain/db/dal/returned_order.dart';
import 'package:captain/db/model/personnel.dart';
import 'package:captain/db/model/product.dart';
import 'package:captain/db/model/returned_order.dart';
import 'package:captain/page/product/create_product.dart';
import 'package:captain/page/returned_order/statistics_returned_order.dart';
import 'package:captain/page/returned_order/view_returned_order.dart';
import 'package:captain/widget/c_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

class CreateReturnedOrderView extends StatefulWidget {
  final GlobalKey<CreateReturnedOrderViewState> createReturnedOrderKey;
  final GlobalKey<StatisticsReturnedOrderViewState> statisticsReturnedOrderKey;
  final GlobalKey<ReturnedOrderTableState> returnedOrderTableKey;

  const CreateReturnedOrderView({this.returnedOrderTableKey, this.createReturnedOrderKey, this.statisticsReturnedOrderKey}) : super(key: createReturnedOrderKey);

  @override
  CreateReturnedOrderViewState createState() => CreateReturnedOrderViewState();
}

class CreateReturnedOrderViewState extends State<CreateReturnedOrderView> {
  final _formKey = GlobalKey<FormState>();
  ReturnedOrder returnedOrder = ReturnedOrder();

  /// Assigning default returnedOrder values here
  // Text editing controllers
  TextEditingController _employeeController = TextEditingController();
  TextEditingController _paintController = TextEditingController();
  TextEditingController _customerController = TextEditingController();
  TextEditingController _countController = TextEditingController();
  TextEditingController _noteController = TextEditingController();

  // Lists required for view to be build
  List<Personnel> _employees = [];
  List<Product> _paints = [];
  List<Personnel> _customers = [];

  /// Default true, unlike other pages because the page requires three data sources to be populated
  bool _doingCRUD = false;

  /// Handles employee and paint input validation
  bool _noEmployeeValue = false;
  bool _noPaintValue = false;

  @override
  void initState() {
    super.initState();
    _assignPersonnelAndPaintData();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(5))),
      child: Container(
        padding: EdgeInsets.only(bottom: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            SizedBox(
              width: double.infinity,
              child: Card(
                margin: EdgeInsets.all(0),
                color: Theme.of(context).primaryColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(5), topRight: Radius.circular(5))),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                  child: Text(
                    "${returnedOrder.id == null ? "Create" : "Update"} ReturnedOrder",
                    style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w800),
                  ),
                ),
              ),
            ),
            Container(
                height: 425,
                padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, right: 20, left: 20, top: 15),
                child: Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        /// Employee input
                        TypeAheadField(
                          textFieldConfiguration: TextFieldConfiguration(
                              controller: _employeeController,
                              maxLines: 1,
                              decoration: InputDecoration(
                                  errorText: _noEmployeeValue ? "Employee is required" : null,
                                  hintText: "Select employee",
                                  labelText: "Employee",
                                  icon: returnedOrder == null || returnedOrder.employee == null || returnedOrder.employee.profileImage == null
                                      ? Icon(
                                          Icons.person_pin,
                                          color: Colors.black12,
                                          size: 30,
                                        )
                                      : ClipOval(
                                          child: Image.file(
                                          File(returnedOrder.employee.profileImage),
                                          fit: BoxFit.cover,
                                          height: 30,
                                          width: 30,
                                        )))),
                          suggestionsCallback: (pattern) async {
                            return _employees.where((Personnel employee) {
                              return employee.name.toLowerCase().startsWith(pattern.toLowerCase()); // Apples to apples
                            });
                          },
                          itemBuilder: (context, Personnel suggestedEmployee) {
                            return ListTile(
                              dense: true,
                              leading: suggestedEmployee.profileImage == null
                                  ? Icon(
                                      Icons.person,
                                      color: Colors.black12,
                                    )
                                  : ClipOval(
                                      child: Image.file(
                                      File(suggestedEmployee.profileImage),
                                      fit: BoxFit.cover,
                                      height: 30,
                                      width: 30,
                                    )),
                              title: Text(suggestedEmployee.name),
                              subtitle: Text(suggestedEmployee.phoneNumber),
                            );
                          },
                          onSuggestionSelected: (Personnel selectedEmployee) {
                            setState(() {
                              _employeeController.text = selectedEmployee.name;
                              returnedOrder.employee = selectedEmployee;
                            });
                          },
                          noItemsFoundBuilder: (BuildContext context) {
                            return Container(
                              padding: EdgeInsets.symmetric(vertical: 12, horizontal: 5),
                              child: Text(
                                "No employees found",
                              ),
                            );
                          },
                        ),

                        /// Paint input
                        TypeAheadField(
                          textFieldConfiguration: TextFieldConfiguration(
                              controller: _paintController,
                              maxLines: 1,
                              decoration: InputDecoration(
                                  errorText: _noPaintValue ? "Paint value is required" : null,
                                  hintText: "Select paint",
                                  labelText: "Paint",
                                  icon: Icon(
                                    Icons.circle,
                                    size: 30,
                                    color: returnedOrder == null || returnedOrder.product == null || returnedOrder.product.colorValue == null
                                        ? Colors.black12
                                        : Color(int.parse(returnedOrder.product.colorValue)),
                                  ))),
                          suggestionsCallback: (pattern) async {
                            return _paints.where((Product paint) {
                              return paint.name.toLowerCase().startsWith(pattern.toLowerCase()); // Apples to apples
                            });
                          },
                          itemBuilder: (context, Product suggestedPaint) {
                            return ListTile(
                              dense: true,
                              leading: Icon(Icons.circle, size: 30, color: Color(int.parse(suggestedPaint.colorValue))),
                              title: Text(
                                suggestedPaint.name,
                                style: TextStyle(fontSize: 14, color: Colors.black87, fontWeight: FontWeight.w800),
                              ),
                            );
                          },
                          onSuggestionSelected: (Product selectedPaint) {
                            setState(() {
                              _paintController.text = selectedPaint.name;
                              returnedOrder.product = selectedPaint;
                            });
                          },
                          noItemsFoundBuilder: (BuildContext context) {
                            return Container(
                              padding: EdgeInsets.symmetric(vertical: 12, horizontal: 5),
                              child: Text(
                                "No paint found",
                              ),
                            );
                          },
                        ),

                        /// Customer input
                        TypeAheadField(
                          textFieldConfiguration: TextFieldConfiguration(
                              controller: _customerController,
                              maxLines: 1,
                              decoration: InputDecoration(
                                  hintText: "Select customer",
                                  labelText: "Customer",
                                  icon: returnedOrder == null || returnedOrder.customer == null || returnedOrder.customer.profileImage == null
                                      ? Icon(
                                          Icons.person_pin,
                                          color: Colors.black12,
                                          size: 30,
                                        )
                                      : ClipOval(
                                          child: Image.file(
                                          File(returnedOrder.customer.profileImage),
                                          fit: BoxFit.cover,
                                          height: 30,
                                          width: 30,
                                        )))),
                          suggestionsCallback: (pattern) async {
                            return _customers.where((Personnel customer) {
                              return customer.name.toLowerCase().startsWith(pattern.toLowerCase()); // Apples to apples
                            });
                          },
                          itemBuilder: (context, Personnel suggestedCustomer) {
                            return ListTile(
                              dense: true,
                              leading: suggestedCustomer.profileImage == null
                                  ? Icon(
                                      Icons.person,
                                      color: Colors.black12,
                                    )
                                  : ClipOval(
                                      child: Image.file(
                                      File(suggestedCustomer.profileImage),
                                      fit: BoxFit.cover,
                                      height: 30,
                                      width: 30,
                                    )),
                              title: Text(suggestedCustomer.name),
                              subtitle: Text(suggestedCustomer.phoneNumber),
                            );
                          },
                          onSuggestionSelected: (Personnel selectedCustomer) {
                            setState(() {
                              _customerController.text = selectedCustomer.name;
                              returnedOrder.customer = selectedCustomer;
                            });
                          },
                          noItemsFoundBuilder: (BuildContext context) {
                            return Container(
                              padding: EdgeInsets.symmetric(vertical: 12, horizontal: 5),
                              child: Text(
                                "No customer found",
                              ),
                            );
                          },
                        ),

                        SizedBox(
                          height: 5,
                        ),
                        TextFormField(
                          validator: (nameValue) {
                            if (nameValue.isEmpty) {
                              return "Count must not be empty";
                            } else {
                              return null;
                            }
                          },
                          keyboardType: TextInputType.number,
                          controller: _countController,
                          onChanged: (countValue) {
                            returnedOrder.count = num.parse(countValue);
                          },
                          onFieldSubmitted: (countValue) {
                            returnedOrder.count = num.parse(countValue);
                          },
                          decoration: InputDecoration(labelText: "Count", contentPadding: EdgeInsets.symmetric(vertical: 5)),
                        ),
                        SizedBox(
                          height: 5,
                        ),

                        TextFormField(
                          controller: _noteController,
                          onChanged: (noteValue) {
                            returnedOrder.note = noteValue;
                          },
                          onFieldSubmitted: (noteValue) {
                            returnedOrder.note = noteValue;
                          },
                          decoration: InputDecoration(labelText: "Note", contentPadding: EdgeInsets.symmetric(vertical: 5)),
                        ),
                      ],
                    ),
                  ),
                )),
            Container(
              child: returnedOrder.id == null
                  ? RaisedButton(
                      color: Theme.of(context).primaryColor,
                      child: _doingCRUD == true
                          ? Container(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 1,
                                backgroundColor: Colors.white,
                              ),
                            )
                          : Text(
                              "Create",
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                      onPressed: () async {
                        if (_formKey.currentState.validate() && fieldsValidated()) {
                          setState(() {
                            _doingCRUD = true;
                          });
                          await createReturnedOrder(context);
                          cleanFields();
                        }
                      },
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        RaisedButton(
                            child: Text(
                              "Update",
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.white),
                            ),
                            onPressed: () async {
                              if (_formKey.currentState.validate() && fieldsValidated()) {
                                setState(() {
                                  _doingCRUD = true;
                                });
                                await updateReturnedOrder(context);
                                cleanFields();
                              }
                            }),
                        OutlineButton(
                          child: Text(
                            "Cancel",
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Theme.of(context).accentColor),
                          ),
                          onPressed: () {
                            cleanFields();
                          },
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void cleanFields() {
    setState(() {
      /// Clearing data
      _doingCRUD = false;
      // Assigning default returnedOrder values on clearing fields here.
      returnedOrder = ReturnedOrder();
      clearInputs();
    });

    /// Notify corresponding widgets.
    widget.returnedOrderTableKey.currentState.setState(() {});
    widget.statisticsReturnedOrderKey.currentState.setState(() {});
  }

  Future<bool> _assignPersonnelAndPaintData() async {
    // Assigning employees data.
    String wherePersonnel = "${Personnel.TYPE} = ?";
    List<String> whereArgsCustomers = [Personnel.CUSTOMER]; // Querying only customers
    List<String> whereArgsEmployees = [Personnel.EMPLOYEE]; // Querying only employees
    _customers = await PersonnelDAL.find(where: wherePersonnel, whereArgs: whereArgsCustomers); // Assign customers
    _employees = await PersonnelDAL.find(where: wherePersonnel, whereArgs: whereArgsEmployees); // Assign employees

    // Assigning paints data
    String wherePaint = "${Product.TYPE} = ?";
    List<String> whereArgsPaint = [CreateProductViewState.PAINT]; // Querying only paint type
    _paints = await ProductDAL.find(where: wherePaint, whereArgs: whereArgsPaint);
    setState(() {});
    return true;
  }

  Future createReturnedOrder(BuildContext context) async {
    ReturnedOrder createdReturnedOrder = await ReturnedOrderDAL.create(returnedOrder);

    /// Showing notification
    CNotifications.showSnackBar(context, "Successfuly created returned order for employee ${returnedOrder.employee.name}", "success", () {}, backgroundColor: Colors.green);
    createInFSAndUpdateLocally(createdReturnedOrder);
  }

  Future createInFSAndUpdateLocally(ReturnedOrder returnedOrder) async {
    // String where = "${ReturnedOrder.ID} = ?";
    // List<String> whereArgs = [returnedOrder.id]; // Querying only returnedOrders
    // ReturnedOrderDAL.find(where: where, whereArgs: whereArgs).then((List<ReturnedOrder> returnedOrder) async {
    //   ReturnedOrder queriedReturnedOrder = returnedOrder.first;
    //
    //   /// todo Creating data to fire store nullify image
    //  dynamic returnedOrderMap = ReturnedOrder.toMap(queriedReturnedOrder);
    //  DocumentReference docRef = await Firestore.instance.collection(ReturnedOrder.COLLECTION_NAME).add(returnedOrderMap);
    //  queriedReturnedOrder.idFS = docRef.documentID;
    //  String where = "${ReturnedOrder.ID} = ?";
    //  List<String> whereArgs = [queriedReturnedOrder.id]; // Querying only returnedOrders
    //  ReturnedOrderDAL.update(where: where, whereArgs: whereArgs, returnedOrder: queriedReturnedOrder);
    // });
  }

  Future updateReturnedOrder(BuildContext context) async {
    /// Query and update user
    String where = "${ReturnedOrder.ID} = ?";
    List<String> whereArgs = [returnedOrder.id];
    await ReturnedOrderDAL.update(where: where, whereArgs: whereArgs, returnedOrder: returnedOrder);

    /// Updating from fire store
    dynamic returnedOrderMap = ReturnedOrder.toMap(returnedOrder);
    returnedOrder.employee.profileImage = null;
    returnedOrder.customer.profileImage = null;
    // Updating to fire store if fire store generated id is present in doc.
    if (returnedOrder.idFS != null) {
      // todo : nullify image
//      Firestore.instance.collection(ReturnedOrder.COLLECTION_NAME).document(returnedOrder.idFS).updateData(returnedOrderMap);
    }
    // Showing notification
    CNotifications.showSnackBar(context, "Successfuly updated retruned order for employee ${returnedOrder.employee.name}", "success", () {}, backgroundColor: Theme.of(context).accentColor);
  }

  void clearInputs() {
    _countController.clear();
    _noteController.clear();
    _employeeController.clear();
    _paintController.clear();
    _customerController.clear();
  }

  void passForUpdate(ReturnedOrder returnedOrderUpdateData) async {
    String where = "${ReturnedOrderDAL.TABLE_NAME}.${ReturnedOrder.ID} = ?";
    List<String> whereArgs = [returnedOrderUpdateData.id]; // Querying only returnedOrders
    List<ReturnedOrder> returnedOrders = await ReturnedOrderDAL.find(where: where, whereArgs: whereArgs);

    setState(() {
      returnedOrder = returnedOrders.first;
      _countController.text = returnedOrder.count.toString();
      _noteController.text = returnedOrder.note;
      _employeeController.text = returnedOrder.employee.name;
      _paintController.text = returnedOrder.product.name;
      _customerController.text = returnedOrder.customer.name;
    });
  }

  bool fieldsValidated() {
    /// Checking if employee and paint value is empty
    setState(() {
      _noEmployeeValue = _employeeController.text.isEmpty;
      _noPaintValue = _paintController.text.isEmpty;
    });
    return !_noEmployeeValue && !_noPaintValue;
  }
}
