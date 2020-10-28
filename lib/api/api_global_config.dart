import 'package:cloud_firestore/cloud_firestore.dart';

class ApiGlobalConfig {
  static const String GLOBAL_KEY_ID = "9NA2lDXNcsU1TlfFDApv";
  static const String GLOBAL_COLLECTION_NAME = "global";
  static get(){


    Firestore.instance
        .collection(GLOBAL_COLLECTION_NAME)
        .document(GLOBAL_KEY_ID)
        .snapshots()
        .listen((DocumentSnapshot globalConfigSnapShot) {

          var globalConfig = globalConfigSnapShot.data;
          print("global config : $globalConfig");
    });
  }
}