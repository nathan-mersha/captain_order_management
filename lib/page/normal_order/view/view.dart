import 'package:captain/db/dal/normal_order.dart';
import 'package:captain/db/model/normal_order.dart';
import 'package:captain/db/model/product.dart';
import 'package:captain/page/normal_order/main.dart';
import 'package:captain/page/normal_order/view/statistics_normal_order.dart';
import 'package:captain/page/product/create_product.dart';
import 'package:captain/widget/c_dialog.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:captain/global.dart' as global;

class NormalOrderTablePage extends StatefulWidget {
  final Function navigateTo;

  NormalOrderTablePage({this.navigateTo});

  @override
  NormalOrderTablePageState createState() => NormalOrderTablePageState();
}

class NormalOrderTablePageState extends State<NormalOrderTablePage> {
  int _rowsPerPage;
  int _sortColumnIndex;
  bool _sortAscending = true;
  _NormalOrderDataSource _normalOrderDataSource;
  TextEditingController _searchController = TextEditingController();

  bool customerSortAscending = true;
  bool totalSortAscending = true;
  bool remainingSortAscending = true;
  bool paidSortAscending = true;
  bool notifiedSortAscending = true;
  bool statusSortAscending = true;
  bool dateSortAscending = true;

  void _sort<T>(
    Comparable<T> Function(NormalOrder d) getField,
    int columnIndex,
    bool ascending,
  ) {
    _normalOrderDataSource._sort<T>(getField, ascending);
    _sortColumnIndex = columnIndex;
    _sortAscending = ascending;
  }

  Future<List<NormalOrder>> getListOfNormalOrders() async {
    List<NormalOrder> normalOrders = await NormalOrderDAL.find();
    return normalOrders;
  }

