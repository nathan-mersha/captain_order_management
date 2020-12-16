import 'package:captain/db/model/statistics.dart';
import 'package:captain/page/customer/create_customer.dart';
import 'package:captain/page/customer/view_customer.dart';
import 'package:captain/widget/statistics.dart';
import 'package:flutter/material.dart';

class StatisticsSpecialOrderView extends StatefulWidget {
  final GlobalKey<CreateCustomerViewState> createCustomerKey;
  final GlobalKey<StatisticsSpecialOrderViewState> statisticsCustomerKey;
  final GlobalKey<CustomerTableState> customerTableKey;

  const StatisticsSpecialOrderView(
      {this.customerTableKey,
      this.createCustomerKey,
      this.statisticsCustomerKey})
      : super(key: statisticsCustomerKey);

  @override
  StatisticsSpecialOrderViewState createState() =>
      StatisticsSpecialOrderViewState();
}

class StatisticsSpecialOrderViewState
    extends State<StatisticsSpecialOrderView> {
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
