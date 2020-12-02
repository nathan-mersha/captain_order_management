import 'package:captain/db/dal/normal_order.dart';
import 'package:captain/db/model/normal_order.dart';
import 'package:captain/db/model/product.dart';
import 'package:captain/page/product/create_product.dart';
import 'package:captain/widget/c_loading.dart';
import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;

class ColorAnalysis extends StatefulWidget {
  final Widget noDataFound;

  ColorAnalysis({this.noDataFound});
  @override
  _ColorAnalysisState createState() => _ColorAnalysisState();
}

class _ColorAnalysisState extends State<ColorAnalysis> {
  List<ColorAnalysisModel> paintsData = [];

  @override
  Widget build(BuildContext context) {
    return Container(
      child: FutureBuilder(
        future: colorStat(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.data == true) {
              return paintsData.length == 0
                  ? widget.noDataFound == null
                      ? buildDataNotFound()
                      : widget.noDataFound
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
                message: "Analyzing Colors",
              );
            }
          } else {
            return CLoading(message: "Analyzing Colors");
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
        domainAxis: charts.OrdinalAxisSpec(renderSpec: new charts.NoneRenderSpec(), viewport: charts.OrdinalViewport(paintsData[0].product.name, paintsData[0].totalLitter.round())),
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

  List<charts.Series<ColorAnalysisModel, String>> refactorData() {
    return [
      new charts.Series<ColorAnalysisModel, String>(
        id: 'Orders',
        colorFn: (_, __) {
          Color primary = Theme.of(context).primaryColorLight;
          return charts.Color(r: primary.red, g: primary.green, b: primary.blue);
        },
        domainFn: (ColorAnalysisModel val, _) => val.product.name,
        measureFn: (ColorAnalysisModel val, _) => val.totalLitter,
        displayName: "Analysis",
        data: paintsData,
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
                  itemCount: paintsData.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(
                        paintsData[index].product.name,
                        style: TextStyle(fontSize: 12),
                      ),
                      subtitle: Text(
                        "${paintsData[index].product.paintType}, ${paintsData[index].product.manufacturer}",
                        style: TextStyle(fontSize: 11),
                      ),
                      trailing: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Text(
                            "${paintsData[index].totalLitter.toStringAsFixed(0)} ltrs",
                            style: TextStyle(fontSize: 12, color: Colors.black87),
                          ),
                          Text(
                            "sold ${paintsData[index].count.toStringAsFixed(0)} times",
                            style: TextStyle(fontSize: 11, color: Colors.black38),
                          ),
                        ],
                      ),
                      dense: true,
                      leading: Icon(
                        Icons.circle,
                        size: 30,
                        color: paintsData[index].product.colorValue == null ? Colors.black12 : Color(int.parse(paintsData[index].product.colorValue)),
                      ),
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

    paintsData.clear();

    normalOrders.forEach((NormalOrder normalOrder) {
      normalOrder.products.forEach((Product product) {
        if (product.type == CreateProductViewState.PAINT) {
          // Doing analysis for paint values only
          /// Checking if the paint exist -1 no, any other value >= 0 yes.
          int index = paintsData.indexWhere((ColorAnalysisModel paintAnalysisModel) {
            return paintAnalysisModel.product.name == product.name;
          });

          /// Product does not exist
          if (index == -1) {
            ColorAnalysisModel colorAnalysisModelNew = ColorAnalysisModel(product: product, count: 1, totalLitter: double.parse(product.quantityInCart.toString()));

            paintsData.add(colorAnalysisModelNew);
          }

          /// Product already exists in the analysis data
          else {
            ColorAnalysisModel colorAnalysisModelNew =
                ColorAnalysisModel(product: product, count: paintsData[index].count + 1, totalLitter: paintsData[index].totalLitter + double.parse(product.quantityInCart.toString()));
            paintsData.removeAt(index);
            paintsData.insert(index, colorAnalysisModelNew);
          }
        }
      });
    });

    // Sorting data
    paintsData.sort((a, b) => b.totalLitter.compareTo(a.totalLitter));
    return true;
  }
}

class ColorAnalysisModel {
  Product product;
  int count;
  double totalLitter;
  ColorAnalysisModel({this.product, this.count, this.totalLitter});
}
