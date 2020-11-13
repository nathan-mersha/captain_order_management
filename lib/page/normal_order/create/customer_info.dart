import 'package:captain/db/dal/personnel.dart';
import 'package:captain/db/model/normal_order.dart';
import 'package:captain/db/model/personnel.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:provider/provider.dart';

class NormalOrderCustomerInformationPage extends StatefulWidget {
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
  Widget build(BuildContext context) {
    normalOrder = Provider.of<NormalOrder>(context);

    return Card(child: Container(
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      child: Row(children: [

      // Column
      Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

        SizedBox(
          width: 200,
          height: 30,
          child: TypeAheadField(
          textFieldConfiguration: TextFieldConfiguration(
              controller: _customerController,
              maxLines: 1,
              decoration: InputDecoration(
                  hintText: "Select customer",
                  labelText: "Customer",
                  icon: normalOrder == null || normalOrder.customer == null || normalOrder.customer.profileImage == null
                      ? Icon(
                    Icons.person_pin,
                    color: Colors.black12,
                    size: 30,
                  )
                      : ClipOval(
                    child: Image.memory(
                      normalOrder.customer.profileImage,
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
        ),),

          GestureDetector(onTap: (){
            // todo : call user here
          },child: Text("phone number", style: TextStyle(color: Theme.of(context).primaryColor),),),
        Text("user email"),
        Text("user address")

      ],)
    ],),),);
  }
}
