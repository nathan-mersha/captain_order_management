import 'package:captain/db/model/normal_order.dart';
import 'package:captain/page/normal_order/create/main.dart';
import 'package:captain/page/normal_order/view/view.dart';
import 'package:flutter/material.dart';

class NormalOrderMainPage extends StatefulWidget {
  @override
  _NormalOrderMainPageState createState() => _NormalOrderMainPageState();
}

class _NormalOrderMainPageState extends State<NormalOrderMainPage> {
  static const String PAGE_CREATE_NORMAL_ORDER = "PAGE_CREATE_NORMAL_ORDER";
  static const String PAGE_VIEW_NORMAL_ORDER = "PAGE_VIEW_NORMAL_ORDER";

  String currentPage = PAGE_CREATE_NORMAL_ORDER; // TODO : default page change to PAGE_VIEW_NORMAL_ORDER on release
  NormalOrder normalOrder;

  @override
  Widget build(BuildContext context) {
    return Container(
        child: currentPage == PAGE_CREATE_NORMAL_ORDER
            ? NormalOrderCreateMainPage(
                normalOrder: normalOrder,
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
