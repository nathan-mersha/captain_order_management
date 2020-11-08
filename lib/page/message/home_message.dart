import 'package:captain/page/message/create_message.dart';
import 'package:captain/page/message/statistics_message.dart';
import 'package:captain/page/message/view_message.dart';
import 'package:flutter/material.dart';

class HomeMessagePage extends StatefulWidget {
  @override
  HomeMessagePageState createState() => HomeMessagePageState();
}

class HomeMessagePageState extends State<HomeMessagePage> with SingleTickerProviderStateMixin {
  // Global keys for views
  GlobalKey<MessageTableState> messageTableKey = GlobalKey();
  GlobalKey<CreateMessageViewState> createMessageKey = GlobalKey();
  GlobalKey<StatisticsMessageViewState> statisticsMessageKey = GlobalKey();

  void doSomethingFromParent() {}
  @override
  Widget build(BuildContext context) {
    return Container(
        child: Column(
      children: <Widget>[
        // Statistics view
        StatisticsMessageView(
          messageTableKey: messageTableKey,
          createMessageKey: createMessageKey,
          statisticsMessageKey: statisticsMessageKey,
        ),
        Container(
          margin: EdgeInsets.only(top: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                flex: 3,
                child: CreateMessageView(
                  messageTableKey: messageTableKey,
                  createMessageKey: createMessageKey,
                  statisticsMessageKey: statisticsMessageKey,
                ), // Create message view
              ),
              SizedBox(
                width: 5,
              ),
              Expanded(
                flex: 7,
                child: MessageTable(
                  messageTableKey: messageTableKey,
                  createMessageKey: createMessageKey,
                  statisticsMessageKey: statisticsMessageKey,
                ), // View messages page
              ),
            ],
          ),
        )
      ],
    ));
  }
}
