import 'package:captain/db/dal/returned_order.dart';
import 'package:captain/db/model/product.dart';
import 'package:captain/db/model/returned_order.dart';
import 'package:captain/widget/c_loading.dart';
import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;

class ReturnedOrderAnalysis extends StatefulWidget {
  @override
  _ReturnedOrderAnalysisState createState() => _ReturnedOrderAnalysisState();
}

class _ReturnedOrderAnalysisState extends State<ReturnedOrderAnalysis> {
  List<ReturnedOrderAnalysisModel> returnsData = [];

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
                message: "Analyzing Returned Orders",
              );
            }
          } else {
            return CLoading(message: "Analyzing Returned Orders");
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
                returnsData[0].product.name, returnsData[0].count)),
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

  List<charts.Series<ReturnedOrderAnalysisModel, String>> refactorData() {
    return [
      new charts.Series<ReturnedOrderAnalysisModel, String>(
        id: 'Returned Orders',
        colorFn: (_, __) {
          Color primary = Theme.of(context).primaryColorLight;
          return charts.Color(
              r: primary.red, g: primary.green, b: primary.blue);
        },
        domainFn: (ReturnedOrderAnalysisModel val, _) => val.product.name,
        measureFn: (ReturnedOrderAnalysisModel val, _) => val.count,
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
                        returnsData[index].product.name,
                        style: TextStyle(fontSize: 12),
                      ),
                      subtitle: Text(
                        "${returnsData[index].product.paintType}, ${returnsData[index].product.manufacturer}",
                        style: TextStyle(fontSize: 11),
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Text(returnsData[index].count.toStringAsFixed(0)),
                          Text(
                              returnsData[index].product.isGallonBased
                                  ? "gallon"
                                  : "-",
                              style: TextStyle(fontSize: 10)),
                        ],
                      ),
                      dense: true,
                      leading: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                        Text("${currentIndex.toString()}.", style: TextStyle(fontSize: 11,),),
                        SizedBox(width: 7,),
                        Icon(
                          Icons.circle,
                          size: 30,
                          color: returnsData[index].product.colorValue == null
                              ? Colors.black12
                              : Color(int.parse(
                              returnsData[index].product.colorValue)),
                        )
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
          .indexWhere((ReturnedOrderAnalysisModel returnedOrderAnalysisModel) {
        return returnedOrderAnalysisModel.product.id ==
            returnedOrder.product.id;
      });

      if (index == -1) {
        // Product does not exist
        ReturnedOrderAnalysisModel returnedOrderAnalysisModelNew =
            ReturnedOrderAnalysisModel(
                product: returnedOrder.product, count: 1);
        returnsData.add(returnedOrderAnalysisModelNew);
      } else {
        ReturnedOrderAnalysisModel returnedOrderAnalysisModelNew =
            ReturnedOrderAnalysisModel(
                product: returnedOrder.product,
                count: returnsData[index].count + 1);

        returnsData.removeAt(index);
        returnsData.insert(index, returnedOrderAnalysisModelNew);
      }
    });

    // Sorting data
    returnsData.sort((a, b) => b.count.compareTo(a.count));

    return true;
  }
}

class ReturnedOrderAnalysisModel {
  Product product;
  int count;
  ReturnedOrderAnalysisModel({this.product, this.count});
}
