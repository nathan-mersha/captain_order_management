import 'package:captain/db/dal/punch.dart';
import 'package:captain/db/model/personnel.dart';
import 'package:captain/db/model/punch.dart';
import 'package:captain/page/punch/create_punch.dart';
import 'package:captain/widget/c_loading.dart';
import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;

class PunchAnalysis extends StatefulWidget {
  @override
  _PunchAnalysisState createState() => _PunchAnalysisState();
}

class _PunchAnalysisState extends State<PunchAnalysis> {
  List<PunchAnalysisModel> punchData = [];

  @override
  Widget build(BuildContext context) {
    return Container(
      child: FutureBuilder(
        future: colorStat(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.data == true) {
              return punchData.length == 0
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
                message: "Analyzing Punch",
              );
            }
          } else {
            return CLoading(message: "Analyzing Punch");
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
        barGroupingType: charts.BarGroupingType.stacked,
        barRendererDecorator: new charts.BarLabelDecorator<String>(),
        behaviors: [
          charts.SlidingViewport(),
          charts.PanAndZoomBehavior(),
        ],
        domainAxis: charts.OrdinalAxisSpec(
          renderSpec: new charts.NoneRenderSpec(),
        ),
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

  List<charts.Series<PunchAnalysisModel, String>> refactorData() {
    return [
      charts.Series<PunchAnalysisModel, String>(
        id: 'Punch In',
        colorFn: (_, __) {
          Color primary = Colors.red;
          return charts.Color(r: primary.red, g: primary.green, b: primary.blue);
        },
        domainFn: (PunchAnalysisModel val, _) => val.employee.name,
        measureFn: (PunchAnalysisModel val, _) => val.weight,
        displayName: "Analysis In",
        data: punchData.where((element) => element.type == CreatePunchViewState.PUNCH_IN).toList(),
      ),
      charts.Series<PunchAnalysisModel, String>(
        id: 'Punch Out',
        colorFn: (_, __) {
          Color primary = Colors.green;
          return charts.Color(r: primary.red, g: primary.green, b: primary.blue);
        },
        domainFn: (PunchAnalysisModel val, _) => val.employee.name,
        measureFn: (PunchAnalysisModel val, _) => val.weight,
        displayName: "Analysis Out",
        data: punchData.where((element) => element.type == CreatePunchViewState.PUNCH_OUT).toList(),
      )
    ];
  }

  Widget buildAnalysisList() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(5))),
      child: Container(
        padding: EdgeInsets.only(bottom: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
                height: 495,
                padding: EdgeInsets.only(right: 20, left: 20, top: 5),
                child: ListView.builder(
                  itemCount: punchData.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(
                        punchData[index].employee.name,
                        style: TextStyle(fontSize: 12),
                      ),
                      subtitle: Text(
                        "${punchData[index].weight.toStringAsFixed(2)} gm",
                        style: TextStyle(fontSize: 11),
                      ),
                      leading: punchData[index].employee.profileImage == null
                          ? Icon(
                              Icons.person_outline_rounded,
                              color: Colors.black54,
                            )
                          : ClipOval(
                              child: Image.memory(
                                punchData[index].employee.profileImage,
                                fit: BoxFit.cover,
                                height: 30,
                                width: 30,
                              ),
                            ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Icon(
                            punchData[index].type == CreatePunchViewState.PUNCH_IN ? Icons.arrow_back : Icons.arrow_forward,
                            size: 14,
                            color: punchData[index].type == CreatePunchViewState.PUNCH_IN ? Colors.red : Colors.green,
                          ),
                          SizedBox(
                            height: 3,
                          ),
                          Text("${punchData[index].count.toString()} qnt", style: TextStyle(fontSize: 10, color: Colors.black54))
                        ],
                      ),
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
    List<Punch> punches = await PunchDAL.find();

    punchData.clear();
    punches.forEach((Punch punch) {
      /// For both in and out
      /// Checking if the paint exist -1 no, any other value >= 0 yes.
      int index = punchData.indexWhere((PunchAnalysisModel punchAnalysisModel) {
        return punchAnalysisModel.employee.id == punch.employee.id && punchAnalysisModel.type == punch.type;
      });

      /// Punch in does not exist
      if (index == -1) {
        PunchAnalysisModel punchAnalysisModel = PunchAnalysisModel(employee: punch.employee, count: 1, weight: punch.weight, type: punch.type);
        punchData.add(punchAnalysisModel);
      }

      /// Product already exists in the analysis data
      else {
        PunchAnalysisModel punchAnalysisModel = PunchAnalysisModel(employee: punch.employee, count: punchData[index].count + 1, weight: punchData[index].weight + punch.weight, type: punch.type);

        // Removing and re-inserting data
        punchData.removeAt(index);
        punchData.insert(index, punchAnalysisModel);
      }
    });
    // Sorting data
    punchData.sort((a, b) => b.count.compareTo(a.count));
    return true;
  }
}

class PunchAnalysisModel {
  Personnel employee;
  int count;
  num weight;
  String type;
  PunchAnalysisModel({this.employee, this.count, this.weight, this.type});
}
