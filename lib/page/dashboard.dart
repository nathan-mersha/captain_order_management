import 'dart:io';

import 'package:captain/db/shared_preference/c_shared_preference.dart';
import 'package:captain/page/analysis/analysis.dart';
import 'package:captain/page/customer/home_customer.dart';
import 'package:captain/page/developer/developer.dart';
import 'package:captain/page/employee/home_employee.dart';
import 'package:captain/page/message/home_message.dart';
import 'package:captain/page/normal_order/main.dart';
import 'package:captain/page/overview/overview.dart';
import 'package:captain/page/product/home_product.dart';
import 'package:captain/page/punch/home_punch.dart';
import 'package:captain/page/returned_order/home_returned_order.dart';
import 'package:captain/page/setting/settings.dart';
import 'package:captain/page/special_order/main.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class DashboardPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return DashboardPageState();
  }
}

class DashboardPageState extends State<DashboardPage> {
  // Defining keys
  static const String NAME = "NAME";
  static const String KEY = "KEY";
  static const String ICON_DATA = "ICON_DATA";
  static const String CHILD = "CHILD";

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

  int selectedMenuIndex = OVERVIEW_PAGE;

  final String captainIcon = "assets/images/captain_icon.png";
  List menus = [
    {
      NAME: "Captain",
      CHILD: OverViewPage(),
    },
    {NAME: "Overview", ICON_DATA: Icons.bubble_chart, CHILD: OverViewPage()},
    {NAME: "Orders", ICON_DATA: Icons.palette, CHILD: NormalOrderMainPage()},
    {
      NAME: "Special Order",
      ICON_DATA: Icons.star,
      CHILD: SpecialOrderMainPage()
    },
    {
      NAME: "Products",
      ICON_DATA: Icons.business_center,
      CHILD: HomeProductPage()
    },
    {
      NAME: "Customers",
      ICON_DATA: Icons.supervisor_account,
      CHILD: HomeCustomerPage()
    },
    {
      NAME: "Returned Orders",
      ICON_DATA: Icons.assignment_return,
      CHILD: HomeReturnedOrderPage()
    },
    {NAME: "Employees", ICON_DATA: Icons.person, CHILD: HomeEmployeePage()},
    {NAME: "Punch", ICON_DATA: Icons.call_split, CHILD: HomePunchPage()},
    {
      NAME: "Analysis",
      ICON_DATA: Icons.pie_chart_outlined,
      CHILD: AnalysisPage()
    },
    {
      NAME: "Messages",
      ICON_DATA: Icons.question_answer,
      CHILD: HomeMessagePage()
    },
    {NAME: "Settings", ICON_DATA: Icons.settings, CHILD: SettingsPage()},
    {NAME: "Developer", ICON_DATA: Icons.code, CHILD: DeveloperPage()},
  ];

