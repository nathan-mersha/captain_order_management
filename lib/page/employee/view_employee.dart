import 'package:captain/db/dal/personnel.dart';
import 'package:captain/db/model/personnel.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EmployeeTable extends StatefulWidget {
  const EmployeeTable();

  @override
  _EmployeeTableState createState() => _EmployeeTableState();
}

class _EmployeeTableState extends State<EmployeeTable> {
  int _rowsPerPage;
  int _sortColumnIndex;
  bool _sortAscending = true;
  bool _searching = false;
  _EmployeeDataSource _employeeDataSource;

  void _sort<T>(
    Comparable<T> Function(Personnel d) getField,
    int columnIndex,
    bool ascending,
  ) {
    _employeeDataSource._sort<T>(getField, ascending);
    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;
    });
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
                if (snapshot.connectionState == ConnectionState.none || snapshot.connectionState == ConnectionState.waiting) {
                  return Container();
                } else {
                  List<Personnel> employees = snapshot.data as List<Personnel>;
                  _EmployeeDataSource _employeeDataSourceVal = _EmployeeDataSource(context, employees);
                  _employeeDataSource = _employeeDataSourceVal;
                  _rowsPerPage = 7;

                  return PaginatedDataTable(
                      headingRowHeight: 70,

                      header: Text(
                        "List of employees",
                        style: TextStyle(fontSize: 13),
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
                      columns: [
                        DataColumn(
                          label: Text("Img"),
                        ),
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
                }
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
  _EmployeeDataSource(this.context, this.employees);

  void _sort<T>(Comparable<T> Function(Personnel d) getField, bool ascending) {
    employees.sort((a, b) {
      final aValue = getField(a);
      final bValue = getField(b);
      print("a value : $aValue");
      print("b value : $bValue");
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
        DataCell(employee.profileImage == null
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
              )),
        DataCell(Text(employee.name ?? '-')),
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
            // todo : delete cell here.
          },
        ))
      ],
    );
  }

  @override
  int get rowCount => employees == null ? 0 : employees.length;

  @override
  bool get isRowCountApproximate => false;

  @override
  int get selectedRowCount => _selectedCount;
}
