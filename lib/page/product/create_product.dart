import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'package:captain/db/dal/product.dart';
import 'package:captain/db/model/product.dart';
import 'package:captain/db/shared_preference/c_shared_preference.dart';
import 'package:captain/page/product/statistics_product.dart';
import 'package:captain/page/product/view_product.dart';
import 'package:captain/rsr/kapci/manufacturers.dart';
import 'package:captain/widget/c_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class CreateProductView extends StatefulWidget {
  final GlobalKey<CreateProductViewState> createProductKey;
  final GlobalKey<StatisticsProductViewState> statisticsProductKey;
  final GlobalKey<ProductTableState> productTableKey;

  const CreateProductView({this.productTableKey, this.createProductKey, this.statisticsProductKey}) : super(key: createProductKey);

  @override
  CreateProductViewState createState() => CreateProductViewState();
}

class CreateProductViewState extends State<CreateProductView> {
  final _formKey = GlobalKey<FormState>();
  Product product = Product(type: PAINT, unitOfMeasurement: LITER, paintType: METALIC, isGallonBased: true); // Assigning default product values here

  // Product types
  static const String PAINT = "Paint"; // values not translatables
  static const String OTHER_PRODUCTS = "Others"; // values not translatables
  List<String> productTypes = [PAINT, OTHER_PRODUCTS];

  // Unit of measurements types
  static const String LITER = "Liter"; // values not translatables
  static const String GALLON = "Gallon"; // values not translatables
  static const String GRAM = "Gram"; // values not translatables
  static const String PIECE = "Piece"; // values not translatables
  static const String PACKAGE = "Package"; // values not translatables
  List<String> measurementTypes = [LITER, GRAM, PIECE, PACKAGE, GALLON];

  // Paint type
  static const String METALIC = "Metalic"; // values not translatables
  static const String AUTO_CRYL = "Auto-Cryl"; // value not translatable
  List<String> paintTypes = [METALIC, AUTO_CRYL];

  // Text editing controllers
  TextEditingController _nameController = TextEditingController();
  TextEditingController _unitPriceController = TextEditingController();
  TextEditingController _manufacturerController = TextEditingController();
  TextEditingController _colorValueController = TextEditingController();

  bool _doingCRUD = false;
  bool _manuallyAdjustPaintPrice = false;

