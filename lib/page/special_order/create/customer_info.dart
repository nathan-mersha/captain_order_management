import 'dart:io';

import 'package:captain/db/dal/personnel.dart';
import 'package:captain/db/model/personnel.dart';
import 'package:captain/db/model/special_order.dart';
import 'package:captain/widget/c_snackbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class SpecialOrderCustomerInformationPage extends StatefulWidget {

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
    if(specialOrder.customer != null && specialOrder.customer.name != null && specialOrder.customer.name.isNotEmpty){
      _customerController.text = specialOrder.customer.name.length > 17 ? specialOrder.customer.name.substring(0, 17) : specialOrder.customer.name;
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 200,
              height: 30,
              child: Container(),
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
        )
      ],
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
