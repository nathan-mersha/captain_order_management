import 'package:captain/db/model/statistics.dart';
import 'package:captain/page/product/create_product.dart';
import 'package:captain/page/product/view_product.dart';
import 'package:captain/widget/statistics.dart';
import 'package:flutter/material.dart';

class StatisticsProductView extends StatefulWidget {
  final GlobalKey<CreateProductViewState> createProductKey;
  final GlobalKey<StatisticsProductViewState> statisticsProductKey;
  final GlobalKey<ProductTableState> productTableKey;

  const StatisticsProductView({this.productTableKey, this.createProductKey, this.statisticsProductKey}) : super(key: statisticsProductKey);

  @override
  StatisticsProductViewState createState() => StatisticsProductViewState();
}

class StatisticsProductViewState extends State<StatisticsProductView> {
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
