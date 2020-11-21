import 'dart:io';
import 'package:captain/widget/c_snackbar.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';
import 'package:captain/global.dart' as global;

class ImportSettings extends StatefulWidget {
  @override
  _ImportSettingsState createState() => _ImportSettingsState();
}

class _ImportSettingsState extends State<ImportSettings> {
  bool _importing = false;
  File restoreFile;

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
                      child: Text(restoreFile == null ? "Pick a file" : restoreFile.path.split("/").last),
                      onPressed: () async {
                        setState(() {
                          _importing = true;
                        });

                        FilePickerResult result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ["db"]);

                        if (result != null) {
                          restoreFile = File(result.files.single.path);
                        }

                        setState(() {
                          _importing = false;
                        });
                      }),
                  SizedBox(
                    height: 40,
                  ),
                  Text(
                    "Your files will be restored to where it was at",
                    style: TextStyle(fontSize: 12, color: Colors.black54),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  restoreFile != null
                      ? Text(
                          DateFormat.yMMMd().format(DateTime.parse(restoreFile.path.split("/").last.replaceAll(".db", ""))),
                          style: TextStyle(fontSize: 13, color: Colors.black87),
                          textAlign: TextAlign.center,
                        )
                      : Container(),
                  SizedBox(
                    height: 10,
                  ),
                  SizedBox(
                    height: 40,
                  ),
                  restoreFile != null
                      ? RaisedButton(
                          color: Colors.red,
                          onPressed: () async {
                            setState(() {
                              _importing = true;
                            });
                            String path = await getDatabasesPath();

                            File copiedFile = await restoreFile.copy("$path/${global.DB_NAME}");
                            copiedFile.rename("$path/${global.DB_NAME}");

                            CNotifications.showSnackBar(
                                context, "Successfuly restored database to : ${DateFormat.yMMMd().format(DateTime.parse(restoreFile.path.split("/").last.replaceAll(".db", "")))}", "success", () {},
                                backgroundColor: Colors.green);

                            setState(() {
                              restoreFile = null;
                              _importing = false;
                            });
                          },
                          child: Text(
                            "Restore",
                            style: TextStyle(color: Colors.white),
                          ))
                      : Container()
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
