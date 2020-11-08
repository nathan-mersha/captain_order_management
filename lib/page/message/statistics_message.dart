import 'package:captain/db/model/statistics.dart';
import 'package:captain/page/message/create_message.dart';
import 'package:captain/page/message/view_message.dart';
import 'package:captain/widget/statistics.dart';
import 'package:flutter/material.dart';

class StatisticsMessageView extends StatefulWidget {
  final GlobalKey<CreateMessageViewState> createMessageKey;
  final GlobalKey<StatisticsMessageViewState> statisticsMessageKey;
  final GlobalKey<MessageTableState> messageTableKey;

  const StatisticsMessageView({this.messageTableKey, this.createMessageKey, this.statisticsMessageKey}) : super(key: statisticsMessageKey);

  @override
  StatisticsMessageViewState createState() => StatisticsMessageViewState();
}

class StatisticsMessageViewState extends State<StatisticsMessageView> {
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
