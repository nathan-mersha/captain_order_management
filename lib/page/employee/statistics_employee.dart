import 'package:captain/db/model/statistics.dart';
import 'package:captain/widget/statistics.dart';
import 'package:flutter/material.dart';

class StatisticsEmployeeView extends StatefulWidget {
  @override
  StatisticsEmployeeViewState createState() => StatisticsEmployeeViewState();
}

class StatisticsEmployeeViewState extends State<StatisticsEmployeeView> {

  void doSomething(){
    print("doing something");
  }
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
