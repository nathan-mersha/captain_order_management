import 'dart:io';
import 'package:captain/db/dal/returned_order.dart';
import 'package:captain/db/model/personnel.dart';
import 'package:captain/db/model/returned_order.dart';
import 'package:captain/widget/c_loading.dart';
import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;

class EmployeeAnalysis extends StatefulWidget {
  @override
  _EmployeeAnalysisState createState() => _EmployeeAnalysisState();
}

class _EmployeeAnalysisState extends State<EmployeeAnalysis> {
  List<EmployeeAnalysisModel> returnsData = [];

  @override
  Widget build(BuildContext context) {
    return Container(
      child: FutureBuilder(
        future: returnedOrderStat(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.data == true) {
              return returnsData.length == 0
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
                message: "Analyzing Employee",
              );
            }
          } else {
            return CLoading(message: "Analyzing Employee");
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
                returnsData[0].employee.name, returnsData[0].count)),
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
            "No Returned orders found",
            style: TextStyle(color: Colors.black54, fontSize: 12),
          )
        ],
      ),
    );
  }

  List<charts.Series<EmployeeAnalysisModel, String>> refactorData() {
    return [
      new charts.Series<EmployeeAnalysisModel, String>(
        id: 'Returned Orders',
        colorFn: (_, __) {
          Color primary = Theme.of(context).primaryColorLight;
          return charts.Color(
              r: primary.red, g: primary.green, b: primary.blue);
        },
        domainFn: (EmployeeAnalysisModel val, _) => val.employee.name,
        measureFn: (EmployeeAnalysisModel val, _) => val.count,
        displayName: "Analysis",
        data: returnsData,
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
                  itemCount: returnsData.length,
                  itemBuilder: (context, index) {
                    int currentIndex = index + 1;

                    return ListTile(
                      title: Text(
                        returnsData[index].employee.name,
                        style: TextStyle(fontSize: 12),
                      ),
                      subtitle: Text(
                        "${returnsData[index].employee.phoneNumber}",
                        style: TextStyle(fontSize: 11),
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Text(
                            "${returnsData[index].count.toStringAsFixed(0)} returns",
                            style:
                                TextStyle(fontSize: 12, color: Colors.black87),
                          ),
                        ],
                      ),
                      dense: true,
                      leading: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                        Text("${currentIndex.toString()}.", style: TextStyle(fontSize: 11,),), // todo : change
                        SizedBox(width: 7,),
                        returnsData[index].employee.profileImage == null
                            ? Icon(
                          Icons.person_outline_rounded,
                          color: Colors.black54,
                        )
                            : ClipOval(
                            child: Image.file(
                              File(returnsData[index].employee.profileImage),
                              fit: BoxFit.cover,
                              height: 30,
                              width: 30,
                            ))
                      ],),
                    );
                  },
                )),
          ],
        ),
      ),
    );
  }

  Future returnedOrderStat() async {
    List<ReturnedOrder> returnedOrders = await ReturnedOrderDAL.find();

    returnsData.clear();
    returnedOrders.forEach((ReturnedOrder returnedOrder) {
      // if product already exist increment count
      // else add product

      int index = returnsData
          .indexWhere((EmployeeAnalysisModel returnedOrderAnalysisModel) {
        return returnedOrderAnalysisModel.employee.id ==
            returnedOrder.employee.id;
      });

      if (index == -1) {
        // Product does not exist
        EmployeeAnalysisModel returnedOrderAnalysisModelNew =
            EmployeeAnalysisModel(
                employee: returnedOrder.employee, count: returnedOrder.count);
        returnsData.add(returnedOrderAnalysisModelNew);
      } else {
        EmployeeAnalysisModel returnedOrderAnalysisModelNew =
            EmployeeAnalysisModel(
                employee: returnedOrder.employee,
                count: returnsData[index].count + returnedOrder.count);

        returnsData.removeAt(index);
        returnsData.insert(index, returnedOrderAnalysisModelNew);
      }
    });

    // Sorting data
    returnsData.sort((a, b) => b.count.compareTo(a.count));

    return true;
  }
}

class EmployeeAnalysisModel {
  Personnel employee;
  int count;
  EmployeeAnalysisModel({this.employee, this.count});
}
