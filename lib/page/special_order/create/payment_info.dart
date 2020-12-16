import 'package:captain/db/model/special_order.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class SpecialOrderPaymentInformationPage extends StatefulWidget {
  final FocusNode focus;

  SpecialOrderPaymentInformationPage({this.focus});

  @override
  _SpecialOrderPaymentInformationPageState createState() =>
      _SpecialOrderPaymentInformationPageState();
}

class _SpecialOrderPaymentInformationPageState
    extends State<SpecialOrderPaymentInformationPage> {
  SpecialOrder specialOrder;

  final oCCy = NumberFormat("#,##0.00", "en_US");
  @override
  Widget build(BuildContext context) {
    specialOrder = Provider.of<SpecialOrder>(context);

    return Card(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Payment Information",
              style:
                  TextStyle(color: Colors.black87, fontWeight: FontWeight.w800),
            ),
            SizedBox(
              height: 18,
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // total amount value
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "total",
                        style: getTitleStyle(),
                      ),
                      Text(
                        "${oCCy.format(specialOrder.totalAmount)} br",
                        style: getValueStyle(),
                      ),
                    ],
                  ),

                  // advance value
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "advance",
                        style: getTitleStyle(),
                      ),
                      Text(
                        "-",
                        style: getTitleStyle(),
                      ),
                    ],
                  ),

                  // remaining value
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "remaining",
                        style: getTitleStyle(),
                      ),
                      Text(
                        "-",
                        style: getTitleStyle(),
                      ),
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  TextStyle getTitleStyle() {
    return TextStyle(color: Colors.black54);
  }

  TextStyle getValueStyle() {
    return TextStyle(
        color: Colors.black87, fontWeight: FontWeight.w800, fontSize: 16);
  }
}
