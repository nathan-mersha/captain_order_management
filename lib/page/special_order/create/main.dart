import 'package:captain/db/model/special_order.dart';
import 'package:captain/page/special_order/create/customer_info.dart';
import 'package:captain/page/special_order/create/other_product.dart';
import 'package:captain/page/special_order/create/paint.dart';
import 'package:captain/page/special_order/create/payment_info.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SpecialOrderCreateMainPage extends StatefulWidget {
  final SpecialOrder specialOrder;
  final Function navigateTo;
  SpecialOrderCreateMainPage({this.specialOrder, this.navigateTo});

  @override
  _SpecialOrderCreateMainPageState createState() => _SpecialOrderCreateMainPageState();
}

class _SpecialOrderCreateMainPageState extends State<SpecialOrderCreateMainPage> {
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
      create: (_) => widget.specialOrder,
      child: Container(
        height: 645,
        child: Row(
          children: [
            // Create paint order
            Expanded(
                child: CreateSpecialOrderPaintPage(
              navigateTo: widget.navigateTo,
            )),

            // Other product & information section
            Expanded(
                child: Container(
              child: Column(
                children: [
                  // Other product
                  /// Not visible when focus
                  Visibility(
                    child: Expanded(flex: 3, child: CreateSpecialOrderOtherProductPage()),
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
                                child: SpecialOrderCustomerInformationPage(
                              focus: _focusCustomer,
                            )), // todo : pass Normal order model.
                            // Payment information
                            Expanded(
                                child: SpecialOrderPaymentInformationPage(
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
