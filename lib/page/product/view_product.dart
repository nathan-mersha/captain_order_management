import 'package:captain/db/dal/product.dart';
import 'package:captain/db/model/product.dart';
import 'package:captain/page/product/create_product.dart';
import 'package:captain/page/product/statistics_product.dart';
import 'package:captain/widget/c_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ProductTable extends StatefulWidget {
  final GlobalKey<CreateProductViewState> createProductKey;
  final GlobalKey<StatisticsProductViewState> statisticsProductKey;
  final GlobalKey<ProductTableState> productTableKey;

  const ProductTable({this.productTableKey, this.createProductKey, this.statisticsProductKey}) : super(key: productTableKey);

  @override
  ProductTableState createState() => ProductTableState();
}

class ProductTableState extends State<ProductTable> {
  int _rowsPerPage;
  int _sortColumnIndex;
  bool _sortAscending = true;
  _ProductDataSource _productDataSource;

  void _sort<T>(
    Comparable<T> Function(Product d) getField,
    int columnIndex,
    bool ascending,
  ) {
    _productDataSource._sort<T>(getField, ascending);
    _sortColumnIndex = columnIndex;
    _sortAscending = ascending;
  }

  Future<List<Product>> getListOfProducts() async {
    List<Product> products = await ProductDAL.find();
    return products;
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
              future: getListOfProducts(),
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  List<Product> products = snapshot.data as List<Product>;
                  _ProductDataSource _productDataSourceVal = _ProductDataSource(context, products, () {
                    setState(() {
                      // updating table here.
                    });
                  }, widget.createProductKey);
                  _productDataSource = _productDataSourceVal;
                } else {
                  _productDataSource = _ProductDataSource(context, [], () {
                    setState(() {
                      // updating table here.
                    });
                  }, widget.createProductKey);
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
                            "List of products",
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
                          return _sort<String>((d) => d.name, columnIndex, ascending);
                        },
                      ),
                      DataColumn(
                        label: Text("Paint type"),
                      ),
                      DataColumn(
                        label: Text("Manufacturer"),
                      ),
                      DataColumn(
                        label: Text("Price (br)"),
                        numeric: true,
                        onSort: (columnIndex, ascending) {
                          return _sort<num>((d) => d.unitPrice, columnIndex, ascending);
                        },
                      ),
                      DataColumn(
                        label: Text("Unit"),
                        onSort: (columnIndex, ascending) {
                          return _sort<String>((d) => d.unitOfMeasurement.toString(), columnIndex, ascending);
                        },
                      ),
                      DataColumn(
                        label: Text(""),
                      ),
                    ],
                    source: _productDataSource);
              },
            )
          ],
        ),
      ),
    );
  }
}

class _ProductDataSource extends DataTableSource {
  final BuildContext context;
  final List<Product> products;
  final Function updateTable;
  final GlobalKey<CreateProductViewState> createProductKey;
  _ProductDataSource(this.context, this.products, this.updateTable, this.createProductKey);

  void _sort<T>(Comparable<T> Function(Product d) getField, bool ascending) {
    products.sort((a, b) {
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
    if (index >= products.length) return null;
    final product = products[index];
    return DataRow.byIndex(
      index: index,
      cells: [
        DataCell(buildProductView(products[index]), onTap: () {
          createProductKey.currentState.passForUpdate(products[index]);
        }),
        DataCell(Text(product.paintType ?? "-")),
        DataCell(Text(product.manufacturer ?? "-", style: TextStyle(color: Colors.black54),)),
        DataCell(Text(product.unitPrice.toStringAsFixed(2))),
        DataCell(Text(product.unitOfMeasurement ?? "-", style: TextStyle(color: Colors.black54))),
        DataCell(IconButton(
          icon: Icon(
            Icons.delete_outline,
            color: Theme.of(context).accentColor,
            size: 15,
          ),
          onPressed: () {
            // deleting product here.
            deleteProduct(products[index]).then((value) => updateTable());
          },
        ))
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

  Future<void> deleteProduct(Product product) async {
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
              message: "Are you sure you want to delete product\n${product.name}",
              onYes: () async {
                // Delete product here.

                String where = "${Product.ID} = ?";
                List<String> whereArgs = [product.id]; // Querying only products

                List<Product> deleteProductList = await ProductDAL.find(where: where, whereArgs: whereArgs);

                await ProductDAL.delete(where: where, whereArgs: whereArgs);

                Product deleteProduct = deleteProductList.first;
                if (deleteProduct.idFS != null) {
                  Firestore.instance.collection(Product.COLLECTION_NAME).document(deleteProduct.idFS).delete();
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
  int get rowCount => products == null ? 0 : products.length;

  @override
  bool get isRowCountApproximate => false;

  @override
  int get selectedRowCount => _selectedCount;
}
