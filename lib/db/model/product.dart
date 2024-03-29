/// Defines product db.model
class Product {
  static const String COLLECTION_NAME = "product";

  /// Defines key values to extract from a map
  static const String ID = "id";
  static const String ID_FS = "idFs";
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
  static const String STATUS = "status";
  static const String FIRST_MODIFIED = "firstModified";
  static const String LAST_MODIFIED = "lastModified";

  String id;
  String idFS;
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
  String status; // pending completed delivered
  DateTime firstModified;
  DateTime lastModified;

  Product(
      {this.id,
      this.idFS,
      this.name,
      this.type,
      this.unitOfMeasurement,
      this.unitPrice,
      this.colorValue,
      this.paintType,
      this.manufacturer,
      this.isGallonBased,
      this.note,
      this.quantityInCart = 0,
      this.subTotal,
      this.status,
      this.firstModified,
      this.lastModified});

  num calculateSubTotal() {
    num subTotal = unitPrice * quantityInCart;
    this.subTotal = subTotal;
    return subTotal;
  }

  static Product clone(Product p) {
    return Product(
        id: p.id,
        idFS: p.idFS,
        name: p.name,
        type: p.type,
        unitOfMeasurement: p.unitOfMeasurement,
        unitPrice: p.unitPrice,
        colorValue: p.colorValue,
        paintType: p.paintType,
        manufacturer: p.manufacturer,
        isGallonBased: p.isGallonBased,
        note: p.note,
        quantityInCart: p.quantityInCart,
        subTotal: p.subTotal,
        status: p.status,
        firstModified: p.firstModified,
        lastModified: p.lastModified);
  }

  /// Converts Model to Map
  static Map<String, dynamic> toMap(Product product) {
    return product == null
        ? null
        : {
            ID: product.id,
            ID_FS: product.idFS,
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
            STATUS: product.status,
            FIRST_MODIFIED: product.firstModified.toIso8601String(),
            LAST_MODIFIED: product.lastModified.toIso8601String()
          };
  }

  /// Converts Map to Model
  static Product toModel(dynamic map) {
    return map == null
        ? null
        : Product(
            id: map[ID],
            idFS: map[ID_FS],
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
            status: map[STATUS],
            firstModified: DateTime.parse(map[FIRST_MODIFIED]),
            lastModified: DateTime.parse(map[LAST_MODIFIED]));
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
    models == null
        ? []
        : models.forEach((Product model) {
            mapList.add(toMap(model));
          });
    return mapList;
  }
}
