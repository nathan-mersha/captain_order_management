import 'package:captain/db/dal/personnel.dart';
import 'package:captain/db/model/personnel.dart';
import 'package:captain/page/employee/create_employee.dart';
import 'package:captain/page/employee/statistics_employee.dart';
import 'package:captain/widget/c_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contact/contacts.dart';
import 'package:intl/intl.dart';

class EmployeeTable extends StatefulWidget {
  final GlobalKey<CreateEmployeeViewState> createEmployeeKey;
  final GlobalKey<StatisticsEmployeeViewState> statisticsEmployeeKey;
  final GlobalKey<EmployeeTableState> employeeTableKey;

  const EmployeeTable(
      {this.employeeTableKey,
      this.createEmployeeKey,
      this.statisticsEmployeeKey})
      : super(key: employeeTableKey);

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
    List<Personnel> employees =
        await PersonnelDAL.find(where: where, whereArgs: whereArgs);
    return employees;
  }

  bool nameSortAscending = true;
  bool phoneNumberSortAscending = true;
  bool addressSortAscending = true;
  bool dateSortAscending = true;

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
                  _EmployeeDataSource _employeeDataSourceVal =
                      _EmployeeDataSource(context, employees, () {
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
                      Container(
                        child: TextFormField(
                          decoration: InputDecoration(
                            labelText: "search",
                            hintText: "search",
                          ),
                          onChanged: (String searchInput) {
                            _employeeDataSource._search(searchInput);
                          },
                        ),
                        width: 120,
                      ),
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
                                style: TextStyle(
                                    fontSize: 13,
                                    color: Theme.of(context).accentColor),
                              )
                            ],
                          ),
                    rowsPerPage: _rowsPerPage,
                    availableRowsPerPage: <int>[
                      _rowsPerPage,
                      _rowsPerPage * 2,
                      _rowsPerPage * 5,
                      _rowsPerPage * 10
                    ],
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
                          nameSortAscending = !nameSortAscending;
                          return _sort<String>((d) => d.name.toLowerCase(),
                              columnIndex, nameSortAscending);
                        },
                      ),
                      DataColumn(
                        label: Text("Phone number"),
                        onSort: (columnIndex, ascending) {
                          phoneNumberSortAscending = !phoneNumberSortAscending;
                          _sort<String>((d) => d.phoneNumber, columnIndex,
                              phoneNumberSortAscending);
                        },
                      ),
                      DataColumn(
                        label: Text("Address"),
                        onSort: (columnIndex, ascending) {
                          addressSortAscending = !addressSortAscending;
                          _sort<String>((d) => d.address, columnIndex,
                              addressSortAscending);
                        },
                      ),
                      DataColumn(
                        label: Text("Date"),
                        onSort: (columnIndex, ascending) {
                          dateSortAscending = !dateSortAscending;
                          _sort<DateTime>((d) => d.firstModified, columnIndex,
                              dateSortAscending);
                        },
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
  List<Personnel> employees;
  List<Personnel> originalBatch = [];
  final Function updateTable;
  final GlobalKey<CreateEmployeeViewState> createEmployeeKey;
  int _selectedCount = 0;

  _EmployeeDataSource(
      this.context, this.employees, this.updateTable, this.createEmployeeKey) {
    originalBatch = List.from(employees);
  }

  void _sort<T>(Comparable<T> Function(Personnel d) getField, bool ascending) {
    employees.sort((a, b) {
      final aValue = getField(a);
      final bValue = getField(b);
      return ascending
          ? Comparable.compare(aValue, bValue)
          : Comparable.compare(bValue, aValue);
    });
    notifyListeners();
  }

  void _search(String searchInput) {
    employees =
        List.from(originalBatch); // Restoring products from original batch
    employees.retainWhere((Personnel p) =>
        p.name.toLowerCase().contains(searchInput.toLowerCase()));

    notifyListeners();
  }

  @override
  DataRow getRow(int index) {
    assert(index >= 0);
    if (index >= employees.length) return null;
    final employee = employees[index];
    return DataRow.byIndex(
      index: index,
      cells: [
        DataCell(
            Text(
              employee.name ?? '-',
              style: TextStyle(color: Theme.of(context).primaryColor),
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
                  Icon(Icons.clear,
                      size: 50, color: Theme.of(context).accentColor),
                ],
              ),
              message:
                  "Are you sure you want to delete employee\n${personnel.name}",
              onYes: () async {
                // Delete employee here.

                String where = "${Personnel.ID} = ?";
                List<String> whereArgs = [
                  personnel.id
                ]; // Querying only employees

                List<Personnel> deletePersonnelList =
                    await PersonnelDAL.find(where: where, whereArgs: whereArgs);

                await PersonnelDAL.delete(where: where, whereArgs: whereArgs);
                await Contacts.deleteContact(Contact(
                    identifier:
                        personnel.contactIdentifier)); // Deleting contact

                Personnel deletePersonnel = deletePersonnelList.first;
                if (deletePersonnel.idFS != null) {
//                  Firestore.instance.collection(Personnel.EMPLOYEE).document(deletePersonnel.idFS).delete();
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
