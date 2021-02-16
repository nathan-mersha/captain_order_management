import 'dart:io';

import 'package:captain/db/dal/personnel.dart';
import 'package:captain/db/dal/product.dart';
import 'package:captain/db/dal/punch.dart';
import 'package:captain/db/model/personnel.dart';
import 'package:captain/db/model/product.dart';
import 'package:captain/db/model/punch.dart';
import 'package:captain/page/product/create_product.dart';
import 'package:captain/page/punch/statistics_punch.dart';
import 'package:captain/page/punch/view_punch.dart';
import 'package:captain/widget/c_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

class CreatePunchView extends StatefulWidget {
  final GlobalKey<CreatePunchViewState> createPunchKey;
  final GlobalKey<StatisticsPunchViewState> statisticsPunchKey;
  final GlobalKey<PunchTableState> punchTableKey;

  const CreatePunchView({this.punchTableKey, this.createPunchKey, this.statisticsPunchKey}) : super(key: createPunchKey);

  @override
  CreatePunchViewState createState() => CreatePunchViewState();
}

class CreatePunchViewState extends State<CreatePunchView> {
  final _formKey = GlobalKey<FormState>();
  Punch punch = Punch(type: PUNCH_IN);

  // Punch types
  static const String PUNCH_IN = "in";
  static const String PUNCH_OUT = "out";
  List<String> punchTypes = [PUNCH_IN, PUNCH_OUT];
  Map<String, String> punchTypeValues;

  /// Assigning default punch values here
  // Text editing controllers
  TextEditingController _employeeController = TextEditingController();
  TextEditingController _paintController = TextEditingController();
  TextEditingController _weightController = TextEditingController();
  TextEditingController _noteController = TextEditingController();

  // Lists required for view to be build
  List<Personnel> _employees = [];
  List<Product> _paints = [];

  /// Default true, unlike other pages because the page requires three data sources to be populated
  bool _doingCRUD = false;

  /// Handles employee and paint input validation
  bool _noEmployeeValue = false;
  bool _noPaintValue = false;

