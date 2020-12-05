import 'package:captain/db/dal/message.dart';
import 'package:captain/db/dal/personnel.dart';
import 'package:captain/db/model/message.dart';
import 'package:captain/db/model/personnel.dart';
import 'package:captain/page/message/statistics_message.dart';
import 'package:captain/page/message/view_message.dart';
import 'package:captain/widget/c_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:sms/sms.dart';

class CreateMessageView extends StatefulWidget {
  final GlobalKey<MessageTableState> messageTableKey;
  final GlobalKey<CreateMessageViewState> createMessageKey;
  final GlobalKey<StatisticsMessageViewState> statisticsMessageKey;

  const CreateMessageView({this.messageTableKey, this.createMessageKey, this.statisticsMessageKey}) : super(key: createMessageKey);

  @override
  CreateMessageViewState createState() => CreateMessageViewState();
}

class CreateMessageViewState extends State<CreateMessageView> {
  final _formKey = GlobalKey<FormState>();
  Message message = Message(recipient: ALL);

  // Recipient types
  static const String ALL = "all"; // values not translatables
  static const String CUSTOMERS = "customers"; // values not translatables
  static const String EMPLOYEES = "employees"; // values not translatables
  List<String> recipientTypes = [ALL, CUSTOMERS, EMPLOYEES];
  Map<String, String> recipientTypeValues;

  // Text editing controllers
  TextEditingController _bodyController = TextEditingController();

  bool _doingCRUD = false;

  @override
  void initState() {
    super.initState();
    // Separating keys to values for translatable.
    // translatable values
    recipientTypeValues = {ALL: "all", CUSTOMERS: "customers", EMPLOYEES: "employees"};
  }

  @override
  void dispose() {
    super.dispose();
    _bodyController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(5))),
      child: Container(
        padding: EdgeInsets.only(bottom: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            SizedBox(
              width: double.infinity,
              child: Card(
                margin: EdgeInsets.all(0),
                color: Theme.of(context).primaryColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(5), topRight: Radius.circular(5))),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                  child: Text(
                    "${message.id == null ? "Create" : "Update"} Message",
                    style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w800),
                  ),
                ),
              ),
            ),
            Container(
                height: 425,
                padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, right: 20, left: 20),
                child: Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        SizedBox(
                          height: 16,
                        ),
                        SizedBox(
                          width: double.infinity,
                          child: DropdownButton(
                              value: message.recipient,
                              hint: Text(
                                "to",
                                style: TextStyle(
                                  fontSize: 12,
                                ),
                              ),
                              isExpanded: true,
                              iconSize: 18,
                              icon: Icon(
                                Icons.keyboard_arrow_down,
                                color: Theme.of(context).primaryColor,
                              ),
                              items: recipientTypes.map<DropdownMenuItem<String>>((String recipientValue) {
                                return DropdownMenuItem(
                                  child: Text(
                                    recipientTypeValues[recipientValue],
                                    style: TextStyle(fontSize: 12),
                                  ),
                                  value: recipientValue,
                                );
                              }).toList(),
                              onChanged: (String newValue) {
                                setState(() {
                                  message.recipient = newValue;
                                });
                              }),
                        ),
                        TextFormField(
                          validator: (nameValue) {
                            if (nameValue.isEmpty) {
                              return "Message must not be empty";
                            } else {
                              return null;
                            }
                          },
                          controller: _bodyController,
                          onChanged: (bodyValue) {
                            message.body = bodyValue;
                          },
                          onFieldSubmitted: (bodyValue) {
                            message.body = bodyValue;
                          },
                          maxLines: 8,
                          maxLength: 160,
                          textAlignVertical: TextAlignVertical.top,
                          decoration: InputDecoration(
                            alignLabelWithHint: true,
                            labelText: "message",
                            contentPadding: EdgeInsets.symmetric(vertical: 5),
                          ),
                        ),
                      ],
                    ),
                  ),
                )),
            Container(
                child: RaisedButton(
              color: Theme.of(context).primaryColor,
              child: _doingCRUD == true
                  ? Container(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 1,
                        backgroundColor: Colors.white,
                      ),
                    )
                  : Text(
                      "Send",
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
              onPressed: () async {
                if (_formKey.currentState.validate()) {
                  createMessage(context);
                }
              },
            )),
          ],
        ),
      ),
    );
  }

  void cleanFields() {
    setState(() {
      /// Clearing data
      _doingCRUD = false;
      message = Message();
      _bodyController.clear();
    });

    /// Notify corresponding widgets.
    widget.messageTableKey.currentState.setState(() {});
    widget.statisticsMessageKey.currentState.setState(() {});
  }

  Future createMessage(BuildContext context) async {
    /// Create Message Message data to local db
    List<String> recipients = await getRecipientPhoneNumbers();

    /// open sms dialog here send sms here.
    if (recipients.isNotEmpty) {
      recipients.forEach((recipient) {
        SmsSender sender = SmsSender();
        SmsMessage m = SmsMessage(recipient, message.body);
        sender.sendSms(m);
      });

      Message createdMessage = await MessageDAL.create(message);
      createInFSAndUpdateLocally(createdMessage);

      /// Showing notification
      CNotifications.showSnackBar(context, "Successfuly created message to ${message.recipient}", "success", () {}, backgroundColor: Colors.green);
      // cleaning fields if device is able to send message
      cleanFields();
    }
  }

  Future createInFSAndUpdateLocally(Message message) async {
    String where = "${Message.ID} = ?";
    List<String> whereArgs = [message.id]; // Querying only messages
    MessageDAL.find(where: where, whereArgs: whereArgs).then((List<Message> message) async {
      Message queriedMessage = message.first;

      /// Creating data to fire store
      // dynamic messageMap = Message.toMap(queriedMessage);
//      DocumentReference docRef = await Firestore.instance.collection(Message.COLLECTION_NAME).add(messageMap);
//      queriedMessage.idFS = docRef.documentID;

      String where = "${Message.ID} = ?";
      List<String> whereArgs = [queriedMessage.id]; // Querying only messages
      MessageDAL.update(where: where, whereArgs: whereArgs, message: queriedMessage);
    });
  }

  Future<List<String>> getRecipientPhoneNumbers() async {
    List<String> recipients = [];
    List<Personnel> personnels;
    if (message.recipient == ALL) {
      personnels = await PersonnelDAL.find();
    } else if (message.recipient == CUSTOMERS) {
      String where = "${Personnel.TYPE} = ?";
      List<String> whereArgs = [Personnel.CUSTOMER]; // Querying only customers
      personnels = await PersonnelDAL.find(where: where, whereArgs: whereArgs);
    } else if (message.recipient == EMPLOYEES) {
      String where = "${Personnel.TYPE} = ?";
      List<String> whereArgs = [Personnel.EMPLOYEE]; // Querying only employees
      personnels = await PersonnelDAL.find(where: where, whereArgs: whereArgs);
    }

    if (personnels != null && personnels.length > 0) {
      personnels.forEach((Personnel personnel) {
        recipients.add(personnel.phoneNumber);
      });
    }

    return recipients;
  }

  void passForView(Message passedMessage) async {
    passedMessage.recipient = null;
    setState(() {
      message = passedMessage;
      _bodyController.text = passedMessage.body;
    });
  }
}