  @override
  void dispose() {
    super.dispose();
    _searchController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 645,
      child: Stack(
        children: [
          Column(
            children: [
              StatisticsNormalOrderView(),
              Scrollbar(
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    FutureBuilder(
                      future: getListOfNormalOrders(),
                      builder: (BuildContext context, AsyncSnapshot snapshot) {
                        if (snapshot.connectionState == ConnectionState.done) {
                          List<NormalOrder> normalOrders = snapshot.data as List<NormalOrder>;
                          _NormalOrderDataSource _normalOrderDataSourceVal = _NormalOrderDataSource(context, normalOrders, () {
                            setState(() {
                              // updating table here.
                            });
                          }, widget.navigateTo);
                          _normalOrderDataSource = _normalOrderDataSourceVal;
                        } else {
                          _normalOrderDataSource = _NormalOrderDataSource(context, [], () {
                            setState(() {
                              // updating table here.
                            });
                          }, widget.navigateTo);
                        }

                        if (global.normalOrderSearchHistory != null && global.normalOrderSearchHistory.isNotEmpty && _normalOrderDataSource != null) {
                          _searchController.text = global.normalOrderSearchHistory;
                          _normalOrderDataSource._search(global.normalOrderSearchHistory);
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
                                  onChanged: (String searchInputValue) {
                                    global.normalOrderSearchHistory = searchInputValue;
                                    _normalOrderDataSource._search(searchInputValue);
                                  },
                                  controller: _searchController,
                                ),
                                width: 190,
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
                                    "List of orders",
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
                                        "Loading orders",
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
                                label: Text("Customer", style: TextStyle(fontWeight: FontWeight.w800)),
                                onSort: (columnIndex, ascending) {
                                  customerSortAscending = !customerSortAscending;
                                  return _sort<String>((d) => d.customer.name, columnIndex, customerSortAscending);
                                },
                              ),
                              DataColumn(
                                label: Text("Orders", style: TextStyle(fontWeight: FontWeight.w800)),
                              ),
                              DataColumn(
                                label: Text("Total(br)", style: TextStyle(fontWeight: FontWeight.w800)),
                                onSort: (columnIndex, ascending) {
                                  totalSortAscending = !totalSortAscending;
                                  return _sort<num>((d) => d.totalAmount, columnIndex, totalSortAscending);
                                },
                              ),
                              DataColumn(
                                label: Text("Remaining(br)", style: TextStyle(fontWeight: FontWeight.w800)),
                                onSort: (columnIndex, ascending) {
                                  remainingSortAscending = !remainingSortAscending;
                                  return _sort<num>((d) => d.remainingPayment, columnIndex, remainingSortAscending);
                                },
                              ),
                              DataColumn(
                                label: Text("Paid", style: TextStyle(fontWeight: FontWeight.w800)),
                                onSort: (columnIndex, ascending) {
                                  paidSortAscending = !paidSortAscending;
                                  return _sort<String>((d) => getPaidStatus(d), columnIndex, paidSortAscending);
                                },
                              ),
                              DataColumn(
                                label: Text("Notified", style: TextStyle(fontWeight: FontWeight.w800)),
                                onSort: (columnIndex, ascending) {
                                  notifiedSortAscending = !notifiedSortAscending;
                                  return _sort<String>((d) => d.userNotified.toString(), columnIndex, notifiedSortAscending);
                                },
                              ),
                              DataColumn(
                                label: Text("Status", style: TextStyle(fontWeight: FontWeight.w800)),
                                onSort: (columnIndex, ascending) {
                                  statusSortAscending = !statusSortAscending;
                                  return _sort<String>((d) => getOverallStatus(d), columnIndex, statusSortAscending);
                                },
                              ),
                              DataColumn(
                                label: Text("Date", style: TextStyle(fontWeight: FontWeight.w800)),
                                onSort: (columnIndex, ascending) {
                                  dateSortAscending = !dateSortAscending;
                                  return _sort<DateTime>((d) => d.firstModified, columnIndex, dateSortAscending);
                                },
                              ),
                              DataColumn(
                                label: Text(""),
                              ),
                            ],
                            source: _normalOrderDataSource);
                      },
                    )
                  ],
                ),
              )
            ],
          ),
          Positioned(
            child: FloatingActionButton(
              child: Icon(Icons.add),
              onPressed: () {
                NormalOrder normalOrder =
                    NormalOrder(advancePayment: 0, paidInFull: false, totalAmount: 0, remainingPayment: 0, userNotified: false, status: NormalOrderMainPageState.PENDING, products: []);
                widget.navigateTo(NormalOrderMainPageState.PAGE_CREATE_NORMAL_ORDER, passedNormalOrder: normalOrder);
              },
            ),
            bottom: 0,
            left: 20,
          )
        ],
      ),
    );
  }

  static Widget getOrdersCount(NormalOrder normalOrder) {
    List<Product> products = normalOrder.products;
    num paintCount = 0;
    num otherCount = 0;

    products.forEach((Product p) {
      p.type == CreateProductViewState.PAINT ? paintCount += 1 : otherCount += 1;
    });

    return Row(
      children: [
        Icon(
          Icons.invert_colors,
          color: Colors.deepPurpleAccent,
          size: 12,
        ),
        SizedBox(
          width: 3,
        ),
        Text(
          paintCount.toStringAsFixed(0),
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
        SizedBox(
          width: 8,
        ),
        Icon(
          Icons.shopping_basket,
          color: Colors.blue,
          size: 12,
        ),
        SizedBox(
          width: 3,
        ),
        Text(
          otherCount.toStringAsFixed(0),
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        )
      ],
    );
  }

  static num getLtrsCount(NormalOrder normalOrder) {
    List<Product> products = normalOrder.products;
    num ltrsCount = 0;

    products.forEach((Product p) {
      if (p.type == CreateProductViewState.PAINT) {
        ltrsCount += p.quantityInCart;
      }
    });

    return ltrsCount;
  }

  static num getPendingCount(NormalOrder normalOrder) {
    List<Product> products = normalOrder.products;
    num pendingCount = 0;

    products.forEach((Product p) {
      if (p.type == CreateProductViewState.PAINT && p.status == NormalOrderMainPageState.PENDING) {
        pendingCount += 1;
      }
    });
    return pendingCount;
  }

  static num getCompletedCount(NormalOrder normalOrder) {
    List<Product> products = normalOrder.products;
    num completedCount = 0;

    products.forEach((Product p) {
      if (p.type == CreateProductViewState.PAINT && p.status == NormalOrderMainPageState.COMPLETED) {
        completedCount += 1;
      }
    });
    return completedCount;
  }

  static String getOverallStatus(NormalOrder normalOrder) {
    List<Product> products = normalOrder.products;
    bool allCompleted = products.every((Product product) => product.status == NormalOrderMainPageState.COMPLETED);
    bool allDelivered = products.every((Product product) => product.status == NormalOrderMainPageState.DELIVERED);
    if (allCompleted) {
      return NormalOrderMainPageState.COMPLETED;
    } else if (allDelivered) {
      return NormalOrderMainPageState.DELIVERED;
    } else {
      return NormalOrderMainPageState.PENDING;
    }
  }

  static Color getStatusColor(String status) {
    if (status == NormalOrderMainPageState.COMPLETED) {
      return Colors.green;
    } else if (status == NormalOrderMainPageState.DELIVERED) {
      return Colors.blue;
    } else {
      return Colors.black26;
    }
  }

  static String getPaidStatus(NormalOrder normalOrder) {
    bool paidInFull = normalOrder.totalAmount == normalOrder.advancePayment;
    return paidInFull.toString();
  }
}

