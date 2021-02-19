import 'dart:io';

import 'package:captain/db/dal/personnel.dart';
import 'package:captain/db/model/personnel.dart';
import 'package:captain/widget/c_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class CustomerDetail extends StatefulWidget {
  final String address;

  CustomerDetail({this.address});

  @override
  CustomerDetailState createState() => CustomerDetailState();
}

class CustomerDetailState extends State<CustomerDetail> {
  int _rowsPerPage;
  int _sortColumnIndex;
  bool _sortAscending = true;
  _CustomerDataSource _customerDataSource;

  void _sort<T>(
      Comparable<T> Function(Personnel d) getField,
      int columnIndex,
      bool ascending,
      ) {
    _customerDataSource._sort<T>(getField, ascending);
    _sortColumnIndex = columnIndex;
    _sortAscending = ascending;
  }

  Future<List<Personnel>> getListOfCustomers() async {
    String where = "${Personnel.TYPE} = ?";
    List<String> whereArgs = [Personnel.CUSTOMER]; // Querying only customers
    List<Personnel> customers = await PersonnelDAL.find(
      where: where,
      whereArgs: whereArgs,
    );

    List<Personnel> filtered = [];
    customers.forEach((Personnel personnel) {
      if(personnel.address == widget.address){
        filtered.add(personnel);
      }
    });
    return filtered;
  }

  bool nameSortAscending = true;
  bool phoneNumberSortAscending = true;
  bool emailSortAscending = true;
  bool addressSortAscending = true;
  bool addressDetailSortAscending = true;
  bool dateSortAscending = true;

  int pageIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 535,
      child: Scrollbar(
        child: ListView(
          shrinkWrap: true,
          children: [
            FutureBuilder(
              future: getListOfCustomers(),
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  List<Personnel> customers = snapshot.data as List<Personnel>;
                  _CustomerDataSource _customerDataSourceVal = _CustomerDataSource(context, customers, () {
                    setState(() {
                      // updating table here.
                    });
                  });
                  _customerDataSource = _customerDataSourceVal;
                } else {
                  _customerDataSource = _CustomerDataSource(context, [], () {
                    setState(() {
                      // updating table here.
                    });
                  },);
                }

                _rowsPerPage = 6;

                return PaginatedDataTable(
                  dataRowHeight: 53,
                    actions: [
                      Container(
                        child: TextFormField(
                          decoration: InputDecoration(
                            labelText: "search",
                            hintText: "search",
                          ),
                          onChanged: (String searchInput) {
                            _customerDataSource._search(searchInput);
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
                        ? Row(children: [
                      Text(
                        "List of customers in ",
                        style: TextStyle(
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        widget.address,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Theme.of(context).accentColor
                        ),
                      )
                    ],)
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
                          "Loading customers",
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
                    onPageChanged: (int page) {
                      pageIndex = page;
                    },
                    sortColumnIndex: _sortColumnIndex,
                    sortAscending: _sortAscending,
                    columnSpacing: 30,
                    columns: [
                      DataColumn(
                        label: Text(""),
                      ),
                      DataColumn(
                        label: Text("Name"),
                        onSort: (columnIndex, ascending) {
                          nameSortAscending = !nameSortAscending;
                          return _sort<String>((d) => d.name.toLowerCase(), columnIndex, nameSortAscending);
                        },
                      ),
                      DataColumn(
                        label: Text("Phone number"),
                        onSort: (columnIndex, ascending) {
                          phoneNumberSortAscending = !phoneNumberSortAscending;
                          _sort<String>((d) => d.phoneNumber, columnIndex, phoneNumberSortAscending);
                        },
                      ),
                      DataColumn(
                        label: Text("Email"),
                        onSort: (columnIndex, ascending) {
                          emailSortAscending = !emailSortAscending;
                          _sort<String>((d) => d.email, columnIndex, emailSortAscending);
                        },
                      ),
                      DataColumn(
                        label: Text("Detail"),
                        onSort: (columnIndex, ascending) {
                          addressDetailSortAscending = !addressDetailSortAscending;
                          _sort<String>((d) => d.addressDetail, columnIndex, addressDetailSortAscending);
                        },
                      ),
                      DataColumn(
                        label: Text("Date"),
                        onSort: (columnIndex, ascending) {
                          dateSortAscending = !dateSortAscending;
                          _sort<DateTime>((d) => d.firstModified, columnIndex, dateSortAscending);
                        },
                      ),
                      DataColumn(
                        label: Text(""),
                      ),
                    ],
                    source: _customerDataSource);
              },
            )
          ],
        ),
      ),
    );
  }
}

