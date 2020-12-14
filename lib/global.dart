import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

SharedPreferences cSP;
Database db;
String normalOrderSearchHistory;
String specialOrderSearchHistory;
String productSearchHistory;

const String DB_NAME = "captain.db";
