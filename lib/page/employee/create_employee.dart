import 'dart:io';

import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'package:captain/db/dal/personnel.dart';
import 'package:captain/db/model/personnel.dart';
import 'package:captain/page/employee/statistics_employee.dart';
import 'package:captain/page/employee/view_employee.dart';
import 'package:captain/rsr/regions.dart';
import 'package:captain/widget/c_snackbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contact/contacts.dart';
import 'package:image_picker/image_picker.dart';

class CreateEmployeeView extends StatefulWidget {
  final GlobalKey<CreateEmployeeViewState> createEmployeeKey;
  final GlobalKey<StatisticsEmployeeViewState> statisticsEmployeeKey;
  final GlobalKey<EmployeeTableState> employeeTableKey;

  const CreateEmployeeView({this.employeeTableKey, this.createEmployeeKey, this.statisticsEmployeeKey}) : super(key: createEmployeeKey);

  @override
  CreateEmployeeViewState createState() => CreateEmployeeViewState();
}

class CreateEmployeeViewState extends State<CreateEmployeeView> {
  final picker = ImagePicker();
  final _formKey = GlobalKey<FormState>();
  bool _absorbInputProfileImg = false;
  Personnel employee = Personnel(type: Personnel.EMPLOYEE);

  // Text editing controllers
  TextEditingController _nameController = TextEditingController();
  TextEditingController _phoneNumberController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _addressDetailController = TextEditingController();
  TextEditingController _addressController = TextEditingController();
  TextEditingController _noteController = TextEditingController();

