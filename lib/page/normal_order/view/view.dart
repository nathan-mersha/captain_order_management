import 'package:captain/db/dal/normal_order.dart';
import 'package:captain/db/model/normal_order.dart';
import 'package:captain/db/model/product.dart';
import 'package:captain/page/normal_order/main.dart';
import 'package:captain/page/product/create_product.dart';
import 'package:captain/widget/c_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
    print("here");
    List<NormalOrder> normalOrders = await NormalOrderDAL.find();
    print('Normal orders list length : ${normalOrders.length}');
    return normalOrders;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 615,
      child: Scaffold(body: Scrollbar(
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
                  });
                  _normalOrderDataSource = _normalOrderDataSourceVal;
                } else {
                  _normalOrderDataSource = _NormalOrderDataSource(context, [], () {
                    setState(() {
                      // updating table here.
                    });
                  });
                }

                _rowsPerPage = 9;

                return PaginatedDataTable(
                    actions: [
                      Container(
                        child: TextFormField(
                          decoration: InputDecoration(
                            labelText: "search",
                            hintText: "search",
                          ),
                          onChanged: (String searchInput) {
                            _normalOrderDataSource._search(searchInput);
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
                      "List of normalOrders",
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
                          "Loading normalOrders",
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
                        label: Text("Customer"),
                        onSort: (columnIndex, ascending) {
                          return _sort<String>((d) => d.customer.name, columnIndex, ascending);
                        },
                      ),
                      DataColumn(
                        label: Text("Orders"),
                      ),
                      DataColumn(
                        label: Text("Ltrs"),
                        onSort: (columnIndex, ascending) {
                          return _sort<num>((d) => getLtrsCount(d), columnIndex, ascending);
                        },
                      ),
                      DataColumn(
                        label: Text("Pending"),
                        onSort: (columnIndex, ascending) {
                          return _sort<num>((d) => getPendingCount(d), columnIndex, ascending);
                        },
                      ),
                      DataColumn(
                        label: Text("Completed"),
                        onSort: (columnIndex, ascending) {
                          return _sort<num>((d) => getCompletedCount(d), columnIndex, ascending);
                        },
                      ),
                      DataColumn(
                        label: Text("Status"),
                        onSort: (columnIndex, ascending) {
                          return _sort<String>((d) => getOverallStatus(d), columnIndex, ascending);
                        },
                      ),

                      DataColumn(
                        label: Text("Total(br)"),
                        onSort: (columnIndex, ascending) {
                          return _sort<num>((d) => d.totalAmount, columnIndex, ascending);
                        },
                      ),

                      DataColumn(
                        label: Text("Advance(br)"),
                        onSort: (columnIndex, ascending) {
                          return _sort<num>((d) => d.advancePayment, columnIndex, ascending);
                        },
                      ),

                      DataColumn(
                        label: Text("Remaining(br)"),
                        onSort: (columnIndex, ascending) {
                          return _sort<num>((d) => d.remainingPayment, columnIndex, ascending);
                        },
                      ),

                      DataColumn(
                        label: Text("Paid"),
                        onSort: (columnIndex, ascending) {
                          return _sort<String>((d) => getPaidStatus(d), columnIndex, ascending);
                        },
                      ),
                      DataColumn(
                        label: Text("Notified"),
                        onSort: (columnIndex, ascending) {
                          return _sort<String>((d) => d.userNotified.toString(), columnIndex, ascending);
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
                    source: _normalOrderDataSource);
              },
            )
          ],
        ),
      ),floatingActionButton: FloatingActionButton(
        child: Icon(Icons.create),
        onPressed: (){

          // Empty Normal order
          widget.navigateTo(NormalOrderMainPageState.PAGE_CREATE_NORMAL_ORDER);


      },),),
    );
  }


  static String getOrdersCount(NormalOrder normalOrder){
    List<Product> products = normalOrder.products;
    num paintCount = 0;
    num otherCount = 0;

    products.forEach((Product p) {
      p.type == CreateProductViewState.PAINT ? paintCount +=1 : otherCount +=1;
    });

    return "${paintCount.toStringAsFixed(0)} paints, ${otherCount.toStringAsFixed(0)} products";
  }

  static num getLtrsCount(NormalOrder normalOrder){
    List<Product> products = normalOrder.products;
    num ltrsCount = 0;

    products.forEach((Product p) {
      if(p.type == CreateProductViewState.PAINT){
        ltrsCount += p.quantityInCart;
      }
    });

    return ltrsCount;
  }

  static num getPendingCount(NormalOrder normalOrder){
    List<Product> products = normalOrder.products;
    num pendingCount = 0;

    products.forEach((Product p) {
      if(p.type == CreateProductViewState.PAINT && p.status == NormalOrderMainPageState.PENDING){
        pendingCount += 1;
      }
    });
    return pendingCount;
  }

  static num getCompletedCount(NormalOrder normalOrder){
    List<Product> products = normalOrder.products;
    num completedCount = 0;

    products.forEach((Product p) {
      if(p.type == CreateProductViewState.PAINT && p.status == NormalOrderMainPageState.COMPLETED){
        completedCount += 1;
      }
    });
    return completedCount;
  }

  static String getOverallStatus(NormalOrder normalOrder){
    List<Product> products = normalOrder.products;
    bool allCompleted = products.any((Product product) => product.status == NormalOrderMainPageState.PENDING);
    return allCompleted ? NormalOrderMainPageState.COMPLETED : NormalOrderMainPageState.PENDING;
  }

  static String getPaidStatus(NormalOrder normalOrder){
    bool paidFully = normalOrder.totalAmount == normalOrder.advancePayment;
    return paidFully ? "Fully paid" : "Partially paid";
  }


}

