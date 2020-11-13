import 'package:captain/db/dal/product.dart';
import 'package:captain/db/model/normal_order.dart';
import 'package:captain/db/model/product.dart';
import 'package:captain/page/product/create_product.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:keyboard_visibility/keyboard_visibility.dart';
import 'package:provider/provider.dart';

class CreateNormalOrderPaintPage extends StatefulWidget {
  CreateNormalOrderPaintPage();

  @override
  CreateNormalOrderPaintPageState createState() => CreateNormalOrderPaintPageState();
}

class CreateNormalOrderPaintPageState extends State<CreateNormalOrderPaintPage> {
  final _paintOrderFormKey = GlobalKey<FormState>();

  NormalOrder normalOrder;

  // Text editing controllers
  TextEditingController _paintController = TextEditingController();
  TextEditingController _volumeController = TextEditingController();

  // Lists required for view to be build
  List<Product> _paints = [];

  // Handles paint validation
  bool _noPaintValue = false;

  Product _currentOnEditPaint = Product(
    type: CreateProductViewState.PAINT,
    unitOfMeasurement: CreateProductViewState.LITER,
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

  bool _doingCRUD = false;
  bool _keyboardIsVisible = false;

  @override
  void initState() {
    super.initState();
    _assignPaintData();
    measurementTypesValues = {CreateProductViewState.LITER: "liter", CreateProductViewState.GRAM: "gram", CreateProductViewState.PIECE: "piece", CreateProductViewState.PACKAGE: "package"};
    statusTypeValues = {PENDING: "pending", COMPLETED: "completed", DELIVERED: "delivered"};

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
    normalOrder = Provider.of<NormalOrder>(context);

    return Container(
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
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                    child: Text(
                      "Paint Order",
                      style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w800),
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
                          height: 30,
                        ),
                        buildForm()
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

  bool paintInNormalOrderAvailable() {
    return normalOrder.products.any((element) => element.type == CreateProductViewState.PAINT);
  }

  Widget noPaintAddedInNormalOrder() {
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
          height: 240,
          child: !paintInNormalOrderAvailable()
              ? noPaintAddedInNormalOrder()
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
                        DataColumn(label: Text("Ltr", style: dataColumnStyle()), numeric: true), // Defines volume of the paint in ltr
                        DataColumn(label: Text("SubTotal", style: dataColumnStyle())),
                        DataColumn(
                            label: SizedBox(
                          width: 1000,
                          child: Text("", style: dataColumnStyle()),
                        )),
                      ],
                      rows: normalOrder.products.where((element) => element.type == CreateProductViewState.PAINT).toList().map((Product paintProduct) {
                        return DataRow(cells: [
                          DataCell(Row(
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
                                style: dataCellStyle(),
                              )
                            ],
                          )),
                          DataCell(Text(paintProduct.paintType ?? "-", style: dataCellStyle())),
                          DataCell(Text(paintProduct.quantityInCart.toString(), style: dataCellStyle())),
                          DataCell(Text(paintProduct.calculateSubTotal().toString(), style: dataCellStyle())),
                          DataCell(IconButton(
                            icon: Icon(
                              Icons.clear,
                              color: Colors.pink,
                              size: 13,
                            ),
                            onPressed: () {
                              setState(() {
                                normalOrder.products.remove(paintProduct);
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
                            color: normalOrder == null || _currentOnEditPaint == null || _currentOnEditPaint.colorValue == null ? Colors.black12 : Color(int.parse(_currentOnEditPaint.colorValue)),
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
                  height: 16,
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
                              normalOrder.addProduct(_currentOnEditPaint);
                              _currentOnEditPaint = Product(
                                type: CreateProductViewState.PAINT,
                                unitOfMeasurement: CreateProductViewState.LITER,
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
                // To create overall order
                Container(
                  width: 200,
                  child: normalOrder.id == null
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
                                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800),
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
                )
                // Define inputs here.
              ],
            ),
          )),
    );
  }

  void clearInputs() {
    setState(() {
      _paintController.clear();
      _volumeController.clear();
    });
  }
}
