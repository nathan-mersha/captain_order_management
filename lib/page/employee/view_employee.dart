import 'package:captain/db/dal/personnel.dart';
import 'package:captain/db/model/personnel.dart';
import 'package:captain/page/employee/create_employee.dart';
import 'package:captain/page/employee/statistics_employee.dart';
import 'package:captain/widget/c_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contact/contacts.dart';
import 'package:intl/intl.dart';

class EmployeeTable extends StatefulWidget {
  final GlobalKey<CreateEmployeeViewState> createEmployeeKey;
  final GlobalKey<StatisticsEmployeeViewState> statisticsEmployeeKey;
  final GlobalKey<EmployeeTableState> employeeTableKey;

  const EmployeeTable({this.employeeTableKey, this.createEmployeeKey, this.statisticsEmployeeKey}) : super(key: employeeTableKey);

  @override
  EmployeeTableState createState() => EmployeeTableState();
}

class EmployeeTableState extends State<EmployeeTable> {
  int _rowsPerPage;
  int _sortColumnIndex;
  bool _sortAscending = true;
  _EmployeeDataSource _employeeDataSource;

  void _sort<T>(
    Comparable<T> Function(Personnel d) getField,
    int columnIndex,
    bool ascending,
  ) {
    _employeeDataSource._sort<T>(getField, ascending);
    _sortColumnIndex = columnIndex;
    _sortAscending = ascending;
  }

  Future<List<Personnel>> getListOfEmployees() async {
    String where = "${Personnel.TYPE} = ?";
    List<String> whereArgs = [Personnel.EMPLOYEE]; // Querying only employees
    List<Personnel> employees = await PersonnelDAL.find(where: where, whereArgs: whereArgs);
    return employees;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 535,
      child: Scrollbar(
        child: ListView(
          shrinkWrap: true,
          children: [
            FutureBuilder(
              future: getListOfEmployees(),
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  List<Personnel> employees = snapshot.data as List<Personnel>;
                  _EmployeeDataSource _employeeDataSourceVal = _EmployeeDataSource(context, employees, () {
                    setState(() {
                      // updating table here.
                    });
                  }, widget.createEmployeeKey);
                  _employeeDataSource = _employeeDataSourceVal;
                } else {
                  _employeeDataSource = _EmployeeDataSource(context, [], () {
                    setState(() {
                      // updating table here.
                    });
                  }, widget.createEmployeeKey);
                }

                _rowsPerPage = 7;

                return PaginatedDataTable(
                    actions: [
                      IconButton(
                          icon: Icon(
                            Icons.refresh,
                            color: Theme.of(context).accentColor,
                          ),
                          onPressed: () {
                            setState(() {});
                          })
                    ],
                    headingRowHeight: 70,
                    header: snapshot.connectionState == ConnectionState.done
                        ? Text(
                            "List of employees",
                            style: TextStyle(
                              fontSize: 13,
                            ),
                          )
                        : Row(
                            children: [
                              SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                              SizedBox(
                                width: 15,
                              ),
                              Text(
                                "Loading employees",
                                style: TextStyle(fontSize: 13, color: Theme.of(context).accentColor),
                              )
                            ],
                          ),
                    rowsPerPage: _rowsPerPage,
                    availableRowsPerPage: <int>[_rowsPerPage, _rowsPerPage * 2, _rowsPerPage * 5, _rowsPerPage * 10],
                    onRowsPerPageChanged: (value) {
                      setState(() {
                        _rowsPerPage = value;
                      });
                    },
                    sortColumnIndex: _sortColumnIndex,
                    sortAscending: _sortAscending,
                    columnSpacing: 30,
                    columns: [
                      DataColumn(
                        label: Text("Name"),
                        onSort: (columnIndex, ascending) {
                          return _sort<String>((d) => d.name, columnIndex, ascending);
                        },
                      ),
                      DataColumn(
                        label: Text("Phone number"),
                        onSort: (columnIndex, ascending) => _sort<String>((d) => d.phoneNumber, columnIndex, ascending),
                      ),
                      DataColumn(
                        label: Text("Address"),
                        onSort: (columnIndex, ascending) => _sort<String>((d) => d.address, columnIndex, ascending),
                      ),
                      DataColumn(
                        label: Text("Date"),
                        onSort: (columnIndex, ascending) => _sort<DateTime>((d) => d.firstModified, columnIndex, ascending),
                      ),
                      DataColumn(
                        label: Text(""),
                      ),
                    ],
                    source: _employeeDataSource);
              },
            )
          ],
        ),
      ),
    );
  }
}

