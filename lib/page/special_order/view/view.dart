import 'package:captain/db/dal/special_order.dart';
import 'package:captain/db/model/product.dart';
import 'package:captain/db/model/special_order.dart';
import 'package:captain/page/product/create_product.dart';
import 'package:captain/page/special_order/main.dart';
import 'package:captain/page/special_order/view/statistics_normal_order.dart';
import 'package:captain/widget/c_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:captain/global.dart' as global;

class SpecialOrderTablePage extends StatefulWidget {
  final Function navigateTo;
  SpecialOrderTablePage({this.navigateTo});

  @override
  SpecialOrderTablePageState createState() => SpecialOrderTablePageState();
}

class SpecialOrderTablePageState extends State<SpecialOrderTablePage> {
  int _rowsPerPage;
  int _sortColumnIndex;
  bool _sortAscending = true;
  _SpecialOrderDataSource _specialOrderDataSource;
  TextEditingController _searchController = TextEditingController();

  void _sort<T>(
    Comparable<T> Function(SpecialOrder d) getField,
    int columnIndex,
    bool ascending,
  ) {
    _specialOrderDataSource._sort<T>(getField, ascending);
    _sortColumnIndex = columnIndex;
    _sortAscending = ascending;
  }

  Future<List<SpecialOrder>> getListOfSpecialOrders() async {
    List<SpecialOrder> specialOrders = await SpecialOrderDAL.find();
    return specialOrders;
  }

