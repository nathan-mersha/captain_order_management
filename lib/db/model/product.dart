/// Defines product db.model
class Product {
  static const String COLLECTION_NAME = "product";

  /// Defines key values to extract from a map
  static const String ID = "id";
  static const String NAME = "name";
  static const String TYPE = "type";
  static const String UNIT_OF_MEASUREMENT = "unitOfMeasurement";
  static const String UNIT_PRICE = "unitPrice";
  static const String COLOR_VALUE = "colorValue";
  static const String PAINT_TYPE = "paintType";
  static const String MANUFACTURER = "manufacturer";
  static const String IS_GALLON_BASED = "isGallonBased";
  static const String NOTE = "note";
  static const String QUANTITY_IN_CART = "quantityInCart";
  static const String SUB_TOTAL = "subTotal";
  static const String DELIVERED = "delivered";
  static const String FIRST_MODIFIED = "firstModified";
  static const String LAST_MODIFIED = "lastModified";

  int id;
  String name;
  String type; // paint, other
  String unitOfMeasurement;
  num unitPrice;
  String colorValue;
  String paintType;
  String manufacturer;
  bool isGallonBased;
  String note;
  num quantityInCart;
  num subTotal;
  bool delivered;
  DateTime firstModified;
  DateTime lastModified;

  Product({
    this.id,
    this.name,
    this.type,
    this.unitOfMeasurement,
    this.unitPrice,
    this.colorValue,
    this.paintType,
    this.manufacturer,
    this.isGallonBased,
    this.note,
    this.quantityInCart,
    this.subTotal,
    this.delivered,
    this.firstModified,
    this.lastModified});

  /// Converts Model to Map
  static Map<String, dynamic> toMap(Product product) {
    return product == null ? null : {
      ID: product.id,
      NAME: product.name,
      TYPE: product.type,
      UNIT_OF_MEASUREMENT: product.unitOfMeasurement,
      UNIT_PRICE: product.unitPrice,
      COLOR_VALUE: product.colorValue,
      PAINT_TYPE: product.paintType,
      MANUFACTURER: product.manufacturer,
      IS_GALLON_BASED: product.isGallonBased,
      NOTE: product.note,
      QUANTITY_IN_CART: product.quantityInCart,
      SUB_TOTAL: product.subTotal,
      DELIVERED: product.delivered,
      FIRST_MODIFIED: product.firstModified,
      LAST_MODIFIED: product.lastModified
    };
  }

  /// Converts Map to Model
  static Product toModel(dynamic map) {
    return map == null ? null : Product(
        id: map[ID],
        name: map[NAME],
        type: map[TYPE],
        unitOfMeasurement: map[UNIT_OF_MEASUREMENT],
        unitPrice: map[UNIT_PRICE],
        colorValue: map[COLOR_VALUE],
        paintType: map[PAINT_TYPE],
        manufacturer: map[MANUFACTURER],
        isGallonBased: map[IS_GALLON_BASED],
        note: map[NOTE],
        quantityInCart: map[QUANTITY_IN_CART],
        subTotal: map[SUB_TOTAL],
        delivered: map[DELIVERED],
        firstModified: DateTime(map[FIRST_MODIFIED]),
        lastModified: DateTime(map[LAST_MODIFIED])
    );
  }

  /// Changes List of Map to List of Model
  static List<Product> toModelList(List<dynamic> maps) {
    List<Product> modelList = [];
    maps.forEach((dynamic map) {
      modelList.add(toModel(map));
    });
    return modelList;
  }

  /// Changes List of Model to List of Map
  static List<Map<String, dynamic>> toMapList(List<Product> models) {
    List<Map<String, dynamic>> mapList = [];
    models == null ? [] :
    models.forEach((Product model) {
      mapList.add(toMap(model));
    });
    return mapList;
  }
}
