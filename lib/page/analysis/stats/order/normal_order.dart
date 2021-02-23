import 'package:captain/db/dal/normal_order.dart';
import 'package:captain/db/dal/special_order.dart';
import 'package:captain/db/model/normal_order.dart';
import 'package:captain/db/model/product.dart';
import 'package:captain/db/model/special_order.dart';
import 'package:captain/page/product/create_product.dart';
import 'package:captain/rsr/export/pdf_exporter.dart';
import 'package:flutter/material.dart';
import 'package:captain/global.dart' as global;
import 'package:intl/intl.dart';

class ProductSoldNormalOrderAnalysis extends StatefulWidget {
  @override
  ProductSoldNormalOrderAnalysisState createState() => ProductSoldNormalOrderAnalysisState();
}

class ProductSoldNormalOrderAnalysisState extends State<ProductSoldNormalOrderAnalysis> {
  int _rowsPerPage;
  int _sortColumnIndex;
  bool _sortAscending = true;
  _ProductDataSource _productDataSource;
  TextEditingController _searchController = TextEditingController();

  bool nameSortAscending = true;
  bool paintTypeSortAscending = true;
  bool countSortAscending = true;
  bool quantitySortAscending = true;
  bool totalAmountSortAscending = true;
  bool unitPriceSortAscending = true;

  DateTime startDate;
  DateTime endDate;
  DateFormat dateFormat = DateFormat("dd-MMM-yyyy");
  List<ProductSoldStat> productSoldStat;

  bool isSpecialOrder = false;

  @override
  void initState() {
    super.initState();
    DateTime now = DateTime.now();
    startDate = DateTime(now.year, now.month - 3, now.day - 7);
    endDate = now;
  }

  @override
  void dispose() {
    super.dispose();
    _searchController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        height: 535,
        child: Stack(
          children: [
            Scrollbar(
              child: ListView(
                shrinkWrap: true,
                children: [
                  FutureBuilder(
                    future: getListOfProductsStat(),
                    builder: (BuildContext context, AsyncSnapshot snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        productSoldStat = snapshot.data as List<ProductSoldStat>;

                        _ProductDataSource _productDataSourceVal = _ProductDataSource(
                          context,
                          productSoldStat,
                          () {
                            setState(() {
                              // updating table here.
                            });
                          },
                        );
                        _productDataSource = _productDataSourceVal;
                      } else {
                        _productDataSource = _ProductDataSource(
                          context,
                          [],
                          () {
                            setState(() {
                              // updating table here.
                            });
                          },
                        );
                      }

                      if (global.productSearchHistory != null && global.productSearchHistory.isNotEmpty && _productDataSource != null) {
                        _searchController.text = global.productSearchHistory;
                        _productDataSource._search(global.productSearchHistory);
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
                                  global.productSearchHistory = searchInput;
                                  _productDataSource._search(searchInput);
                                },
                                controller: _searchController,
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
                                }),
                            IconButton(
                                icon: Icon(
                                  Icons.picture_as_pdf,
                                  color: Theme.of(context).accentColor,
                                ),
                                onPressed: () {
                                  Exporter exporter = Exporter();
                                  exporter.toPdfProductSold(productSoldStat: productSoldStat, context: context, from: startDate, to: endDate);
                                }),
                            IconButton(
                                icon: Icon(
                                  isSpecialOrder ? Icons.star : Icons.palette,
                                  color: Theme.of(context).accentColor,
                                ),
                                onPressed: () {
                                  setState(() {
                                    isSpecialOrder = !isSpecialOrder;
                                  });
                                })
                          ],
                          headingRowHeight: 70,
                          header: snapshot.connectionState == ConnectionState.done
                              ? RichText(
                                  text: TextSpan(
                                    text: 'Sold from ',
                                    style: TextStyle(fontSize: 15, color: Colors.black87),
                                    children: <TextSpan>[
                                      TextSpan(text: dateFormat.format(startDate), style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 16, fontWeight: FontWeight.w600)),
                                      TextSpan(text: ' to '),
                                      TextSpan(text: dateFormat.format(endDate), style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 16, fontWeight: FontWeight.w600)),
                                    ],
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
                                      "Loading products",
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
                              label: Text("Name"),
                              onSort: (columnIndex, ascending) {
                                nameSortAscending = !nameSortAscending;
                                return _sort<String>((d) => d.product.name, columnIndex, nameSortAscending);
                              },
                            ),
                            DataColumn(
                              label: Text("Paint type"),
                              onSort: (columnIndex, ascending) {
                                paintTypeSortAscending = !paintTypeSortAscending;
                                return _sort<String>((d) => d.product.type ?? "-", columnIndex, paintTypeSortAscending);
                              },
                            ),
                            DataColumn(
                              label: Text("Count"),
                              onSort: (columnIndex, ascending) {
                                countSortAscending = !countSortAscending;
                                return _sort<num>((d) => d.count ?? "-", columnIndex, countSortAscending);
                              },
                            ),
                            DataColumn(
                              label: Text("Qnt"),
                              onSort: (columnIndex, ascending) {
                                quantitySortAscending = !quantitySortAscending;
                                return _sort<num>((d) => d.quantity ?? "-", columnIndex, quantitySortAscending);
                              },
                            ),
                            DataColumn(
                              label: Text("Total (br)"),
                              onSort: (columnIndex, ascending) {
                                totalAmountSortAscending = !totalAmountSortAscending;
                                return _sort<num>((d) => d.totalAmount ?? "-", columnIndex, totalAmountSortAscending);
                              },
                            ),
                            DataColumn(
                              label: Text("Unit Price (br)"),
                              onSort: (columnIndex, ascending) {
                                unitPriceSortAscending = !unitPriceSortAscending;
                                return _sort<num>((d) => d.product.unitPrice ?? "-", columnIndex, unitPriceSortAscending);
                              },
                            ),
                          ],
                          source: _productDataSource);
                    },
                  )
                ],
              ),
            ),
            Align(
              child: FloatingActionButton(
                  child: Icon(Icons.calendar_today_outlined),
                  onPressed: () async {
                    DateTimeRange dateTimeRange = await showDateRangePicker(
                      context: context,
                      firstDate: DateTime(2020, 8, 1),
                      lastDate: DateTime.now(),
                    );
                    setState(() {
                      startDate = dateTimeRange.start;
                      endDate = dateTimeRange.end;
                    });
                  }),
              alignment: Alignment.bottomLeft,
            )
          ],
        ));
  }

  bool isWithInRange(DateTime dateTime) {
    return dateTime.isAfter(startDate) && dateTime.isBefore(endDate);
  }

  void _sort<T>(
    Comparable<T> Function(ProductSoldStat d) getField,
    int columnIndex,
    bool ascending,
  ) {
    _productDataSource._sort<T>(getField, ascending);
    _sortColumnIndex = columnIndex;
    _sortAscending = ascending;
  }

  Future<List<ProductSoldStat>> getListOfProductsStat() async {
    List<ProductSoldStat> productSoldStats = [];
    if (isSpecialOrder) {
      List<SpecialOrder> specialOrders = await SpecialOrderDAL.find();
      specialOrders.forEach((SpecialOrder specialOrder) {
        if (isWithInRange(specialOrder.firstModified)) {
          // iterate if within range
          specialOrder.products.forEach((Product product) {
            int index = productSoldStats.indexWhere((ProductSoldStat stat) => stat.product.id == product.id);
            if (index == -1) {
              // new entry
              ProductSoldStat productSoldStat = ProductSoldStat(product: product, totalAmount: product.subTotal, count: 1, quantity: product.quantityInCart);
              productSoldStats.add(productSoldStat);
            } else {
              productSoldStats[index].totalAmount = productSoldStats[index].totalAmount + product.subTotal;
              productSoldStats[index].count = productSoldStats[index].count + 1;
              productSoldStats[index].quantity = productSoldStats[index].quantity + product.quantityInCart;
            }
          });
        }
      });
    } else {
      List<NormalOrder> normalOrders = await NormalOrderDAL.find();
      normalOrders.forEach((NormalOrder normalOrder) {
        if (isWithInRange(normalOrder.firstModified)) {
          // iterate if within range
          normalOrder.products.forEach((Product product) {
            int index = productSoldStats.indexWhere((ProductSoldStat stat) => stat.product.id == product.id);
            if (index == -1) {
              // new entry
              ProductSoldStat productSoldStat = ProductSoldStat(product: product, totalAmount: product.subTotal, count: 1, quantity: product.quantityInCart);
              productSoldStats.add(productSoldStat);
            } else {
              productSoldStats[index].totalAmount = productSoldStats[index].totalAmount + product.subTotal;
              productSoldStats[index].count = productSoldStats[index].count + 1;
              productSoldStats[index].quantity = productSoldStats[index].quantity + product.quantityInCart;
            }
          });
        }
      });
    }

    return productSoldStats;
  }
}

