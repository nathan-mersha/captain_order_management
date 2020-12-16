import 'package:captain/page/returned_order/create_returned_order.dart';
import 'package:captain/page/returned_order/statistics_returned_order.dart';
import 'package:captain/page/returned_order/view_returned_order.dart';
import 'package:flutter/material.dart';

class HomeReturnedOrderPage extends StatefulWidget {
  @override
  HomeReturnedOrderPageState createState() => HomeReturnedOrderPageState();
}

class HomeReturnedOrderPageState extends State<HomeReturnedOrderPage>
    with SingleTickerProviderStateMixin {
  // Global keys for views
  GlobalKey<ReturnedOrderTableState> returnedOrderTableKey = GlobalKey();
  GlobalKey<CreateReturnedOrderViewState> createReturnedOrderKey = GlobalKey();
  GlobalKey<StatisticsReturnedOrderViewState> statisticsReturnedOrderKey =
      GlobalKey();

  void doSomethingFromParent() {}
  @override
  Widget build(BuildContext context) {
    return Container(
        child: Column(
      children: <Widget>[
        // Statistics view
        StatisticsReturnedOrderView(
          returnedOrderTableKey: returnedOrderTableKey,
          createReturnedOrderKey: createReturnedOrderKey,
          statisticsReturnedOrderKey: statisticsReturnedOrderKey,
        ),
        Container(
          margin: EdgeInsets.only(top: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                flex: 3,
                child: CreateReturnedOrderView(
                  returnedOrderTableKey: returnedOrderTableKey,
                  createReturnedOrderKey: createReturnedOrderKey,
                  statisticsReturnedOrderKey: statisticsReturnedOrderKey,
                ), // Create returnedOrder view
              ),
              SizedBox(
                width: 5,
              ),
              Expanded(
                flex: 7,
                child: ReturnedOrderTable(
                  returnedOrderTableKey: returnedOrderTableKey,
                  createReturnedOrderKey: createReturnedOrderKey,
                  statisticsReturnedOrderKey: statisticsReturnedOrderKey,
                ), // View returnedOrders page
              ),
            ],
          ),
        )
      ],
    ));
  }
}
