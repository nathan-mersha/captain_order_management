import 'package:flutter/material.dart';

class DashboardPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return DashboardPageState();
  }
}

class DashboardPageState extends State<DashboardPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
//      drawer: Menu.getSideDrawer(context),
      backgroundColor: Theme.of(context).backgroundColor,
      body: Center(child: Text("Dasboard page"),),
    );
  }
}