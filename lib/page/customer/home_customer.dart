import 'package:captain/page/customer/create_customer.dart';
import 'package:captain/page/customer/statistics_customer.dart';
import 'package:captain/page/customer/view_customer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class HomeCustomerPage extends StatefulWidget {
  @override
  HomeCustomerPageState createState() => HomeCustomerPageState();
}

class HomeCustomerPageState extends State<HomeCustomerPage> with SingleTickerProviderStateMixin {
  // Global keys for views
  GlobalKey<CustomerTableState> customerTableKey = GlobalKey();
  GlobalKey<CreateCustomerViewState> createCustomerKey = GlobalKey();
  GlobalKey<StatisticsCustomerViewState> statisticsCustomerKey = GlobalKey();

  void doSomethingFromParent() {}
  @override
  Widget build(BuildContext context) {
    return Container(
        child: Column(
      children: <Widget>[
        // Statistics view
        StatisticsCustomerView(
          customerTableKey: customerTableKey,
          createCustomerKey: createCustomerKey,
          statisticsCustomerKey: statisticsCustomerKey,

        ),
        Container(
          margin: EdgeInsets.only(top: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                flex: 3,
                child: CreateCustomerView(
                  customerTableKey: customerTableKey,
                  createCustomerKey: createCustomerKey,
                  statisticsCustomerKey: statisticsCustomerKey,
                ), // Create customer view
              ),
              SizedBox(
                width: 5,
              ),
              Expanded(
                flex: 7,
                child: CustomerTable(
                  customerTableKey: customerTableKey,
                  createCustomerKey: createCustomerKey,
                  statisticsCustomerKey: statisticsCustomerKey,
                ), // View customers page
              ),
            ],
          ),
        )
      ],
    ));
  }
}
