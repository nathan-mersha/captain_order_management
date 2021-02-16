import 'package:captain/db/model/statistics.dart';
import 'package:captain/page/returned_order/create_returned_order.dart';
import 'package:captain/page/returned_order/view_returned_order.dart';
import 'package:captain/widget/statistics.dart';
import 'package:flutter/material.dart';

class StatisticsReturnedOrderView extends StatefulWidget {
  final GlobalKey<CreateReturnedOrderViewState> createReturnedOrderKey;
  final GlobalKey<StatisticsReturnedOrderViewState> statisticsReturnedOrderKey;
  final GlobalKey<ReturnedOrderTableState> returnedOrderTableKey;

  const StatisticsReturnedOrderView({this.returnedOrderTableKey, this.createReturnedOrderKey, this.statisticsReturnedOrderKey})
      : super(key: statisticsReturnedOrderKey);

  @override
  StatisticsReturnedOrderViewState createState() => StatisticsReturnedOrderViewState();
}

class StatisticsReturnedOrderViewState extends State<StatisticsReturnedOrderView> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        StatisticsCard(Statistics(stat: "1234")),
        StatisticsCard(Statistics(stat: "44")),
        StatisticsCard(Statistics(stat: "342")),
        StatisticsCard(Statistics(stat: "12")),
        StatisticsCard(Statistics(stat: "0")),
      ],
    );
  }
}
