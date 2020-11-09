import 'package:captain/db/dal/message.dart';
import 'package:captain/db/model/message.dart';
import 'package:captain/page/message/create_message.dart';
import 'package:captain/page/message/statistics_message.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MessageTable extends StatefulWidget {
  final GlobalKey<CreateMessageViewState> createMessageKey;
  final GlobalKey<StatisticsMessageViewState> statisticsMessageKey;
  final GlobalKey<MessageTableState> messageTableKey;

  const MessageTable({this.messageTableKey, this.createMessageKey, this.statisticsMessageKey}) : super(key: messageTableKey);

  @override
  MessageTableState createState() => MessageTableState();
}

class MessageTableState extends State<MessageTable> {
  int _rowsPerPage;
  int _sortColumnIndex;
  bool _sortAscending = true;
  _MessageDataSource _messageDataSource;

  void _sort<T>(
    Comparable<T> Function(Message d) getField,
    int columnIndex,
    bool ascending,
  ) {
    _messageDataSource._sort<T>(getField, ascending);
    _sortColumnIndex = columnIndex;
    _sortAscending = ascending;
  }

  Future<List<Message>> getListOfMessages() async {
    List<Message> messages = await MessageDAL.find();
    return messages;
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
              future: getListOfMessages(),
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  List<Message> messages = snapshot.data as List<Message>;
                  _MessageDataSource _messageDataSourceVal = _MessageDataSource(context, messages, () {
                    setState(() {
                      // updating table here.
                    });
                  }, widget.createMessageKey);
                  _messageDataSource = _messageDataSourceVal;
                } else {
                  _messageDataSource = _MessageDataSource(context, [], () {
                    setState(() {
                      // updating table here.
                    });
                  }, widget.createMessageKey);
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
                            "List of messages",
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
                                "Loading messages",
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
                        label: Text("to"),
                        onSort: (columnIndex, ascending) {
                          return _sort<String>((d) => d.recipient, columnIndex, ascending);
                        },
                      ),
                      DataColumn(
                        label: Text("message"),
                        onSort: (columnIndex, ascending) => _sort<String>((d) => d.body, columnIndex, ascending),
                      ),
                      DataColumn(
                        label: Text("Date"),
                        onSort: (columnIndex, ascending) => _sort<DateTime>((d) => d.firstModified, columnIndex, ascending),
                      ),
                    ],
                    source: _messageDataSource);
              },
            )
          ],
        ),
      ),
    );
  }
}

class _MessageDataSource extends DataTableSource {
  final BuildContext context;
  final List<Message> messages;
  final Function updateTable;
  final GlobalKey<CreateMessageViewState> createMessageKey;
  _MessageDataSource(this.context, this.messages, this.updateTable, this.createMessageKey);

  void _sort<T>(Comparable<T> Function(Message d) getField, bool ascending) {
    messages.sort((a, b) {
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
    if (index >= messages.length) return null;
    final message = messages[index];
    return DataRow.byIndex(
      index: index,
      cells: [
        DataCell(Text(
          message.recipient ?? '-',
          style: TextStyle(color: Colors.black54),
        )),
        DataCell(
            SizedBox(
              width: 300,
              child: Text(
                message.body ?? '-',
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ), onTap: () {
          createMessageKey.currentState.passForView(message);
        }),
        DataCell(Text(DateFormat.yMMMd().format(message.firstModified), style: TextStyle(color: Colors.black54))),
      ],
    );
  }

  @override
  int get rowCount => messages == null ? 0 : messages.length;

  @override
  bool get isRowCountApproximate => false;

  @override
  int get selectedRowCount => _selectedCount;
}