class _NormalOrderDataSource extends DataTableSource {
  final oCCy = NumberFormat("#,##0.00", "en_US");

  final BuildContext context;
  List<NormalOrder> normalOrders = [];
  List<NormalOrder> originalBatch = [];
  final Function updateTable;
  final Function navigate;
  int _selectedCount = 0;

  _NormalOrderDataSource(this.context, this.normalOrders, this.updateTable, this.navigate) {
    originalBatch = List.from(normalOrders ?? []);
  }

  void _sort<T>(Comparable<T> Function(NormalOrder d) getField, bool ascending) {
    normalOrders.sort((a, b) {
      final aValue = getField(a);
      final bValue = getField(b);
      return ascending ? Comparable.compare(aValue, bValue) : Comparable.compare(bValue, aValue);
    });
    notifyListeners();
  }

  void _search(String searchInput) {
    normalOrders = List.from(originalBatch); // Restoring products from original batch
    normalOrders.retainWhere((NormalOrder p) => p.customer.name.toLowerCase().contains(searchInput.toLowerCase()));
    notifyListeners();
  }

  @override
  DataRow getRow(int index) {
    assert(index >= 0);
    if (index >= normalOrders.length) return null;
    final normalOrder = normalOrders[index];
    return DataRow.byIndex(
      index: index,
      cells: [
        /// Customer
        DataCell(
            Text(
              normalOrder.customer.name ?? '-',
              style: TextStyle(color: Theme.of(context).primaryColor),
            ), onTap: () {
          navigate(NormalOrderMainPageState.PAGE_CREATE_NORMAL_ORDER, passedNormalOrder: normalOrder);
        }),

        /// Orders
        DataCell(NormalOrderTablePageState.getOrdersCount(normalOrder)),

        /// Total (br)
        DataCell(Text(oCCy.format(normalOrder.totalAmount) ?? '-')),

        /// Remaining payment (br)
        DataCell(Text(
          oCCy.format(normalOrder.remainingPayment) ?? '-',
        )),

        /// Paid
        DataCell(Icon(
          Icons.check_circle,
          color: NormalOrderTablePageState.getPaidStatus(normalOrder) == "true" ? Colors.green : Colors.black26,
          size: 17,
        )),

        /// Notified
        DataCell(Icon(
          Icons.notifications,
          color: normalOrder.userNotified ? Colors.green : Colors.black26,
          size: 17,
        )),

        /// Status
        DataCell(Icon(
          Icons.check_circle,
          color: NormalOrderTablePageState.getStatusColor(NormalOrderTablePageState.getOverallStatus(normalOrder)),
          size: 17,
        )),

        /// First modified
        DataCell(Text(DateFormat.yMMMd().format(normalOrder.firstModified))),

        /// Delete
        DataCell(IconButton(
          icon: Icon(
            Icons.delete_outline,
            color: Theme.of(context).accentColor,
            size: 15,
          ),
          onPressed: () {
            // deleting normalOrder here.
            deleteNormalOrder(normalOrders[index]).then((value) => updateTable());
          },
        ))
      ],
    );
  }

  Future<void> deleteNormalOrder(NormalOrder normalOrder) async {
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
              message: "Are you sure you want to delete order of\n${normalOrder.customer.name}",
              onYes: () async {
                // Delete normalOrder here.

                String where = "${NormalOrder.ID} = ?";
                List<String> whereArgs = [normalOrder.id]; // Querying only normalOrders

                List<NormalOrder> deleteNormalOrderList = await NormalOrderDAL.find(where: where, whereArgs: whereArgs);

                await NormalOrderDAL.delete(where: where, whereArgs: whereArgs);

                NormalOrder deleteNormalOrder = deleteNormalOrderList.first;
                if (deleteNormalOrder.idFS != null) {
//                  Firestore.instance.collection(NormalOrder.COLLECTION_NAME).document(deleteNormalOrder.idFS).delete();
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
  int get rowCount => normalOrders == null ? 0 : normalOrders.length;

  @override
  bool get isRowCountApproximate => false;

  @override
  int get selectedRowCount => _selectedCount;
}
