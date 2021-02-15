import 'dart:io';

import 'package:captain/db/dal/normal_order.dart';
import 'package:captain/db/model/normal_order.dart';
import 'package:captain/db/model/personnel.dart';
import 'package:captain/widget/c_loading.dart';
import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:intl/intl.dart';

class SalesAnalysis extends StatefulWidget {
  @override
  _SalesAnalysisState createState() => _SalesAnalysisState();
}

class _SalesAnalysisState extends State<SalesAnalysis> {
  List<SalesAnalysisModel> salesData = [];

  final oCCy = NumberFormat("#,##0.00", "en_US");

  @override
  Widget build(BuildContext context) {
    return Container(
      child: FutureBuilder(
        future: colorStat(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.data == true) {
              return salesData.length == 0
                  ? buildDataNotFound()
                  : Row(
                      children: [
                        Expanded(flex: 1, child: buildAnalysisList()),
                        Expanded(
                          flex: 2,
                          child: buildAnalysisGraph(),
                        )
                      ],
                    );
            } else {
              return CLoading(
                message: "Analyzing Customers",
              );
            }
          } else {
            return CLoading(message: "Analyzing Customers");
          }
        },
      ),
    );
  }

  Widget buildAnalysisGraph() {
    return Card(
        child: ClipRect(
      child: charts.BarChart(
        refactorData(),
        animate: true,
        barRendererDecorator: new charts.BarLabelDecorator<String>(),
        behaviors: [
          charts.SlidingViewport(),
          charts.PanAndZoomBehavior(),
        ],
        domainAxis: charts.OrdinalAxisSpec(
            renderSpec: new charts.NoneRenderSpec(),
            viewport: charts.OrdinalViewport(
                salesData[0].personnel.name, salesData[0].count)),
      ),
    ));
  }

  Center buildDataNotFound() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.hourglass_empty,
            color: Theme.of(context).accentColor,
          ),
          SizedBox(
            height: 10,
          ),
          Text(
            "No orders found",
            style: TextStyle(color: Colors.black54, fontSize: 12),
          )
        ],
      ),
    );
  }

  List<charts.Series<SalesAnalysisModel, String>> refactorData() {
    return [
      new charts.Series<SalesAnalysisModel, String>(
        id: 'Orders',
        colorFn: (_, __) {
          Color primary = Theme.of(context).primaryColorLight;
          return charts.Color(
              r: primary.red, g: primary.green, b: primary.blue);
        },
        domainFn: (SalesAnalysisModel val, _) => val.personnel.name,
        measureFn: (SalesAnalysisModel val, _) => val.totalAmount,
        displayName: "Analysis",
        data: salesData,
      )
    ];
  }

  Widget buildAnalysisList() {
    return Card(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(5))),
      child: Container(
        padding: EdgeInsets.only(bottom: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
                height: 495,
                padding: EdgeInsets.only(right: 20, left: 0, top: 5),
                child: ListView.builder(
                  itemCount: salesData.length,
                  itemBuilder: (context, index) {
                    int currentIndex = index + 1;

                    return ListTile(
                      title: Text(
                        salesData[index].personnel.name,
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w800),
                      ),
                      subtitle: Text(
                        "${salesData[index].personnel.phoneNumber}",
                        style: TextStyle(fontSize: 11, color: Colors.black38),
                      ),
                      trailing: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "${oCCy.format(salesData[index].totalAmount)} br",
                            style: TextStyle(fontSize: 11),
                          ),
                          Text(
                            "${salesData[index].count.toStringAsFixed(0)} times",
                            style:
                                TextStyle(fontSize: 11, color: Colors.black38),
                          ),
                        ],
                      ),
                      leading: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text("${currentIndex.toString()}.", style: TextStyle(fontSize: 11,),), // todo : change
                          SizedBox(width: 7,), // todo : change
                        salesData[index].personnel.profileImage == null
                            ? Icon(
                          Icons.person_outline_rounded,
                          color: Colors.black54,
                        )
                            : ClipOval(
                            child: Image.file(
                              File(salesData[index].personnel.profileImage),
                              fit: BoxFit.cover,
                              height: 30,
                              width: 30,
                            ))
                      ],),
                      dense: true,
                    );
                  },
                )),
          ],
        ),
      ),
    );
  }

  Future colorStat() async {
    List<NormalOrder> normalOrders = await NormalOrderDAL.find();

    salesData.clear();
    normalOrders.forEach((NormalOrder normalOrder) {
      // Doing analysis for paint values only
      /// Checking if the paint exist -1 no, any other value >= 0 yes.
      int index = salesData.indexWhere((SalesAnalysisModel salesAnalysisModel) {
        return salesAnalysisModel.personnel.id == normalOrder.customer.id;
      });

      /// Customer does not exist
      if (index == -1) {
        SalesAnalysisModel colorAnalysisModelNew = SalesAnalysisModel(
            personnel: normalOrder.customer,
            count: 1,
            totalAmount: normalOrder.totalAmount);
        salesData.add(colorAnalysisModelNew);
      }

      /// Product already exists in the analysis data
      else {
        SalesAnalysisModel colorAnalysisModelNew = SalesAnalysisModel(
            personnel: normalOrder.customer,
            count: salesData[index].count + 1,
            totalAmount:
                salesData[index].totalAmount + normalOrder.totalAmount);

        // Removing and re-inserting data
        salesData.removeAt(index);
        salesData.insert(index, colorAnalysisModelNew);
      }
    });

    // Sorting data
    salesData.sort((a, b) => b.totalAmount.compareTo(a.totalAmount));

    return true;
  }
}

class SalesAnalysisModel {
  Personnel personnel;
  int count;
  num totalAmount;

  SalesAnalysisModel({this.personnel, this.count, this.totalAmount});
}
