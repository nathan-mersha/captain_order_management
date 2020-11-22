import 'package:captain/db/model/statistics.dart';
import 'package:captain/widget/statistics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class OverviewPage extends StatefulWidget {
  @override
  _OverviewPageState createState() => _OverviewPageState();
}

class _OverviewPageState extends State<OverviewPage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 645,
      child: Column(children: [

      Expanded(
          flex: 1,
          child: Row(children: [
        StatisticsCard(Statistics(stat: "1234")),
        StatisticsCard(Statistics(stat: "1234")),
        StatisticsCard(Statistics(stat: "1234")),

      ],)),

        Expanded(flex : 4, child: Row(children: [

          Expanded(flex : 1, child: Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(5))),
            child: Container(
              padding: EdgeInsets.only(bottom: 10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  SizedBox(
                    width: double.infinity,
                    child: Card(
                      margin: EdgeInsets.all(0),
                      color: Theme.of(context).primaryColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(5), topRight: Radius.circular(5))),
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        child: Text(
                          "Recently completed",
                          style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w800),
                        ),
                      ),
                    ),
                  ),
                  Container(
                      height: 445,
                      padding: EdgeInsets.only(right: 20, left: 20, top: 15),
                      child:Container()),

                ],
              ),
            ),
          )),

          Expanded(flex : 2, child: Column(children: [

            Expanded(flex : 2, child: Card()),
            Expanded(child: Row(children: [
              StatisticsCard(Statistics(stat: "1234")),
              StatisticsCard(Statistics(stat: "1234")),
            ],))

          ],),)



        ],),)

    ],),);
  }
}
