import 'package:captain/db/dal/returned_order.dart';
import 'package:captain/db/model/returned_order.dart';
import 'package:captain/page/returned_order/statistics_returned_order.dart';
import 'package:captain/page/returned_order/view_returned_order.dart';
import 'package:captain/widget/c_snackbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

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
  TextEditingController _countController = TextEditingController();
  TextEditingController _noteController = TextEditingController();

  bool _doingCRUD = false;

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
                        if (_formKey.currentState.validate()) {
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
                              if (_formKey.currentState.validate()) {
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

  Future createReturnedOrder(BuildContext context) async {
    ReturnedOrder createdReturnedOrder = await ReturnedOrderDAL.create(returnedOrder);

    /// Showing notification
    CNotifications.showSnackBar(context, "Successfuly created retruned order for employee ${returnedOrder.employee.name}", "success", () {}, backgroundColor: Colors.green);
    createInFSAndUpdateLocally(createdReturnedOrder);
  }

  Future createInFSAndUpdateLocally(ReturnedOrder returnedOrder) async {
    String where = "${ReturnedOrder.ID} = ?";
    List<String> whereArgs = [returnedOrder.id]; // Querying only returnedOrders
    ReturnedOrderDAL.find(where: where, whereArgs: whereArgs).then((List<ReturnedOrder> returnedOrder) async {
      ReturnedOrder queriedReturnedOrder = returnedOrder.first;

      /// Creating data to fire store
      dynamic returnedOrderMap = ReturnedOrder.toMap(queriedReturnedOrder);
      DocumentReference docRef = await Firestore.instance.collection(ReturnedOrder.COLLECTION_NAME).add(returnedOrderMap);
      queriedReturnedOrder.idFS = docRef.documentID;
      String where = "${ReturnedOrder.ID} = ?";
      List<String> whereArgs = [queriedReturnedOrder.id]; // Querying only returnedOrders
      ReturnedOrderDAL.update(where: where, whereArgs: whereArgs, returnedOrder: queriedReturnedOrder);
    });
  }

  Future updateReturnedOrder(BuildContext context) async {
    /// Query and update user
    String where = "${ReturnedOrder.ID} = ?";
    List<String> whereArgs = [returnedOrder.id];
    await ReturnedOrderDAL.update(where: where, whereArgs: whereArgs, returnedOrder: returnedOrder);

    /// Updating from fire store
    dynamic returnedOrderMap = ReturnedOrder.toMap(returnedOrder);
    // Updating to fire store if fire store generated id is present in doc.
    if (returnedOrder.idFS != null) {
      Firestore.instance.collection(ReturnedOrder.COLLECTION_NAME).document(returnedOrder.idFS).updateData(returnedOrderMap);
    }
    // Showing notification
    CNotifications.showSnackBar(context, "Successfuly updated retruned order for employee ${returnedOrder.employee.name}", "success", () {}, backgroundColor: Theme.of(context).accentColor);
  }

  void clearInputs() {
    _countController.clear();
    _noteController.clear();

    // todo : add clear inputs for customer and employee values
  }

  void passForUpdate(ReturnedOrder returnedOrderUpdateData) async {
    String where = "${ReturnedOrder.ID} = ?";
    List<String> whereArgs = [returnedOrderUpdateData.id]; // Querying only returnedOrders
    List<ReturnedOrder> returnedOrders = await ReturnedOrderDAL.find(where: where, whereArgs: whereArgs);

    setState(() {
      returnedOrder = returnedOrders.first;
      _countController.text = returnedOrder.count.toString();
      _noteController.text = returnedOrder.note;
      // todo : pass customer, color code and employee values for update here.
    });
  }
}
