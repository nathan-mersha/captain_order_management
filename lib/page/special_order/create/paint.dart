import 'package:captain/db/dal/product.dart';
import 'package:captain/db/dal/special_order.dart';
import 'package:captain/db/model/product.dart';
import 'package:captain/db/model/special_order.dart';
import 'package:captain/page/product/create_product.dart';
import 'package:captain/page/special_order/main.dart';
import 'package:captain/rsr/export/pdf_exporter.dart';
import 'package:captain/widget/c_snackbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:intl/intl.dart';
import 'package:keyboard_visibility/keyboard_visibility.dart';
import 'package:provider/provider.dart';

class CreateSpecialOrderPaintPage extends StatefulWidget {
  final Function navigateTo;

  CreateSpecialOrderPaintPage({this.navigateTo});

  @override
  CreateSpecialOrderPaintPageState createState() => CreateSpecialOrderPaintPageState();
}

class CreateSpecialOrderPaintPageState extends State<CreateSpecialOrderPaintPage> {
  final _paintOrderFormKey = GlobalKey<FormState>();

  SpecialOrder specialOrder;

  // Text editing controllers
  TextEditingController _paintController = TextEditingController();
  TextEditingController _volumeController = TextEditingController();
  TextEditingController _unitPriceController = TextEditingController();

  // Lists required for view to be build
  List<Product> _paints = [];

  // Handles paint validation
  bool _noPaintValue = false;

  Product _currentOnEditPaint = Product(
    type: CreateProductViewState.PAINT,
    unitOfMeasurement: CreateProductViewState.LITER,
    status: SpecialOrderMainPageState.PENDING,
    quantityInCart: 0,
    unitPrice: 0,
  );

  // Status type

  List<String> statusTypes = [SpecialOrderMainPageState.PENDING, SpecialOrderMainPageState.COMPLETED, SpecialOrderMainPageState.DELIVERED];
  Map<String, String> statusTypeValues;
  Map<String, String> measurementTypesValues;

  bool _doingCRUD = false;
  bool _keyboardIsVisible = false;

  final oCCy = NumberFormat("#,##0.00", "en_US");

  @override
  void initState() {
    super.initState();
    _assignPaintData();
    measurementTypesValues = {CreateProductViewState.LITER: "liter", CreateProductViewState.GRAM: "gram", CreateProductViewState.PIECE: "piece", CreateProductViewState.PACKAGE: "package"};
    statusTypeValues = {SpecialOrderMainPageState.PENDING: "pending", SpecialOrderMainPageState.COMPLETED: "completed", SpecialOrderMainPageState.DELIVERED: "delivered"};

    KeyboardVisibilityNotification().addNewListener(
      onChange: (bool visible) {
        _keyboardIsVisible = visible;
      },
    );
  }

  Future<bool> _assignPaintData() async {
    // Assigning paints data
    String wherePaint = "${Product.TYPE} = ?";
    List<String> whereArgsPaint = [CreateProductViewState.PAINT]; // Querying only paint type
    _paints = await ProductDAL.find(where: wherePaint, whereArgs: whereArgsPaint);
    setState(() {});
    return true;
  }

