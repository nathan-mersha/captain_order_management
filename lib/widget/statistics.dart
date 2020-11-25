import 'dart:math';

import 'package:captain/db/model/statistics.dart';
import 'package:flutter/material.dart';
import 'package:random_color/random_color.dart';

class StatisticsCard extends StatefulWidget {
  final Statistics statistics;
  final Future<num> getStat;

  StatisticsCard(this.statistics, {this.getStat});


  @override
  _StatisticsCardState createState() => _StatisticsCardState();
}

class _StatisticsCardState extends State<StatisticsCard> {

  final RandomColor _randomColor = RandomColor();

  TextStyle getStatStyle(){
    return TextStyle(fontWeight: FontWeight.w800, color: Colors.black87, fontSize: 17);
  }
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
                    widget.statistics.title,
                    style: TextStyle(color: _randomColor.randomColor(colorHue: ColorHue.purple, colorBrightness: ColorBrightness.dark), fontSize: 11, fontWeight: FontWeight.w800),
                  ),

                  SizedBox(height: 20,),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      widget.getStat == null
                          ? Text(
                        widget.statistics.stat,
                        style: getStatStyle(),
                      ) : FutureBuilder(future: widget.getStat, initialData: 0,builder: (BuildContext context, AsyncSnapshot snapshot){
                          if(snapshot.connectionState == ConnectionState.done){
                            return Text(snapshot.data.toString(), style: getStatStyle());
                          }else {
                            return Text("0", style: getStatStyle(),);
                          }

                      },),
                      Text(
                        widget.statistics.subTitle,
                        style: TextStyle(fontSize: 9, color: _randomColor.randomColor(colorHue: ColorHue.orange)),
                      )
                    ],)
                ],
              ),
              Align(
                child: Icon(
                  widget.statistics.iconData,
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