class _ProductDataSource extends DataTableSource {
  final BuildContext context;
  final Function updateTable;

  List<ProductSoldStat> productSoldStat;
  List<ProductSoldStat> originalBatch = [];
  int _selectedCount = 0;

  final oCCy = NumberFormat("#,##0.00", "en_US");

  _ProductDataSource(this.context, this.productSoldStat, this.updateTable) {
    originalBatch = List.from(productSoldStat);
  }

  void _sort<T>(Comparable<T> Function(ProductSoldStat d) getField, bool ascending) {
    productSoldStat.sort((a, b) {
      final aValue = getField(a);
      final bValue = getField(b);
      return ascending ? Comparable.compare(aValue, bValue) : Comparable.compare(bValue, aValue);
    });
    notifyListeners();
  }

  void _search(String searchInput) {
    productSoldStat = List.from(originalBatch); // Restoring products from original batch
    productSoldStat.retainWhere((ProductSoldStat p) => p.product.name.toLowerCase().contains(searchInput.toLowerCase()));
    notifyListeners();
  }

  @override
  DataRow getRow(int index) {
    assert(index >= 0);
    if (index >= productSoldStat.length) return null;
    final product = productSoldStat[index];
    return DataRow.byIndex(
      index: index,
      cells: [
        DataCell(buildProductView(productSoldStat[index].product), onTap: () {}),
        DataCell(Text(productSoldStat[index].product.type.toString() ?? "-")),
        DataCell(Text(productSoldStat[index].count.toString() ?? "-")),
        DataCell(Row(
          // crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(productSoldStat[index].quantity.toString() ?? "-"),
            SizedBox(
              width: 3,
            ),
            Text(
              productSoldStat[index].product.unitOfMeasurement.toLowerCase() ?? "-",
              style: TextStyle(fontSize: 11, color: Colors.black87),
            ),
          ],
        )),
        DataCell(Text(oCCy.format(productSoldStat[index].totalAmount))),
        DataCell(Text(oCCy.format(productSoldStat[index].product.unitPrice))),
      ],
    );
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
  int get rowCount => productSoldStat == null ? 0 : productSoldStat.length;

  @override
  bool get isRowCountApproximate => false;

  @override
  int get selectedRowCount => _selectedCount;
}

class ProductSoldStat {
  Product product;
  num count;
  num quantity;
  num totalAmount;

  ProductSoldStat({this.product, this.count, this.quantity, this.totalAmount});
}
