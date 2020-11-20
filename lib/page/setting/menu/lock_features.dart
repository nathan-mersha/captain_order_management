import 'package:captain/db/shared_preference/c_shared_preference.dart';
import 'package:flutter/material.dart';

class LockFeaturesSettings extends StatefulWidget {
  @override
  _LockFeaturesSettingsState createState() => _LockFeaturesSettingsState();
}

class _LockFeaturesSettingsState extends State<LockFeaturesSettings> {
  CSharedPreference cSP = GetCSPInstance.cSharedPreference;

  static const String NAME = "NAME";
  static const String DESCRIPTION = "DESCRIPTION";
  static const String KEY = "KEY";

  List menus = [
    {
      NAME: "Normal Order",
      DESCRIPTION: "create normal order for customers",
      KEY: CSharedPreference.FEATURE_ADMIN_ONLY_ORDER,
    },
    {
      NAME: "Special Order",
      DESCRIPTION: "create special order for customers",
      KEY: CSharedPreference.FEATURE_ADMIN_ONLY_SPECIAL_ORDER,
    },
    {
      NAME: "Products",
      DESCRIPTION: "create your products and paints",
      KEY: CSharedPreference.FEATURE_ADMIN_ONLY_PRODUCT,
    },
    {
      NAME: "Customers",
      DESCRIPTION: "create and manage your customers",
      KEY: CSharedPreference.FEATURE_ADMIN_ONLY_CUSTOMERS,
    },
    {
      NAME: "Returned orders",
      DESCRIPTION: "manage your returned paint orders",
      KEY: CSharedPreference.FEATURE_ADMIN_ONLY_RETURNED_ORDERS,
    },
    {
      NAME: "Employees",
      DESCRIPTION: "create and manage your employees here",
      KEY: CSharedPreference.FEATURE_ADMIN_ONLY_EMPLOYEES,
    },
    {
      NAME: "Punch",
      DESCRIPTION: "manage your paint punches",
      KEY: CSharedPreference.FEATURE_ADMIN_ONLY_PUNCH,
    },
    {
      NAME: "Analysis",
      DESCRIPTION: "view how you are doing overall",
      KEY: CSharedPreference.FEATURE_ADMIN_ONLY_ANALYSIS,
    },
    {
      NAME: "Messages",
      DESCRIPTION: "manage your messages",
      KEY: CSharedPreference.FEATURE_ADMIN_ONLY_MESSAGES,
    }
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: ListView.builder(
          itemCount: menus.length,
          itemBuilder: (context, index) {
            return Container(
              child: ListTile(
                leading: Checkbox(
                  value: getValue(menus[index][KEY]),
                  onChanged: (bool) {
                    setValue(menus[index][KEY], bool);
                  },
                ),
                title: Text(
                  menus[index][NAME],
                  style: TextStyle(fontSize: 13),
                ),
                subtitle: Text(
                  menus[index][DESCRIPTION],
                  style: TextStyle(fontSize: 12),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  bool getValue(String key) {
    if (key == CSharedPreference.FEATURE_ADMIN_ONLY_ORDER) {
      return cSP.featureAdminOnlyOrder;
    } else if (key == CSharedPreference.FEATURE_ADMIN_ONLY_SPECIAL_ORDER) {
      return cSP.featureAdminOnlySpecialOrder;
    } else if (key == CSharedPreference.FEATURE_ADMIN_ONLY_PRODUCT) {
      return cSP.featureAdminOnlyProduct;
    } else if (key == CSharedPreference.FEATURE_ADMIN_ONLY_CUSTOMERS) {
      return cSP.featureAdminOnlyCustomers;
    } else if (key == CSharedPreference.FEATURE_ADMIN_ONLY_RETURNED_ORDERS) {
      return cSP.featureAdminOnlyReturnedOrders;
    } else if (key == CSharedPreference.FEATURE_ADMIN_ONLY_EMPLOYEES) {
      return cSP.featureAdminOnlyEmployees;
    } else if (key == CSharedPreference.FEATURE_ADMIN_ONLY_PUNCH) {
      return cSP.featureAdminOnlyPunch;
    } else if (key == CSharedPreference.FEATURE_ADMIN_ONLY_ANALYSIS) {
      return cSP.featureAdminOnlyAnalysis;
    } else if (key == CSharedPreference.FEATURE_ADMIN_ONLY_MESSAGES) {
      return cSP.featureAdminOnlyMessages;
    } else {
      return false;
    }
  }

  setValue(String key, bool value) {
    if (key == CSharedPreference.FEATURE_ADMIN_ONLY_ORDER) {
      setState(() {
        cSP.featureAdminOnlyOrder = value;
      });
    } else if (key == CSharedPreference.FEATURE_ADMIN_ONLY_SPECIAL_ORDER) {
      setState(() {
        cSP.featureAdminOnlySpecialOrder = value;
      });
    } else if (key == CSharedPreference.FEATURE_ADMIN_ONLY_PRODUCT) {
      setState(() {
        cSP.featureAdminOnlyProduct = value;
      });
    } else if (key == CSharedPreference.FEATURE_ADMIN_ONLY_CUSTOMERS) {
      setState(() {
        cSP.featureAdminOnlyCustomers = value;
      });
    } else if (key == CSharedPreference.FEATURE_ADMIN_ONLY_RETURNED_ORDERS) {
      setState(() {
        cSP.featureAdminOnlyReturnedOrders = value;
      });
    } else if (key == CSharedPreference.FEATURE_ADMIN_ONLY_EMPLOYEES) {
      setState(() {
        cSP.featureAdminOnlyEmployees = value;
      });
    } else if (key == CSharedPreference.FEATURE_ADMIN_ONLY_PUNCH) {
      setState(() {
        cSP.featureAdminOnlyPunch = value;
      });
    } else if (key == CSharedPreference.FEATURE_ADMIN_ONLY_ANALYSIS) {
      setState(() {
        cSP.featureAdminOnlyAnalysis = value;
      });
    } else if (key == CSharedPreference.FEATURE_ADMIN_ONLY_MESSAGES) {
      setState(() {
        cSP.featureAdminOnlyMessages = value;
      });
    }
  }
}
