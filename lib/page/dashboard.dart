import 'package:captain/page/analysis.dart';
import 'package:captain/page/customers.dart';
import 'package:captain/page/developer.dart';
import 'package:captain/page/employees.dart';
import 'package:captain/page/messages.dart';
import 'package:captain/page/orders.dart';
import 'package:captain/page/overview.dart';
import 'package:captain/page/products.dart';
import 'package:captain/page/punch.dart';
import 'package:captain/page/returned_orders.dart';
import 'package:captain/page/settings.dart';
import 'package:captain/page/special_orders.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DashboardPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return DashboardPageState();
  }
}

class DashboardPageState extends State<DashboardPage> {
  int selectedMenuIndex = 7; // todo : change index to 1 over view page selected by default
  List menus = [
    {
      "name": "Captain",
      "child": OverviewPage(),
    },
    {"name": "Overview", "iconData": Icons.bubble_chart, "child": OverviewPage()},
    {"name": "Orders", "iconData": Icons.palette, "child": OrdersPage()},
    {"name": "Special Order", "iconData": Icons.star, "child": SpecialOrdersPage()},
    {"name": "Products", "iconData": Icons.business_center, "child": ProductsPage()},
    {"name": "Customers", "iconData": Icons.supervisor_account, "child": CustomersPage()},
    {"name": "Returned Orders", "iconData": Icons.assignment_return, "child": ReturnedOrdersPage()},
    {"name": "Employees", "iconData": Icons.person, "child": EmployeesPage()},
    {"name": "Punch", "iconData": Icons.call_split, "child": PunchPage()},
    {"name": "Analysis", "iconData": Icons.pie_chart_outlined, "child": AnalysisPage()},
    {"name": "Messages", "iconData": Icons.question_answer, "child": MessagesPage()},
    {"name": "Settings", "iconData": Icons.settings, "child": SettingsPage()},
    {"name": "Developer", "iconData": Icons.code, "child": DeveloperPage()},
  ];

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      resizeToAvoidBottomInset: false,
      body: Row(
        children: <Widget>[
          Expanded(
              flex: 2,
              child: Drawer(
                  child: Container(
                color: Theme.of(context).primaryColor,
                child: ListView.builder(
                  itemCount: menus.length,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return Container(
                        padding: EdgeInsets.only(left: 10, bottom: 14, top: 6, right: 0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Image.asset(
                              "assets/images/captain_icon.png",
                              scale: 10,
                            ),
                            SizedBox(
                              width: 30,
                            ),
                            Text(
                              "Captain",
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 18),
                            )
                          ],
                        ),
                      );
                    } else {
                      return Container(
                        color: selectedMenuIndex == index ? Theme.of(context).primaryColorLight : Theme.of(context).primaryColor,
                        child: ListTile(
                          leading: Icon(
                            menus[index]["iconData"],
                            color: Colors.white,
                            size: selectedMenuIndex == index ? 20 : 16,
                          ),
                          title: Text(
                            menus[index]["name"],
                            style: TextStyle(color: Colors.white, fontSize: selectedMenuIndex == index ? 13 : 12, fontWeight: selectedMenuIndex == index ? FontWeight.w800 : FontWeight.w100),
                          ),
                          trailing: Icon(
                            Icons.navigate_next,
                            color: Colors.white,
                            size: selectedMenuIndex == index ? 16 : 13,
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
            flex: 7,
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
                        style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w800),
                      ),
                      Text(
                        "Captain order and customer management",
                        style: TextStyle(color: Colors.black54, fontSize: 11),
                      )
                    ],
                  ),
                ),
                Container(child: menus[selectedMenuIndex]["child"],margin: EdgeInsets.all(8),)
              ],
            ),
          )
        ],
      ),
    );
  }
}