  bool _addressError = false;
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
                    "${employee.id == null ? "Create" : "Update"} Employee",
                    style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w800),
                  ),
                ),
              ),
            ),
            Container(
                height: 425,
                padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, right: 20, left: 20),
                child: Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Container(
                            child: AbsorbPointer(
                                absorbing: _absorbInputProfileImg,
                                child: GestureDetector(
                                    child: getProfileImage(),
                                    onTap: () {
                                      _pickImage();
                                    }))),
                        TextFormField(
                          validator: (nameValue) {
                            if (nameValue.isEmpty) {
                              return "Name must not be empty";
                            } else {
                              return null;
                            }
                          },
                          controller: _nameController,
                          onChanged: (nameValue) {
                            employee.name = nameValue;
                          },
                          onFieldSubmitted: (nameValue) {
                            employee.name = nameValue;
                          },
                          decoration: InputDecoration(labelText: "Name", contentPadding: EdgeInsets.symmetric(vertical: 5)),
                        ),
                        TextFormField(
                          validator: (phoneNumberValue) {
                            if (phoneNumberValue.isEmpty) {
                              return "Phone number must not be empty";
                            } else if (phoneNumberValue.length != 10 && phoneNumberValue.length != 12) {
                              return "valid 0911234567 or 251911234567";
                            } else {
                              return null;
                            }
                          },
                          controller: _phoneNumberController,
                          keyboardType: TextInputType.phone,
                          onChanged: (phoneNumberValue) {
                            employee.phoneNumber = phoneNumberValue;
                          },
                          onFieldSubmitted: (phoneNumberValue) {
                            employee.phoneNumber = phoneNumberValue;
                          },
                          decoration: InputDecoration(labelText: "Phone number", contentPadding: EdgeInsets.symmetric(vertical: 5)),
                        ),
                        TextFormField(
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(labelText: "Email", contentPadding: EdgeInsets.symmetric(vertical: 5)),
                          controller: _emailController,
                          onChanged: (emailValue) {
                            employee.email = emailValue;
                          },
                          onFieldSubmitted: (emailValue) {
                            employee.email = emailValue;
                          },
                        ),
                        SimpleAutoCompleteTextField(
                          suggestions: AddisAbabaRegions.regions,
                          clearOnSubmit: false,
                          decoration: InputDecoration(labelText: "Address", contentPadding: EdgeInsets.all(0)),
                          controller: _addressController,
                          textSubmitted: (String addressValue) {
                            employee.address = addressValue;
                            setState(() {
                              _addressError = false;
                            });
                          },
                        ),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Visibility(
                              visible: _addressError,
                              child: Column(
                                children: [
                                  SizedBox(
                                    height: 2,
                                  ),
                                  Text(
                                    "Address must not be empty",
                                    style: TextStyle(color: Colors.red.shade800, fontSize: 12),
                                  )
                                ],
                              )),
                        ),
                        TextFormField(
                          onChanged: (addressDetailValue) {
                            employee.addressDetail = addressDetailValue;
                          },
                          onFieldSubmitted: (addressDetailValue) {
                            employee.addressDetail = addressDetailValue;
                          },
                          controller: _addressDetailController,
                          decoration: InputDecoration(labelText: "Address detail", contentPadding: EdgeInsets.symmetric(vertical: 5)),
                        ),
                        TextFormField(
                          decoration: InputDecoration(labelText: "Note", contentPadding: EdgeInsets.symmetric(vertical: 5)),
                          controller: _noteController,
                          onChanged: (noteValue) {
                            employee.note = noteValue;
                          },
                          onFieldSubmitted: (noteValue) {
                            employee.note = noteValue;
                          },
                        ),
                      ],
                    ),
                  ),
                )),
            Container(
              child: employee.id == null
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
                          if (employee.address == null) {
                            // Validating if address exists.
                            setState(() {
                              _addressError = true;
                            });
                          } else {
                            setState(() {
                              _doingCRUD = true;
                              _addressError = false;
                            });

                            await createEmployee(context);
                            cleanFields();
                          }
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
                                if (employee.address == null) {
                                  // Validating if address exists.
                                  setState(() {
                                    _addressError = true;
                                  });
                                } else {
                                  setState(() {
                                    _doingCRUD = true;
                                    _addressError = false;
                                  });

                                  await updateEmployee(context);
                                  cleanFields();
                                }
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
      employee = Personnel(type: Personnel.EMPLOYEE);
      clearInputs();
    });

    /// Notify corresponding widgets.
    widget.employeeTableKey.currentState.setState(() {});
    widget.statisticsEmployeeKey.currentState.setState(() {});
  }

  Future createEmployee(BuildContext context) async {
    Contact contact = Contact(
      givenName: employee.name,
      displayName: employee.name,
      phones: [Item(value: employee.phoneNumber)],
      emails: [Item(value: employee.email)],
      jobTitle: Personnel.EMPLOYEE,
      note: employee.note,
    );

    Contact createdContact = await Contacts.addContact(contact);

    /// Create Personnel Employee data to local db
    employee.contactIdentifier = createdContact.identifier;
    Personnel createdEmployee = await PersonnelDAL.create(employee);

    /// Showing notification
    CNotifications.showSnackBar(context, "Successfuly created : ${employee.name}", "success", () {}, backgroundColor: Colors.green);

    createInFSAndUpdateLocally(createdEmployee);
  }

  Future createInFSAndUpdateLocally(Personnel employee) async {
    String where = "${Personnel.ID} = ?";
    List<String> whereArgs = [employee.id]; // Querying only employees
    PersonnelDAL.find(where: where, whereArgs: whereArgs).then((List<Personnel> personnel) async {
      Personnel queriedEmployee = personnel.first;

      /// Creating data to fire store
      dynamic employeeMap = Personnel.toMap(queriedEmployee);
      employeeMap[Personnel.PROFILE_IMAGE] = null; // setting profile image to null, takes too much space, and takes time uploading object
//      DocumentReference docRef = await Firestore.instance.collection(Personnel.EMPLOYEE).add(employeeMap);
//      queriedEmployee.idFS = docRef.documentID;

      String where = "${Personnel.ID} = ?";
      List<String> whereArgs = [queriedEmployee.id]; // Querying only employees
      PersonnelDAL.update(where: where, whereArgs: whereArgs, personnel: queriedEmployee);
    });
  }

  Future updateEmployee(BuildContext context) async {
    /// Query and update user
    String where = "${Personnel.ID} = ?";
    List<String> whereArgs = [employee.id];
    await PersonnelDAL.update(where: where, whereArgs: whereArgs, personnel: employee);

    /// Updating contacts
    Contact contact = Contact(
        givenName: employee.name,
        displayName: employee.name,
        phones: [Item(value: employee.phoneNumber)],
        emails: [Item(value: employee.email)],
        jobTitle: Personnel.EMPLOYEE,
        note: employee.note,
        identifier: employee.contactIdentifier);

    Contacts.updateContact(contact);

    /// Updating from fire store
    dynamic employeeMap = Personnel.toMap(employee);
    employeeMap[Personnel.PROFILE_IMAGE] = null; // setting profile image to null, takes too much space, and takes time uploading object

    // Updating to fire store if fire store generated id is present in doc.
    if (employee.idFS != null) {
//      Firestore.instance.collection(Personnel.EMPLOYEE).document(employee.idFS).updateData(employeeMap);
    }

    // Showing notification
    CNotifications.showSnackBar(context, "Successfuly updated : ${employee.name}", "success", () {}, backgroundColor: Theme.of(context).accentColor);
  }

  void _pickImage() async {
    PickedFile file = await picker.getImage(source: ImageSource.gallery, imageQuality: 50);
    if (file != null) {
      employee.profileImage = file.path;
      setState(() {}); // not assigning profile image in set state to reduce lag.
    }
  }

  Widget getProfileImage() {
    double imageSize = 70;
    double iconSize = 45;
    EdgeInsets padding = EdgeInsets.only(top: 20);

    if (employee.profileImage == null) {
      return Container(
        margin: padding,
        child: Icon(
          Icons.person_outline_rounded,
          color: Theme.of(context).primaryColorLight,
          size: iconSize,
        ),
      );
    } else {
      return Container(
        margin: padding,
        height: imageSize,
        width: imageSize,
        child: ClipOval(
            child: Image.file(
          File(employee.profileImage),
          fit: BoxFit.cover,
          height: 30,
          width: 30,
        )),
      );
    }
  }

  void clearInputs() {
    _nameController.clear();
    _phoneNumberController.clear();
    _emailController.clear();
    _addressController.clear();
    _addressDetailController.clear();
    _noteController.clear();
  }

  @override
  void dispose() {
    super.dispose();
    _nameController.dispose();
    _phoneNumberController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _addressDetailController.dispose();
    _noteController.dispose();
  }

  void passForUpdate(Personnel employeeUpdateData) async {
    String where = "${Personnel.ID} = ?";
    List<String> whereArgs = [employeeUpdateData.id]; // Querying only employees
    List<Personnel> personnel = await PersonnelDAL.find(where: where, whereArgs: whereArgs);

    setState(() {
      employee = personnel.first;
      _nameController.text = employee.name;
      _phoneNumberController.text = employee.phoneNumber;
      _emailController.text = employee.email;
      _addressController.text = employee.address;
      _addressDetailController.text = employee.addressDetail;
      _noteController.text = employee.note;
    });
  }
}
