import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'package:captain/db/dal/personnel.dart';
import 'package:captain/db/model/personnel.dart';
import 'package:captain/rsr/kapci/regions.dart';
import 'package:captain/widget/c_dialog.dart';
import 'package:captain/widget/c_snackbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class CreateEmployeeView extends StatefulWidget {
  @override
  _CreateEmployeeViewState createState() => _CreateEmployeeViewState();
}

class _CreateEmployeeViewState extends State<CreateEmployeeView> {
  final picker = ImagePicker();
  final _formKey = GlobalKey<FormState>();
  bool _absorbInputProfileImg = false;
  Personnel employee = Personnel(type: Personnel.EMPLOYEE);

  // Text editing controllers
  TextEditingController _nameController = TextEditingController();
  TextEditingController _phoneNumberController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _addressDetailController = TextEditingController();
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
                          decoration: InputDecoration(labelText: "Address"),
                          clearOnSubmit: false,
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
                              child: Column(children: [
                                SizedBox(height: 2,),
                                Text(
                                  "Address must not be empty",
                                  style: TextStyle(color: Colors.red.shade800, fontSize: 12),
                                )
                              ],)),
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
              child: RaisedButton(
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
                        employee.id == null ? "Create" : "Update",
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.white),
                      ),
                onPressed: () {
                  if (_formKey.currentState.validate()) {
                    if (employee.address == null) {
                      print("Herr address empty");
                      setState(() {
                        _addressError = true;
                      });
                    } else {
                      setState(() {
                        _doingCRUD = true;
                        _addressError = false;
                      });
                      // Create Employee to DB
                      if (employee.id == null) {
                        PersonnelDAL.create(employee).whenComplete(() {
                          // Creating contact here.
                          Contact contact = Contact(
                            androidAccountName: employee.name,
                            givenName: employee.name,
                            displayName: employee.name,
                            phones: [Item(value: employee.phoneNumber)],
                            emails: [Item(value: employee.email)],
                            jobTitle: "Captain Employee",
                            avatar: employee.profileImage,
                          );
                          ContactsService.addContact(contact);

                          // Creating data to fire store
                          dynamic employeeMap = Personnel.toMap(employee);
                          employeeMap[Personnel.PROFILE_IMAGE] = null; // setting profile image to null, takes too much space, and takes time uploading object
                          // Saving to fire store.
                          Firestore.instance.collection(Personnel.EMPLOYEE).add(employeeMap).then((value) {});

                          // Showing notification
                          CNotifications.showSnackBar(context, "Successfuly created : ${employee.name}", "success", () {}, backgroundColor: Colors.green);

                          setState(() {
                            _doingCRUD = false;
                          });

                          employee = new Personnel(type: Personnel.EMPLOYEE);
                          clearInputs();

                          // Clearing data
                        });
                      }
                      // todo Update employee
                      else {}
                    }
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _pickImage() async {
    final imageSource = await showDialog<ImageSource>(
        context: context,
        builder: (context) => CDialog(
              widgetYes: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  Icon(
                    Icons.camera_alt,
                    size: 50,
                    color: Theme.of(context).primaryColor,
                  ),
                  Text(
                    "Camera",
                    style: TextStyle(color: Colors.black54),
                  )
                ],
              ),
              widgetNo: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  Icon(Icons.photo, size: 50, color: Theme.of(context).accentColor),
                  Text(
                    "Gallery",
                    style: TextStyle(color: Colors.black54),
                  )
                ],
              ),
              message: "Please selecte image source",
              onYes: () {
                Navigator.pop(context, ImageSource.camera);
              },
              onNo: () {
                Navigator.pop(context, ImageSource.gallery);
              },
            ));

    if (imageSource != null) {
      final PickedFile file = await picker.getImage(source: imageSource, imageQuality: 50);

      if (file != null) {
        employee.profileImage = await file.readAsBytes();
        setState(() {}); // not assigning profile image in set state to reduce lag.
      }
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
          Icons.camera,
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
          child: Image.memory(
            employee.profileImage,
            fit: BoxFit.cover,
            height: 30,
            width: 30,
          ),
        ),
      );
    }
  }

  void clearInputs() {
    _nameController.clear();
    _phoneNumberController.clear();
    _emailController.clear();
    _addressDetailController.clear();
    _noteController.clear();
  }
}
