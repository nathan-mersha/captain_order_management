import 'package:captain/db/dal/personnel.dart';
import 'package:captain/db/model/personnel.dart';
import 'package:captain/db/model/statistics.dart';
import 'package:captain/rsr/kapci/regions.dart';
import 'package:captain/widget/c_dialog.dart';
import 'package:captain/widget/c_snackbar.dart';
import 'package:captain/widget/statistics.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class EmployeesPage extends StatefulWidget {
  @override
  _EmployeesPageState createState() => _EmployeesPageState();
}

class _EmployeesPageState extends State<EmployeesPage> with SingleTickerProviderStateMixin {
  final picker = ImagePicker();
  final _formKey = GlobalKey<FormState>();
  bool _absorbInputProfileImg = false;
  bool _doingCRUD = false;
  Personnel employee = Personnel(type: Personnel.EMPLOYEE);
  List<Personnel> employees;

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Column(
      children: <Widget>[
        // Statistics view
        Row(
          children: <Widget>[
            StatisticsCard(Statistics(stat: "1234")),
            StatisticsCard(Statistics(stat: "1234")),
            StatisticsCard(Statistics(stat: "1234")),
            StatisticsCard(Statistics(stat: "1234")),
            StatisticsCard(Statistics(stat: "1234")),
          ],
        ),

        // Create employee and employees list
        AbsorbPointer(
          absorbing: _doingCRUD,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                flex: 1,
                child: Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(5))),
                  child: Container(
                    padding: EdgeInsets.only(bottom: 23),
                    child: Column(
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
                            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, right: 20, left: 20),
                            height: 465,
                            child: Form(
                              key: _formKey,
                              child: ListView(
                                children: <Widget>[
                                  Container(
                                      child: AbsorbPointer(
                                          absorbing: _absorbInputProfileImg,
                                          child: GestureDetector(
                                              child: Stack(
                                                alignment: AlignmentDirectional.center,
                                                children: <Widget>[getProfileImage()],
                                              ),
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
                                    onChanged: (nameValue) {
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
                                    keyboardType: TextInputType.phone,
                                    onChanged: (phoneNumberValue) {
                                      employee.phoneNumber = phoneNumberValue;
                                    },
                                    decoration: InputDecoration(labelText: "Phone number", contentPadding: EdgeInsets.symmetric(vertical: 5)),
                                  ),
                                  TextFormField(
                                    keyboardType: TextInputType.emailAddress,
                                    decoration: InputDecoration(labelText: "Email", contentPadding: EdgeInsets.symmetric(vertical: 5)),
                                    onChanged: (emailValue) {
                                      employee.email = emailValue;
                                    },
                                  ),
                                  SizedBox(
                                    child: DropdownButton<String>(
                                      isExpanded: true,
                                      isDense: false,
                                      itemHeight: 58,
                                      hint: Text(
                                        "Please select address",
                                        style: TextStyle(fontSize: 11),
                                      ),
                                      onChanged: (addressValue) {
                                        setState(() {
                                          employee.address = addressValue;
                                        });
                                        // on package change
                                      },
                                      value: employee.address,
                                      items: AddisAbabaRegions.regions.map((String package) {
                                        return DropdownMenuItem<String>(value: package, child: Text(package));
                                      }).toList(),
                                    ),
                                  ),
                                  TextFormField(
                                    onChanged: (addressDetailValue) {
                                      employee.addressDetail = addressDetailValue;
                                    },
                                    decoration: InputDecoration(labelText: "Address Detail", contentPadding: EdgeInsets.symmetric(vertical: 5)),
                                  ),
                                  TextFormField(
                                    decoration: InputDecoration(labelText: "Note", contentPadding: EdgeInsets.symmetric(vertical: 5)),
                                    onChanged: (noteValue) {
                                      employee.note = noteValue;
                                    },
                                  ),
                                ],
                              ),
                            )),
                        SizedBox(
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
                                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800),
                                  ),
                            onPressed: () {
                              if (_formKey.currentState.validate()) {
                                setState(() {
                                  _doingCRUD = true;
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

                                    setState(() {
                                      _doingCRUD = false;
                                      employee = new Personnel(type: Personnel.EMPLOYEE);
                                    });

                                    // Showing notification
                                    CNotifications.showSnackBar(context, "Successfuly created : ${employee.name}", "success", () {}, backgroundColor: Colors.green);

                                    // Clearing data
                                  });
                                }
                                // Update employee
                                else {}
                              }
                            },
                          ),
                          width: 200,
                          height: 30,
                        )
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(5))),
                  child: Container(
                    padding: EdgeInsets.only(bottom: 23),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
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
                                "Employees",
                                style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w800),
                              ),
                            ),
                          ),
                        ),
                        Container(
                          height: 495,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.vertical,
                            child: FutureBuilder(
                              future: getListOfEmployees(),
                              builder: (BuildContext context, AsyncSnapshot<List<Personnel>> snapshot) {
                                if (snapshot.connectionState == ConnectionState.waiting || snapshot.connectionState == ConnectionState.none) {
                                  return Text("Waiting connection");
                                } else if (snapshot.connectionState == ConnectionState.done) {
                                  if (snapshot.hasData) {
                                    employees = snapshot.data;
//
//                              setState(() {
//                              });

                                    print("employees data : ${snapshot.data}");
                                    return Container(
//                                   padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, right: 20, left: 20),
                                        child: employees == null
                                            ? Text("No employees found")
                                            : DataTable(
                                                columns: [
                                                  DataColumn(label: Text("Name")),
                                                  DataColumn(label: Text("Phone number")),
                                                  DataColumn(label: Text("Address")),
                                                  DataColumn(label: Text("Date")),
                                                  DataColumn(label: Text("")),
                                                ],
                                                rows: employees.map((Personnel employee) {
                                                  return DataRow(cells: [
                                                    DataCell(Text(employee.name ?? '-')),
                                                    DataCell(Text(employee.phoneNumber ?? '-')),
                                                    DataCell(Text(employee.address ?? '-')),
                                                    DataCell(Text(DateFormat.yMMMd().format(employee.firstModified))),
                                                    DataCell(IconButton(
                                                      icon: Icon(
                                                        Icons.delete_outline,
                                                        color: Theme.of(context).accentColor,
                                                        size: 15,
                                                      ),
                                                      onPressed: () {
                                                        // todo : delete cell here.
                                                        print("deleting ${employee.name}");
                                                      },
                                                    ))
                                                  ]);
                                                }).toList(),
                                              ));
                                  } else if (snapshot.hasError) {
                                    // Error returned
                                    return Text(snapshot.error.toString());
                                  } else {
                                    return Text("Waiting");
                                  }
                                } else {
                                  return Text("Waiting");
                                }
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        )
      ],
    ));
  }

  Future<List<Personnel>> getListOfEmployees() {
    // todo : query employees only and not all personnel.
    return PersonnelDAL.find();
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
    double imgWidth = 30;

    if (employee.profileImage == null) {
      return Container(
        height: imgWidth,
        width: imgWidth,
        color: Colors.white,
        child: Icon(
          Icons.camera,
          color: Theme.of(context).accentColor,
          size: 45,
        ),
      );
    } else {
      return Container(
        height: 70,
        width: 70,
        child: ClipOval(
          child: Image.memory(
            employee.profileImage,
            fit: BoxFit.cover,
            height: imgWidth,
            width: imgWidth,
          ),
        ),
      );
    }
  }
}
