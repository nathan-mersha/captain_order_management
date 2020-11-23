import 'package:captain/db/dal/normal_order.dart';
import 'package:captain/db/dal/personnel.dart';
import 'package:captain/db/dal/returned_order.dart';
import 'package:captain/db/model/normal_order.dart';
import 'package:captain/db/model/personnel.dart';
import 'package:captain/db/model/returned_order.dart';
import 'package:captain/db/model/statistics.dart';
import 'package:captain/page/analysis/stats/color.dart';
import 'package:captain/widget/statistics.dart';
import 'package:flutter/material.dart';

class OverViewPage extends StatefulWidget {
  @override
  _OverViewPageState createState() => _OverViewPageState();
}

class _OverViewPageState extends State<OverViewPage> {
  num totalOrders = 0;
  num totalCustomers = 0;
  num totalReturnedOrders = 0;

  @override
  Widget build(BuildContext context) {
    return Container(
        height: 645,
        child: Column(
          children: [
            Expanded(
                flex: 1,
                child: Row(
                  children: [
                    StatisticsCard(Statistics(stat: totalOrders.toString(), title: "Orders", subTitle: "total order", iconData: Icons.color_lens)),
                    StatisticsCard(Statistics(stat: totalCustomers.toString(), title: "Cusotmers", subTitle: "total customers", iconData: Icons.supervisor_account)),
                    StatisticsCard(Statistics(stat: totalReturnedOrders.toString(), title: "Returned Orders", subTitle: "total returned orders", iconData: Icons.assignment_return)),
                  ],
                )),
            Expanded(flex: 4, child: ColorAnalysis())
          ],
        ));
  }

  Future getStat() async {
    List<NormalOrder> normalOrders = await NormalOrderDAL.find();
    String where = "${Personnel.TYPE} = ?";
    List<String> whereArgs = [Personnel.CUSTOMER]; // Querying only customers
    List<Personnel> customers = await PersonnelDAL.find(
      where: where,
      whereArgs: whereArgs,
    );
    List<ReturnedOrder> returnOrders = await ReturnedOrderDAL.find();

    totalOrders = normalOrders.length;
    totalCustomers = customers.length;
    totalReturnedOrders = returnOrders.length;

    return true;
  }
}
