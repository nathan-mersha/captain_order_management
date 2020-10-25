/// Defines message model
class Message {
  static const String COLLECTION_NAME = "message";

  /// Defines key values to extract from a map
  static const String MESSAGE_ID = "messageId";
  static const String RECIPIENT = "recipient";
  static const String BODY = "body";
  static const String FIRST_MODIFIED = "firstModified";
  static const String LAST_MODIFIED = "lastModified";

  String messageId;
  String recipient;
  String body;
  DateTime firstModified;
  DateTime lastModified;

  Message({this.messageId, this.recipient,this.body, this.firstModified, this.lastModified});

  /// Converts Model to Map
  static Map<String, dynamic> toMap(Message message) {
    return {
      MESSAGE_ID: message.messageId,
      RECIPIENT : message.recipient,
      BODY : message.body,
      FIRST_MODIFIED: message.firstModified,
      LAST_MODIFIED: message.lastModified
    };
  }

  /// Converts Map to Model
  static Message toModel(dynamic map) {
    return Message(
        messageId: map[MESSAGE_ID],
        recipient: map[RECIPIENT],
        body: map[BODY],
        firstModified: map[FIRST_MODIFIED],
        lastModified: map[LAST_MODIFIED]);
  }

  /// Changes List of Map to List of Model
  static List<Message> toModelList(List<dynamic> maps) {
    List<Message> modelList = [];
    maps.forEach((dynamic map) {
      modelList.add(toModel(map));
    });
    return modelList;
  }

  /// Changes List of Model to List of Map
  static List<Map<String, dynamic>> toMapList(List<Message> models) {
    List<Map<String, dynamic>> mapList = [];
    models.forEach((Message model) {
      mapList.add(toMap(model));
    });
    return mapList;
  }
}
