import 'package:captain/db/dal/product.dart';
import 'package:captain/db/model/product.dart';
import 'package:captain/db/model/special_order.dart';
import 'package:captain/page/product/create_product.dart';
import 'package:captain/widget/c_snackbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:intl/intl.dart';
import 'package:keyboard_visibility/keyboard_visibility.dart';
import 'package:provider/provider.dart';

class CreateSpecialOrderOtherProductPage extends StatefulWidget {
  CreateSpecialOrderOtherProductPage();

  @override
  CreateSpecialOrderOtherProductPageState createState() => CreateSpecialOrderOtherProductPageState();
}

class CreateSpecialOrderOtherProductPageState extends State<CreateSpecialOrderOtherProductPage> {
  final _paintOrderFormKey = GlobalKey<FormState>();

  SpecialOrder specialOrder;

  // Text editing controllers
  TextEditingController _otherProductsController = TextEditingController();
  TextEditingController _quantityController = TextEditingController();
  TextEditingController _unitPriceController = TextEditingController();

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

  final oCCy = NumberFormat("#,##0.00", "en_US");

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

  @override
  Widget build(BuildContext context) {
    specialOrder = Provider.of<SpecialOrder>(context);

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
                      "Other Products",
                      style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
              ),
              Container(
                  height: 400,
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

  bool otherProductsInSpecialOrderAvailable() {
    bool otherProductsAvailable = specialOrder.products.any((element) => element.type == CreateProductViewState.OTHER_PRODUCTS);
    print("Other prducts available : ${otherProductsAvailable.toString()}");
    return otherProductsAvailable;
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
    return Visibility(
        visible: !_keyboardIsVisible,
        child: Container(
          height: 160,
          child: !otherProductsInSpecialOrderAvailable()
              ? noPaintAddedInSpecialOrder()
              : ListView(
                  children: [
                    DataTable(
//                      columnSpacing: 10,
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
                        DataColumn(
                          label: Text("Unit Price", style: dataColumnStyle()),
                        ), // Defines volume of the paint in ltr
                        DataColumn(label: Text("SubTotal", style: dataColumnStyle())),
                      ],
                      rows: specialOrder.products.where((element) => element.type == CreateProductViewState.OTHER_PRODUCTS).toList().map((Product otherProduct) {
                        return DataRow(cells: [
                          DataCell(GestureDetector(
                            child: Text(
                              otherProduct.name ?? "-",
                              style: TextStyle(fontSize: 12, color: Theme.of(context).primaryColor),
                            ),
                            onDoubleTap: () {
                              setState(() {
                                specialOrder.products.remove(otherProduct);
                              });
                              CNotifications.showSnackBar(context, "Successfuly removed ${otherProduct.name}", "success", () {}, backgroundColor: Colors.red);
                            },
                          )),
                          DataCell(Container(
                            width: 20,
                            child: Text(otherProduct.quantityInCart.toString(), style: dataCellStyle()),
                          )),
                          DataCell(Text("${oCCy.format(otherProduct.unitPrice)} br", style: dataCellStyle())),
                          DataCell(Text("${oCCy.format(otherProduct.calculateSubTotal())} br", style: dataCellStyle())),
                        ]);
                      }).toList(),
                    )
                  ],
                ),
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

                /// Unit price controller
                TextFormField(
                  validator: (unitPriceValue) {
                    if (unitPriceValue.isEmpty) {
                      return "Unit price must not be empty";
                    } else if (num.tryParse(unitPriceValue) == null) {
                      return "Unit price is not valid format";
                    } else {
                      return null;
                    }
                  },
                  keyboardType: TextInputType.number,
                  controller: _unitPriceController,
                  onChanged: (unitPriceValue) {
                    currentOnEditProduct.unitPrice = num.parse(unitPriceValue);
                  },
                  onFieldSubmitted: (unitPriceValue) {
                    currentOnEditProduct.unitPrice = num.parse(unitPriceValue);
                  },
                  decoration: InputDecoration(labelText: "Unit price", contentPadding: EdgeInsets.symmetric(vertical: 5), suffix: Text("br")),
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
                            print("Every thing is good");
                            // Every thing seems good.
                            setState(() {
                              _noOtherProductValue = false;
                              currentOnEditProduct.quantityInCart = num.parse(_quantityController.text);

                              specialOrder.addProduct(currentOnEditProduct);
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
      _unitPriceController.clear();
    });
  }
}
