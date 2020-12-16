import 'package:captain/db/model/statistics.dart';
import 'package:captain/page/punch/create_punch.dart';
import 'package:captain/page/punch/view_punch.dart';
import 'package:captain/widget/statistics.dart';
import 'package:flutter/material.dart';

class StatisticsPunchView extends StatefulWidget {
  final GlobalKey<CreatePunchViewState> createPunchKey;
  final GlobalKey<StatisticsPunchViewState> statisticsPunchKey;
  final GlobalKey<PunchTableState> punchTableKey;

  const StatisticsPunchView(
      {this.punchTableKey, this.createPunchKey, this.statisticsPunchKey})
      : super(key: statisticsPunchKey);

  @override
  StatisticsPunchViewState createState() => StatisticsPunchViewState();
}

class StatisticsPunchViewState extends State<StatisticsPunchView> {
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
