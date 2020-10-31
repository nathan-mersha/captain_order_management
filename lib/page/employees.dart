import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'package:captain/db/dal/personnel.dart';
import 'package:captain/db/model/personnel.dart';
import 'package:captain/db/model/statistics.dart';
import 'package:captain/rsr/kapci/regions.dart';
import 'package:captain/widget/c_dialog.dart';
import 'package:captain/widget/c_snackbar.dart';
import 'package:captain/widget/statistics.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:contacts_service/contacts_service.dart';
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

  // Text editing controllers
  TextEditingController _nameController = TextEditingController();
  TextEditingController _phoneNumberController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _addressDetailController = TextEditingController();
  TextEditingController _noteController = TextEditingController();

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

        AbsorbPointer(
          absorbing: _doingCRUD,
          child: Container(
            margin: EdgeInsets.only(top: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  flex: 1,
                  child: Card(
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
                                        decoration: InputDecoration(hintText: 'Address'),
                                        textSubmitted: (String addressValue) {
                                          employee.address = addressValue;
                                        },
                                      ),
                                      TextFormField(
                                        onChanged: (addressDetailValue) {
                                          employee.addressDetail = addressDetailValue;
                                        },
                                        onFieldSubmitted: (addressDetailValue) {
                                          employee.addressDetail = addressDetailValue;
                                        },
                                        controller: _addressDetailController,
                                        decoration: InputDecoration(labelText: "Address Detail", contentPadding: EdgeInsets.symmetric(vertical: 5)),
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

                            child: OutlineButton(

//                              color: Theme.of(context).primaryColorLight,
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
                                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800,color: Theme.of(context).accentColor),
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
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 5,),
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
                            height: 460,
                            child: FutureBuilder(
                              future: getListOfEmployees(),
                              builder: (BuildContext context, AsyncSnapshot<List<Personnel>> snapshot) {
                                if (snapshot.connectionState == ConnectionState.waiting || snapshot.connectionState == ConnectionState.none) {
                                  return buildTableLoader();
                                } else if (snapshot.connectionState == ConnectionState.done) {
                                  if (snapshot.hasData) {
                                    employees = snapshot.data;
                                    return Container(
                                        child: employees == null
                                            ? Text("No employees found")
                                            :
                                        SingleChildScrollView(scrollDirection: Axis.vertical,child: SingleChildScrollView(scrollDirection: Axis.horizontal,child: DataTable(
                                          headingTextStyle: TextStyle(fontWeight: FontWeight.w800, color: Colors.black87, fontSize: 12),
                                          dataTextStyle: TextStyle(color: Colors.black54, fontSize: 11),
                                          columns: [
                                            DataColumn(label: Text("Img")),
                                            DataColumn(label: Text("Name"), tooltip: "Name"),
                                            DataColumn(label: Text("Phone number"), tooltip: "Phone numbger"),
                                            DataColumn(label: Text("Address"), tooltip: "Address"),
                                            DataColumn(label: Text("Date"), tooltip: "Date"),
                                            DataColumn(label: Text("")),
                                          ],
                                          rows: employees.map((Personnel employee) {
                                            return DataRow(cells: [
                                              DataCell(employee.profileImage == null
                                                  ? Icon(
                                                Icons.person,
                                                color: Colors.black12,
                                              )
                                                  : ClipOval(
                                                child: Image.memory(
                                                  employee.profileImage,
                                                  fit: BoxFit.cover,
                                                  height: 30,
                                                  width: 30,
                                                ),
                                              )),
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
                                                },
                                              ))
                                            ]);
                                          }).toList(),
                                        ),),));
                                  } else if (snapshot.hasError) {
                                    // Error returned
                                    return Text(snapshot.error.toString());
                                  } else {
                                    return Text("Waiting 2222");
                                  }
                                } else {
                                  return Text("Waiting 3333");
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        )
      ],
    ));
  }

  Widget buildTableLoader({String message = "loading", Widget icon = const CircularProgressIndicator(strokeWidth: 2,)}) {
    return Container(child: Column(

      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SingleChildScrollView(scrollDirection: Axis.vertical,child: SingleChildScrollView(scrollDirection: Axis.horizontal,child: DataTable(
          headingTextStyle: TextStyle(fontWeight: FontWeight.w800, color: Colors.black87, fontSize: 12),
          dataTextStyle: TextStyle(color: Colors.black54, fontSize: 11),
          columns: [
            DataColumn(label: Text("Img")),
            DataColumn(label: Text("Name"), tooltip: "Name"),
            DataColumn(label: Text("Phone number"), tooltip: "Phone numbger"),
            DataColumn(label: Text("Address"), tooltip: "Address"),
            DataColumn(label: Text("Date"), tooltip: "Date"),
            DataColumn(label: Text("")),
          ],
          rows: [],
        ),),),

        Expanded(child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

          Center(child: icon,),
          Text(message,)
        ],))


      ],
    ),);
  }

  void clearInputs() {
    _nameController.clear();
    _phoneNumberController.clear();
    _emailController.clear();
    _addressDetailController.clear();
    _noteController.clear();
  }

  Future<List<Personnel>> getListOfEmployees() {
    // todo : query employees only and not all personnel.
    String where = "${Personnel.TYPE} = ?";
    List<String> whereArgs = [Personnel.EMPLOYEE]; // Querying only employees
    return PersonnelDAL.find(where: where, whereArgs: whereArgs);
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
}
