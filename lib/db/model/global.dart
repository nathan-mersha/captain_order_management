/// Defines global db.model
class Global {
  static const String COLLECTION_NAME = "global";

  /// Defines key values to extract from a map
  static const String LOCK_SYSTEM = "lockSystem";

  bool lockSystem;

  Global({
    this.lockSystem,
  });

  /// Converts Model to Map
  static Map<String, dynamic> toMap(Global global) {
    return global == null
        ? null
        : {
            LOCK_SYSTEM: global.lockSystem,
          };
  }

  /// Converts Map to Model
  static Global toModel(dynamic map) {
    return map == null
        ? null
        : Global(
            lockSystem: map[LOCK_SYSTEM],
          );
  }

  /// Changes List of Map to List of Model
  static List<Global> toModelList(List<dynamic> maps) {
    List<Global> modelList = [];
    maps.forEach((dynamic map) {
      modelList.add(toModel(map));
    });
    return modelList;
  }

  /// Changes List of Model to List of Map
  static List<Map<String, dynamic>> toMapList(List<Global> models) {
    List<Map<String, dynamic>> mapList = [];
    models.forEach((Global model) {
      mapList.add(toMap(model));
    });
    return mapList;
  }
}
