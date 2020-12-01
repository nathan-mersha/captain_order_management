import 'package:captain/db/dal/normal_order.dart';
import 'package:captain/db/model/normal_order.dart';
import 'package:captain/db/model/product.dart';
import 'package:captain/page/product/create_product.dart';
import 'package:captain/widget/c_loading.dart';
import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;

class ManufacturerAnalysis extends StatefulWidget {
  @override
  _ManufacturerAnalysisState createState() => _ManufacturerAnalysisState();
}

class _ManufacturerAnalysisState extends State<ManufacturerAnalysis> {
  List<ManufacturerAnalysisModel> manufacturerData = [];

  @override
  Widget build(BuildContext context) {
    return Container(
      child: FutureBuilder(
        future: colorStat(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.data == true) {
              return manufacturerData.length == 0
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
                message: "Analyzing Manufacturers",
              );
            }
          } else {
            return CLoading(message: "Analyzing Manufacturers");
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
        domainAxis: charts.OrdinalAxisSpec(renderSpec: new charts.NoneRenderSpec(), viewport: charts.OrdinalViewport(manufacturerData[0].manufacturer, manufacturerData[0].count)),
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

  List<charts.Series<ManufacturerAnalysisModel, String>> refactorData() {
    return [
      new charts.Series<ManufacturerAnalysisModel, String>(
        id: 'Orders',
        colorFn: (_, __) {
          Color primary = Theme.of(context).primaryColorLight;
          return charts.Color(r: primary.red, g: primary.green, b: primary.blue);
        },
        domainFn: (ManufacturerAnalysisModel val, _) => val.manufacturer ?? "-",
        measureFn: (ManufacturerAnalysisModel val, _) => val.count,
        displayName: "Analysis",
        data: manufacturerData,
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
                  itemCount: manufacturerData.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(
                        manufacturerData[index].manufacturer ?? "-",
                        style: TextStyle(fontSize: 12),
                      ),
                      subtitle: Text(
                        "sold ${manufacturerData[index].count.toStringAsFixed(0)} times",
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
    List<NormalOrder> normalOrders = await NormalOrderDAL.find();

    manufacturerData.clear();
    normalOrders.forEach((NormalOrder normalOrder) {
      normalOrder.products.forEach((Product product) {
        if (product.type == CreateProductViewState.PAINT) {
          // Doing analysis for paint values only
          /// Checking if the paint exist -1 no, any other value >= 0 yes.
          int index = manufacturerData.indexWhere((ManufacturerAnalysisModel paintAnalysisModel) {
            return paintAnalysisModel.manufacturer == product.manufacturer;
          });

          /// Product does not exist
          if (index == -1) {
            ManufacturerAnalysisModel colorAnalysisModelNew = ManufacturerAnalysisModel(
              manufacturer: product.manufacturer,
              count: 1,
            );
            manufacturerData.add(colorAnalysisModelNew);
          }

          /// Product already exists in the analysis data
          else {
            ManufacturerAnalysisModel colorAnalysisModelNew = ManufacturerAnalysisModel(
              manufacturer: product.manufacturer,
              count: manufacturerData[index].count + 1,
            );

            // Removing and re-inserting data
            manufacturerData.removeAt(index);
            manufacturerData.insert(index, colorAnalysisModelNew);
          }
        }
      });
    });

    // Sorting data
    manufacturerData.sort((a, b) => b.count.compareTo(a.count));

    return true;
  }
}

class ManufacturerAnalysisModel {
  String manufacturer;
  int count;
  ManufacturerAnalysisModel({
    this.manufacturer,
    this.count,
  });
}