class _NormalOrderDataSource extends DataTableSource {
  final BuildContext context;
  List<NormalOrder> normalOrders = [];
  List<NormalOrder> originalBatch = [];
  final Function updateTable;
  int _selectedCount = 0;

  _NormalOrderDataSource(this.context, this.normalOrders, this.updateTable) {
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
    normalOrders.retainWhere((NormalOrder p) => p.customer.name.toLowerCase().startsWith(searchInput.toLowerCase()));
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
            Row(
              children: [
                normalOrder.customer.profileImage == null
                    ? Icon(
                  Icons.person,
                  color: Colors.black12,
                )
                    : ClipOval(
                  child: Image.memory(
                    normalOrder.customer.profileImage,
                    fit: BoxFit.cover,
                    height: 30,
                    width: 30,
                  ),
                ),
                SizedBox(
                  width: 10,
                ),
                Text(
                  normalOrder.customer.name ?? '-',
                  style: TextStyle(color: Theme.of(context).primaryColor),
                )
              ],
            ), onTap: () {
              // todo : open page for update
//          createNormalOrderKey.currentState.passForUpdate(normalOrders[index]);
        }),

        /// Orders
        DataCell(Text(NormalOrderTablePageState.getOrdersCount(normalOrder).toString() ?? '-')),

        /// Liters
        DataCell(Text(NormalOrderTablePageState.getLtrsCount(normalOrder).toString() ?? '-')),

        /// Pending
        DataCell(Text(NormalOrderTablePageState.getPendingCount(normalOrder).toString() ?? '-')),

        /// Completed
        DataCell(Text(NormalOrderTablePageState.getCompletedCount(normalOrder).toString() ?? '-')),

        /// Status
        DataCell(Text(NormalOrderTablePageState.getOverallStatus(normalOrder) ?? '-')),

        /// Total (br)
        DataCell(Text(normalOrder.totalAmount.toStringAsFixed(2)?? '-')),

        /// Advance Payment (br)
        DataCell(Text(normalOrder.advancePayment.toStringAsFixed(2)?? '-')),

        /// Remaining payment (br)
        DataCell(Text(normalOrder.remainingPayment.toStringAsFixed(2)?? '-')),

        /// Paid
        DataCell(Text(NormalOrderTablePageState.getPaidStatus(normalOrder) ?? '-')),

        /// Notified
        DataCell(Text(normalOrder.userNotified.toString() ?? '-')),

        DataCell(Text(DateFormat.yMMMd().format(normalOrder.firstModified))),
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
          message: "Are you sure you want to delete normalOrder of\n${normalOrder.customer.name}",
          onYes: () async {
            // Delete normalOrder here.

            String where = "${NormalOrder.ID} = ?";
            List<String> whereArgs = [normalOrder.id]; // Querying only normalOrders

            List<NormalOrder> deleteNormalOrderList = await NormalOrderDAL.find(where: where, whereArgs: whereArgs);

            await NormalOrderDAL.delete(where: where, whereArgs: whereArgs);

            NormalOrder deleteNormalOrder = deleteNormalOrderList.first;
            if (deleteNormalOrder.idFS != null) {
              Firestore.instance.collection(NormalOrder.COLLECTION_NAME).document(deleteNormalOrder.idFS).delete();
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
