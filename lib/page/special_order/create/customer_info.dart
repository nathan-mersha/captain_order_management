import 'package:captain/db/dal/personnel.dart';
import 'package:captain/db/model/normal_order.dart';
import 'package:captain/db/model/personnel.dart';
import 'package:captain/db/model/special_order.dart';
import 'package:captain/widget/c_snackbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class SpecialOrderCustomerInformationPage extends StatefulWidget {
  final FocusNode focus;

  SpecialOrderCustomerInformationPage({this.focus});

  @override
  _SpecialOrderCustomerInformationPageState createState() => _SpecialOrderCustomerInformationPageState();
}

class _SpecialOrderCustomerInformationPageState extends State<SpecialOrderCustomerInformationPage> {
  SpecialOrder specialOrder;
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
  Widget build(BuildContext context) {
    specialOrder = Provider.of<SpecialOrder>(context);

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
              height: 18,
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 200,
                    height: 30,
                    child: TypeAheadField(
                      textFieldConfiguration: TextFieldConfiguration(
                          focusNode: widget.focus,
                          controller: _customerController,
                          maxLines: 1,
                          decoration: InputDecoration(
                              hintText: "customer name",
                              icon: specialOrder == null || specialOrder.customer == null || specialOrder.customer.profileImage == null
                                  ? Icon(
                                      Icons.person_pin,
                                      color: Colors.black12,
                                      size: 30,
                                    )
                                  : ClipOval(
                                      child: Image.memory(
                                        specialOrder.customer.profileImage,
                                        fit: BoxFit.cover,
                                        height: 30,
                                        width: 30,
                                      ),
                                    ))),
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
                                  child: Image.memory(
                                    suggestedCustomer.profileImage,
                                    fit: BoxFit.cover,
                                    height: 30,
                                    width: 30,
                                  ),
                                ),
                          title: Text(suggestedCustomer.name),
                          subtitle: Text(suggestedCustomer.phoneNumber),
                        );
                      },
                      onSuggestionSelected: (Personnel selectedCustomer) {
                        setState(() {
                          _customerController.text = selectedCustomer.name;
                          specialOrder.customer = selectedCustomer;
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
                      if (specialOrder.customer != null && specialOrder.customer.phoneNumber != null) {
                        String launchURL = 'tel:${specialOrder.customer.phoneNumber}';
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
    return specialOrder.customer == null || specialOrder.customer.phoneNumber == null ? "no phone number" : specialOrder.customer.phoneNumber;
  }

  String getEmail() {
    return specialOrder.customer == null || specialOrder.customer.email == null ? "no email" : specialOrder.customer.email;
  }

  String getAddress() {
    return specialOrder.customer == null || specialOrder.customer.address == null ? "no address" : specialOrder.customer.address;
  }
}
