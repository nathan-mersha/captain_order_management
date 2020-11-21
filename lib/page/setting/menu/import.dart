import 'dart:io';

import 'package:captain/widget/c_snackbar.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:captain/global.dart' as global;

class ImportSettings extends StatefulWidget {
  @override
  _ImportSettingsState createState() => _ImportSettingsState();
}

class _ImportSettingsState extends State<ImportSettings> {
  bool _importing = false;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
            width: double.infinity,
            child: Text(
              "Import Database",
              style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w800),
            ),
            padding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
            color: Colors.black45),
        SizedBox(
          height: 40,
        ),
        AbsorbPointer(
          absorbing: _importing,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 15),
            child: Form(
              child: Column(
                children: [
                  OutlineButton(
                      child: Text("Pick a file"),
                      onPressed: () async {
//                        setState(() {
//                          _importing = true;
//                        });

                        print("Picked");
                        FilePickerResult result = await FilePicker.platform.pickFiles();

                        print("result : ${result.names}");
                        if (result != null) {
                          File file = File(result.files.single.path);
                          print("file picked");
                          print(file.path);
                        } else {
                          print("user canceled");
                          // User canceled the picker
                        }

//                        setState(() {
//                          _importing = false;
//                        });
                      }),
                  SizedBox(
                    height: 40,
                  ),
                  Text(
                    "Your files will be stored in",
                    style: TextStyle(fontSize: 12, color: Colors.black54),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    "Internal storage / Android / data / com.awramarket.captain_order_management /",
                    style: TextStyle(fontSize: 12, color: Colors.black87),
                    textAlign: TextAlign.center,
                  )
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
