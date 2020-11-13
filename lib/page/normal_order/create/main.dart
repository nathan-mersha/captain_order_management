import 'package:captain/db/model/normal_order.dart';
import 'package:captain/page/normal_order/create/customer_info.dart';
import 'package:captain/page/normal_order/create/other_product.dart';
import 'package:captain/page/normal_order/create/paint.dart';
import 'package:captain/page/normal_order/create/payment_info.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class NormalOrderCreateMainPage extends StatefulWidget {
  final NormalOrder normalOrder;

  NormalOrderCreateMainPage({this.normalOrder});
  @override
  _NormalOrderCreateMainPageState createState() => _NormalOrderCreateMainPageState();
}

class _NormalOrderCreateMainPageState extends State<NormalOrderCreateMainPage> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => NormalOrder(products: []),
      child: Container(
        height: 645,
        child: Row(
          children: [
            // Create paint order
            Expanded(child: CreateNormalOrderPaintPage()), // todo : pass Normal order model.

            // Other product & information section
            Expanded(
                child: Container(
                  child: Column(
                    children: [
                      // Other product
                      Expanded(flex: 2, child: CreateNormalOrderOtherProductPage()), // todo : pass Normal order model.

                      // Customer and Payment information page
                      Expanded(
                          flex: 1,
                          child: Container(
                            child: Row(
                              children: [
                                // Customer information
                                Expanded(child: NormalOrderCustomerInformationPage()), // todo : pass Normal order model.
                                // Payment information
                                Expanded(child: NormalOrderPaymentInformationPage()) // todo : pass Normal order model.
                              ],
                            ),
                          ))
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }
}