  @override
  void dispose() {
    super.dispose();
    _nameController.dispose();
    _unitPriceController.dispose();
    _manufacturerController.dispose();
    _colorValueController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    setPaintTypeUnitPrice();

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(5))),
      child: Container(
        padding: EdgeInsets.only(bottom: 10),
        child: Column(
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
                    "${product.id == null ? "Create" : "Update"} Product",
                    style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w800),
                  ),
                ),
              ),
            ),
            Container(
                height: 425,
                padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, right: 20, left: 20, top: 15),
                child: Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        // Product type select
                        SizedBox(
                          width: double.infinity,
                          child: DropdownButton(
                              value: product.type,
                              hint: Text(
                                "product type",
                                style: TextStyle(
                                  fontSize: 12,
                                ),
                              ),
                              isExpanded: true,
                              iconSize: 18,
                              icon: Icon(
                                Icons.keyboard_arrow_down,
                                color: Theme.of(context).primaryColor,
                              ),
                              items: productTypes.map<DropdownMenuItem<String>>((String productValue) {
                                return DropdownMenuItem(
                                  child: Row(
                                    children: [
                                      Icon(
                                        productValue == PAINT ? Icons.invert_colors : Icons.shopping_basket,
                                        size: 15,
                                        color: Theme.of(context).accentColor,
                                      ),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      Text(
                                        productValue,
                                        style: TextStyle(fontSize: 12),
                                      ),
                                    ],
                                  ),
                                  value: productValue,
                                );
                              }).toList(),
                              onChanged: (String newValue) {
                                setState(() {
                                  product.type = newValue;
                                });
                              }),
                        ),

                        SizedBox(
                          height: 10,
                        ),

                        TextFormField(
                          validator: (nameValue) {
                            if (nameValue.isEmpty) {
                              return "Name must not be empty";
                            } else {
                              return null;
                            }
                          },
                          controller: _nameController,
                          onChanged: (nameValue) {
                            product.name = nameValue;
                          },
                          onFieldSubmitted: (nameValue) {
                            product.name = nameValue;
                          },
                          decoration: InputDecoration(labelText: "Name", contentPadding: EdgeInsets.symmetric(vertical: 5)),
                        ),

                        product.type == PAINT ? buildForPaintProduct() : buildForOtherProduct(),

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
                            product.unitPrice = num.parse(unitPriceValue);
                            _manuallyAdjustPaintPrice = true;
                          },
                          onFieldSubmitted: (unitPriceValue) {
                            product.unitPrice = num.parse(unitPriceValue);
                            _manuallyAdjustPaintPrice = true;
                          },
                          decoration: InputDecoration(
                              labelText: "Unit price",
                              contentPadding: EdgeInsets.symmetric(vertical: 5),
                              suffix: Text("br per ${product.unitOfMeasurement ?? LITER}")),
                        ),

                        product.type == PAINT
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Checkbox(
                                    value: product.isGallonBased,
                                    onChanged: (bool isGallonBasedValue) {
                                      setState(() {
                                        product.isGallonBased = isGallonBasedValue;
                                      });
                                    },
                                  ),
                                  Text(
                                    "gallon based",
                                    style: TextStyle(fontSize: 12, color: Colors.black87),
                                  )
                                ],
                              )
                            : Container()
                      ],
                    ),
                  ),
                )),
            Container(
              child: product.id == null
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
                      onPressed: () async {
                        if (_formKey.currentState.validate()) {
                          setState(() {
                            _doingCRUD = true;
                          });
                          await createProduct(context);
                          cleanFields();
                        }
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
                            onPressed: () async {
                              if (_formKey.currentState.validate()) {
                                setState(() {
                                  _doingCRUD = true;
                                });
                                await updateProduct(context);
                                cleanFields();
                              }
                            }),
                        OutlineButton(
                          child: Text(
                            "Cancel",
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Theme.of(context).accentColor),
                          ),
                          onPressed: () {
                            cleanFields();
                          },
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildForOtherProduct() {
    return Column(
      children: [
        SizedBox(
          height: 5,
        ),
        SizedBox(
          width: double.infinity,
          child: DropdownButton(
              value: product.unitOfMeasurement,
              hint: Text("unit of measurment",
                  style: TextStyle(
                    fontSize: 12,
                  )),
              isExpanded: true,
              iconSize: 18,
              icon: Icon(
                Icons.keyboard_arrow_down,
                color: Theme.of(context).primaryColor,
              ),
              items: measurementTypes.map<DropdownMenuItem<String>>((String measurementValue) {
                return DropdownMenuItem(
                  child: Row(
                    children: [
                      Text(
                        measurementValue,
                        style: TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                  value: measurementValue,
                );
              }).toList(),
              onChanged: (String newValue) {
                setState(() {
                  product.unitOfMeasurement = newValue;
                });
              }),
        ),
      ],
    );
  }

  Widget buildForPaintProduct() {
    Color pickerColor = Color(0xff443a49);

    return Column(
      children: [
        GestureDetector(
          onTap: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('Pick a color!'),
                  content: SingleChildScrollView(
                    child: ColorPicker(
                      pickerColor: pickerColor,
                      onColorChanged: (changedColor) {
                        pickerColor = changedColor;
                      },
                      showLabel: true,
                      pickerAreaHeightPercent: 0.8,
                    ),
                  ),
                  actions: <Widget>[
                    FlatButton(
                      child: const Text('Select'),
                      onPressed: () {
                        setState(() {
                          product.colorValue = pickerColor.value.toString();
                          _colorValueController.text = pickerColor.value.toString();
                        });
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                );
              },
            );
          },
          child: TextFormField(
            style: TextStyle(fontSize: 12, color: Color(int.parse(product.colorValue ?? "0xfffffffff")), fontWeight: FontWeight.w800),
            controller: _colorValueController,
            validator: (colorValue) {
              if (colorValue.isEmpty) {
                return "Please select a color";
              } else {
                return null;
              }
            },
            enabled: false,
            decoration: InputDecoration(
                errorStyle: TextStyle(color: Colors.red),
                labelText: "Color value",
                contentPadding: EdgeInsets.symmetric(vertical: 5),
                suffix: Container(
                  height: 8,
                  width: 16,
                  color: Color(int.parse(product.colorValue ?? "0xfffffffff")),
                )),
          ),
        ),
        SizedBox(
          height: 13,
        ),
        SizedBox(
          width: double.infinity,
          child: DropdownButton(
              value: product.paintType,
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
                        paintTypeValue,
                        style: TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                  value: paintTypeValue,
                );
              }).toList(),
              onChanged: (String newValue) {
                setState(() {
                  product.paintType = newValue;
                });
              }),
        ),
        SimpleAutoCompleteTextField(
          suggestions: KapciManufacturers.VALUES,
          clearOnSubmit: false,
          decoration: InputDecoration(labelText: "Manufacturer", contentPadding: EdgeInsets.all(0)),
          textCapitalization: TextCapitalization.none,
          controller: _manufacturerController,
          textSubmitted: (String manufacturerValue) {
            product.manufacturer = manufacturerValue;
          },
        ),
        SizedBox(
          height: 5,
        ),
      ],
    );
  }

  void cleanFields() {
    setState(() {
      /// Clearing data
      _doingCRUD = false;
      // Assigning default product values on clearing fields here.
      product = Product(type: PAINT, unitOfMeasurement: LITER, paintType: METALIC, isGallonBased: true);
      clearInputs();
    });

    /// Notify corresponding widgets.
    widget.productTableKey.currentState.setState(() {});
    widget.statisticsProductKey.currentState.setState(() {});
  }

  Future createProduct(BuildContext context) async {
    /// Create Product Product data to local db
    /// on creating product based on the product type nullify corresponding fields
    if (product.type == OTHER_PRODUCTS) {
      product.colorValue = null;
      product.paintType = null;
      product.manufacturer = null;
      product.isGallonBased = null;
    }
    Product createdProduct = await ProductDAL.create(product);

    /// Showing notification
    CNotifications.showSnackBar(context, "Successfuly created : ${product.name}", "success", () {}, backgroundColor: Colors.green);
    createInFSAndUpdateLocally(createdProduct);
  }

  Future createInFSAndUpdateLocally(Product product) async {
    String where = "${Product.ID} = ?";
    List<String> whereArgs = [product.id]; // Querying only products
    ProductDAL.find(where: where, whereArgs: whereArgs).then((List<Product> product) async {
      Product queriedProduct = product.first;

      /// Creating data to fire store
      // dynamic productMap = Product.toMap(queriedProduct);
//      DocumentReference docRef = await Firestore.instance.collection(Product.COLLECTION_NAME).add(productMap);
//      queriedProduct.idFS = docRef.documentID;
      String where = "${Product.ID} = ?";
      List<String> whereArgs = [queriedProduct.id]; // Querying only products
      ProductDAL.update(where: where, whereArgs: whereArgs, product: queriedProduct);
    });
  }

  setPaintTypeUnitPrice() {
    CSharedPreference cSP = GetCSPInstance.cSharedPreference;
    num metalicPrice = cSP.metalicPricePerLitter;
    num autoCrylPrice = cSP.autoCrylPricePerLitter;

    if (product.id == null && product.type == PAINT && _manuallyAdjustPaintPrice == false) {
      product.unitPrice = product.paintType == METALIC ? metalicPrice : autoCrylPrice;
      _unitPriceController.text = product.unitPrice.toString();
    }
  }

  Future updateProduct(BuildContext context) async {
    /// Query and update user
    String where = "${Product.ID} = ?";
    List<String> whereArgs = [product.id];
    await ProductDAL.update(where: where, whereArgs: whereArgs, product: product);

    /// Updating from fire store
    // dynamic productMap = Product.toMap(product);
    // Updating to fire store if fire store generated id is present in doc.
    if (product.idFS != null) {
//      Firestore.instance.collection(Product.COLLECTION_NAME).document(product.idFS).updateData(productMap);
    }
    // Showing notification
    CNotifications.showSnackBar(context, "Successfuly updated : ${product.name}", "success", () {}, backgroundColor: Theme.of(context).accentColor);
  }

  void clearInputs() {
    _nameController.clear();
    _unitPriceController.clear();
    _colorValueController.clear();
    _manufacturerController.clear();
  }

  void passForUpdate(Product productUpdateData) async {
    String where = "${Product.ID} = ?";
    List<String> whereArgs = [productUpdateData.id]; // Querying only products
    List<Product> products = await ProductDAL.find(where: where, whereArgs: whereArgs);

    setState(() {
      product = products.first;
      _nameController.text = product.name;
      _unitPriceController.text = product.unitPrice.toString();
      _colorValueController.text = product.colorValue;
      _manufacturerController.text = product.manufacturer;
    });
  }
}
