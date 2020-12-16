import 'package:captain/db/model/statistics.dart';
import 'package:captain/page/customer/create_customer.dart';
import 'package:captain/page/customer/view_customer.dart';
import 'package:captain/widget/statistics.dart';
import 'package:flutter/material.dart';

class StatisticsNormalOrderView extends StatefulWidget {
  final GlobalKey<CreateCustomerViewState> createCustomerKey;
  final GlobalKey<StatisticsNormalOrderViewState> statisticsCustomerKey;
  final GlobalKey<CustomerTableState> customerTableKey;

  const StatisticsNormalOrderView(
      {this.customerTableKey,
      this.createCustomerKey,
      this.statisticsCustomerKey})
      : super(key: statisticsCustomerKey);

  @override
  StatisticsNormalOrderViewState createState() =>
      StatisticsNormalOrderViewState();
}

class StatisticsNormalOrderViewState extends State<StatisticsNormalOrderView> {
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
