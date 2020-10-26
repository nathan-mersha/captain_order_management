import 'package:shared_preferences/shared_preferences.dart';

class CSharedPreference {
  // Passwords and password settings
  static const MAIN_PASSWORD = "MAIN_PASSWORD";
  static const ADMIN_PASSWORD = "ADMIN_PASSWORD";
  static const MAIN_PASSWORD_ENABLED = "MAIN_PASSWORD_ENABLED";

  // Lock system if deal is broken
  static const LOCK_SYSTEM = "LOCK_SYSTEM";
  static const SEND_NOTIFICATION_AUTOMATICALLY = "SEND_NOTIFICATION_AUTOMATICALLY";

  // User locale
  static const CURRENT_THEME = "CURRENT_THEME";
  static const CURRENT_LANGUAGE = "CURRENT_LANGUAGE";

  // Paint prices
  static const AUTO_CRYL_PRICE_PER_LITTER = "AUTO_CRYL_PRICE_PER_LITTER";
  static const METALIC_PRICE_PER_LITTER = "METALIC_PRICE_PER_LITTER";

  // Enable to allow admin only to the views.
  static const FEATURE_ADMIN_ONLY_ORDER = "FEATURE_ADMIN_ONLY_ORDER";
  static const FEATURE_ADMIN_ONLY_PRODUCT = "FEATURE_ADMIN_ONLY_PRODUCT";
  static const FEATURE_ADMIN_ONLY_EMPLOYEES = "FEATURE_ADMIN_ONLY_EMPLOYEES";
  static const FEATURE_ADMIN_ONLY_CUSTOMERS = "FEATURE_ADMIN_ONLY_CUSTOMERS";
  static const FEATURE_ADMIN_ONLY_RETURNED_ORDERS = "FEATURE_ADMIN_ONLY_RETURNED_ORDERS";
  static const FEATURE_ADMIN_ONLY_PUNCH = "FEATURE_ADMIN_ONLY_PUNCH";
  static const FEATURE_ADMIN_ONLY_ANALYSIS = "FEATURE_ADMIN_ONLY_ANALYSIS";
  static const FEATURE_ADMIN_ONLY_MESSAGES = "FEATURE_ADMIN_ONLY_MESSAGES";
  static const FEATURE_ADMIN_ONLY_SPECIAL_ORDER = "FEATURE_ADMIN_ONLY_SPECIAL_ORDER";
  static const FEATURE_ADMIN_ONLY_SETTINGS = "FEATURE_ADMIN_ONLY_SETTINGS";

  SharedPreferences pref;
  CSharedPreference() {
    initializeSharedPreference();
  }

  void initializeSharedPreference() async {
    pref = await SharedPreferences.getInstance();
  }

  dynamic get(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.get(key);
  }

  // Passwords and password settings
  set mainPassword(String mainPassword) => pref.setString(MAIN_PASSWORD, mainPassword);
  set adminPassword(String adminPassword) => pref.setString(ADMIN_PASSWORD, adminPassword);
  set mainPasswordEnabled(bool mainPasswordEnabled) => pref.setBool(MAIN_PASSWORD_ENABLED, mainPasswordEnabled);

  // Lock system if deal is broken
  set lockSystem(bool lockSystem) => pref.setBool(LOCK_SYSTEM, lockSystem);
  set sendNotificationAutomatically(bool sendNotificationAutomatically) => pref.setBool(SEND_NOTIFICATION_AUTOMATICALLY, sendNotificationAutomatically);

  // User locale
  set currentTheme(String currentTheme) => pref.setString(CURRENT_THEME, currentTheme);
  set currentLanguage(String currentLanguage) => pref.setString(CURRENT_LANGUAGE, currentLanguage);

  // Paint prices
  set autoCrylPricePerLitter(num autoCrylPricePerLitter) => pref.setDouble(AUTO_CRYL_PRICE_PER_LITTER, autoCrylPricePerLitter);
  set metalicPricePerLitter(num metalicPricePerLitter) => pref.setDouble(METALIC_PRICE_PER_LITTER, metalicPricePerLitter);