  @override
  Widget build(BuildContext context) {
    specialOrder = Provider.of<SpecialOrder>(context);

    return WillPopScope(
        child: Container(
            height: 645,
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
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              "Paint Order",
                              style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w800),
                            ),
                            SizedBox(
                              height: 25,
                              child: IconButton(
                                padding: EdgeInsets.all(0),
                                icon: Icon(
                                  Icons.picture_as_pdf,
                                  color: Colors.white,
                                ),
                                onPressed: () {
                                  if (specialOrder.customer != null) {
                                    Exporter exporter = Exporter();
                                    exporter.toPdf(
                                        customer: specialOrder.customer,
                                        products: specialOrder.products,
                                        totalAmount: specialOrder.totalAmount,
                                        advanceAmount: 0,
                                        remainingAmount: 0,
                                        lastModified: specialOrder.lastModified,
                                        context: context);
                                  } else {
                                    CNotifications.showSnackBar(context, "No customer has been selected", "ok", () {}, backgroundColor: Colors.red);
                                  }
                                },
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                  Container(
                      height: 592,
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            buildTable(),
                            SizedBox(
                              height: 15,
                            ),
                            Row(
                              children: [Expanded(child: Container()), Expanded(flex: 2, child: buildForm())],
                            ),
                            buildCreateOrder()
                          ],
                        ),
                      )),
                ],
              ),
            )),
        onWillPop: () {
          widget.navigateTo(SpecialOrderMainPageState.PAGE_VIEW_SPECIAL_ORDER);
          return Future.value(false);
        });
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

  bool paintInSpecialOrderAvailable() {
    return specialOrder.products.any((element) => element.type == CreateProductViewState.PAINT);
  }

  Widget buildCreateOrder() {
    return Container(
      width: 200,
      child: specialOrder.id == null
          ? RaisedButton(
              color: Theme.of(context).primaryColor,
              child: _doingCRUD == true
                  ? Container(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 1,
                      ),
                    )
                  : Text(
                      "Create Order",
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
              onPressed: () {
                // don't need to validate form as the corresponding product type form already do.
                if (specialOrder.products.length == 0) {
                  // No products added
                  CNotifications.showSnackBar(context, "No products have been added in cart", "ok", () {}, backgroundColor: Colors.red);
                } else if (specialOrder.customer == null) {
                  // No customer added
                  CNotifications.showSnackBar(context, "No customer has been selected", "ok", () {}, backgroundColor: Colors.red);
                } else {
                  // Everything seems ok
                  SpecialOrderDAL.create(specialOrder).then((value) {
                    widget.navigateTo(SpecialOrderMainPageState.PAGE_VIEW_SPECIAL_ORDER);
                  });
                }
              },
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                RaisedButton(
                    child: Text(
                      "Update",
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800),
                    ),
                    onPressed: () async {
                      if (specialOrder.products.length == 0) {
                        // No products added
                        CNotifications.showSnackBar(context, "No products have been added in cart", "ok", () {}, backgroundColor: Colors.red);
                      } else if (specialOrder.customer == null) {
                        // No customer added
                        CNotifications.showSnackBar(context, "No customer has been selected", "ok", () {}, backgroundColor: Colors.red);
                      } else {
                        setState(() {
                          _doingCRUD = true;
                        });

                        await updateSpecialOrder(context);
                        widget.navigateTo(SpecialOrderMainPageState.PAGE_VIEW_SPECIAL_ORDER);
                      }
                    }),
                OutlineButton(
                  child: Text(
                    "Cancel",
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Theme.of(context).accentColor),
                  ),
                  onPressed: () {
                    widget.navigateTo(SpecialOrderMainPageState.PAGE_VIEW_SPECIAL_ORDER);
                  },
                ),
              ],
            ),
    );
  }

  Future updateSpecialOrder(BuildContext context) async {
    /// Query and update user
    String where = "${SpecialOrder.ID} = ?";
    List<String> whereArgs = [specialOrder.id];
    await SpecialOrderDAL.update(
      where: where,
      whereArgs: whereArgs,
      specialOrder: specialOrder,
    );

    /// Updating from fire store
    specialOrder.customer.profileImage = null;
    dynamic specialOrderMap = SpecialOrder.toMap(specialOrder);

    // Updating to fire store if fire store generated id is present in doc.
    if (specialOrder.idFS != null) {
      Firestore.instance.collection(SpecialOrder.COLLECTION_NAME).document(specialOrder.idFS).updateData(specialOrderMap);
    }

    // Showing notification
    CNotifications.showSnackBar(context, "Successfuly updated : ${specialOrder.customer.name}", "success", () {}, backgroundColor: Theme.of(context).accentColor);
  }

  Widget noPaintAddedInSpecialOrder() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.invert_colors_off,
            color: Theme.of(context).accentColor,
          ),
          SizedBox(
            height: 20,
          ),
          Text(
            "No paint product in order",
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
          height: 200,
          child: !paintInSpecialOrderAvailable()
              ? noPaintAddedInSpecialOrder()
              : ListView(
                  children: [
                    DataTable(
                      columnSpacing: 30,
                      columns: [
                        DataColumn(
                            label: Text(
                          "Color",
                          style: dataColumnStyle(),
                        )),
                        DataColumn(label: Text("Type", style: dataColumnStyle())), // Defines the paint type, auto-cryl/metalic
                        DataColumn(
                          label: Text("Ltr", style: dataColumnStyle()),
                        ), // Defines volume of the paint in ltr
                        DataColumn(label: Text("Unit Price", style: dataColumnStyle())),
                        DataColumn(label: Text("SubTotal", style: dataColumnStyle())),
                      ],
                      rows: specialOrder.products.where((element) => element.type == CreateProductViewState.PAINT).toList().map((Product paintProduct) {
                        return DataRow(cells: [
                          DataCell(GestureDetector(
                            child: Row(
                              children: [
                                Icon(
                                  Icons.circle,
                                  size: 10,
                                  color: paintProduct == null || paintProduct.colorValue == null ? Colors.black12 : Color(int.parse(paintProduct.colorValue)),
                                ),
                                SizedBox(
                                  width: 5,
                                ),
                                Text(
                                  paintProduct.name ?? "-",
                                  style: TextStyle(fontSize: 12, color: Theme.of(context).primaryColor),
                                )
                              ],
                            ),
                            onDoubleTap: () {
                              setState(() {
                                specialOrder.products.remove(paintProduct);
                              });
                              CNotifications.showSnackBar(context, "Successfuly removed ${paintProduct.name}", "success", () {}, backgroundColor: Colors.red);
                            },
                          )),
                          DataCell(Text(paintProduct.paintType ?? "-", style: dataCellStyle())),
                          DataCell(Text(paintProduct.quantityInCart.toString(), style: dataCellStyle())),
                          DataCell(Text("${oCCy.format(paintProduct.unitPrice)} br", style: dataCellStyle())),
                          DataCell(Text("${oCCy.format(paintProduct.calculateSubTotal())} br", style: dataCellStyle())),
                        ]);
                      }).toList(),
                    )
                  ],
                ),
        ));
  }

  Color getStatusColor(String status) {
    if (status == SpecialOrderMainPageState.PENDING) {
      return Colors.orange;
    } else if (status == SpecialOrderMainPageState.COMPLETED) {
      return Colors.green;
    } else if (status == SpecialOrderMainPageState.DELIVERED) {
      return Colors.blue;
    } else {
      return Colors.black54;
    }
  }

  Widget buildForm() {
    return Container(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, right: 30, left: 30, top: 0),
      child: Form(
          key: _paintOrderFormKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(
                  height: 5,
                ),

                /// Paint input
                TypeAheadField(
                  textFieldConfiguration: TextFieldConfiguration(
                      controller: _paintController,
                      maxLines: 1,
                      decoration: InputDecoration(
                          errorText: _noPaintValue ? "Paint value is required" : null,
                          hintText: "Select paint",
                          labelText: "Paint",
                          icon: Icon(
                            Icons.circle,
                            size: 30,
                            color: specialOrder == null || _currentOnEditPaint == null || _currentOnEditPaint.colorValue == null ? Colors.black12 : Color(int.parse(_currentOnEditPaint.colorValue)),
                          ))),
                  suggestionsCallback: (pattern) async {
                    return _paints.where((Product paint) {
                      return paint.name.toLowerCase().startsWith(pattern.toLowerCase()); // Apples to apples
                    });
                  },
                  itemBuilder: (context, Product suggestedPaint) {
                    return ListTile(
                      dense: true,
                      leading: Icon(Icons.circle, size: 30, color: Color(int.parse(suggestedPaint.colorValue))),
                      title: Text(suggestedPaint.name),
                      subtitle: Text(suggestedPaint.colorValue),
                    );
                  },
                  onSuggestionSelected: (Product selectedPaint) {
                    setState(() {
                      _paintController.text = selectedPaint.name;
                      _currentOnEditPaint = selectedPaint;
                    });
                  },
                  noItemsFoundBuilder: (BuildContext context) {
                    return Container(
                      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 5),
                      child: Text(
                        "No paint found",
                      ),
                    );
                  },
                ),

                SizedBox(
                  height: 10,
                ),

                /// Volume controller
                TextFormField(
                  validator: (volumeValue) {
                    if (volumeValue.isEmpty) {
                      return "Volume must not be empty";
                    } else if (num.tryParse(volumeValue) == null) {
                      return "Volume is not valid format";
                    } else {
                      return null;
                    }
                  },
                  keyboardType: TextInputType.number,
                  controller: _volumeController,
                  onChanged: (volumeValue) {
                    _currentOnEditPaint.quantityInCart = num.parse(volumeValue);
                  },
                  onFieldSubmitted: (volumeValue) {
                    _currentOnEditPaint.quantityInCart = num.parse(volumeValue);
                  },
                  decoration: InputDecoration(labelText: "Volume", contentPadding: EdgeInsets.symmetric(vertical: 5), suffix: Text("liter")),
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
                    _currentOnEditPaint.unitPrice = num.parse(unitPriceValue);
                  },
                  onFieldSubmitted: (unitPriceValue) {
                    _currentOnEditPaint.unitPrice = num.parse(unitPriceValue);
                  },
                  decoration: InputDecoration(labelText: "Unit price", contentPadding: EdgeInsets.symmetric(vertical: 5), suffix: Text("br")),
                ),

                SizedBox(
                  height: 8,
                ),
                Align(
                  alignment: Alignment.topRight,
                  child: OutlineButton(
                      onPressed: () {
                        if (_paintOrderFormKey.currentState.validate()) {
                          if (_paintController.text.isEmpty) {
                            setState(() {
                              _noPaintValue = true;
                            });
                          } else {
                            // Every thing seems good.
                            setState(() {
                              _noPaintValue = false;
                              _currentOnEditPaint.quantityInCart = num.parse(_volumeController.text);
                              specialOrder.addProduct(_currentOnEditPaint);
                              _currentOnEditPaint.status = SpecialOrderMainPageState.PENDING;
                              _currentOnEditPaint = Product(
                                type: CreateProductViewState.PAINT,
                                unitOfMeasurement: CreateProductViewState.LITER,
                                status: SpecialOrderMainPageState.PENDING,
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

                SizedBox(
                  height: 70,
                ),
              ],
            ),
          )),
    );
  }

  void clearInputs() {
    setState(() {
      _paintController.clear();
      _volumeController.clear();
      _unitPriceController.clear();
    });
  }
}
