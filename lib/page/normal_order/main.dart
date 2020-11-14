import 'package:captain/db/model/normal_order.dart';
import 'package:captain/page/normal_order/create/main.dart';
import 'package:captain/page/normal_order/view/view.dart';
import 'package:flutter/material.dart';

class NormalOrderMainPage extends StatefulWidget {
  @override
  NormalOrderMainPageState createState() => NormalOrderMainPageState();
}

class NormalOrderMainPageState extends State<NormalOrderMainPage> {
  static const String PAGE_CREATE_NORMAL_ORDER = "PAGE_CREATE_NORMAL_ORDER";
  static const String PAGE_VIEW_NORMAL_ORDER = "PAGE_VIEW_NORMAL_ORDER";

  String currentPage = PAGE_CREATE_NORMAL_ORDER; // TODO : default page change to PAGE_VIEW_NORMAL_ORDER on release

  static const String PENDING = "Pending"; // values not translatables
  static const String COMPLETED = "Completed"; // value not translatable
  static const String DELIVERED = "Delivered"; // value not translatable
  NormalOrder normalOrder = NormalOrder(advancePayment: 0, paidInFull: false, totalAmount: 0, remainingPayment : 0, userNotified: false, status: PENDING, products: []);

  @override
  Widget build(BuildContext context) {
    return Container(
        child: currentPage == PAGE_CREATE_NORMAL_ORDER
            ? NormalOrderCreateMainPage(
                normalOrder: normalOrder,
                navigateTo: changePage,
              )
            : ViewNormalOrderPage());
  }

  changePage(String pageName, {NormalOrder passedNormalOrder}) {
    setState(() {
      currentPage = pageName;
      normalOrder = passedNormalOrder;
    });
  }
}
