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
            StatisticsCard(Statistics(stat: "44")),
            StatisticsCard(Statistics(stat: "342")),
            StatisticsCard(Statistics(stat: "12")),
            StatisticsCard(Statistics(stat: "0")),
          ],
        ),

        Container(
          margin: EdgeInsets.only(top: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                flex: 3,
                child: CreateEmployeeView(),
              ),
              SizedBox(
                width: 5,
              ),
              Expanded(
                flex: 7,
                child: EmployeeTable(),
              ),
            ],
          ),
        )
      ],
    ));
  }
}
