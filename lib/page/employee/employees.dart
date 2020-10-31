import 'package:captain/db/model/statistics.dart';
import 'package:captain/page/employee/create_employee.dart';
import 'package:captain/page/employee/view_employee.dart';
import 'package:captain/widget/statistics.dart';
import 'package:flutter/material.dart';

class EmployeesPage extends StatefulWidget {
  @override
  _EmployeesPageState createState() => _EmployeesPageState();
}

class _EmployeesPageState extends State<EmployeesPage> with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return Container(
        child: Column(
      children: <Widget>[
        // Statistics view
        Row(
          children: <Widget>[
            StatisticsCard(Statistics(stat: "1234")),
            StatisticsCard(Statistics(stat: "1234")),
            StatisticsCard(Statistics(stat: "1234")),
            StatisticsCard(Statistics(stat: "1234")),
            StatisticsCard(Statistics(stat: "1234")),
          ],
        ),

        Container(
          margin: EdgeInsets.only(top: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                flex: 1,
                child: CreateEmployeeView(),
              ),
              SizedBox(
                width: 5,
              ),
              Expanded(
                flex: 2,
                child: EmployeeTable(),
              ),
            ],
          ),
        )
      ],
    ));
  }
}
