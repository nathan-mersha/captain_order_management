import 'dart:io';

import 'package:captain/db/dal/personnel.dart';
import 'package:captain/db/model/normal_order.dart';
import 'package:captain/db/model/personnel.dart';
import 'package:captain/widget/c_snackbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class NormalOrderCustomerInformationPage extends StatefulWidget {
  final FocusNode focus;

  NormalOrderCustomerInformationPage({this.focus});

  @override
  _NormalOrderCustomerInformationPageState createState() => _NormalOrderCustomerInformationPageState();
}

class _NormalOrderCustomerInformationPageState extends State<NormalOrderCustomerInformationPage> {
  NormalOrder normalOrder;
  List<Personnel> _customers = [];
  TextEditingController _customerController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _assignPersonnelData();
  }

  Future<bool> _assignPersonnelData() async {
    // Assigning employees data.
    String wherePersonnel = "${Personnel.TYPE} = ?";
    List<String> whereArgsCustomers = [Personnel.CUSTOMER]; // Querying only customers
    _customers = await PersonnelDAL.find(where: wherePersonnel, whereArgs: whereArgsCustomers); // Assign customers
    setState(() {});
    return true;
  }

  @override
  void dispose() {
    super.dispose();
    _customerController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    normalOrder = Provider.of<NormalOrder>(context);

    if (normalOrder.customer != null && normalOrder.customer.name != null && normalOrder.customer.name.isNotEmpty) {
      _customerController.text = normalOrder.customer.name.length > 17 ? normalOrder.customer.name.substring(0, 17) : normalOrder.customer.name;
    }
    return Card(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Customer Information",
              style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w800),
            ),
            SizedBox(
              height: 5,
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 200,
                    height: 45,
                    child: TypeAheadField(
                      textFieldConfiguration: TextFieldConfiguration(
                          focusNode: widget.focus,
                          controller: _customerController,
                          maxLines: 1,
                          decoration: InputDecoration(
                              hintText: "customer name",
                              icon: normalOrder == null || normalOrder.customer == null || normalOrder.customer.profileImage == null
                                  ? Icon(
                                      Icons.person_pin,
                                      color: Colors.black12,
                                      size: 30,
                                    )
                                  : ClipOval(
                                      child: Image.file(
                                      File(normalOrder.customer.profileImage),
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
                          normalOrder.customer = selectedCustomer;
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
                  ),
                  SizedBox(height: 10),
                  GestureDetector(
                    onTap: () {
                      if (normalOrder.customer != null && normalOrder.customer.phoneNumber != null) {
                        String launchURL = 'tel:${normalOrder.customer.phoneNumber}';
                        _makePhoneCall(launchURL);
                      } else {
                        CNotifications.showSnackBar(context, "No phone provided", "failed", () {}, backgroundColor: Colors.red);
                      }
                    },
                    child: Text(
                      getPhoneNumber(),
                      style: TextStyle(color: Theme.of(context).primaryColor),
                    ),
                  ),
                  Text(
                    getEmail(),
                    style: TextStyle(color: Colors.black54),
                  ),
                  Text(getAddress(), style: TextStyle(color: Colors.black54))
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Future<void> _makePhoneCall(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    }
  }

  String getPhoneNumber() {
    return normalOrder.customer == null || normalOrder.customer.phoneNumber == null ? "no phone number" : normalOrder.customer.phoneNumber;
  }

  String getEmail() {
    return normalOrder.customer == null || normalOrder.customer.email == null ? "no email" : normalOrder.customer.email;
  }

  String getAddress() {
    return normalOrder.customer == null || normalOrder.customer.address == null ? "no address" : normalOrder.customer.address;
  }
}
