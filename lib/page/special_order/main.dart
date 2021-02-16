import 'package:captain/db/model/special_order.dart';
import 'package:captain/page/special_order/create/main.dart';
import 'package:captain/page/special_order/view/view.dart';
import 'package:flutter/material.dart';

class SpecialOrderMainPage extends StatefulWidget {
  @override
  SpecialOrderMainPageState createState() => SpecialOrderMainPageState();
}

class SpecialOrderMainPageState extends State<SpecialOrderMainPage> {
  static const String PAGE_CREATE_SPECIAL_ORDER = "PAGE_CREATE_SPECIAL_ORDER";
  static const String PAGE_VIEW_SPECIAL_ORDER = "PAGE_VIEW_SPECIAL_ORDER";

  String currentPage = PAGE_VIEW_SPECIAL_ORDER;

  static const String PENDING = "Pending"; // values not translatables
  static const String COMPLETED = "Completed"; // value not translatable
  static const String DELIVERED = "Delivered"; // value not translatable
  SpecialOrder specialOrder = SpecialOrder(advancePayment: 0, paidInFull: false, totalAmount: 0, remainingPayment: 0, products: []);

  @override
  Widget build(BuildContext context) {

    print("from special order / main : ${specialOrder.remainingPayment}");
    return Container(
        child: currentPage == PAGE_CREATE_SPECIAL_ORDER
            ? SpecialOrderCreateMainPage(
                specialOrder: specialOrder,
                navigateTo: changePage,
              )
            : SpecialOrderTablePage(navigateTo: changePage));
  }

  changePage(String pageName, {SpecialOrder passedSpecialOrder}) {
    setState(() {
      currentPage = pageName;
      if (passedSpecialOrder != null) {
        specialOrder = passedSpecialOrder; // normal order passed for update reasons
      }
    });
  }
}
