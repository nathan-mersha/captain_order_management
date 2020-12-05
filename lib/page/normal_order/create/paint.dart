import 'package:captain/db/dal/message.dart';
import 'package:captain/db/dal/normal_order.dart';
import 'package:captain/db/dal/product.dart';
import 'package:captain/db/model/message.dart';
import 'package:captain/db/model/normal_order.dart';
import 'package:captain/db/model/product.dart';
import 'package:captain/db/shared_preference/c_shared_preference.dart';
import 'package:captain/page/normal_order/main.dart';
import 'package:captain/page/product/create_product.dart';
import 'package:captain/rsr/export/pdf_exporter.dart';
import 'package:captain/widget/c_dialog.dart';
import 'package:captain/widget/c_snackbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:intl/intl.dart';
import 'package:keyboard_visibility/keyboard_visibility.dart';
import 'package:provider/provider.dart';
import 'package:sms/sms.dart';

class CreateNormalOrderPaintPage extends StatefulWidget {
  final Function navigateTo;

  CreateNormalOrderPaintPage({this.navigateTo});

  @override
  CreateNormalOrderPaintPageState createState() => CreateNormalOrderPaintPageState();
}

class CreateNormalOrderPaintPageState extends State<CreateNormalOrderPaintPage> {
  CSharedPreference cSharedPreference = CSharedPreference();

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
    status: NormalOrderMainPageState.PENDING,
    quantityInCart: 0,
    unitPrice: 0,
  );

  // Status type

  List<String> statusTypes = [NormalOrderMainPageState.PENDING, NormalOrderMainPageState.COMPLETED, NormalOrderMainPageState.DELIVERED];
  Map<String, String> statusTypeValues;
  Map<String, String> measurementTypesValues;

  bool _doingCRUD = false;
  bool _keyboardIsVisible = false;

  final oCCy = NumberFormat("#,##0.00", "en_US");

  @override
  void dispose() {
    super.dispose();
    _paintController.dispose();
    _volumeController.dispose();
  }

  @override
  void initState() {
    super.initState();
    _assignPaintData();
    measurementTypesValues = {CreateProductViewState.LITER: "liter", CreateProductViewState.GRAM: "gram", CreateProductViewState.PIECE: "piece", CreateProductViewState.PACKAGE: "package"};
    statusTypeValues = {NormalOrderMainPageState.PENDING: "pending", NormalOrderMainPageState.COMPLETED: "completed", NormalOrderMainPageState.DELIVERED: "delivered"};

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
                              "Paint Order - ${getInCartCount()}",
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
                                  if (normalOrder.customer != null) {
                                    Exporter exporter = Exporter();
                                    exporter.toPdf(
                                        customer: normalOrder.customer,
                                        products: normalOrder.products,
                                        totalAmount: normalOrder.totalAmount,
                                        advanceAmount: normalOrder.advancePayment,
                                        remainingAmount: normalOrder.remainingPayment,
                                        lastModified: normalOrder.lastModified,
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
                              height: 30,
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
          widget.navigateTo(NormalOrderMainPageState.PAGE_VIEW_NORMAL_ORDER);
          return Future.value(false);
        });
  }

  TextStyle dataCellStyle() {
    return TextStyle(fontSize: 12, color: Colors.black87);
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

  Widget buildCreateOrder() {
    return Container(
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
                // don't need to validate form as the corresponding product type form already do.
                if (normalOrder.products.length == 0) {
                  // No products added
                  CNotifications.showSnackBar(context, "No products have been added in cart", "ok", () {}, backgroundColor: Colors.red);
                } else if (normalOrder.customer == null) {
                  // No customer added
                  CNotifications.showSnackBar(context, "No customer has been selected", "ok", () {}, backgroundColor: Colors.red);
                } else {
                  // Everything seems ok
                  NormalOrderDAL.create(normalOrder).then((value) {
                    widget.navigateTo(NormalOrderMainPageState.PAGE_VIEW_NORMAL_ORDER);
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
                      if (normalOrder.products.length == 0) {
                        // No products added
                        CNotifications.showSnackBar(context, "No products have been added in cart", "ok", () {}, backgroundColor: Colors.red);
                      } else if (normalOrder.customer == null) {
                        // No customer added
                        CNotifications.showSnackBar(context, "No customer has been selected", "ok", () {}, backgroundColor: Colors.red);
                      } else {
                        setState(() {
                          _doingCRUD = true;
                        });

                        await updateNormalOrder(context);
                        widget.navigateTo(NormalOrderMainPageState.PAGE_VIEW_NORMAL_ORDER);
                      }
                    }),
                OutlineButton(
                  child: Text(
                    "Cancel",
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Theme.of(context).accentColor),
                  ),
                  onPressed: () {
                    widget.navigateTo(NormalOrderMainPageState.PAGE_VIEW_NORMAL_ORDER);
                  },
                ),
              ],
            ),
    );
  }

  Future updateNormalOrder(BuildContext context) async {
    /// Query and update user
    String where = "${NormalOrder.ID} = ?";
    List<String> whereArgs = [normalOrder.id];
    await NormalOrderDAL.update(
      where: where,
      whereArgs: whereArgs,
      normalOrder: normalOrder,
    );

    /// Updating from fire store
//    normalOrder.customer.profileImage = null;
//    normalOrder.employee.profileImage = null;
//     dynamic normalOrderMap = NormalOrder.toMap(normalOrder);

    // todo Updating to fire store if fire store generated id is present in doc.
//    if (normalOrder.idFS != null) {
//      Firestore.instance.collection(NormalOrder.COLLECTION_NAME).document(normalOrder.idFS).updateData(normalOrderMap);
//    }

    // Showing notification
    CNotifications.showSnackBar(context, "Successfuly updated : ${normalOrder.customer.name}", "success", () {}, backgroundColor: Theme.of(context).accentColor);
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

  int getInCartCount() {
    return normalOrder.products.where((element) => element.type == CreateProductViewState.PAINT).length;
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
                        DataColumn(label: Text("Status", style: dataColumnStyle())),
                      ],
                      rows: normalOrder.products.where((element) => element.type == CreateProductViewState.PAINT).toList().map((Product paintProduct) {
                        return DataRow(cells: [
                          DataCell(
                              SingleChildScrollView(
                                child: GestureDetector(
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
                                SizedBox(
                                  width: 130,
                                  child: Text(
                                    paintProduct.name ?? "-",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  ),
                                )
                              ],
                            ),
                            onLongPress: () async {
                              return await removePaintProductFromCart(paintProduct);
                            },
                          ),scrollDirection: Axis.horizontal,)),
                          DataCell(GestureDetector(
                            child: Text(paintProduct.paintType ?? "-", style: dataCellStyle()),
                            onLongPress: () async {
                              return await removePaintProductFromCart(paintProduct);
                            },
                          )),
                          DataCell(Text(paintProduct.quantityInCart.toString(), style: dataCellStyle())),
                          DataCell(Text(paintProduct.calculateSubTotal().toString(), style: dataCellStyle())),
                          DataCell(
                            SizedBox(
                              width: double.infinity,
                              child: DropdownButton(
                                  value: paintProduct.status,
                                  isExpanded: true,
                                  iconSize: 16,
                                  icon: Icon(
                                    Icons.keyboard_arrow_down,
                                    color: getStatusColor(paintProduct.status),
                                  ),
                                  items: statusTypes.map<DropdownMenuItem<String>>((String statusValue) {
                                    return DropdownMenuItem(
                                      child: Row(
                                        children: [
                                          Text(
                                            statusTypeValues[statusValue],
                                            style: TextStyle(fontSize: 12, color: getStatusColor(statusValue)),
                                          ),
                                        ],
                                      ),
                                      value: statusValue,
                                    );
                                  }).toList(),
                                  onChanged: (String newValue) {
                                    setState(() {
                                      paintProduct.status = newValue;
                                      notifyUserViaSMS(normalOrder);
                                    });
                                  }),
                            ),
                          ),
                        ]);
                      }).toList(),
                    )
                  ],
                ),
        ));
  }

  Future<String> removePaintProductFromCart(Product paintProduct) async {
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
              message: "Are you sure you want to delete \n${paintProduct.name}",
              onYes: () async {
                // Delete customer here.
                Navigator.pop(context);

                setState(() {
                  normalOrder.removeProduct(paintProduct);
                });
                CNotifications.showSnackBar(context, "Successfuly removed ${paintProduct.name}", "success", () {}, backgroundColor: Colors.red);

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

  notifyUserViaSMS(NormalOrder normalOrder) async {
    if (normalOrder.customer != null && normalOrder.customer.phoneNumber != null) {
      bool allPaintsCompleted = normalOrder.products.every((Product product) {
        if (product.type == CreateProductViewState.PAINT) {
          return product.status == NormalOrderMainPageState.COMPLETED;
        } else {
          return true;
        }
      });

      if (allPaintsCompleted && cSharedPreference.sendNotificationAutomatically) {
        String firstName = normalOrder.customer.name.split(" ").first;
        String smsMessage =
            "ሰላም ${firstName.length > 11 ? firstName.substring(0, 11) : firstName} በ ${DateFormat.yMMMd().format(normalOrder.firstModified ?? DateTime.now())} ያዘዙት ቀለም ደርሷል መጥተው ይውሰዱ. ካፕሲ የመኪና ቀለሞች!";

        SmsSender sender = SmsSender();
        SmsMessage message = SmsMessage(normalOrder.customer.phoneNumber, smsMessage);
        sender.sendSms(message);

        Message sentMessage = Message(recipient: normalOrder.customer.name, body: smsMessage);
        MessageDAL.create(sentMessage);

        normalOrder.userNotified = true;
        CNotifications.showSnackBar(context, "Successfuly sent completed message to ${normalOrder.customer.name}", "success", () {}, backgroundColor: Colors.green);
      }

      String where = "${Product.ID} = ?";
      List<String> whereArgs = [normalOrder.id];
      await NormalOrderDAL.update(where: where, whereArgs: whereArgs, normalOrder: normalOrder);
    }
  }

  Color getStatusColor(String status) {
    if (status == NormalOrderMainPageState.PENDING) {
      return Colors.orange;
    } else if (status == NormalOrderMainPageState.COMPLETED) {
      return Colors.green;
    } else if (status == NormalOrderMainPageState.DELIVERED) {
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
                      title: Text(
                        suggestedPaint.name,
                        style: TextStyle(fontSize: 14, color: Colors.black87, fontWeight: FontWeight.w800),
                      ),
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
                              CNotifications.showSnackBar(context, "Successfuly added ${_currentOnEditPaint.name}", "success", () {}, backgroundColor: Colors.green);
                              _currentOnEditPaint.status = NormalOrderMainPageState.PENDING;
                              _currentOnEditPaint = Product(
                                type: CreateProductViewState.PAINT,
                                unitOfMeasurement: CreateProductViewState.LITER,
                                status: NormalOrderMainPageState.PENDING,
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
    });
  }
}
