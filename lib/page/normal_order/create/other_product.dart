import 'package:captain/db/dal/product.dart';
import 'package:captain/db/model/normal_order.dart';
import 'package:captain/db/model/product.dart';
import 'package:captain/page/normal_order/main.dart';
import 'package:captain/page/product/create_product.dart';
import 'package:captain/widget/c_dialog.dart';
import 'package:captain/widget/c_snackbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:keyboard_visibility/keyboard_visibility.dart';
import 'package:provider/provider.dart';

class CreateNormalOrderOtherProductPage extends StatefulWidget {
  CreateNormalOrderOtherProductPage();

  @override
  CreateNormalOrderOtherProductPageState createState() => CreateNormalOrderOtherProductPageState();
}

class CreateNormalOrderOtherProductPageState extends State<CreateNormalOrderOtherProductPage> {
  final _paintOrderFormKey = GlobalKey<FormState>();

  NormalOrder normalOrder;

  // Text editing controllers
  TextEditingController _otherProductsController = TextEditingController();
  TextEditingController _quantityController = TextEditingController();

  // Lists required for view to be build
  List<Product> _otherProducts = [];

  // Handles paint validation
  bool _noOtherProductValue = false;

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

  bool _keyboardIsVisible = false;

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _otherProductsController.dispose();
    _quantityController.dispose();
  }

  @override
  void initState() {
    super.initState();
    _assignOtherProductData();
    measurementTypesValues = {CreateProductViewState.LITER: "liter", CreateProductViewState.GRAM: "gram", CreateProductViewState.PIECE: "piece", CreateProductViewState.PACKAGE: "package"};
    statusTypeValues = {PENDING: "pending", COMPLETED: "completed", DELIVERED: "delivered"};

    KeyboardVisibilityNotification().addNewListener(
      onChange: (bool visible) {
        _keyboardIsVisible = visible;
      },
    );
  }

  Future<bool> _assignOtherProductData() async {
    // Assigning paints data
    String wherePaint = "${Product.TYPE} = ?";
    List<String> whereArgsPaint = [CreateProductViewState.OTHER_PRODUCTS]; // Querying only paint type
    _otherProducts = await ProductDAL.find(where: wherePaint, whereArgs: whereArgsPaint);
    setState(() {});
    return true;
  }

  int getInCartCount() {
    return normalOrder.products.where((element) => element.type.toLowerCase() == CreateProductViewState.OTHER_PRODUCTS).length;
  }

  @override
  Widget build(BuildContext context) {
    normalOrder = Provider.of<NormalOrder>(context);

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
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(5), topRight: Radius.circular(5))),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                    child: Text(
                      "Other Products - ${getInCartCount()}",
                      style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
              ),
              Container(
                  height: 375,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        buildTable(),
                        SizedBox(
                          height: 10,
                        ),
                        Row(
                          children: [Expanded(flex: 1, child: Container()), Expanded(flex: 2, child: buildForm())],
                        )
                      ],
                    ),
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

  bool otherProductsInNormalOrderAvailable() {
    bool otherProductsAvailable = normalOrder.products.any((element) => element.type.toLowerCase() == CreateProductViewState.OTHER_PRODUCTS);
    return otherProductsAvailable;
  }

  Widget noPaintAddedInNormalOrder() {
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
    return Visibility(
        visible: !_keyboardIsVisible,
        child: Container(
          height: 160,
          child: !otherProductsInNormalOrderAvailable()
              ? noPaintAddedInNormalOrder()
              : ListView(
                  children: [
                    DataTable(
                      columnSpacing: 10,
                      columns: [
                        DataColumn(
                            label: Text(
                          "Name",
                          style: dataColumnStyle(),
                        )),
                        DataColumn(
                            label: Container(
                          width: 30,
                          child: Text("Qnt", style: dataColumnStyle()),
                        )), // Defines the paint type, auto-cryl/metalic
                        DataColumn(label: Text("Unit Price", style: dataColumnStyle()), numeric: true), // Defines volume of the paint in ltr
                        DataColumn(label: Text("SubTotal", style: dataColumnStyle())),
                        DataColumn(label: Text("Delivered", style: dataColumnStyle())),
                      ],
                      rows: normalOrder.products.where((element) => element.type.toLowerCase() == CreateProductViewState.OTHER_PRODUCTS).toList().map((Product otherProduct) {
                        return DataRow(cells: [
                          DataCell(GestureDetector(
                            child: Text(
                              otherProduct.name ?? "-",
                              style: TextStyle(fontSize: 12, color: Theme.of(context).primaryColor),
                            ),
                            onLongPress: () {
                              removePaintProductFromCart(otherProduct);
                            },
                          )),
                          DataCell(Container(
                            width: 20,
                            child: Text(otherProduct.quantityInCart.toString(), style: dataCellStyle()),
                          )),
                          DataCell(Text(otherProduct.unitPrice.toString(), style: dataCellStyle())),
                          DataCell(Text(otherProduct.calculateSubTotal().toString(), style: dataCellStyle())),
                          DataCell(Switch(
                            value: otherProduct.status == NormalOrderMainPageState.DELIVERED,
                            onChanged: (bool changed) {
                              setState(() {
                                otherProduct.status = changed ? NormalOrderMainPageState.DELIVERED : NormalOrderMainPageState.PENDING;
                              });
                            },
                          )),
                        ]);
                      }).toList(),
                    )
                  ],
                ),
        ));
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
                  Icon(Icons.clear, size: 50, color: Theme.of(context).accentColor),
                ],
              ),
              message: "Are you sure you want to delete \n${otherProduct.name}",
              onYes: () async {
                // Delete customer here.
                Navigator.pop(context);

                setState(() {
                  normalOrder.removeProduct(otherProduct);
                });
                CNotifications.showSnackBar(context, "Successfuly removed ${otherProduct.name}", "success", () {}, backgroundColor: Colors.red);

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

  Widget buildForm() {
    return Container(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, right: 30, left: 30, top: 0),
      child: Form(
          key: _paintOrderFormKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                /// Paint input
                TypeAheadField(
                  textFieldConfiguration: TextFieldConfiguration(
                      controller: _otherProductsController,
                      maxLines: 1,
                      decoration: InputDecoration(
                        errorText: _noOtherProductValue ? "Product is required" : null,
                        hintText: "Select product",
                        labelText: "Product",
                      )),
                  suggestionsCallback: (pattern) async {
                    return _otherProducts.where((Product paint) {
                      return paint.name.toLowerCase().startsWith(pattern.toLowerCase()); // Apples to apples
                    });
                  },
                  itemBuilder: (context, Product suggestedPaint) {
                    return ListTile(
                      dense: true,
                      title: Text(suggestedPaint.name),
                    );
                  },
                  onSuggestionSelected: (Product selectedPaint) {
                    setState(() {
                      _otherProductsController.text = selectedPaint.name;
                      currentOnEditProduct = selectedPaint;
                    });
                  },
                  noItemsFoundBuilder: (BuildContext context) {
                    return Container(
                      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 5),
                      child: Text(
                        "No produts found",
                      ),
                    );
                  },
                ),

                SizedBox(
                  height: 6,
                ),

                /// Volume controller
                TextFormField(
                  validator: (volumeValue) {
                    if (volumeValue.isEmpty) {
                      return "Quantity must not be empty";
                    } else if (num.tryParse(volumeValue) == null) {
                      return "Quantity is not valid format";
                    } else {
                      return null;
                    }
                  },
                  keyboardType: TextInputType.number,
                  controller: _quantityController,
                  onChanged: (volumeValue) {
                    currentOnEditProduct.quantityInCart = num.parse(volumeValue);
                  },
                  onFieldSubmitted: (volumeValue) {
                    currentOnEditProduct.quantityInCart = num.parse(volumeValue);
                  },
                  decoration: InputDecoration(labelText: "Quantity", contentPadding: EdgeInsets.symmetric(vertical: 5), suffix: Text(currentOnEditProduct.unitOfMeasurement ?? "liter")),
                ),

                SizedBox(
                  height: 10,
                ),
                Align(
                  alignment: Alignment.topRight,
                  child: OutlineButton(
                      onPressed: () {
                        if (_paintOrderFormKey.currentState.validate()) {
                          if (_otherProductsController.text.isEmpty) {
                            setState(() {
                              _noOtherProductValue = true;
                            });
                          } else {
                            // Every thing seems good.
                            setState(() {
                              _noOtherProductValue = false;
                              currentOnEditProduct.quantityInCart = num.parse(_quantityController.text);

                              normalOrder.addProduct(currentOnEditProduct);
                              CNotifications.showSnackBar(context, "Successfuly added ${currentOnEditProduct.name}", "success", () {}, backgroundColor: Colors.green);

                              currentOnEditProduct = Product(
                                type: CreateProductViewState.OTHER_PRODUCTS,
                                quantityInCart: 0,
                                unitPrice: 0,
                              );
                              clearInputs();
                            });
                          }
                        }
                      },
                      child: Text(
                        "add",
                        style: TextStyle(color: Theme.of(context).accentColor, fontSize: 12),
                      )),
                ),

                // Define inputs here.
              ],
            ),
          )),
    );
  }

  void clearInputs() {
    setState(() {
      _otherProductsController.clear();
      _quantityController.clear();
    });
  }
}
