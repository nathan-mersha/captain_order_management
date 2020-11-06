import 'package:captain/page/product/create_product.dart';
import 'package:captain/page/product/statistics_product.dart';
import 'package:captain/page/product/view_product.dart';
import 'package:flutter/material.dart';

class HomeProductPage extends StatefulWidget {
  @override
  HomeProductPageState createState() => HomeProductPageState();
}

class HomeProductPageState extends State<HomeProductPage> with SingleTickerProviderStateMixin {
  // Global keys for views
  GlobalKey<ProductTableState> productTableKey = GlobalKey();
  GlobalKey<CreateProductViewState> createProductKey = GlobalKey();
  GlobalKey<StatisticsProductViewState> statisticsProductKey = GlobalKey();

  void doSomethingFromParent() {}
  @override
  Widget build(BuildContext context) {
    return Container(
        child: Column(
      children: <Widget>[
        // Statistics view
        StatisticsProductView(
          productTableKey: productTableKey,
          createProductKey: createProductKey,
          statisticsProductKey: statisticsProductKey,
        ),
        Container(
          margin: EdgeInsets.only(top: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                flex: 3,
                child: CreateProductView(
                  productTableKey: productTableKey,
                  createProductKey: createProductKey,
                  statisticsProductKey: statisticsProductKey,
                ), // Create product view
              ),
              SizedBox(
                width: 5,
              ),
              Expanded(
                flex: 7,
                child: ProductTable(
                  productTableKey: productTableKey,
                  createProductKey: createProductKey,
                  statisticsProductKey: statisticsProductKey,
                ), // View products page
              ),
            ],
          ),
        )
      ],
    ));
  }
}
