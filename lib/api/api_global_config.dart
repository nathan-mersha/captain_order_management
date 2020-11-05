import 'package:captain/db/model/global.dart';
import 'package:captain/db/shared_preference/c_shared_preference.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ApiGlobalConfig {
  static const String GLOBAL_KEY_ID = "9NA2lDXNcsU1TlfFDApv";
  static get() {
    Firestore.instance.collection(Global.COLLECTION_NAME).document(GLOBAL_KEY_ID).snapshots().listen((DocumentSnapshot globalConfigSnapShot) {
      Global global = Global.toModel(globalConfigSnapShot.data);
      CSharedPreference cSP = GetCSPInstance.cSharedPreference;

      if (global != null) {
        // Updating system locked status
        cSP.systemLocked = global.lockSystem;
      }
    });
  }
}