  // Enable to allow admin only to the views.
  set featureAdminOnlyOrder(bool featureAdminOnlyOrder) => pref.setBool(FEATURE_ADMIN_ONLY_ORDER, featureAdminOnlyOrder);
  set featureAdminOnlyProduct(bool featureAdminOnlyProduct) => pref.setBool(FEATURE_ADMIN_ONLY_PRODUCT, featureAdminOnlyProduct);
  set featureAdminOnlyEmployees(bool featureAdminOnlyEmployees) => pref.setBool(FEATURE_ADMIN_ONLY_EMPLOYEES, featureAdminOnlyEmployees);
  set featureAdminOnlyCustomers(bool featureAdminOnlyCustomers) => pref.setBool(FEATURE_ADMIN_ONLY_CUSTOMERS, featureAdminOnlyCustomers);
  set featureAdminOnlyReturnedOrders(bool featureAdminOnlyReturnedOrders) => pref.setBool(FEATURE_ADMIN_ONLY_RETURNED_ORDERS, featureAdminOnlyReturnedOrders);
  set featureAdminOnlyPunch(bool featureAdminOnlyPunch) => pref.setBool(FEATURE_ADMIN_ONLY_PUNCH, featureAdminOnlyPunch);
  set featureAdminOnlyAnalysis(bool featureAdminOnlyAnalysis) => pref.setBool(FEATURE_ADMIN_ONLY_ANALYSIS, featureAdminOnlyAnalysis);
  set featureAdminOnlyMessages(bool featureAdminOnlyMessages) => pref.setBool(FEATURE_ADMIN_ONLY_MESSAGES, featureAdminOnlyMessages);
  set featureAdminOnlySpecialOrder(bool featureAdminOnlySpecialOrder) => pref.setBool(FEATURE_ADMIN_ONLY_SPECIAL_ORDER, featureAdminOnlySpecialOrder);
  set featureAdminOnlySettings(bool featureAdminOnlySettings) => pref.setBool(FEATURE_ADMIN_ONLY_SETTINGS, featureAdminOnlySettings);


  String get mainPassword => pref.getString(MAIN_PASSWORD) ?? "main";
  String get adminPassword => pref.getString(ADMIN_PASSWORD) ?? "admin";
  bool get mainPasswordEnabled => pref.getBool(MAIN_PASSWORD_ENABLED) ?? true;
  
  bool get lockSystem => pref.getBool(LOCK_SYSTEM) ?? false;
  bool get sendNotificationAutomatically => pref.getBool(SEND_NOTIFICATION_AUTOMATICALLY) ?? true;
  
  String get currentTheme => pref.getString(CURRENT_THEME) ?? "weyne"; // todo : move default value to theme page reference
  String get currentLanguage => pref.getString(CURRENT_LANGUAGE) ?? "en"; // todo : move default value to language page reference
  
  num get autoCrylPricePerLitter => pref.getDouble(AUTO_CRYL_PRICE_PER_LITTER) ?? 950;
  num get metalicPricePerLitter => pref.getDouble(METALIC_PRICE_PER_LITTER) ?? 800;

  bool get featureAdminOnlyOrder => pref.getBool(FEATURE_ADMIN_ONLY_ORDER) ?? false;
  bool get featureAdminOnlyProduct => pref.getBool(FEATURE_ADMIN_ONLY_PRODUCT) ?? false;
  bool get featureAdminOnlyEmployees => pref.getBool(FEATURE_ADMIN_ONLY_EMPLOYEES) ?? false;
  bool get featureAdminOnlyCustomers => pref.getBool(FEATURE_ADMIN_ONLY_CUSTOMERS) ?? false;
  bool get featureAdminOnlyReturnedOrders => pref.getBool(FEATURE_ADMIN_ONLY_RETURNED_ORDERS) ?? false;
  bool get featureAdminOnlyPunch => pref.getBool(FEATURE_ADMIN_ONLY_PUNCH) ?? false;
  bool get featureAdminOnlyAnalysis => pref.getBool(FEATURE_ADMIN_ONLY_ANALYSIS) ?? false;
  bool get featureAdminOnlyMessages => pref.getBool(FEATURE_ADMIN_ONLY_MESSAGES) ?? false;
  bool get featureAdminOnlySpecialOrder => pref.getBool(FEATURE_ADMIN_ONLY_SPECIAL_ORDER) ?? true;
  bool get featureAdminOnlySettings => pref.getBool(FEATURE_ADMIN_ONLY_SETTINGS) ?? false;

}

class GetCSPInstance {
  static CSharedPreference cSharedPreference = CSharedPreference();
}