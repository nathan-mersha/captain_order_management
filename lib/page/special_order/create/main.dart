import 'package:captain/db/model/special_order.dart';
import 'package:captain/page/special_order/create/payment_info.dart';
import 'package:captain/page/special_order/create/product_input.dart';
import 'package:captain/page/special_order/create/products_table.dart';
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
                flex: 2,
                child: Column(
                  children: [
                    ProductInputPage(
                      navigateTo: widget.navigateTo,
                    )
                  ],
                )),

            // Other product & information section
            Expanded(
                flex: 5,
                child: Container(
                  child: Column(
                    children: [
                      // Other product
                      /// Not visible when focus
                      Expanded(flex: 3, child: ProductViewPage()),

                      // Customer and Payment information page
                      Expanded(flex: 1, child: SpecialOrderPaymentInformationPage()),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }
}