  bool customerSortAscending = true;
  bool addressSortAscending = true;
  bool totalSortAscending = true;
  bool dateSortAscending = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 645,
      child: Stack(
        children: [
          Column(
            children: [
              StatisticsSpecialOrderView(),
              Scrollbar(
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    FutureBuilder(
                      future: getListOfSpecialOrders(),
                      builder: (BuildContext context, AsyncSnapshot snapshot) {
                        if (snapshot.connectionState == ConnectionState.done) {
                          List<SpecialOrder> specialOrders = snapshot.data as List<SpecialOrder>;
                          _SpecialOrderDataSource _specialOrderDataSourceVal = _SpecialOrderDataSource(context, specialOrders, () {
                            setState(() {
                              // updating table here.
                            });
                          }, widget.navigateTo);
                          _specialOrderDataSource = _specialOrderDataSourceVal;
                        } else {
                          _specialOrderDataSource = _SpecialOrderDataSource(context, [], () {
                            setState(() {
                              // updating table here.
                            });
                          }, widget.navigateTo);
                        }

                        if(global.specialOrderSearchHistory != null && global.specialOrderSearchHistory.isNotEmpty && _specialOrderDataSource != null){
                          _searchController.text = global.specialOrderSearchHistory;
                          _specialOrderDataSource._search(global.specialOrderSearchHistory);
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
                                    global.specialOrderSearchHistory = searchInputValue;
                                    _specialOrderDataSource._search(searchInputValue);
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
                                    "List of special orders",
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
                            columns: [
                              DataColumn(
                                label: Text("Customer", style: TextStyle(fontWeight: FontWeight.w800)),
                                onSort: (columnIndex, ascending) {
                                  customerSortAscending = !customerSortAscending;
                                  return _sort<String>((d) => d.customer.name, columnIndex, customerSortAscending);
                                },
                              ),
                              DataColumn(
                                label: Text("Address", style: TextStyle(fontWeight: FontWeight.w800)),
                                onSort: (columnIndex, ascending) {
                                  addressSortAscending = !addressSortAscending;
                                  return _sort<String>((d) => d.customer.address, columnIndex, addressSortAscending);
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
                                label: Text("Date", style: TextStyle(fontWeight: FontWeight.w800)),
                                onSort: (columnIndex, ascending){
                                  dateSortAscending = !dateSortAscending;
                                  return  _sort<DateTime>((d) => d.firstModified, columnIndex, dateSortAscending);
                                },
                              ),
                              DataColumn(
                                label: Text(""),
                              ),
                            ],
                            source: _specialOrderDataSource);
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
                SpecialOrder specialOrder = SpecialOrder(totalAmount: 0, products: []);
                widget.navigateTo(SpecialOrderMainPageState.PAGE_CREATE_SPECIAL_ORDER, passedSpecialOrder: specialOrder);
              },
            ),
            bottom: 0,
            left: 20,
          )
        ],
      ),
    );
  }

  static Widget getOrdersCount(SpecialOrder specialOrder) {
    List<Product> products = specialOrder.products;
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

  static num getLtrsCount(SpecialOrder specialOrder) {
    List<Product> products = specialOrder.products;
    num ltrsCount = 0;

    products.forEach((Product p) {
      if (p.type == CreateProductViewState.PAINT) {
        ltrsCount += p.quantityInCart;
      }
    });

    return ltrsCount;
  }

  static num getPendingCount(SpecialOrder specialOrder) {
    List<Product> products = specialOrder.products;
    num pendingCount = 0;

    products.forEach((Product p) {
      if (p.type == CreateProductViewState.PAINT && p.status == SpecialOrderMainPageState.PENDING) {
        pendingCount += 1;
      }
    });
    return pendingCount;
  }

  static num getCompletedCount(SpecialOrder specialOrder) {
    List<Product> products = specialOrder.products;
    num completedCount = 0;

    products.forEach((Product p) {
      if (p.type == CreateProductViewState.PAINT && p.status == SpecialOrderMainPageState.COMPLETED) {
        completedCount += 1;
      }
    });
    return completedCount;
  }

  static String getOverallStatus(SpecialOrder specialOrder) {
    List<Product> products = specialOrder.products;
    bool allCompleted = products.any((Product product) => product.status == SpecialOrderMainPageState.COMPLETED);
    return allCompleted ? SpecialOrderMainPageState.COMPLETED : SpecialOrderMainPageState.PENDING;
  }
}

class _SpecialOrderDataSource extends DataTableSource {
  final oCCy = NumberFormat("#,##0.00", "en_US");

  final BuildContext context;
  List<SpecialOrder> specialOrders = [];
  List<SpecialOrder> originalBatch = [];
  final Function updateTable;
  final Function navigate;
  int _selectedCount = 0;

  _SpecialOrderDataSource(this.context, this.specialOrders, this.updateTable, this.navigate) {
    originalBatch = List.from(specialOrders ?? []);
  }

  void _sort<T>(Comparable<T> Function(SpecialOrder d) getField, bool ascending) {
    specialOrders.sort((a, b) {
      final aValue = getField(a);
      final bValue = getField(b);
      return ascending ? Comparable.compare(aValue, bValue) : Comparable.compare(bValue, aValue);
    });
    notifyListeners();
  }

  void _search(String searchInput) {
    specialOrders = List.from(originalBatch); // Restoring products from original batch
    specialOrders.retainWhere((SpecialOrder p) => p.customer.name.toLowerCase().contains(searchInput.toLowerCase()));
    notifyListeners();
  }

  @override
  DataRow getRow(int index) {
    assert(index >= 0);
    if (index >= specialOrders.length) return null;
    final specialOrder = specialOrders[index];
    return DataRow.byIndex(
      index: index,
      cells: [
        /// Customer
        DataCell(
            Text(
              specialOrder.customer.name ?? '-',
              style: TextStyle(color: Theme.of(context).primaryColor),
            ), onTap: () {
          navigate(SpecialOrderMainPageState.PAGE_CREATE_SPECIAL_ORDER, passedSpecialOrder: specialOrder);
        }),

        /// Address
        DataCell(
          Text(
            specialOrder.customer.address ?? '-',
          ),
        ),

        /// Orders
        DataCell(SpecialOrderTablePageState.getOrdersCount(specialOrder)),

        /// Total (br)
        DataCell(Text("${oCCy.format(specialOrder.totalAmount)} br" ?? '-')),

        /// First modified
        DataCell(Text(DateFormat.yMMMd().format(specialOrder.firstModified))),

        /// Delete
        DataCell(IconButton(
          icon: Icon(
            Icons.delete_outline,
            color: Theme.of(context).accentColor,
            size: 15,
          ),
          onPressed: () {
            // deleting specialOrder here.
            deleteSpecialOrder(specialOrders[index]).then((value) => updateTable());
          },
        ))
      ],
    );
  }

  Future<void> deleteSpecialOrder(SpecialOrder specialOrder) async {
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
              message: "Are you sure you want to delete order of\n${specialOrder.customer.name}",
              onYes: () async {
                // Delete specialOrder here.

                String where = "${SpecialOrder.ID} = ?";
                List<String> whereArgs = [specialOrder.id]; // Querying only specialOrders

                List<SpecialOrder> deleteSpecialOrderList = await SpecialOrderDAL.find(where: where, whereArgs: whereArgs);

                await SpecialOrderDAL.delete(where: where, whereArgs: whereArgs);

                SpecialOrder deleteSpecialOrder = deleteSpecialOrderList.first;
                if (deleteSpecialOrder.idFS != null) {
                  Firestore.instance.collection(SpecialOrder.COLLECTION_NAME).document(deleteSpecialOrder.idFS).delete();
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
  int get rowCount => specialOrders == null ? 0 : specialOrders.length;

  @override
  bool get isRowCountApproximate => false;

  @override
  int get selectedRowCount => _selectedCount;
}
