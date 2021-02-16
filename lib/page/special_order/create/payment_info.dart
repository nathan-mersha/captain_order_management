import 'package:captain/db/model/special_order.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class SpecialOrderPaymentInformationPage extends StatefulWidget {
  final FocusNode focus;

  SpecialOrderPaymentInformationPage({this.focus});

  @override
  _SpecialOrderPaymentInformationPageState createState() => _SpecialOrderPaymentInformationPageState();
}

class _SpecialOrderPaymentInformationPageState extends State<SpecialOrderPaymentInformationPage> {
  SpecialOrder specialOrder;

  TextEditingController advanceController = TextEditingController();
  bool advanceInitialized = false;

  final oCCy = NumberFormat("#,##0.00", "en_US");
  @override
  Widget build(BuildContext context) {
    specialOrder = Provider.of<SpecialOrder>(context);

    if(!advanceInitialized){
      advanceController.text = oCCy.format(specialOrder.advancePayment);
      advanceInitialized = true;
    }

    return Card(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              "Payment Information",
              style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w800),
            ),
            SizedBox(
              height: 10,
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
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

                    /// Volume controller
                    SizedBox(
                      width: 100,
                      height: 35,
                      child: TextFormField(
                        keyboardType: TextInputType.number,
                        controller: advanceController,
                        focusNode: widget.focus,
                        onChanged: (advanceValue) {
                          setState(() {
                            specialOrder.advancePayment = num.parse(advanceValue);
                            specialOrder.calculatePaymentInfo();
                          });
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 5,),

                // remaining value
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "remaining",
                      style: getTitleStyle(),
                    ),
                    Text(
                      "${oCCy.format(specialOrder.remainingPayment)} br",
                      style: getTitleStyle(),
                    ),
                  ],
                ),

                SizedBox(height: 3,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,

                  children: [
                    Text(
                      "paid in full",
                      style: getTitleStyle(),
                    ),
                    SizedBox(child: Switch(
                      value: specialOrder.paidInFull,
                      onChanged: (bool changed) {
                        setState(() {
                          if (changed) {
                            specialOrder.paidInFull = true;
                            specialOrder.advancePayment = specialOrder.totalAmount;
                            specialOrder.calculatePaymentInfo();
                          } else {
                            specialOrder.paidInFull = false;
                            specialOrder.advancePayment = 0; // Reset advance payment to 0
                            specialOrder.calculatePaymentInfo();
                          }
                          advanceController.text = oCCy.format(specialOrder.advancePayment);
                        });
                      },
                    ),height: 30,)
                  ],
                ),

              ],
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
