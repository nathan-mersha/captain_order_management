import 'package:captain/db/dal/returned_order.dart';
import 'package:captain/db/model/product.dart';
import 'package:captain/db/model/returned_order.dart';
import 'package:captain/page/product/create_product.dart';
import 'package:captain/page/returned_order/create_returned_order.dart';
import 'package:captain/page/returned_order/statistics_returned_order.dart';
import 'package:captain/widget/c_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ReturnedOrderTable extends StatefulWidget {
  final GlobalKey<CreateReturnedOrderViewState> createReturnedOrderKey;
  final GlobalKey<StatisticsReturnedOrderViewState> statisticsReturnedOrderKey;
  final GlobalKey<ReturnedOrderTableState> returnedOrderTableKey;

  const ReturnedOrderTable({this.returnedOrderTableKey, this.createReturnedOrderKey, this.statisticsReturnedOrderKey}) : super(key: returnedOrderTableKey);

  @override
  ReturnedOrderTableState createState() => ReturnedOrderTableState();
}

class ReturnedOrderTableState extends State<ReturnedOrderTable> {
  int _rowsPerPage;
  int _sortColumnIndex;
  bool _sortAscending = true;
  _ReturnedOrderDataSource _returnedOrderDataSource;

  void _sort<T>(
    Comparable<T> Function(ReturnedOrder d) getField,
    int columnIndex,
    bool ascending,
  ) {
    _returnedOrderDataSource._sort<T>(getField, ascending);
    _sortColumnIndex = columnIndex;
    _sortAscending = ascending;
  }

  Future<List<ReturnedOrder>> getListOfReturnedOrders() async {
    List<ReturnedOrder> returnedOrders = await ReturnedOrderDAL.find();
    return returnedOrders;
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
              future: getListOfReturnedOrders(),
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  List<ReturnedOrder> returnedOrders = snapshot.data as List<ReturnedOrder>;
                  _ReturnedOrderDataSource _returnedOrderDataSourceVal = _ReturnedOrderDataSource(context, returnedOrders, () {
                    setState(() {
                      // updating table here.
                    });
                  }, widget.createReturnedOrderKey);
                  _returnedOrderDataSource = _returnedOrderDataSourceVal;
                } else {
                  _returnedOrderDataSource = _ReturnedOrderDataSource(context, [], () {
                    setState(() {
                      // updating table here.
                    });
                  }, widget.createReturnedOrderKey);
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
                            _returnedOrderDataSource._search(searchInput);
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
                            "List of returned orders",
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
                                "Loading returned orders",
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
                    columnSpacing: 20,
                    columns: [
                      DataColumn(
                        label: Text("Employee"),
                        onSort: (columnIndex, ascending) {
                          return _sort<String>((d) => d.employee.name, columnIndex, ascending);
                        },
                      ),
                      DataColumn(
                        label: Text("Color"),
                      ),
                      DataColumn(
                        label: Text("Count"),
                        onSort: (columnIndex, ascending) {
                          return _sort<num>((d) => d.count, columnIndex, ascending);
                        },
                      ),
                      DataColumn(
                        label: Text("Customer"),
                        onSort: (columnIndex, ascending) {
                          return _sort<String>((d) => d.customer.name, columnIndex, ascending);
                        },
                      ),
                      DataColumn(
                        label: Text("Date"),
                        onSort: (columnIndex, ascending) => _sort<DateTime>((d) => d.firstModified, columnIndex, ascending),
                      ),
                      DataColumn(
                        label: Text(""),
                      ),
                    ],
                    source: _returnedOrderDataSource);
              },
            )
          ],
        ),
      ),
    );
  }
}

class _ReturnedOrderDataSource extends DataTableSource {
  final BuildContext context;
  List<ReturnedOrder> returnedOrders;
  List<ReturnedOrder> originalBatch = [];
  final Function updateTable;
  final GlobalKey<CreateReturnedOrderViewState> createReturnedOrderKey;
  int _selectedCount = 0;

  _ReturnedOrderDataSource(this.context, this.returnedOrders, this.updateTable, this.createReturnedOrderKey) {
    originalBatch = List.from(returnedOrders);
  }

  void _sort<T>(Comparable<T> Function(ReturnedOrder d) getField, bool ascending) {
    returnedOrders.sort((a, b) {
      final aValue = getField(a);
      final bValue = getField(b);
      return ascending ? Comparable.compare(aValue, bValue) : Comparable.compare(bValue, aValue);
    });
    notifyListeners();
  }

  void _search(String searchInput) {
    returnedOrders = List.from(originalBatch); // Restoring returned order from original batch
    returnedOrders.retainWhere((ReturnedOrder r) => r.product.name.toLowerCase().startsWith(searchInput.toLowerCase()));
    notifyListeners();
  }

  Widget buildProductView(Product product) {
    if (product.type == CreateProductViewState.PAINT) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              product.isGallonBased ? Icon(Icons.check_circle, size: 9, color: Theme.of(context).primaryColorLight) : Container(),
              SizedBox(
                width: 5,
              ),
              Text(product.name ?? '-'),
            ],
          ),
          SizedBox(
            height: 4,
          ),
          Container(
            height: 5,
            width: 16,
            color: Color(int.parse(product.colorValue ?? "0xfffffffff")),
          )
        ],
      );
    } else {
      return Text(product.name ?? '-');
    }
  }

  @override
  DataRow getRow(int index) {
    assert(index >= 0);
    if (index >= returnedOrders.length) return null;
    final returnedOrder = returnedOrders[index];
    return DataRow.byIndex(
      index: index,
      cells: [
        DataCell(
            Text(
              returnedOrder.employee.name ?? '-',
              style: TextStyle(color: Theme.of(context).primaryColor),
            ), onTap: () {
          createReturnedOrderKey.currentState.passForUpdate(returnedOrders[index]);
        }),
        DataCell(buildProductView(returnedOrder.product)),
        DataCell(Text(returnedOrder.count.toString() ?? "-")),
        DataCell(Text(returnedOrder.customer == null ? "-" : returnedOrder.customer.name)),
        DataCell(Text(DateFormat.yMMMd().format(returnedOrder.firstModified))),
        DataCell(IconButton(
          icon: Icon(
            Icons.delete_outline,
            color: Theme.of(context).accentColor,
            size: 15,
          ),
          onPressed: () {
            // deleting returnedOrder here.
            deleteReturnedOrder(returnedOrders[index]).then((value) => updateTable());
          },
        ))
      ],
    );
  }

  Future<void> deleteReturnedOrder(ReturnedOrder returnedOrder) async {
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
              message: "Are you sure you want to delete returnedOrder of\n${returnedOrder.employee.name}",
              onYes: () async {
                // Delete returnedOrder here.

                String where = "${ReturnedOrder.ID} = ?";
                List<String> whereArgs = [returnedOrder.id]; // Querying only returnedOrders

                List<ReturnedOrder> deleteReturnedOrderList = await ReturnedOrderDAL.find(where: where, whereArgs: whereArgs);

                await ReturnedOrderDAL.delete(where: where, whereArgs: whereArgs);

                ReturnedOrder deleteReturnedOrder = deleteReturnedOrderList.first;
                if (deleteReturnedOrder.idFS != null) {
                  Firestore.instance.collection(ReturnedOrder.COLLECTION_NAME).document(deleteReturnedOrder.idFS).delete();
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
  int get rowCount => returnedOrders == null ? 0 : returnedOrders.length;

  @override
  bool get isRowCountApproximate => false;

  @override
  int get selectedRowCount => _selectedCount;
}
