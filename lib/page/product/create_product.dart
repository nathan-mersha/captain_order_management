import 'package:captain/db/dal/product.dart';
import 'package:captain/db/model/product.dart';
import 'package:captain/page/product/statistics_product.dart';
import 'package:captain/page/product/view_product.dart';
import 'package:captain/widget/c_snackbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

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
  Product product = Product(type: PAINT, unitOfMeasurement: LITER);

  // Product types
  static const String PAINT = "Paint"; // values not translatables
  static const String OTHER_PRODUCTS = "Others"; // values not translatables
  List<String> productTypes = [PAINT, OTHER_PRODUCTS];
  Map<String, String> productTypesValues;

  // Unit of measurements types
  static const String LITER = "Liter"; // values not translatables
  static const String GRAM = "Gram"; // values not translatables
  static const String PIECE = "Piece"; // values not translatables
  static const String PACKAGE = "Package"; // values not translatables
  List<String> measurementTypes = [LITER, GRAM, PIECE, PACKAGE];
  Map<String, String> measurementTypesValues;

  // Text editing controllers
  TextEditingController _nameController = TextEditingController();
  TextEditingController _unitPriceController = TextEditingController();
  TextEditingController _noteController = TextEditingController();
  // todo : assign more controllers here.

  bool _doingCRUD = false;

  @override
  void initState() {
    super.initState();
    // Separating keys to values for translatable.
    productTypesValues = {PAINT: "paint", OTHER_PRODUCTS: "others"};
    measurementTypesValues = {LITER: "liter", GRAM: "gram", PIECE: "piece", PACKAGE: "package"};
  }

  @override
  Widget build(BuildContext context) {
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
                                style: TextStyle(fontSize: 12,),
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
                                      Text(
                                        productTypesValues[productValue],
                                        style: TextStyle(fontSize: 12),
                                      ),
                                      SizedBox(
                                        width: 16,
                                      ),
                                      Icon(
                                        productValue == PAINT ? Icons.format_paint : Icons.local_drink,
                                        size: 15,
                                        color: Theme.of(context).accentColor,
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
                          height: 15,
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

                        product.type == PAINT ? buildForPaintProduct() : buildForOtherProduct()
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
        SizedBox(height: 5,),
        SizedBox(
          width: double.infinity,
          child: DropdownButton(
              value: product.unitOfMeasurement,
              hint: Text("unit of measurment", style: TextStyle(fontSize: 12,)),
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
                        measurementTypesValues[measurementValue],
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
          },
          onFieldSubmitted: (unitPriceValue) {
            product.unitPrice = num.parse(unitPriceValue);
          },
          decoration: InputDecoration(
              labelText: "Unit price", contentPadding: EdgeInsets.symmetric(vertical: 5), suffix: Text("br per ${measurementTypesValues[product.unitOfMeasurement] ?? measurementTypesValues[LITER]}")),
        ),
        TextFormField(
          controller: _noteController,
          onChanged: (noteValue) {
            product.note = noteValue;
          },
          onFieldSubmitted: (noteValue) {
            product.note = noteValue;
          },
          decoration: InputDecoration(labelText: "Note", contentPadding: EdgeInsets.symmetric(vertical: 5)),
        )
      ],
    );
  }

  Widget buildForPaintProduct() {
    return Column(
      children: [
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
      ],
    );
  }

  void cleanFields() {
    setState(() {
      /// Clearing data
      _doingCRUD = false;
      product = Product(type: PAINT, unitOfMeasurement: LITER);
      clearInputs();
    });

    /// Notify corresponding widgets.
    widget.productTableKey.currentState.setState(() {});
    widget.statisticsProductKey.currentState.setState(() {});
  }

  Future createProduct(BuildContext context) async {
    /// Create Product Product data to local db

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
      dynamic productMap = Product.toMap(queriedProduct);
      DocumentReference docRef = await Firestore.instance.collection(Product.COLLECTION_NAME).add(productMap);
      queriedProduct.idFS = docRef.documentID;
      String where = "${Product.ID} = ?";
      List<String> whereArgs = [queriedProduct.id]; // Querying only products
      ProductDAL.update(where: where, whereArgs: whereArgs, product: queriedProduct);
    });
  }

  Future updateProduct(BuildContext context) async {
    /// Query and update user
    String where = "${Product.ID} = ?";
    List<String> whereArgs = [product.id];
    await ProductDAL.update(where: where, whereArgs: whereArgs, product: product);

    /// Updating from fire store
    dynamic productMap = Product.toMap(product);
    // Updating to fire store if fire store generated id is present in doc.
    if (product.idFS != null) {
      Firestore.instance.collection(Product.COLLECTION_NAME).document(product.idFS).updateData(productMap);
    }
    // Showing notification
    CNotifications.showSnackBar(context, "Successfuly updated : ${product.name}", "success", () {}, backgroundColor: Theme.of(context).accentColor);
  }

  void clearInputs() {
    _nameController.clear();
    _unitPriceController.clear();
    _noteController.clear();
  }

  void passForUpdate(Product productUpdateData) async {
    String where = "${Product.ID} = ?";
    List<String> whereArgs = [productUpdateData.id]; // Querying only products
    List<Product> products = await ProductDAL.find(where: where, whereArgs: whereArgs);

    setState(() {
      product = products.first;
      _nameController.text = product.name;
      _unitPriceController.text = product.unitPrice.toString();
      _noteController.text = product.note;
    });
  }
}
