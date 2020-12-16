import 'package:captain/page/punch/create_punch.dart';
import 'package:captain/page/punch/statistics_punch.dart';
import 'package:captain/page/punch/view_punch.dart';
import 'package:flutter/material.dart';

class HomePunchPage extends StatefulWidget {
  @override
  HomePunchPageState createState() => HomePunchPageState();
}

class HomePunchPageState extends State<HomePunchPage>
    with SingleTickerProviderStateMixin {
  // Global keys for views
  GlobalKey<PunchTableState> punchTableKey = GlobalKey();
  GlobalKey<CreatePunchViewState> createPunchKey = GlobalKey();
  GlobalKey<StatisticsPunchViewState> statisticsPunchKey = GlobalKey();

  void doSomethingFromParent() {}
  @override
  Widget build(BuildContext context) {
    return Container(
        child: Column(
      children: <Widget>[
        // Statistics view
        StatisticsPunchView(
          punchTableKey: punchTableKey,
          createPunchKey: createPunchKey,
          statisticsPunchKey: statisticsPunchKey,
        ),
        Container(
          margin: EdgeInsets.only(top: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                flex: 3,
                child: CreatePunchView(
                  punchTableKey: punchTableKey,
                  createPunchKey: createPunchKey,
                  statisticsPunchKey: statisticsPunchKey,
                ), // Create punch view
              ),
              SizedBox(
                width: 5,
              ),
              Expanded(
                flex: 7,
                child: PunchTable(
                  punchTableKey: punchTableKey,
                  createPunchKey: createPunchKey,
                  statisticsPunchKey: statisticsPunchKey,
                ), // View punchs page
              ),
            ],
          ),
        )
      ],
    ));
  }
}