class _CustomerDataSource extends DataTableSource {
  final BuildContext context;
  List<Personnel> customers;
  List<Personnel> originalBatch = [];
  final Function updateTable;
  int _selectedCount = 0;

  _CustomerDataSource(this.context, this.customers, this.updateTable) {
    originalBatch = List.from(customers);
  }

  void _sort<T>(Comparable<T> Function(Personnel d) getField, bool ascending) {
    customers.sort((a, b) {
      final aValue = getField(a);
      final bValue = getField(b);
      return ascending ? Comparable.compare(aValue, bValue) : Comparable.compare(bValue, aValue);
    });
    notifyListeners();
  }

  void _search(String searchInput) {
    customers = List.from(originalBatch); // Restoring products from original batch
    customers.retainWhere((Personnel p) => p.name.toLowerCase().contains(searchInput.toLowerCase()));
    notifyListeners();
  }

  Widget getProfileImage(Personnel customer) {
    double imageSize = 30;
    double iconSize = 30;

    // /storage/emulated/0/Android/data/com.awramarket.captain_order_management/files/Pictures/20201124_154051.jpg
    if (customer.profileImage == null) {
      return Container(
        // margin: padding,
        child: Icon(
          Icons.person_outline_rounded,
          color: Theme.of(context).primaryColorLight,
          size: iconSize,
        ),
      );
    } else {
      return Container(
        // margin: padding,
        height: imageSize,
        width: imageSize,
        child: ClipOval(
            child: Image.file(
              File(customer.profileImage),
              fit: BoxFit.cover,
              height: 30,
              width: 30,
            )),
      );
    }
  }

  @override
  DataRow getRow(int index) {
    assert(index >= 0);
    if (index >= customers.length) return null;
    final customer = customers[index];
    return DataRow.byIndex(
      index: index,
      cells: [
        DataCell(getProfileImage(customer)),
        DataCell(
            Text(
              customer.name ?? '-',
              style: TextStyle(color: Theme.of(context).primaryColor),
            )),
        DataCell(Text(customer.phoneNumber ?? '-')),
        DataCell(SizedBox(child: Text(customer.email ?? '-', overflow: TextOverflow.fade,maxLines: 1,),width: 100,)),
        DataCell(SizedBox(child: Text(customer.addressDetail ?? '-', overflow: TextOverflow.fade,maxLines: 1,),width: 100,)),

        DataCell(Text(DateFormat.yMMMd().format(customer.firstModified))),
        DataCell(IconButton(
          icon: Icon(
            Icons.phone,
            color: Colors.green,
          ),
          onPressed: () {
            if (customer != null && customer.phoneNumber != null) {
              String launchURL = 'tel:${customer.phoneNumber}';
              _makePhoneCall(launchURL);
            } else {
              CNotifications.showSnackBar(context, "No phone provided", "failed", () {}, backgroundColor: Colors.red);
            }
          },
        ))
      ],
    );
  }


  Future<void> _makePhoneCall(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    }
  }

  @override
  int get rowCount => customers == null ? 0 : customers.length;

  @override
  bool get isRowCountApproximate => false;

  @override
  int get selectedRowCount => _selectedCount;
}
