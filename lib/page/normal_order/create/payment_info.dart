import 'package:captain/db/model/normal_order.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class NormalOrderPaymentInformationPage extends StatefulWidget {
  final FocusNode focus;

  NormalOrderPaymentInformationPage({this.focus});

  @override
  _NormalOrderPaymentInformationPageState createState() => _NormalOrderPaymentInformationPageState();
}

class _NormalOrderPaymentInformationPageState extends State<NormalOrderPaymentInformationPage> {
  NormalOrder normalOrder;
  TextEditingController _advanceController = TextEditingController();

  final oCCy = NumberFormat("#,##0.00", "en_US");

  @override
  void dispose() {
    super.dispose();
    _advanceController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    normalOrder = Provider.of<NormalOrder>(context);

    return Card(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Payment Information",
              style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w800),
            ),
            SizedBox(
              height: 18,
            ),
            Expanded(
              child: Column(
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
                        "${oCCy.format(normalOrder.totalAmount)} br",
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

                      /// Volume controller
                      SizedBox(
                        width: 100,
                        child: TextFormField(
                          keyboardType: TextInputType.number,
                          initialValue: oCCy.format(normalOrder.advancePayment),
                          focusNode: widget.focus,
                          onChanged: (advanceValue) {
                            setState(() {
                              normalOrder.advancePayment = num.parse(advanceValue);
                              normalOrder.calculatePaymentInfo();
                            });
                          },
                        ),
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
                        "${oCCy.format(normalOrder.remainingPayment)} br",
                        style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w800, fontSize: 14),
                      ),
                    ],
                  ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "paid in full",
                        style: getTitleStyle(),
                      ),
                      Switch(
                        value: normalOrder.paidInFull,
                        onChanged: (bool changed) {
                          setState(() {
                            if (changed) {
                              normalOrder.paidInFull = true;
                              normalOrder.advancePayment = normalOrder.totalAmount;
                              normalOrder.calculatePaymentInfo();
                            } else {
                              normalOrder.paidInFull = false;
                              normalOrder.advancePayment = 0; // Reset advance payment to 0
                              normalOrder.calculatePaymentInfo();
                            }
                          });
                        },
                      )
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
    return TextStyle(color: Colors.black87, fontWeight: FontWeight.w800, fontSize: 16);
  }
}
