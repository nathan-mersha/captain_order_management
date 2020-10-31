//// Copyright 2019 The Flutter team. All rights reserved.
//// Use of this source code is governed by a BSD-style license that can be
//// found in the LICENSE file.
//
//import 'package:flutter/material.dart';
//import 'package:flutter/rendering.dart';
//import 'package:intl/intl.dart';
//
//class DataTableDemo extends StatefulWidget {
//  const DataTableDemo();
//
//  @override
//  _DataTableDemoState createState() => _DataTableDemoState();
//}
//
//class _DataTableDemoState extends State<DataTableDemo> {
//  int _rowsPerPage = PaginatedDataTable.defaultRowsPerPage;
//  int _sortColumnIndex;
//  bool _sortAscending = true;
//  _DessertDataSource _dessertsDataSource;
//
//  @override
//  void didChangeDependencies() {
//    super.didChangeDependencies();
//    _dessertsDataSource ??= _DessertDataSource(context);
//  }
//
//  void _sort<T>(
//      Comparable<T> Function(_Dessert d) getField,
//      int columnIndex,
//      bool ascending,
//      ) {
//    _dessertsDataSource._sort<T>(getField, ascending);
//    setState(() {
//      _sortColumnIndex = columnIndex;
//      _sortAscending = ascending;
//    });
//  }
//
//  @override
//  Widget build(BuildContext context) {
//    return Scaffold(
//      appBar: AppBar(
//        automaticallyImplyLeading: false,
//        title: Text("Data table title"),
//      ),
//      body: Scrollbar(
//        child: ListView(
//          padding: const EdgeInsets.all(16),
//          children: [
//            PaginatedDataTable(
//              header: Text("table header"),
//              rowsPerPage: _rowsPerPage,
//              onRowsPerPageChanged: (value) {
//                setState(() {
//                  _rowsPerPage = value;
//                });
//              },
//              sortColumnIndex: _sortColumnIndex,
//              sortAscending: _sortAscending,
//              onSelectAll: _dessertsDataSource._selectAll,
//              columns: [
//                DataColumn(
//                  label: Text("column desert"),
//                  onSort: (columnIndex, ascending) =>
//                      _sort<String>((d) => d.name, columnIndex, ascending),
//                ),
//                DataColumn(
//                  label: Text("column calories"),
//                  numeric: true,
//                  onSort: (columnIndex, ascending) =>
//                      _sort<num>((d) => d.calories, columnIndex, ascending),
//                ),
//                DataColumn(
//                  label: Text("column fat"),
//                  numeric: true,
//                  onSort: (columnIndex, ascending) =>
//                      _sort<num>((d) => d.fat, columnIndex, ascending),
//                ),
//                DataColumn(
//                  label: Text("column carbs"),
//                  numeric: true,
//                  onSort: (columnIndex, ascending) =>
//                      _sort<num>((d) => d.carbs, columnIndex, ascending),
//                ),
//                DataColumn(
//                  label: Text("column protien"),
//                  numeric: true,
//                  onSort: (columnIndex, ascending) =>
//                      _sort<num>((d) => d.protein, columnIndex, ascending),
//                ),
//                DataColumn(
//                  label: Text("column sodium"),
//                  numeric: true,
//                  onSort: (columnIndex, ascending) =>
//                      _sort<num>((d) => d.sodium, columnIndex, ascending),
//                ),
//                DataColumn(
//                  label: Text("column calcium"),
//                  numeric: true,
//                  onSort: (columnIndex, ascending) =>
//                      _sort<num>((d) => d.calcium, columnIndex, ascending),
//                ),
//                DataColumn(
//                  label: Text("column iron"),
//                  numeric: true,
//                  onSort: (columnIndex, ascending) =>
//                      _sort<num>((d) => d.iron, columnIndex, ascending),
//                ),
//              ],
//              source: _dessertsDataSource,
//            ),
//          ],
//        ),
//      ),
//    );
//  }
//}
//
//class _Dessert {
//  _Dessert(this.name, this.calories, this.fat, this.carbs, this.protein,
//      this.sodium, this.calcium, this.iron);
//  final String name;
//  final int calories;
//  final double fat;
//  final int carbs;
//  final double protein;
//  final int sodium;
//  final int calcium;
//  final int iron;
//
//  bool selected = false;
//}
//
//class _DessertDataSource extends DataTableSource {
//  _DessertDataSource(this.context) {
////    final localizations = GalleryLocalizations.of(context);
//    _desserts = <_Dessert>[
//      _Dessert(
//        "desert name",
//        582,
//        26.0,
//        77,
//        7.0,
//        54,
//        12,
//        6,
//      ),
//    ];
//  }
//
//  final BuildContext context;
//  List<_Dessert> _desserts;
//
//  void _sort<T>(Comparable<T> Function(_Dessert d) getField, bool ascending) {
//    _desserts.sort((a, b) {
//      final aValue = getField(a);
//      final bValue = getField(b);
//      return ascending
//          ? Comparable.compare(aValue, bValue)
//          : Comparable.compare(bValue, aValue);
//    });
//    notifyListeners();
//  }
//
//  int _selectedCount = 0;
//
//  @override
//  DataRow getRow(int index) {
//    final format = NumberFormat.decimalPercentPattern(
//      locale: GalleryOptions.of(context).locale.toString(),
//      decimalDigits: 0,
//    );
//    assert(index >= 0);
//    if (index >= _desserts.length) return null;
//    final dessert = _desserts[index];
//    return DataRow.byIndex(
//      index: index,
//      selected: dessert.selected,
//      onSelectChanged: (value) {
//        if (dessert.selected != value) {
//          _selectedCount += value ? 1 : -1;
//          assert(_selectedCount >= 0);
//          dessert.selected = value;
//          notifyListeners();
//        }
//      },
//      cells: [
//        DataCell(Text(dessert.name)),
//        DataCell(Text('${dessert.calories}')),
//        DataCell(Text(dessert.fat.toStringAsFixed(1))),
//        DataCell(Text('${dessert.carbs}')),
//        DataCell(Text(dessert.protein.toStringAsFixed(1))),
//        DataCell(Text('${dessert.sodium}')),
//        DataCell(Text('${format.format(dessert.calcium / 100)}')),
//        DataCell(Text('${format.format(dessert.iron / 100)}')),
//      ],
//    );
//  }
//
//  @override
//  int get rowCount => _desserts.length;
//
//  @override
//  bool get isRowCountApproximate => false;
//
//  @override
//  int get selectedRowCount => _selectedCount;
//
//  void _selectAll(bool checked) {
//    for (final dessert in _desserts) {
//      dessert.selected = checked;
//    }
//    _selectedCount = checked ? _desserts.length : 0;
//    notifyListeners();
//  }
//}
//
