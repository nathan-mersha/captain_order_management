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
  GlobalKey<EmployeeTableState> employeeTableKey = GlobalKey();
  GlobalKey<CreateEmployeeViewState> createEmployeeKey = GlobalKey();
  GlobalKey<StatisticsEmployeeViewState> statisticsEmployeeKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Column(
      children: <Widget>[
        // Statistics view
        StatisticsEmployeeView(
          employeeTableKey: employeeTableKey,
          createEmployeeKey: createEmployeeKey,
          statisticsEmployeeKey: statisticsEmployeeKey,
        ),
        Container(
          margin: EdgeInsets.only(top: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                flex: 3,
                child: CreateEmployeeView(
                  employeeTableKey: employeeTableKey,
                  createEmployeeKey: createEmployeeKey,
                  statisticsEmployeeKey: statisticsEmployeeKey,
                ), // Create employee view
              ),
              SizedBox(
                width: 5,
              ),
              Expanded(
                flex: 7,
                child: EmployeeTable(
                  employeeTableKey: employeeTableKey,
                  createEmployeeKey: createEmployeeKey,
                  statisticsEmployeeKey: statisticsEmployeeKey,
                ), // View employees page
              ),
            ],
          ),
        )
      ],
    ));
  }
}
