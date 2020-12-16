import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Statistics {
  String title;
  IconData iconData;
  String stat;
  String subTitle;

  Statistics(
      {this.title = "statistics",
      this.iconData = Icons.show_chart,
      this.stat = "-",
      this.subTitle = "unknown"});
}