class _EmployeeDataSource extends DataTableSource {
  final BuildContext context;
  final List<Personnel> employees;
  final Function updateTable;
  final GlobalKey<CreateEmployeeViewState> createEmployeeKey;
  _EmployeeDataSource(this.context, this.employees, this.updateTable, this.createEmployeeKey);

  void _sort<T>(Comparable<T> Function(Personnel d) getField, bool ascending) {
    employees.sort((a, b) {
      final aValue = getField(a);
      final bValue = getField(b);
      return ascending ? Comparable.compare(aValue, bValue) : Comparable.compare(bValue, aValue);
    });
    notifyListeners();
  }

  int _selectedCount = 0;

  @override
  DataRow getRow(int index) {
    assert(index >= 0);
    if (index >= employees.length) return null;
    final employee = employees[index];
    return DataRow.byIndex(
      index: index,
      cells: [
        DataCell(
            Row(
              children: [
                employee.profileImage == null
                    ? Icon(
                        Icons.person,
                        color: Colors.black12,
                      )
                    : ClipOval(
                        child: Image.memory(
                          employee.profileImage,
                          fit: BoxFit.cover,
                          height: 30,
                          width: 30,
                        ),
                      ),
                SizedBox(
                  width: 10,
                ),
                Text(
                  employee.name ?? '-',
                  style: TextStyle(color: Theme.of(context).primaryColor),
                )
              ],
            ), onTap: () {
          createEmployeeKey.currentState.passForUpdate(employees[index]);
        }),
        DataCell(Text(employee.phoneNumber ?? '-')),
        DataCell(Text(employee.address ?? '-')),
        DataCell(Text(DateFormat.yMMMd().format(employee.firstModified))),
        DataCell(IconButton(
          icon: Icon(
            Icons.delete_outline,
            color: Theme.of(context).accentColor,
            size: 15,
          ),
          onPressed: () {
            // deleting employee here.
            deleteEmployee(employees[index]).then((value) => updateTable());
          },
        ))
      ],
    );
  }

  Future<void> deleteEmployee(Personnel personnel) async {
    return await showDialog<String>(
        context: context,
        builder: (context) => CDialog(
              widgetYes: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  Icon(
                    Icons.done,
                    size: 50,
                    color: Theme.of(context).primaryColor,
                  ),
                ],
              ),
              widgetNo: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  Icon(Icons.clear, size: 50, color: Theme.of(context).accentColor),
                ],
              ),
              message: "Are you sure you want to delete employee\n${personnel.name}",
              onYes: () async {
                // Delete employee here.

                String where = "${Personnel.ID} = ?";
                List<String> whereArgs = [personnel.id]; // Querying only employees

                List<Personnel> deletePersonnelList = await PersonnelDAL.find(where: where, whereArgs: whereArgs);

                await PersonnelDAL.delete(where: where, whereArgs: whereArgs);
                await Contacts.deleteContact(Contact(identifier: personnel.contactIdentifier)); // Deleting contact

                Personnel deletePersonnel = deletePersonnelList.first;
                if (deletePersonnel.idFS != null) {
                  Firestore.instance.collection(Personnel.EMPLOYEE).document(deletePersonnel.idFS).delete();
                }

                Navigator.pop(context);
                return null;
              },
              onNo: () {
                Navigator.pop(
                  context,
                );
                return null;
              },
            ));
  }

  @override
  int get rowCount => employees == null ? 0 : employees.length;

  @override
  bool get isRowCountApproximate => false;

  @override
  int get selectedRowCount => _selectedCount;
}
