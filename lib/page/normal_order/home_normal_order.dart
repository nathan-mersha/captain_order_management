import 'package:captain/db/model/normal_order.dart';
import 'package:captain/page/normal_order/create_normal_order.dart';
import 'package:captain/page/normal_order/view_normal_order.dart';
import 'package:flutter/material.dart';

class HomeNormalOrdersPage extends StatefulWidget {
  @override
  _HomeNormalOrdersPageState createState() => _HomeNormalOrdersPageState();
}

class _HomeNormalOrdersPageState extends State<HomeNormalOrdersPage> {
  static const String PAGE_CREATE_NORMAL_ORDER = "PAGE_CREATE_NORMAL_ORDER";
  static const String PAGE_VIEW_NORMAL_ORDER = "PAGE_VIEW_NORMAL_ORDER";

  String currentPage = PAGE_CREATE_NORMAL_ORDER; // TODO : default page change to PAGE_VIEW_NORMAL_ORDER on release
  NormalOrder normalOrder;

  @override
  Widget build(BuildContext context) {
    return Container(child: currentPage == PAGE_CREATE_NORMAL_ORDER
        ? CreateNormalOrderPage(normalOrder: normalOrder,)
        : ViewNormalOrderPage());
  }

  changePage(String pageName, {NormalOrder passedNormalOrder}){
    setState(() {
      currentPage = pageName;
      normalOrder = passedNormalOrder;
    });
  }
}
