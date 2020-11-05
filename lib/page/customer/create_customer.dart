import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'package:captain/db/dal/personnel.dart';
import 'package:captain/db/model/personnel.dart';
import 'package:captain/page/customer/statistics_customer.dart';
import 'package:captain/page/customer/view_customer.dart';
import 'package:captain/rsr/kapci/regions.dart';
import 'package:captain/widget/c_dialog.dart';
import 'package:captain/widget/c_snackbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contact/contacts.dart';
import 'package:image_picker/image_picker.dart';

class CreateCustomerView extends StatefulWidget {
  final GlobalKey<CreateCustomerViewState> createCustomerKey;
  final GlobalKey<StatisticsCustomerViewState> statisticsCustomerKey;
  final GlobalKey<CustomerTableState> customerTableKey;

  const CreateCustomerView({this.customerTableKey, this.createCustomerKey, this.statisticsCustomerKey}) : super(key: createCustomerKey);

  @override
  CreateCustomerViewState createState() => CreateCustomerViewState();
}

class CreateCustomerViewState extends State<CreateCustomerView> {
  final picker = ImagePicker();
  final _formKey = GlobalKey<FormState>();
  bool _absorbInputProfileImg = false;
  Personnel customer = Personnel(type: Personnel.CUSTOMER);

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
                    "${customer.id == null ? "Create" : "Update"} Customer",
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
                            customer.name = nameValue;
                          },
                          onFieldSubmitted: (nameValue) {
                            customer.name = nameValue;
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
                            customer.phoneNumber = phoneNumberValue;
                          },
                          onFieldSubmitted: (phoneNumberValue) {
                            customer.phoneNumber = phoneNumberValue;
                          },
                          decoration: InputDecoration(labelText: "Phone number", contentPadding: EdgeInsets.symmetric(vertical: 5)),
                        ),
                        TextFormField(
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(labelText: "Email", contentPadding: EdgeInsets.symmetric(vertical: 5)),
                          controller: _emailController,
                          onChanged: (emailValue) {
                            customer.email = emailValue;
                          },
                          onFieldSubmitted: (emailValue) {
                            customer.email = emailValue;
                          },
                        ),
                        SimpleAutoCompleteTextField(
                          suggestions: AddisAbabaRegions.regions,
                          clearOnSubmit: false,
                          decoration: InputDecoration(labelText: "Address"),
                          controller: _addressController,
                          textSubmitted: (String addressValue) {
                            customer.address = addressValue;
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
                            customer.addressDetail = addressDetailValue;
                          },
                          onFieldSubmitted: (addressDetailValue) {
                            customer.addressDetail = addressDetailValue;
                          },
                          controller: _addressDetailController,
                          decoration: InputDecoration(labelText: "Address detail", contentPadding: EdgeInsets.symmetric(vertical: 5)),
                        ),
                        TextFormField(
                          decoration: InputDecoration(labelText: "Note", contentPadding: EdgeInsets.symmetric(vertical: 5)),
                          controller: _noteController,
                          onChanged: (noteValue) {
                            customer.note = noteValue;
                          },
                          onFieldSubmitted: (noteValue) {
                            customer.note = noteValue;
                          },
                        ),
                      ],
                    ),
                  ),
                )),
            Container(
              child: customer.id == null
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
                          if (customer.address == null) {
                            // Validating if address exists.
                            setState(() {
                              _addressError = true;
                            });
                          } else {
                            setState(() {
                              _doingCRUD = true;
                              _addressError = false;
                            });

                            await createCustomer(context);
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
                                if (customer.address == null) {
                                  // Validating if address exists.
                                  setState(() {
                                    _addressError = true;
                                  });
                                } else {
                                  setState(() {
                                    _doingCRUD = true;
                                    _addressError = false;
                                  });

                                  await updateCustomer(context);
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
      customer = Personnel(type: Personnel.CUSTOMER);
      clearInputs();
    });

    /// Notify corresponding widgets.
    widget.customerTableKey.currentState.setState(() {});
    widget.statisticsCustomerKey.currentState.setState(() {});
  }

  Future createCustomer(BuildContext context) async {
    Contact contact = Contact(
      givenName: customer.name,
      displayName: customer.name,
      phones: [Item(value: customer.phoneNumber)],
      emails: [Item(value: customer.email)],
      jobTitle: Personnel.CUSTOMER,
      avatar: customer.profileImage,
      note: customer.note,
    );

    Contact createdContact = await Contacts.addContact(contact);

    /// Create Personnel Customer data to local db
    customer.contactIdentifier = createdContact.identifier;
    Personnel createdCustomer = await PersonnelDAL.create(customer);

    /// Showing notification
    CNotifications.showSnackBar(context, "Successfuly created : ${customer.name}", "success", () {}, backgroundColor: Colors.green);

    createInFSAndUpdateLocally(createdCustomer);
  }

  Future createInFSAndUpdateLocally(Personnel customer) async {
    String where = "${Personnel.ID} = ?";
    List<String> whereArgs = [customer.id]; // Querying only customers
    PersonnelDAL.find(where: where, whereArgs: whereArgs).then((List<Personnel> personnel) async {
      Personnel queriedCustomer = personnel.first;

      /// Creating data to fire store
      dynamic customerMap = Personnel.toMap(queriedCustomer);
      customerMap[Personnel.PROFILE_IMAGE] = null; // setting profile image to null, takes too much space, and takes time uploading object
      DocumentReference docRef = await Firestore.instance.collection(Personnel.CUSTOMER).add(customerMap);
      queriedCustomer.idFS = docRef.documentID;

      String where = "${Personnel.ID} = ?";
      List<String> whereArgs = [queriedCustomer.id]; // Querying only customers
      PersonnelDAL.update(where: where, whereArgs: whereArgs, personnel: queriedCustomer);
    });
  }

  Future updateCustomer(BuildContext context) async {
    /// Query and update user
    String where = "${Personnel.ID} = ?";
    List<String> whereArgs = [customer.id];
    await PersonnelDAL.update(where: where, whereArgs: whereArgs, personnel: customer);

    /// Updating contacts
    Contact contact = Contact(
        givenName: customer.name,
        displayName: customer.name,
        phones: [Item(value: customer.phoneNumber)],
        emails: [Item(value: customer.email)],
        jobTitle: Personnel.CUSTOMER,
        avatar: customer.profileImage,
        note: customer.note,
        identifier: customer.contactIdentifier);

    Contacts.updateContact(contact);

    /// Updating from fire store
    dynamic customerMap = Personnel.toMap(customer);
    customerMap[Personnel.PROFILE_IMAGE] = null; // setting profile image to null, takes too much space, and takes time uploading object

    // Updating to fire store if fire store generated id is present in doc.
    if (customer.idFS != null) {
      Firestore.instance.collection(Personnel.CUSTOMER).document(customer.idFS).updateData(customerMap);
    }

    // Showing notification
    CNotifications.showSnackBar(context, "Successfuly updated : ${customer.name}", "success", () {}, backgroundColor: Theme.of(context).accentColor);
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
        customer.profileImage = await file.readAsBytes();
        setState(() {}); // not assigning profile image in set state to reduce lag.
      }
    }
  }

  Widget getProfileImage() {
    double imageSize = 70;
    double iconSize = 45;
    EdgeInsets padding = EdgeInsets.only(top: 20);

    if (customer.profileImage == null) {
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
          child: Image.memory(
            customer.profileImage,
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
    _addressController.clear();
    _addressDetailController.clear();
    _noteController.clear();
  }

  void passForUpdate(Personnel customerUpdateData) async {
    String where = "${Personnel.ID} = ?";
    List<String> whereArgs = [customerUpdateData.id]; // Querying only customers
    List<Personnel> personnel = await PersonnelDAL.find(where: where, whereArgs: whereArgs);

    setState(() {
      customer = personnel.first;
      _nameController.text = customer.name;
      _phoneNumberController.text = customer.phoneNumber;
      _emailController.text = customer.email;
      _addressController.text = customer.address;
      _addressDetailController.text = customer.addressDetail;
      _noteController.text = customer.note;
    });
  }
}
