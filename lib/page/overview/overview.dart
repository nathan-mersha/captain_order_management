import 'package:captain/db/dal/normal_order.dart';
import 'package:captain/db/dal/personnel.dart';
import 'package:captain/db/dal/punch.dart';
import 'package:captain/db/dal/returned_order.dart';
import 'package:captain/db/model/normal_order.dart';
import 'package:captain/db/model/personnel.dart';
import 'package:captain/db/model/punch.dart';
import 'package:captain/db/model/returned_order.dart';
import 'package:captain/db/model/statistics.dart';
import 'package:captain/page/analysis/stats/color.dart';
import 'package:captain/page/punch/create_punch.dart';
import 'package:captain/widget/statistics.dart';
import 'package:flutter/material.dart';

class OverViewPage extends StatefulWidget {
  @override
  _OverViewPageState createState() => _OverViewPageState();
}

class _OverViewPageState extends State<OverViewPage> {
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
                    StatisticsCard(
                      Statistics(
                        title: "Orders",
                        subTitle: "total order",
                        iconData: Icons.color_lens,
                      ),
                      getStat: getTotalOrderCount(),
                    ),
                    StatisticsCard(
                      Statistics(
                        title: "Today",
                        subTitle: "today's order",
                        iconData: Icons.color_lens,
                      ),
                      getStat: getTotalOrderCount(),
                    ),
                    StatisticsCard(
                      Statistics(title: "Customers", subTitle: "total customers", iconData: Icons.supervisor_account),
                      getStat: getCustomerCount(),
                    ),
                    StatisticsCard(
                      Statistics(title: "Returned Orders", subTitle: "total returned orders", iconData: Icons.assignment_return),
                      getStat: getTotalReturnedOrdersCount(),
                    ),
                    StatisticsCard(
                      Statistics(title: "Punch in", subTitle: "total punch in", iconData: Icons.arrow_back),
                      getStat: getPunchInCount(),
                    ),
                    StatisticsCard(
                      Statistics(title: "Punch out", subTitle: "total punch out", iconData: Icons.arrow_forward),
                      getStat: getPunchOutCount(),
                    ),
                  ],
                )),
            Expanded(
                flex: 4,
                child: ColorAnalysis(
                  noDataFound: noDataFound(),
                ))
          ],
        ));
  }

  Widget noDataFound() {
    return Card(
      elevation: 0,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.color_lens,
              color: Theme.of(context).accentColor,
              size: 70,
            ),
            SizedBox(
              height: 20,
            ),
            Text(
              "No orders has been created",
              style: TextStyle(color: Colors.black54, fontSize: 16),
            )
          ],
        ),
      ),
    );
  }

  Future<num> getTotalOrderCount() async {
    List<NormalOrder> normalOrders = await NormalOrderDAL.find();
    return normalOrders.length;
  }

  Future<num> getTodayOrderCount() async {
    // todo : query today order count

    List<NormalOrder> normalOrders = await NormalOrderDAL.find();
    return normalOrders.length;
  }


  Future<num> getTotalReturnedOrdersCount() async {
    List<ReturnedOrder> returnOrders = await ReturnedOrderDAL.find();
    return returnOrders.length;
  }

  Future<num> getPunchInCount() async {
    String where = "${Punch.TYPE} = ?";
    List<String> whereArgs = [CreatePunchViewState.PUNCH_IN]; //
    List<Punch> punches = await PunchDAL.find(where: where, whereArgs: whereArgs);
    return punches.length;
  }

  Future<num> getPunchOutCount() async {
    String where = "${Punch.TYPE} = ?";
    List<String> whereArgs = [CreatePunchViewState.PUNCH_OUT]; //
    List<Punch> punches = await PunchDAL.find(where: where, whereArgs: whereArgs);
    return punches.length;
  }

  Future<num> getCustomerCount() async {
    String where = "${Personnel.TYPE} = ?";
    List<String> whereArgs = [Personnel.CUSTOMER]; // Querying only customers
    List<Personnel> customers = await PersonnelDAL.find(
      where: where,
      whereArgs: whereArgs,
    );

    return customers.length;
  }
}
