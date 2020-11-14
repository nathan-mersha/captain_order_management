import 'package:captain/db/model/normal_order.dart';
import 'package:captain/page/normal_order/create/customer_info.dart';
import 'package:captain/page/normal_order/create/other_product.dart';
import 'package:captain/page/normal_order/create/paint.dart';
import 'package:captain/page/normal_order/create/payment_info.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class NormalOrderCreateMainPage extends StatefulWidget {
  final NormalOrder normalOrder;
  final Function navigateTo;
  NormalOrderCreateMainPage({this.normalOrder, this.navigateTo});

  @override
  _NormalOrderCreateMainPageState createState() => _NormalOrderCreateMainPageState();
}

class _NormalOrderCreateMainPageState extends State<NormalOrderCreateMainPage> {
  FocusNode _focusCustomer = FocusNode();
  FocusNode _focusPayment = FocusNode();
  bool focusOnLowerElements = false;
  @override
  void initState() {
    super.initState();
    _focusCustomer.addListener(() {
      setState(() {
        focusOnLowerElements = _focusCustomer.hasFocus;
      });
    });
    _focusPayment.addListener(() {
      setState(() {
        focusOnLowerElements = _focusPayment.hasFocus;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => widget.normalOrder,
      child: Container(
        height: 645,
        child: Row(
          children: [
            // Create paint order
            Expanded(child: CreateNormalOrderPaintPage(navigateTo: widget.navigateTo,)), // todo : pass Normal order model.

            // Other product & information section
            Expanded(
                child: Container(
              child: Column(
                children: [
                  // Other product
                  /// Not visible when focus
                  Visibility(
                    child: Expanded(flex: 2, child: CreateNormalOrderOtherProductPage()),
                    visible: !focusOnLowerElements,
                  ),

                  // Customer and Payment information page
                  Expanded(
                      flex: 1,
                      child: Container(
                        child: Row(
                          children: [
                            // Customer information
                            Expanded(
                                child: NormalOrderCustomerInformationPage(
                              focus: _focusCustomer,
                            )), // todo : pass Normal order model.
                            // Payment information
                            Expanded(
                                child: NormalOrderPaymentInformationPage(
                              focus: _focusPayment,
                            )) // todo : pass Normal order model.
                          ],
                        ),
                      )),

                  /// visible only when focusing on customer and payment info
                  Visibility(
                    child: Expanded(
                      flex: 2,
                      child: Container(),
                    ),
                    visible: focusOnLowerElements,
                  )
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }
}
