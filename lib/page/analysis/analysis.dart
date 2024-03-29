import 'package:captain/page/analysis/stats/color.dart';
import 'package:captain/page/analysis/stats/customer/customer.dart';
import 'package:captain/page/analysis/stats/employee.dart';
import 'package:captain/page/analysis/stats/manufacturer.dart';
import 'package:captain/page/analysis/stats/product.dart';
import 'package:captain/page/analysis/stats/order/normal_order.dart';
import 'package:captain/page/analysis/stats/punch.dart';
import 'package:captain/page/analysis/stats/returned_order.dart';
import 'package:captain/page/analysis/stats/sales.dart';
import 'package:flutter/material.dart';

class AnalysisPage extends StatefulWidget {
  @override
  _AnalysisPageState createState() => _AnalysisPageState();
}

class _AnalysisPageState extends State<AnalysisPage> {
  // Defining keys
  static const String NAME = "NAME";
  static const String DESCRIPTION = "DESCRIPTION";
  static const String ICON = "ICON";
  static const String CHILD = "CHILD";

  // static const int RETURNED_ORDER = 0;
  // static const int COLOR = 1;
  static const int PRODUCT = 2;
  // static const int EMPLOYEE = 3;
  // static const int MANUFACTURER = 4;
  // static const int CUSTOMER = 5;
  // static const int PUNCH = 6;
  // static const int SALES = 7;

  int selectedMenuIndex = PRODUCT;
  List menus = [
    {NAME: "Returned", DESCRIPTION: "Return counts of product", ICON: Icons.assignment_return, CHILD: ReturnedOrderAnalysis()},
    {NAME: "Color", DESCRIPTION: "Color codes by sale", ICON: Icons.color_lens, CHILD: ColorAnalysis()},
    {NAME: "Product", DESCRIPTION: "Which product is being sold", ICON: Icons.business_center, CHILD: ProductAnalysis()},
    {NAME: "Employee", DESCRIPTION: "Employees grade by returns", ICON: Icons.person, CHILD: EmployeeAnalysis()},
    {NAME: "Order", DESCRIPTION: "Products sold data", ICON: Icons.request_page, CHILD: ProductSoldNormalOrderAnalysis()},
    {NAME: "Customer", DESCRIPTION: "Customers by address", ICON: Icons.supervisor_account, CHILD: CustomerAnalysis()},
    {NAME: "Punch", DESCRIPTION: "Punch in/out by employee", ICON: Icons.call_split, CHILD: PunchAnalysis()},
    {NAME: "Sales", DESCRIPTION: "Customers are buying products", ICON: Icons.supervisor_account, CHILD: SalesAnalysis()},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 645,
      child: Column(
        children: [
          // Menus section
          Expanded(
              flex: 1,
              child: Container(
                child: GridView.builder(
                  scrollDirection: Axis.vertical,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 8),
                  itemCount: menus.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedMenuIndex = index;
                        });
                      },
                      child: Card(
                        elevation: isSelected(index) ? 3 : 0.5,
                        color: isSelected(index) ? Theme.of(context).primaryColor : Colors.white,
                        child: Container(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                  child: Column(
                                children: [
                                  Text(
                                    menus[index][NAME],
                                    style: TextStyle(
                                        fontSize: isSelected(index) ? 13 : 12,
                                        color: isSelected(index) ? Colors.white : Theme.of(context).primaryColor,
                                        fontWeight: isSelected(index) ? FontWeight.w600 : FontWeight.w200),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        menus[index][DESCRIPTION],
                                        style: TextStyle(fontSize: 10, color: isSelected(index) ? Colors.white : Colors.black54),
                                        textAlign: TextAlign.left,
                                      ),
                                    ],
                                  )
                                ],
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              )),
                              Icon(
                                menus[index][ICON],
                                size: isSelected(index) ? 21 : 15,
                                color: isSelected(index) ? Colors.white : Theme.of(context).primaryColor,
                              )
                            ],
                          ),
                          padding: EdgeInsets.all(8),
                        ),
                      ),
                    );
                  },
                ),
              )),

          Expanded(flex: 4, child: menus[selectedMenuIndex][CHILD])
        ],
      ),
    );
  }

  bool isSelected(int index) => selectedMenuIndex == index;
}
