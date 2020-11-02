import 'package:captain/page/employee/create_employee.dart';
import 'package:captain/page/employee/statistics_employee.dart';
import 'package:captain/page/employee/view_employee.dart';
import 'package:flutter/material.dart';

class HomeEmployeePage extends StatefulWidget {
  @override
  HomeEmployeePageState createState() => HomeEmployeePageState();
}

class HomeEmployeePageState extends State<HomeEmployeePage> with SingleTickerProviderStateMixin {

  // Global keys for views
  GlobalKey<CreateEmployeeViewState> createEmployeeKey = GlobalKey();
  GlobalKey<EmployeeTableState> viewEmployeeKey = GlobalKey();
  GlobalKey<StatisticsEmployeeViewState> statisticsEmployeeKey = GlobalKey();


  void doSomethingFromParent(){

  }
  @override
  Widget build(BuildContext context) {

    return Container(
        child: Column(
      children: <Widget>[
        // Statistics view
        StatisticsEmployeeView(),
        Container(
          margin: EdgeInsets.only(top: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                flex: 3,
                child: CreateEmployeeView(viewEmployeeKey: viewEmployeeKey,statisticsEmployeeKey: statisticsEmployeeKey,), // Create employee view
              ),
              SizedBox(
                width: 5,
              ),
              Expanded(
                flex: 7,
                child: EmployeeTable(createEmployeeKey: createEmployeeKey,statisticsEmployeeKey: statisticsEmployeeKey,), // View employees page
              ),
            ],
          ),
        )
      ],
    ));
  }
  
}

