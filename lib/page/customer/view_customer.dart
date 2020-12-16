import 'package:captain/db/dal/personnel.dart';
import 'package:captain/db/model/personnel.dart';
import 'package:captain/page/customer/create_customer.dart';
import 'package:captain/page/customer/statistics_customer.dart';
import 'package:captain/widget/c_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contact/contacts.dart';
import 'package:intl/intl.dart';

class CustomerTable extends StatefulWidget {
  final GlobalKey<CreateCustomerViewState> createCustomerKey;
  final GlobalKey<StatisticsCustomerViewState> statisticsCustomerKey;
  final GlobalKey<CustomerTableState> customerTableKey;

  const CustomerTable(
      {this.customerTableKey,
      this.createCustomerKey,
      this.statisticsCustomerKey})
      : super(key: customerTableKey);

  @override
  CustomerTableState createState() => CustomerTableState();
}

class CustomerTableState extends State<CustomerTable> {
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
    return customers;
  }

  bool nameSortAscending = true;
  bool phoneNumberSortAscending = true;
  bool addressSortAscending = true;
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
                  _CustomerDataSource _customerDataSourceVal =
                      _CustomerDataSource(context, customers, () {
                    setState(() {
                      // updating table here.
                    });
                  }, widget.createCustomerKey);
                  _customerDataSource = _customerDataSourceVal;
                } else {
                  _customerDataSource = _CustomerDataSource(context, [], () {
                    setState(() {
                      // updating table here.
                    });
                  }, widget.createCustomerKey);
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
                        ? Text(
                            "List of customers",
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
                                "Loading customers",
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
                    onPageChanged: (int page) {
                      pageIndex = page;
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
  final GlobalKey<CreateCustomerViewState> createCustomerKey;
  int _selectedCount = 0;

  _CustomerDataSource(
      this.context, this.customers, this.updateTable, this.createCustomerKey) {
    originalBatch = List.from(customers);
  }

  void _sort<T>(Comparable<T> Function(Personnel d) getField, bool ascending) {
    customers.sort((a, b) {
      final aValue = getField(a);
      final bValue = getField(b);
      return ascending
          ? Comparable.compare(aValue, bValue)
          : Comparable.compare(bValue, aValue);
    });
    notifyListeners();
  }

  void _search(String searchInput) {
    customers =
        List.from(originalBatch); // Restoring products from original batch
    customers.retainWhere((Personnel p) =>
        p.name.toLowerCase().contains(searchInput.toLowerCase()));
    notifyListeners();
  }

  @override
  DataRow getRow(int index) {
    assert(index >= 0);
    if (index >= customers.length) return null;
    final customer = customers[index];
    return DataRow.byIndex(
      index: index,
      cells: [
        DataCell(
            Text(
              customer.name ?? '-',
              style: TextStyle(color: Theme.of(context).primaryColor),
            ), onTap: () {
          createCustomerKey.currentState.passForUpdate(customers[index]);
        }),
        DataCell(Text(customer.phoneNumber ?? '-')),
        DataCell(Text(customer.address ?? '-')),
        DataCell(Text(DateFormat.yMMMd().format(customer.firstModified))),
        DataCell(IconButton(
          icon: Icon(
            Icons.delete_outline,
            color: Theme.of(context).accentColor,
            size: 15,
          ),
          onPressed: () {
            // deleting customer here.
            deleteCustomer(customers[index]).then((value) => updateTable());
          },
        ))
      ],
    );
  }

  Future<void> deleteCustomer(Personnel personnel) async {
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
                  "Are you sure you want to delete customer\n${personnel.name}",
              onYes: () async {
                // Delete customer here.

                String where = "${Personnel.ID} = ?";
                List<String> whereArgs = [
                  personnel.id
                ]; // Querying only customers

                List<Personnel> deletePersonnelList =
                    await PersonnelDAL.find(where: where, whereArgs: whereArgs);

                await PersonnelDAL.delete(where: where, whereArgs: whereArgs);
                await Contacts.deleteContact(Contact(
                    identifier:
                        personnel.contactIdentifier)); // Deleting contact

                Personnel deletePersonnel = deletePersonnelList.first;
                if (deletePersonnel.idFS != null) {
//                  Firestore.instance.collection(Personnel.CUSTOMER).document(deletePersonnel.idFS).delete();
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
  int get rowCount => customers == null ? 0 : customers.length;

  @override
  bool get isRowCountApproximate => false;

  @override
  int get selectedRowCount => _selectedCount;
}
