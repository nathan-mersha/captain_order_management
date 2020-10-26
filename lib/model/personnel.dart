/// Defines personnel model
class Personnel {
  static const String COLLECTION_NAME = "personnel";

  /// Defines key values to extract from a map
  static const String PERSONNEL_ID = "personnelId";
  static const String NAME = "name";
  static const String PHONE_NUMBER = "phoneNumber";
  static const String EMAIL = "email";
  static const String ADDRESS = "address";
  static const String ADDRESS_DETAIL = "addressDetail";
  static const String TYPE = "type";
  static const String PROFILE_IMAGE = "profileImage";
  static const String NOTE = "note";
  static const String FIRST_MODIFIED = "firstModified";
  static const String LAST_MODIFIED = "lastModified";

  String personnelId;
  String name;
  String phoneNumber;
  String email;
  String address;
  String addressDetail;
  String type;
  List profileImage;
  String note;
  DateTime firstModified;
  DateTime lastModified;

  Personnel({
    this.personnelId,
    this.name,
    this.phoneNumber,
    this.email,
    this.address,
    this.addressDetail,
    this.type,
    this.profileImage,
    this.note,
    this.firstModified,
    this.lastModified
  });

  /// Converts Model to Map
  static Map<String, dynamic> toMap(Personnel personnel) {
    return {
      PERSONNEL_ID: personnel.personnelId,
      NAME: personnel.name,
      PHONE_NUMBER: personnel.phoneNumber,
      EMAIL: personnel.email,
      ADDRESS: personnel.address,
      ADDRESS_DETAIL: personnel.addressDetail,
      TYPE: personnel.type,
      PROFILE_IMAGE: personnel.profileImage,
      NOTE: personnel.note,
      FIRST_MODIFIED: personnel.firstModified,
      LAST_MODIFIED: personnel.lastModified
    };
  }

  /// Converts Map to Model
  static Personnel toModel(dynamic map) {
    return Personnel(
        personnelId: map[PERSONNEL_ID],
        name: map[NAME],
        phoneNumber: map[PHONE_NUMBER],
        email: map[EMAIL],
        address: map[ADDRESS],
        addressDetail: map[ADDRESS_DETAIL],
        type: map[TYPE],
        profileImage: map[PROFILE_IMAGE],
        note: map[NOTE],
        firstModified: map[FIRST_MODIFIED],
        lastModified: map[LAST_MODIFIED]);
  }

  /// Changes List of Map to List of Model
  static List<Personnel> toModelList(List<dynamic> maps) {
    List<Personnel> modelList = [];
    maps.forEach((dynamic map) {
      modelList.add(toModel(map));
    });
    return modelList;
  }

  /// Changes List of Model to List of Map
  static List<Map<String, dynamic>> toMapList(List<Personnel> models) {
    List<Map<String, dynamic>> mapList = [];
    models.forEach((Personnel model) {
      mapList.add(toMap(model));
    });
    return mapList;
  }
}