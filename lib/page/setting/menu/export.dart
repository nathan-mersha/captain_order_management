import 'dart:io';

import 'package:captain/widget/c_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:captain/global.dart' as global;

class ExportSettings extends StatefulWidget {
  @override
  _ExportSettingsState createState() => _ExportSettingsState();
}

class _ExportSettingsState extends State<ExportSettings> {
  bool _exporting = false;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
            width: double.infinity,
            child: Text(
              "Export Database",
              style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w800),
            ),
            padding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
            color: Colors.black45),
        SizedBox(
          height: 40,
        ),
        AbsorbPointer(
          absorbing: _exporting,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 15),
            child: Form(
              child: Column(
                children: [
                  OutlineButton(
                      child: _exporting ? CircularProgressIndicator() : Text("Export"),
                      onPressed: () async {
                        setState(() {
                          _exporting = true;
                        });
                        String path = await getDatabasesPath();
                        File sourceFile = File("$path/${global.DB_NAME}"); // source file
                        Directory dir = await getExternalStorageDirectory();
                        String newPath = "${dir.path}/${DateTime.now()}.db";
                        await copyFile(sourceFile, newPath);
                        CNotifications.showSnackBar(context, "Successfuly exported database to $newPath", "success", () {}, backgroundColor: Colors.green);
                        setState(() {
                          _exporting = false;
                        });
                      }),

                  SizedBox(height: 40,),
                  Text("Your files will be stored in", style: TextStyle(fontSize: 12, color: Colors.black54),textAlign: TextAlign.center,),
                  SizedBox(height: 10,),
                  Text("Internal storage / Android / data / com.awramarket.captain_order_management /", style: TextStyle(fontSize: 12, color: Colors.black87),textAlign: TextAlign.center,)
                ],
              ),
            ),
          ),
        )
      ],
    );
  }

  Future<File> copyFile(File sourceFile, String newPath) async {
    final newFile = await sourceFile.copy(newPath);
    return newFile;
  }
}
