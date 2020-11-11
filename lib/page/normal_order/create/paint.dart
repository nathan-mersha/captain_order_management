import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'package:captain/db/dal/personnel.dart';
import 'package:captain/db/dal/product.dart';
import 'package:captain/db/model/normal_order.dart';
import 'package:captain/db/model/personnel.dart';
import 'package:captain/db/model/product.dart';
import 'package:captain/page/product/create_product.dart';
import 'package:captain/rsr/kapci/manufacturers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:keyboard_visibility/keyboard_visibility.dart';

class CreateNormalOrderPaintPage extends StatefulWidget {
  final NormalOrder normalOrder;

  CreateNormalOrderPaintPage({this.normalOrder});

  @override
  CreateNormalOrderPaintPageState createState() => CreateNormalOrderPaintPageState();
}

class CreateNormalOrderPaintPageState extends State<CreateNormalOrderPaintPage> {
  final _paintOrderFormKey = GlobalKey<FormState>();

  NormalOrder normalOrder;

  // Text editing controllers
  TextEditingController _paintController = TextEditingController();
  TextEditingController _manufacturerController = TextEditingController();
  TextEditingController _volumeController = TextEditingController();

  // Lists required for view to be build
  List<Product> _paints = [];
  List<Personnel> _customers = [];

  // Handles paint validation
  bool _noPaintValue = false;

  // Paint type
  List<String> paintTypes = [CreateProductViewState.METALIC, CreateProductViewState.AUTO_CRYL];
  Map<String, String> paintTypesValues;
  Map<String, String> productTypesValues;

  Product _currentOnEditPaint = Product(
    type: CreateProductViewState.PAINT,
    unitOfMeasurement: CreateProductViewState.LITER,
    paintType: CreateProductViewState.METALIC,
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
    _assignPersonnelAndPaintData();
    normalOrder = widget.normalOrder ?? NormalOrder(products: []);
    paintTypesValues = {CreateProductViewState.METALIC: "Metalic", CreateProductViewState.AUTO_CRYL: "Auto-Cryl"};
    productTypesValues = {CreateProductViewState.PAINT: "paint", CreateProductViewState.OTHER_PRODUCTS: "others"};
    measurementTypesValues = {CreateProductViewState.LITER: "liter", CreateProductViewState.GRAM: "gram", CreateProductViewState.PIECE: "piece", CreateProductViewState.PACKAGE: "package"};
    statusTypeValues = {PENDING: "pending", COMPLETED: "completed", DELIVERED: "delivered"};

    KeyboardVisibilityNotification().addNewListener(
      onChange: (bool visible) {
        _keyboardIsVisible = visible;
      },
    );
  }

  Future<bool> _assignPersonnelAndPaintData() async {
    // Assigning employees data.
    String wherePersonnel = "${Personnel.TYPE} = ?";
    List<String> whereArgsCustomers = [Personnel.CUSTOMER]; // Querying only customers
    _customers = await PersonnelDAL.find(where: wherePersonnel, whereArgs: whereArgsCustomers); // Assign customers

    // Assigning paints data
    String wherePaint = "${Product.TYPE} = ?";
    List<String> whereArgsPaint = [CreateProductViewState.PAINT]; // Querying only paint type
    _paints = await ProductDAL.find(where: wherePaint, whereArgs: whereArgsPaint);
    setState(() {});
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        color: Colors.yellow,
        height: 645,
        child: Card(
          color: Colors.purple,
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
                  color: Colors.green,
                  height: 592,
                  padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, right: 20, left: 20, top: 0),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [buildTable(), buildForm()],
                    ),
                  )),
            ],
          ),
        ));
  }

  Widget buildTable() {
    return Visibility(
        visible: !_keyboardIsVisible,
        child: SingleChildScrollView(
          child: Container(
            height: 180,
            color: Colors.red,
            child: DataTable(
              columns: [
                DataColumn(label: Text("Color")),
                DataColumn(label: Text("Type")), // Defines the paint type, auto-cryl/metalic
                DataColumn(label: Text("Volume"), numeric: true), // Defines volume of the paint in ltr
                DataColumn(label: Text("SubTotal")),
                DataColumn(label: Text("")),
              ],
              rows: normalOrder.products.map((Product paintProduct) {
                // todo : check type of product to be paint
                return DataRow(cells: [
                  DataCell(Text(paintProduct.name)),
                  DataCell(Text(paintProduct.type)),
                  DataCell(Text(paintProduct.quantityInCart.toString())),
                  DataCell(Text(paintProduct.subTotal.toString())),
                  DataCell(IconButton(
                    icon: Icon(Icons.exposure_minus_1),
                  )),
                ]);
              }).toList(),
            ),
          ),
        ));
  }

  Widget buildForm() {
    return Container(
      color: Colors.lightGreenAccent,
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

                /// Paint type input
                SizedBox(
                  width: double.infinity,
                  child: DropdownButton(
                      value: _currentOnEditPaint.paintType,
                      hint: Text("paint type",
                          style: TextStyle(
                            fontSize: 12,
                          )),
                      isExpanded: true,
                      iconSize: 18,
                      icon: Icon(
                        Icons.keyboard_arrow_down,
                        color: Theme.of(context).primaryColor,
                      ),
                      items: paintTypes.map<DropdownMenuItem<String>>((String paintTypeValue) {
                        return DropdownMenuItem(
                          child: Row(
                            children: [
                              Text(
                                paintTypesValues[paintTypeValue],
                                style: TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                          value: paintTypeValue,
                        );
                      }).toList(),
                      onChanged: (String newValue) {
                        setState(() {
                          _currentOnEditPaint.paintType = newValue;
                        });
                      }),
                ),

                /// Manufacturer type
                SimpleAutoCompleteTextField(
                  suggestions: KapciManufacturers.VALUES,
                  clearOnSubmit: false,
                  decoration: InputDecoration(labelText: "Manufacturer", contentPadding: EdgeInsets.all(0)),
                  textCapitalization: TextCapitalization.none,
                  controller: _manufacturerController,
                  textSubmitted: (String manufacturerValue) {
                    _currentOnEditPaint.manufacturer = manufacturerValue;
                  },
                ),

                /// Volume controller
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
                  height: 8,
                ),
                Align(
                  alignment: Alignment.topRight,
                  child: OutlineButton(onPressed: () {}, child: Text("Add")),
                ),

                SizedBox(
                  height: 90,
                ),
                // To create overall order
                Container(
                  width: 200,
                  color: Colors.blue,
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
                                  "Create Order",
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
                )
                // Define inputs here.
              ],
            ),
          )),
    );
  }
}