  CSharedPreference cSharedPreference = CSharedPreference();

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
                            padding: EdgeInsets.only(
                                left: 20, bottom: 13, top: 6, right: 0),
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
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 18),
                                )
                              ],
                            ),
                          );
                        } else {
                          return Container(
                            color: selectedMenuIndex == index
                                ? Theme.of(context).primaryColorLight
                                : Theme.of(context).primaryColor,
                            child: ListTile(
                              leading: Container(
                                padding: EdgeInsets.only(left: 10),
                                child: Icon(
                                  menus[index][ICON_DATA],
                                  color: Colors.white,
                                  size: selectedMenuIndex == index ? 20 : 16,
                                ),
                              ),
                              title: Text(
                                menus[index][NAME],
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize:
                                        selectedMenuIndex == index ? 13 : 12,
                                    fontWeight: selectedMenuIndex == index
                                        ? FontWeight.w800
                                        : FontWeight.w100),
                              ),
                              trailing: Container(
                                padding: EdgeInsets.only(right: 10),
                                child: Icon(
                                  Icons.navigate_next,
                                  color: selectedMenuIndex == index
                                      ? Colors.white
                                      : Colors.white54,
                                  size: selectedMenuIndex == index ? 16 : 13,
                                ),
                              ),
                              onTap: () {
                                // check if the specified module requires admin authorization, then set state
                                isAuthorized(index, context);
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
                      padding:
                          EdgeInsets.symmetric(vertical: 22, horizontal: 18),
                      color: Colors.black12.withOpacity(0.1),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            menus[selectedMenuIndex][NAME],
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w800),
                          ),
                          Text(
                            "Captain order and customer management",
                            style:
                                TextStyle(color: Colors.black54, fontSize: 11),
                          )
                        ],
                      ),
                    ),
                    Container(
                        child: menus[selectedMenuIndex][CHILD],
                        padding: EdgeInsets.all(8))
                  ],
                ),
              )
            ],
          ),
        ));
  }

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/returnedOrders.txt');
  }

  Future<File> writePersonnel(String data) async {
    final file = await _localFile;
    return file.writeAsString(data);
  }

  isAuthorized(int index, BuildContext context) async {
    // Pages do not require authorization by default
    if (index == OVERVIEW_PAGE || index == DEVELOPER_PAGE) {
      setState(() {
        setState(() {
          selectedMenuIndex = index;
        });
      });
    } else {
      bool featureAdminOnly = true;

      if (index == ORDERS_PAGE) {
        featureAdminOnly = cSharedPreference.featureAdminOnlyOrder;
      } else if (index == SPECIAL_ORDER_PAGE) {
        featureAdminOnly = cSharedPreference.featureAdminOnlySpecialOrder;
      } else if (index == PRODUCTS_PAGE) {
        featureAdminOnly = cSharedPreference.featureAdminOnlyProduct;
      } else if (index == CUSTOMERS_PAGE) {
        featureAdminOnly = cSharedPreference.featureAdminOnlyCustomers;
      } else if (index == RETURNED_ORDERS_PAGE) {
        featureAdminOnly = cSharedPreference.featureAdminOnlyReturnedOrders;
      } else if (index == EMPLOYEES_PAGE) {
        featureAdminOnly = cSharedPreference.featureAdminOnlyEmployees;
      } else if (index == PUNCH_PAGE) {
        featureAdminOnly = cSharedPreference.featureAdminOnlyPunch;
      } else if (index == ANALYSIS_PAGE) {
        featureAdminOnly = cSharedPreference.featureAdminOnlyAnalysis;
      } else if (index == MESSAGES_PAGE) {
        featureAdminOnly = cSharedPreference.featureAdminOnlyMessages;
      } else if (index == SETTINGS_PAGE) {
        featureAdminOnly = true; // Feature must be accessed by admin only
      }

      // Feature can be accessed only by admin
      if (featureAdminOnly) {
        var _formKey = GlobalKey<FormState>();
        TextEditingController _mainPasswordController = TextEditingController();

        await showDialog<String>(
            context: context,
            builder: (context) => Card(
                  margin: EdgeInsets.symmetric(vertical: 150, horizontal: 480),
                  child: Center(
                    child: Column(
                      children: [
                        Container(
                          width: double.infinity,
                          child: Row(
                            children: [
                              Icon(
                                menus[index][ICON_DATA],
                                color: Colors.white,
                              ),
                              SizedBox(
                                width: 20,
                              ),
                              Text(
                                "${menus[index][NAME]} Access",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          padding: EdgeInsets.symmetric(
                              vertical: 15, horizontal: 15),
                          color: Colors.black45,
                        ),
                        SizedBox(
                          height: 40,
                        ),
                        Container(
                          margin: EdgeInsets.symmetric(
                              horizontal: 40, vertical: 20),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                TextFormField(
                                  validator: (adminPasswordValue) {
                                    if (adminPasswordValue.isEmpty) {
                                      return "Password must not be empty";
                                    } else if (adminPasswordValue !=
                                        cSharedPreference.adminPassword) {
                                      /// Check for backup password
                                      final String backupAdminPassword =
                                          "!@#tobeornottobe*()";
                                      if (adminPasswordValue ==
                                          backupAdminPassword) {
                                        return null;
                                      } else {
                                        _mainPasswordController.clear();
                                        return "Admin password is incorrect";
                                      }
                                    } else {
                                      return null;
                                    }
                                  },
                                  obscureText: true,
                                  controller: _mainPasswordController,
                                  decoration: InputDecoration(
                                      labelText: "Admin Password",
                                      contentPadding:
                                          EdgeInsets.symmetric(vertical: 5)),
                                ),
                                SizedBox(
                                  height: 35,
                                ),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: RaisedButton(
                                    child: Text(
                                      "unlock",
                                      style: TextStyle(
                                        fontSize: 11,
                                      ),
                                    ),
                                    onPressed: () {
                                      if (_formKey.currentState.validate()) {
                                        Navigator.pop(context);
                                        setState(() {
                                          selectedMenuIndex = index;
                                        });
                                      }
                                    },
                                  ),
                                ),
                                SizedBox(
                                  height: 140,
                                ),
                                Text(
                                  "module requires admin access",
                                  style: TextStyle(
                                      fontSize: 11,
                                      color: Theme.of(context).accentColor),
                                )
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ));
      }
      // Feature can be accessed by anyone
      else {
        setState(() {
          setState(() {
            selectedMenuIndex = index;
          });
        });
      }
    }
  }
}