  @override
  void initState() {
    super.initState();
    punchTypeValues = {PUNCH_IN: "in", PUNCH_OUT: "out"};
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
                    "${punch.id == null ? "Create" : "Update"} Punch",
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
                                  icon: punch == null || punch.employee == null || punch.employee.profileImage == null
                                      ? Icon(
                                          Icons.person_pin,
                                          color: Colors.black12,
                                          size: 30,
                                        )
                                      : ClipOval(
                                          child: Image.file(
                                          File(punch.employee.profileImage),
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
                              punch.employee = selectedEmployee;
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
                                    color: punch == null || punch.product == null || punch.product.colorValue == null
                                        ? Colors.black12
                                        : Color(int.parse(punch.product.colorValue)),
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
                              punch.product = selectedPaint;
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

                        SizedBox(
                          height: 20,
                        ),
                        SizedBox(
                          width: double.infinity,
                          child: DropdownButton(
                              value: punch.type,
                              hint: Text(
                                "type",
                                style: TextStyle(
                                  fontSize: 12,
                                ),
                              ),
                              isExpanded: true,
                              iconSize: 18,
                              icon: Icon(
                                Icons.keyboard_arrow_down,
                                color: Theme.of(context).primaryColor,
                              ),
                              items: punchTypes.map<DropdownMenuItem<String>>((String punchValue) {
                                return DropdownMenuItem(
                                  child: Row(
                                    children: [
                                      Icon(
                                        punchValue == PUNCH_IN ? Icons.arrow_back : Icons.arrow_forward,
                                        size: 15,
                                        color: punchValue == PUNCH_IN ? Colors.red : Colors.green,
                                      ),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      Text(
                                        punchTypeValues[punchValue],
                                        style: TextStyle(fontSize: 12),
                                      ),
                                    ],
                                  ),
                                  value: punchValue,
                                );
                              }).toList(),
                              onChanged: (String newValue) {
                                setState(() {
                                  punch.type = newValue;
                                });
                              }),
                        ),

                        SizedBox(
                          height: 5,
                        ),
                        TextFormField(
                          validator: (nameValue) {
                            if (nameValue.isEmpty) {
                              return "Weight must not be empty";
                            } else {
                              return null;
                            }
                          },
                          keyboardType: TextInputType.number,
                          controller: _weightController,
                          onChanged: (countValue) {
                            punch.weight = num.parse(countValue);
                          },
                          onFieldSubmitted: (countValue) {
                            punch.weight = num.parse(countValue);
                          },
                          decoration: InputDecoration(labelText: "Weight (gm)", contentPadding: EdgeInsets.symmetric(vertical: 5)),
                        ),
                        SizedBox(
                          height: 5,
                        ),

                        TextFormField(
                          controller: _noteController,
                          onChanged: (noteValue) {
                            punch.note = noteValue;
                          },
                          onFieldSubmitted: (noteValue) {
                            punch.note = noteValue;
                          },
                          decoration: InputDecoration(labelText: "Note", contentPadding: EdgeInsets.symmetric(vertical: 5)),
                        ),
                      ],
                    ),
                  ),
                )),
            Container(
              child: punch.id == null
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
                          await createPunch(context);
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
                                await updatePunch(context);
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
      // Assigning default punch values on clearing fields here.
      punch = Punch(type: PUNCH_IN);
      clearInputs();
    });

    /// Notify corresponding widgets.
    widget.punchTableKey.currentState.setState(() {});
    widget.statisticsPunchKey.currentState.setState(() {});
  }

  Future<bool> _assignPersonnelAndPaintData() async {
    // Assigning employees data.
    String wherePersonnel = "${Personnel.TYPE} = ?";
    List<String> whereArgsEmployees = [Personnel.EMPLOYEE]; // Querying only employees
    _employees = await PersonnelDAL.find(where: wherePersonnel, whereArgs: whereArgsEmployees); // Assign employees

    // Assigning paints data
    String wherePaint = "${Product.TYPE} = ?";
    List<String> whereArgsPaint = [CreateProductViewState.PAINT]; // Querying only paint type
    _paints = await ProductDAL.find(where: wherePaint, whereArgs: whereArgsPaint);
    setState(() {});
    return true;
  }

  Future createPunch(BuildContext context) async {
    Punch createdPunch = await PunchDAL.create(punch);

    /// Showing notification
    CNotifications.showSnackBar(context, "Successfuly created punch for employee ${punch.employee.name}", "success", () {},
        backgroundColor: Colors.green);
    createInFSAndUpdateLocally(createdPunch);
  }

  Future createInFSAndUpdateLocally(Punch punch) async {
    String where = "${Punch.ID} = ?";
    List<String> whereArgs = [punch.id]; // Querying only punchs
    PunchDAL.find(where: where, whereArgs: whereArgs).then((List<Punch> punch) async {
      Punch queriedPunch = punch.first;

      /// todo Creating data to fire store, nullify image
      dynamic punchMap = Punch.toMap(queriedPunch);
//      DocumentReference docRef = await Firestore.instance.collection(Punch.COLLECTION_NAME).add(punchMap);
//      queriedPunch.idFS = docRef.documentID;
//      String where = "${Punch.ID} = ?";
//      List<String> whereArgs = [queriedPunch.id]; // Querying only punchs
//      PunchDAL.update(where: where, whereArgs: whereArgs, punch: queriedPunch);
    });
  }

  Future updatePunch(BuildContext context) async {
    /// Query and update user
    String where = "${Punch.ID} = ?";
    List<String> whereArgs = [punch.id];
    await PunchDAL.update(where: where, whereArgs: whereArgs, punch: punch);

    /// Updating from fire store
    dynamic punchMap = Punch.toMap(punch);
    // Updating to fire store if fire store generated id is present in doc.
    if (punch.idFS != null) {
      // todo : nullify image
//      Firestore.instance.collection(Punch.COLLECTION_NAME).document(punch.idFS).updateData(punchMap);
    }
    // Showing notification
    CNotifications.showSnackBar(context, "Successfuly updated retruned order for employee ${punch.employee.name}", "success", () {},
        backgroundColor: Theme.of(context).accentColor);
  }

  @override
  void dispose() {
    super.dispose();
    _weightController.dispose();
    _noteController.dispose();
    _employeeController.dispose();
    _paintController.dispose();
  }

  void clearInputs() {
    _weightController.clear();
    _noteController.clear();
    _employeeController.clear();
    _paintController.clear();
  }

  void passForUpdate(Punch punchUpdateData) async {
    String where = "${Punch.ID} = ?";
    List<String> whereArgs = [punchUpdateData.id]; // Querying only punchs
    List<Punch> punchs = await PunchDAL.find(where: where, whereArgs: whereArgs);

    setState(() {
      punch = punchs.first;
      _weightController.text = punch.weight.toString();
      _noteController.text = punch.note;
      _employeeController.text = punch.employee.name;
      _paintController.text = punch.product.name;
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
