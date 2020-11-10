import 'package:captain/db/dal/punch.dart';
import 'package:captain/db/model/product.dart';
import 'package:captain/db/model/punch.dart';
import 'package:captain/page/product/create_product.dart';
import 'package:captain/page/punch/create_punch.dart';
import 'package:captain/page/punch/statistics_punch.dart';
import 'package:captain/widget/c_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PunchTable extends StatefulWidget {
  final GlobalKey<CreatePunchViewState> createPunchKey;
  final GlobalKey<StatisticsPunchViewState> statisticsPunchKey;
  final GlobalKey<PunchTableState> punchTableKey;

  const PunchTable({this.punchTableKey, this.createPunchKey, this.statisticsPunchKey}) : super(key: punchTableKey);

  @override
  PunchTableState createState() => PunchTableState();
}

class PunchTableState extends State<PunchTable> {
  int _rowsPerPage;
  int _sortColumnIndex;
  bool _sortAscending = true;
  _PunchDataSource _punchDataSource;

  void _sort<T>(
    Comparable<T> Function(Punch d) getField,
    int columnIndex,
    bool ascending,
  ) {
    _punchDataSource._sort<T>(getField, ascending);
    _sortColumnIndex = columnIndex;
    _sortAscending = ascending;
  }

  Future<List<Punch>> getListOfPunchs() async {
    List<Punch> punchs = await PunchDAL.find();

    return punchs;
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
              future: getListOfPunchs(),
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  List<Punch> punchs = snapshot.data as List<Punch>;
                  _PunchDataSource _punchDataSourceVal = _PunchDataSource(context, punchs, () {
                    setState(() {
                      // updating table here.
                    });
                  }, widget.createPunchKey);
                  _punchDataSource = _punchDataSourceVal;
                } else {
                  _punchDataSource = _PunchDataSource(context, [], () {
                    setState(() {
                      // updating table here.
                    });
                  }, widget.createPunchKey);
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
                            _punchDataSource._search(searchInput);
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
                            "List of punchs",
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
                                "Loading punchs",
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
                        label: Text("Type"),
                        onSort: (columnIndex, ascending) {
                          return _sort<String>((d) => d.type, columnIndex, ascending);
                        },
                      ),
                      DataColumn(
                        label: Text("Weight (gm)"),
                        onSort: (columnIndex, ascending) {
                          return _sort<num>((d) => d.weight, columnIndex, ascending);
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
                    source: _punchDataSource);
              },
            )
          ],
        ),
      ),
    );
  }
}

class _PunchDataSource extends DataTableSource {
  final BuildContext context;
  List<Punch> punchs;
  List<Punch> originalBatch = [];
  final Function updateTable;
  final GlobalKey<CreatePunchViewState> createPunchKey;
  int _selectedCount = 0;

  _PunchDataSource(this.context, this.punchs, this.updateTable, this.createPunchKey) {
    originalBatch = List.from(punchs);
  }

  void _sort<T>(Comparable<T> Function(Punch d) getField, bool ascending) {
    punchs.sort((a, b) {
      final aValue = getField(a);
      final bValue = getField(b);
      return ascending ? Comparable.compare(aValue, bValue) : Comparable.compare(bValue, aValue);
    });
    notifyListeners();
  }

  void _search(String searchInput) {
    punchs = List.from(originalBatch); // Restoring punches from original batch
    punchs.retainWhere((Punch p) => p.product.name.toLowerCase().startsWith(searchInput.toLowerCase()));
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
    if (index >= punchs.length) return null;
    final punch = punchs[index];
    return DataRow.byIndex(
      index: index,
      cells: [
        DataCell(
            Row(
              children: [
                punch.employee.profileImage == null
                    ? Icon(
                        Icons.person,
                        color: Colors.black12,
                      )
                    : ClipOval(
                        child: Image.memory(
                          punch.employee.profileImage,
                          fit: BoxFit.cover,
                          height: 30,
                          width: 30,
                        ),
                      ),
                SizedBox(
                  width: 10,
                ),
                Text(
                  punch.employee.name ?? '-',
                  style: TextStyle(color: Theme.of(context).primaryColor),
                )
              ],
            ), onTap: () {
          createPunchKey.currentState.passForUpdate(punchs[index]);
        }),
        DataCell(buildProductView(punch.product)),
        DataCell(Row(
          children: [
            Icon(
              punch.type == CreatePunchViewState.PUNCH_IN ? Icons.arrow_back : Icons.arrow_forward,
              size: 15,
              color: punch.type == CreatePunchViewState.PUNCH_IN ? Colors.red : Colors.green,
            ),
            SizedBox(
              width: 10,
            ),
            Text(
              punch.type,
              style: TextStyle(fontSize: 12),
            ),
          ],
        )),
        DataCell(Text(punch.weight.toString() ?? "-")),
        DataCell(Text(DateFormat.yMMMd().format(punch.firstModified))),
        DataCell(IconButton(
          icon: Icon(
            Icons.delete_outline,
            color: Theme.of(context).accentColor,
            size: 15,
          ),
          onPressed: () {
            // deleting punch here.
            deletePunch(punchs[index]).then((value) => updateTable());
          },
        ))
      ],
    );
  }

  Future<void> deletePunch(Punch punch) async {
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
              message: "Are you sure you want to delete punch of\n${punch.employee.name}",
              onYes: () async {
                // Delete punch here.

                String where = "${Punch.ID} = ?";
                List<String> whereArgs = [punch.id]; // Querying only punchs

                List<Punch> deletePunchList = await PunchDAL.find(where: where, whereArgs: whereArgs);

                await PunchDAL.delete(where: where, whereArgs: whereArgs);

                Punch deletePunch = deletePunchList.first;
                if (deletePunch.idFS != null) {
                  Firestore.instance.collection(Punch.COLLECTION_NAME).document(deletePunch.idFS).delete();
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
  int get rowCount => punchs == null ? 0 : punchs.length;

  @override
  bool get isRowCountApproximate => false;

  @override
  int get selectedRowCount => _selectedCount;
}
