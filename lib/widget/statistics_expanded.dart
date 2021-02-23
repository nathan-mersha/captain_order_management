import 'package:captain/db/model/statistics.dart';
import 'package:flutter/material.dart';
import 'package:random_color/random_color.dart';

class StatisticsExpandedCard extends StatefulWidget {
  final Statistics statistics;

  final num getTotalStat;
  final num getTodayStat;
  final num getWeekStat;
  final num getMonthStat;
  final num getYearStat;

  StatisticsExpandedCard(this.statistics, {this.getTotalStat, this.getTodayStat, this.getWeekStat, this.getMonthStat, this.getYearStat});

  @override
  _StatisticsExpandedCardState createState() => _StatisticsExpandedCardState();
}

class _StatisticsExpandedCardState extends State<StatisticsExpandedCard> {
  final RandomColor _randomColor = RandomColor();

  TextStyle getStatStyle() {
    return TextStyle(fontWeight: FontWeight.w500, color: Colors.black87, fontSize: 13);
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    color: Theme.of(context).primaryColor,
                    padding: EdgeInsets.all(5),
                    child: Text(
                      widget.statistics.title,
                      style: TextStyle(
                          // color: _randomColor.randomColor(colorHue: ColorHue.blue, colorBrightness: ColorBrightness.dark),
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w800),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      widget.getTotalStat == null
                          ? Text(
                              widget.statistics.stat,
                              style: getStatStyle(),
                            )
                          : Text(widget.getTotalStat.toString(), style: getStatStyle()),
                      Text(
                        "total",
                        style: TextStyle(fontSize: 9, color: _randomColor.randomColor(colorHue: ColorHue.blue)),
                      )
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      widget.getTodayStat == null
                          ? Text(
                              widget.statistics.stat,
                              style: getStatStyle(),
                            )
                          : Text(widget.getTodayStat.toString(), style: getStatStyle()),
                      Text(
                        "today",
                        style: TextStyle(fontSize: 9, color: _randomColor.randomColor(colorHue: ColorHue.blue)),
                      )
                    ],
                  ),
                ],
              ),
              SizedBox(
                height: 18,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      widget.getWeekStat == null
                          ? Text(
                              widget.statistics.stat,
                              style: getStatStyle(),
                            )
                          : Text(widget.getWeekStat.toString(), style: getStatStyle()),
                      Text(
                        "week",
                        style: TextStyle(fontSize: 9, color: _randomColor.randomColor(colorHue: ColorHue.blue)),
                      )
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      widget.getMonthStat == null
                          ? Text(
                              widget.statistics.stat,
                              style: getStatStyle(),
                            )
                          : Text(widget.getMonthStat.toString(), style: getStatStyle()),
                      Text(
                        "month",
                        style: TextStyle(fontSize: 9, color: _randomColor.randomColor(colorHue: ColorHue.blue)),
                      )
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      widget.getYearStat == null
                          ? Text(
                              widget.statistics.stat,
                              style: getStatStyle(),
                            )
                          : Text(widget.getYearStat.toString(), style: getStatStyle()),
                      Text(
                        "year",
                        style: TextStyle(fontSize: 9, color: _randomColor.randomColor(colorHue: ColorHue.blue)),
                      )
                    ],
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
