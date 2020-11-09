import 'package:captain/db/model/normal_order.dart';
import 'package:captain/db/model/product.dart';
import 'package:captain/page/product/create_product.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CreateNormalOrderPage extends StatefulWidget {
  final NormalOrder normalOrder;

  CreateNormalOrderPage({this.normalOrder});

  @override
  CreateNormalOrderPageState createState() => CreateNormalOrderPageState();
}

class CreateNormalOrderPageState extends State<CreateNormalOrderPage> {
  final _paintOrderFormKey = GlobalKey<FormState>();

  NormalOrder normalOrder;

  // Paint type
  List<String> paintTypes = [CreateProductViewState.METALIC, CreateProductViewState.AUTO_CRYL];
  Map<String, String> paintTypesValues;

  // Status type
  static const String PENDING = "Pending"; // values not translatables
  static const String COMPLETED = "Completed"; // value not translatable
  static const String DELIVERED = "Delivered"; // value not translatable
  List<String> statusTypes = [PENDING, COMPLETED, DELIVERED];
  Map<String, String> statusTypeValues;

  bool _doingCRUD = false;

  @override
  void initState() {
    super.initState();
    normalOrder = widget.normalOrder ?? NormalOrder(paintOrders: [], otherProducts: []);
    paintTypesValues = {CreateProductViewState.METALIC: "Metalic", CreateProductViewState.AUTO_CRYL: "Auto-Cryl"};
    statusTypeValues = {PENDING: "pending", COMPLETED: "completed", DELIVERED: "delivered"};
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 670,
      child: Row(
        children: [
          // Create paint order
          Expanded(child: buildCreatePaintOrder()),

          // Other product & information section
          Expanded(
              child: Container(
            child: Column(
              children: [
                // Other product
                Expanded(flex: 3, child: buildOtherProductOrder()),

                // Customer and Payment information page
                Expanded(
                    flex: 1,
                    child: Container(
                      child: Row(
                        children: [
                          // Customer information
                          Expanded(child: buildCustomerInformation()),
                          // Payment information
                          Expanded(child: buildPaymentInformation())
                        ],
                      ),
                    ))
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget buildPaintOrderCart() {
    return Container(
      height: 200,
      color: Colors.red,
      child: DataTable(

        columns: [
          DataColumn(label: Text("Color")),
          DataColumn(label: Text("Type")), // Defines the paint type, auto-cryl/metalic
          DataColumn(label: Text("Volume"),numeric: true), // Defines volume of the paint in ltr
          DataColumn(label: Text("SubTotal")),
          DataColumn(label: Text("")),
        ],
        rows: normalOrder.paintOrders.map((Product paintProduct){

          return DataRow(cells: [

            DataCell(Text(paintProduct.name)),
            DataCell(Text(paintProduct.type)),
            DataCell(Text(paintProduct.quantityInCart.toString())),
            DataCell(Text(paintProduct.subTotal.toString())),
            DataCell(IconButton(icon: Icon(Icons.exposure_minus_1),)),
          ]);
        }).toList(),
      ),
    );
  }

  Widget buildPaintOrderForm() {

    return Container();
  }
  Widget buildCreatePaintOrder() {
    return Card(child: Column(
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
                "Paint Order",
                style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w800),
              ),
            ),
          ),
        ),
        Container(
            height: 560,
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, right: 20, left: 20, top: 15),
            child: Form(
              key: _paintOrderFormKey,
              child: SingleChildScrollView(
                child: Column(
                  children: [buildPaintOrderCart(), buildPaintOrderForm()],
                ),
              ),
            )),
        Container(
          child: normalOrder.id == null
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
            onPressed: () {
              // dont need to validate form as the corresponding product type form already do.

              // todo : create order
              // todo : clear all fields
              // todo : navigate to table page
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
                  onPressed: () {
                    // todo : update order
                    // todo : clear fields
                    // todo : navigate to table page
                  }),
              OutlineButton(
                child: Text(
                  "Cancel",
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Theme.of(context).accentColor),
                ),
                onPressed: () {
                  // todo : clear both form fields
                },
              ),
            ],
          ),
        ),
      ],
    ),);
  }

  Widget buildOtherProductOrder() {
    return Container(
      color: Colors.green,
    );
  }

  Widget buildCustomerInformation() {
    return Container(
      color: Colors.blue,
    );
  }

  Widget buildPaymentInformation() {
    return Container(color: Colors.purple);
  }
}
