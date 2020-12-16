import 'package:captain/db/model/product.dart';
import 'package:captain/db/model/special_order.dart';
import 'package:captain/page/product/create_product.dart';
import 'package:captain/widget/c_dialog.dart';
import 'package:captain/widget/c_snackbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class ProductViewPage extends StatefulWidget {
  ProductViewPage();

  @override
  ProductViewPageState createState() => ProductViewPageState();
}

class ProductViewPageState extends State<ProductViewPage> {
  SpecialOrder specialOrder;

  // Text editing controllers
  TextEditingController _otherProductsController = TextEditingController();
  TextEditingController _quantityController = TextEditingController();
  TextEditingController _unitPriceController = TextEditingController();
  // Handles paint validation

  Product currentOnEditProduct = Product(
    type: CreateProductViewState.OTHER_PRODUCTS,
    quantityInCart: 0,
    unitPrice: 0,
  );

  // Status type
  static const String PENDING = "Pending"; // values not translatables
  static const String COMPLETED = "Completed"; // value not translatable
  static const String DELIVERED = "Delivered"; // value not translatable
  List<String> statusTypes = [PENDING, COMPLETED, DELIVERED];
  Map<String, String> statusTypeValues;
  Map<String, String> measurementTypesValues;

  final oCCy = NumberFormat("#,##0.00", "en_US");

  @override
  void dispose() {
    super.dispose();
    _otherProductsController.dispose();
    _quantityController.dispose();
    _unitPriceController.dispose();
  }

  @override
  void initState() {
    super.initState();
    measurementTypesValues = {
      CreateProductViewState.LITER: "liter",
      CreateProductViewState.GRAM: "gram",
      CreateProductViewState.PIECE: "piece",
      CreateProductViewState.PACKAGE: "package"
    };
    statusTypeValues = {
      PENDING: "pending",
      COMPLETED: "completed",
      DELIVERED: "delivered"
    };
  }

  @override
  Widget build(BuildContext context) {
    specialOrder = Provider.of<SpecialOrder>(context);

    print("Specila ordre length : ${specialOrder.products.length}");
    return Container(
        height: 625,
        child: Card(
          child: Column(
            children: <Widget>[
              SizedBox(
                width: double.infinity,
                child: Card(
                  margin: EdgeInsets.all(0),
                  color: Theme.of(context).primaryColor,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(5),
                          topRight: Radius.circular(5))),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                    child: Text(
                      "Other Products",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
              ),
              Container(
                  height: 400,
                  child: SingleChildScrollView(
                    child: buildTable(),
                  )),
            ],
          ),
        ));
  }

  TextStyle dataCellStyle() {
    return TextStyle(fontSize: 12, color: Colors.black54);
  }

  TextStyle dataColumnStyle() {
    return TextStyle(
      fontSize: 13,
      color: Colors.black87,
    );
  }

  Widget noPaintAddedInSpecialOrder() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: 75,
          ),
          Icon(
            Icons.flash_off,
            color: Theme.of(context).accentColor,
          ),
          SizedBox(
            height: 20,
          ),
          Text(
            "No other product in order",
            style: TextStyle(color: Colors.black54, fontSize: 13),
          )
        ],
      ),
    );
  }

  Widget buildTable() {
    return Container(
      height: 400,
      child: specialOrder.products.length == 0
          ? noPaintAddedInSpecialOrder()
          : ListView(
              children: [
                DataTable(
                  columnSpacing: 1,
                  columns: [
                    DataColumn(
                        label: Text(
                      "Name",
                      style: dataColumnStyle(),
                    )),
                    DataColumn(
                        label: Container(
                      child: Text("Qnt", style: dataColumnStyle()),
                    )),
                    DataColumn(
                        label: Container(
                      child: Text("Unit", style: dataColumnStyle()),
                    )),
                    DataColumn(
                        label: Container(
                      child: Text("Maker", style: dataColumnStyle()),
                    )),

                    /// Defines the paint type, auto-cryl/metalic
                    DataColumn(
                      label: Text("Unit Price", style: dataColumnStyle()),
                    ), // Defines volume of the paint in ltr
                    DataColumn(
                        label: Text("SubTotal", style: dataColumnStyle())),
                  ],
                  rows: specialOrder.products.map((Product otherProduct) {
                    return DataRow(cells: [
                      DataCell(SizedBox(
                        child: GestureDetector(
                          child: otherProduct.type ==
                                  CreateProductViewState.PAINT
                              ? Row(
                                  children: [
                                    Icon(
                                      Icons.circle,
                                      size: 10,
                                      color: otherProduct == null ||
                                              otherProduct.colorValue == null
                                          ? Colors.black12
                                          : Color(int.parse(
                                              otherProduct.colorValue)),
                                    ),
                                    SizedBox(
                                      width: 5,
                                    ),
                                    Expanded(
                                      child: Text(
                                        otherProduct.name ?? "-",
                                        style: TextStyle(
                                            fontSize: 12,
                                            color:
                                                Theme.of(context).primaryColor),
//                              overflow: TextOverflow.fade,
                                      ),
                                    )
                                  ],
                                )
                              : Text(
                                  otherProduct.name ?? "-",
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: Theme.of(context).primaryColor),
                                ),
                          onLongPress: () {
                            removePaintProductFromCart(otherProduct);
                          },
                        ),
                        width: 150,
                      )),
                      DataCell(GestureDetector(
                        child: Container(
                          child: Text(otherProduct.quantityInCart.toString(),
                              style: dataCellStyle()),
                        ),
                        onLongPress: () {
                          removePaintProductFromCart(otherProduct);
                        },
                      )),
                      DataCell(GestureDetector(
                        child: Container(
                          child: Text(otherProduct.unitOfMeasurement.toString(),
                              style: dataCellStyle()),
                        ),
                        onLongPress: () {
                          removePaintProductFromCart(otherProduct);
                        },
                      )),
                      DataCell(Text(
                          otherProduct.manufacturer != null &&
                                  otherProduct.manufacturer.isNotEmpty
                              ? otherProduct.manufacturer
                              : "-",
                          style: dataCellStyle())),
                      DataCell(Text("${oCCy.format(otherProduct.unitPrice)} br",
                          style: dataCellStyle())),
                      DataCell(Text(
                          "${oCCy.format(otherProduct.calculateSubTotal())} br",
                          style: dataCellStyle())),
                    ]);
                  }).toList(),
                )
              ],
            ),
    );
  }

  Future<String> removePaintProductFromCart(Product otherProduct) async {
    return await showDialog<String>(
        context: context,
        builder: (context) => CDialog(
              widgetYes: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  Icon(
                    Icons.done,
                    size: 50,
                    color: Theme.of(context).primaryColor,
                  ),
                ],
              ),
              widgetNo: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  Icon(Icons.clear,
                      size: 50, color: Theme.of(context).accentColor),
                ],
              ),
              message: "Are you sure you want to delete \n${otherProduct.name}",
              onYes: () async {
                // Delete customer here.
                Navigator.pop(context);

                setState(() {
                  specialOrder.removeProduct(otherProduct);
                });
                CNotifications.showSnackBar(
                    context,
                    "Successfuly removed ${otherProduct.name}",
                    "success",
                    () {},
                    backgroundColor: Colors.red);

                return null;
              },
              onNo: () {
                Navigator.pop(
                  context,
                );
                return null;
              },
            ));
  }

  void clearInputs() {
    setState(() {
      _otherProductsController.clear();
      _quantityController.clear();
      _unitPriceController.clear();
    });
  }
}
