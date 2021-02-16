import 'package:captain/db/dal/personnel.dart';
import 'package:captain/db/model/personnel.dart';
import 'package:captain/widget/c_loading.dart';
import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;

class CustomerAnalysis extends StatefulWidget {
  @override
  _CustomerAnalysisState createState() => _CustomerAnalysisState();
}

class _CustomerAnalysisState extends State<CustomerAnalysis> {
  List<CustomerAnalysisModel> customerData = [];

  @override
  Widget build(BuildContext context) {
    return Container(
      child: FutureBuilder(
        future: colorStat(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.data == true) {
              return customerData.length == 0
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
                message: "Analyzing Customer",
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
            renderSpec: new charts.NoneRenderSpec(), viewport: charts.OrdinalViewport(customerData[0].address, customerData[0].count)),
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

  List<charts.Series<CustomerAnalysisModel, String>> refactorData() {
    return [
      new charts.Series<CustomerAnalysisModel, String>(
        id: 'Orders',
        colorFn: (_, __) {
          Color primary = Theme.of(context).primaryColorLight;
          return charts.Color(r: primary.red, g: primary.green, b: primary.blue);
        },
        domainFn: (CustomerAnalysisModel val, _) => val.address.substring(0, val.address.length < 18 ? val.address.length : 18),
        measureFn: (CustomerAnalysisModel val, _) => val.count,
        displayName: "Analysis",
        data: customerData,
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
                padding: EdgeInsets.only(right: 20, left: 0, top: 5),
                child: ListView.builder(
                  itemCount: customerData.length,
                  itemBuilder: (context, index) {
                    int currentIndex = index + 1;

                    return ListTile(
                      leading: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            "${currentIndex.toString()}.",
                            style: TextStyle(fontSize: 11),
                          )
                        ],
                      ),
                      title: Text(
                        customerData[index].address,
                        style: TextStyle(fontSize: 12),
                      ),
                      subtitle: Text(
                        "${customerData[index].count.toStringAsFixed(0)} customers",
                        style: TextStyle(fontSize: 11, color: Colors.black38),
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
    String where = "${Personnel.TYPE} = ?";
    List<String> whereArgs = [Personnel.CUSTOMER]; // Querying only customers
    List<Personnel> customers = await PersonnelDAL.find(
      where: where,
      whereArgs: whereArgs,
    );

    customerData.clear();
    customers.forEach((Personnel personnel) {
      // Doing analysis for customer values only
      /// Checking if the customer exist -1 no, any other value >= 0 yes.
      int index = customerData.indexWhere((CustomerAnalysisModel customerAnalysisModel) {
        return customerAnalysisModel.address.trim() == personnel.address.trim();
      });

      /// Product does not exist
      if (index == -1) {
        CustomerAnalysisModel colorAnalysisModelNew = CustomerAnalysisModel(
          address: personnel.address,
          count: 1,
        );
        customerData.add(colorAnalysisModelNew);
      }

      /// Product already exists in the analysis data
      else {
        CustomerAnalysisModel colorAnalysisModelNew = CustomerAnalysisModel(
          address: personnel.address,
          count: customerData[index].count + 1,
        );

        // Removing and re-inserting data
        customerData.removeAt(index);
        customerData.insert(index, colorAnalysisModelNew);
      }
    });

    // Sorting data
    customerData.sort((a, b) => b.count.compareTo(a.count));

    return true;
  }
}

class CustomerAnalysisModel {
  String address;
  int count;
  CustomerAnalysisModel({
    this.address,
    this.count,
  });
}
