import 'package:captain/db/model/statistics.dart';
import 'package:flutter/material.dart';
import 'package:random_color/random_color.dart';

class StatisticsCard extends StatelessWidget {
  final Statistics statistics;
  final RandomColor _randomColor = RandomColor();

  StatisticsCard(this.statistics);
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    statistics.title,
                    style: TextStyle(color: _randomColor.randomColor(colorHue: ColorHue.purple, colorBrightness: ColorBrightness.dark), fontSize: 11, fontWeight: FontWeight.w800),
                  ),

                 SizedBox(height: 20,),
                 Column(
                   crossAxisAlignment: CrossAxisAlignment.start,
                   children: [
                   Text(
                     statistics.stat,
                     style: TextStyle(fontWeight: FontWeight.w800, color: Colors.black87, fontSize: 17),
                   ),
                   Text(
                     statistics.subTitle,
                     style: TextStyle(fontSize: 9, color: _randomColor.randomColor(colorHue: ColorHue.orange)),
                   )
                 ],)
                ],
              ),
              Align(
                child: Icon(
                  statistics.iconData,
                  size: 16,
                  color: Theme.of(context).accentColor,
                ),
                alignment: Alignment.topRight,
              )
            ],
          ),
        ),
      ),
    );
  }
}
