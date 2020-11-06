import 'package:captain/page/analysis/analysis.dart';
import 'package:captain/page/customer/home_customer.dart';
import 'package:captain/page/developer/developer.dart';
import 'package:captain/page/employee/home_employee.dart';
import 'package:captain/page/message/messages.dart';
import 'package:captain/page/order/orders.dart';
import 'package:captain/page/overview/overview.dart';
import 'package:captain/page/product/home_product.dart';
import 'package:captain/page/punch/punch.dart';
import 'package:captain/page/returned_order/returned_orders.dart';
import 'package:captain/page/setting/settings.dart';
import 'package:captain/page/special_order/special_orders.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DashboardPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return DashboardPageState();
  }
}

class DashboardPageState extends State<DashboardPage> {
  static const int OVERVIEW_PAGE = 1;
  static const int ORDERS_PAGE = 2;
  static const int SPECIAL_ORDER_PAGE = 3;
  static const int PRODUCTS_PAGE = 4;
  static const int CUSTOMERS_PAGE = 5;
  static const int RETURNED_ORDERS_PAGE = 6;
  static const int EMPLOYEES_PAGE = 7;
  static const int PUNCH_PAGE = 8;
  static const int ANALYSIS_PAGE = 9;
  static const int MESSAGES_PAGE = 10;
  static const int SETTINGS_PAGE = 11;
  static const int DEVELOPER_PAGE = 12;

//  int selectedMenuIndex = OVERVIEW_PAGE; // todo Uncomment for final release
  int selectedMenuIndex = PRODUCTS_PAGE;

  final String captainIcon = "assets/images/captain_icon.png";
  List menus = [
    {
      "name": "Captain",
      "child": OverviewPage(),
    },
    {"name": "Overview", "iconData": Icons.bubble_chart, "child": OverviewPage()},
    {"name": "Orders", "iconData": Icons.palette, "child": OrdersPage()},
    {"name": "Special Order", "iconData": Icons.star, "child": SpecialOrdersPage()},
    {"name": "Products", "iconData": Icons.business_center, "child": HomeProductPage()},
    {"name": "Customers", "iconData": Icons.supervisor_account, "child": HomeCustomerPage()},
    {"name": "Returned Orders", "iconData": Icons.assignment_return, "child": ReturnedOrdersPage()},
    {"name": "Employees", "iconData": Icons.person, "child": HomeEmployeePage()},
    {"name": "Punch", "iconData": Icons.call_split, "child": PunchPage()},
    {"name": "Analysis", "iconData": Icons.pie_chart_outlined, "child": AnalysisPage()},
    {"name": "Messages", "iconData": Icons.question_answer, "child": MessagesPage()},
    {"name": "Settings", "iconData": Icons.settings, "child": SettingsPage()},
    {"name": "Developer", "iconData": Icons.code, "child": DeveloperPage()},
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        top: true,
        child: Scaffold(
          backgroundColor: Theme.of(context).backgroundColor,
          resizeToAvoidBottomInset: false,
          body: Row(
            children: <Widget>[
              Expanded(
                  flex: 2,
                  child: Drawer(
                      child: Container(
                    padding: EdgeInsets.only(top: 12),
                    color: Theme.of(context).primaryColor,
                    child: ListView.builder(
                      itemCount: menus.length,
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          return Container(
                            padding: EdgeInsets.only(left: 20, bottom: 13, top: 6, right: 0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Image.asset(
                                  captainIcon,
                                  scale: 9,
                                ),
                                SizedBox(
                                  width: 17,
                                ),
                                Text(
                                  "Captain",
                                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 18),
                                )
                              ],
                            ),
                          );
                        } else {
                          return Container(
                            color: selectedMenuIndex == index ? Theme.of(context).primaryColorLight : Theme.of(context).primaryColor,
                            child: ListTile(
                              leading: Container(
                                padding: EdgeInsets.only(left: 10),
                                child: Icon(
                                  menus[index]["iconData"],
                                  color: Colors.white,
                                  size: selectedMenuIndex == index ? 20 : 16,
                                ),
                              ),
                              title: Text(
                                menus[index]["name"],
                                style: TextStyle(color: Colors.white, fontSize: selectedMenuIndex == index ? 13 : 12, fontWeight: selectedMenuIndex == index ? FontWeight.w800 : FontWeight.w100),
                              ),
                              trailing: Container(
                                padding: EdgeInsets.only(right: 10),
                                child: Icon(
                                  Icons.navigate_next,
                                  color: selectedMenuIndex == index ? Colors.white : Colors.white54,
                                  size: selectedMenuIndex == index ? 16 : 13,
                                ),
                              ),
                              onTap: () {
                                setState(() {
                                  selectedMenuIndex = index;
                                });
                              },
                            ),
                          );
                        }
                      },
                    ),
                  ))),
              Expanded(
                flex: 8,
                child: Column(
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.symmetric(vertical: 22, horizontal: 18),
                      color: Colors.black12.withOpacity(0.1),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            menus[selectedMenuIndex]["name"],
                            style: TextStyle(color: Colors.black, fontWeight: FontWeight.w800),
                          ),
                          Text(
                            "Captain order and customer management",
                            style: TextStyle(color: Colors.black54, fontSize: 11),
                          )
                        ],
                      ),
                    ),
                    Container(child: menus[selectedMenuIndex]["child"], padding: EdgeInsets.all(8))
                  ],
                ),
              )
            ],
          ),
        ));
  }
}
