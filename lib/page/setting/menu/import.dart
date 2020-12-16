import 'dart:io';
import 'package:archive/archive.dart';
import 'package:captain/widget/c_snackbar.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as path;
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
              "Restore Database",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w800),
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
                      child: Text(restoreFile == null
                          ? "Pick a file"
                          : restoreFile.path
                              .split("/")
                              .last
                              .replaceAll("_kapci_backup.zip", "")),
                      onPressed: () async {
                        setState(() {
                          _importing = true;
                        });

                        FilePickerResult result = await FilePicker.platform
                            .pickFiles(
                                type: FileType.custom,
                                allowedExtensions: ["zip"]);

                        print("File path : ${result.files.single.path}");
                        if (result.files.single.path
                            .endsWith("_kapci_backup.zip")) {
                          print("File is okay");
                          restoreFile = File(result.files.single.path);
                        } else {
                          restoreFile = null;
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
                  restoreFile != null ? buildRestoreDate() : Container(),
                  SizedBox(
                    height: 10,
                  ),
                  SizedBox(
                    height: 40,
                  ),
                  restoreFile != null
                      ? RaisedButton(
                          color:
                              restoreFile == null ? Colors.black54 : Colors.red,
                          onPressed: () async {
                            if (restoreFile != null) {
                              setState(() {
                                _importing = true;
                              });

                              String picturesPathOriginal =
                                  "/storage/emulated/0/Android/data/com.awramarket.captain_order_management/files/Pictures";

                              /// Delete Current Pictures directory
                              Directory imageDirectoryOld =
                                  Directory(picturesPathOriginal);
                              if (imageDirectoryOld.existsSync()) {
                                imageDirectoryOld.deleteSync(recursive: true);
                              }

                              /// Delete Current DB directory
                              String path = await getDatabasesPath();
                              Directory databaseOld =
                                  Directory("$path/${global.DB_NAME}");
                              if (databaseOld.existsSync()) {
                                databaseOld.deleteSync(recursive: true);
                              }

                              /// Extract file
                              Directory extractDirectory =
                                  await getTemporaryDirectory();
                              // Read the Zip file from disk.
                              final bytes = restoreFile.readAsBytesSync();

                              // Decode the Zip file
                              final archive = ZipDecoder().decodeBytes(bytes);

                              for (final file in archive) {
                                final filename = file.name;
                                if (file.isFile) {
                                  final data = file.content as List<int>;
                                  File("${extractDirectory.path}/$filename")
                                    ..createSync(recursive: true)
                                    ..writeAsBytesSync(data);
                                } else {
                                  Directory(
                                      "${extractDirectory.path}/$filename")
                                    ..create(recursive: true);
                                }
                              }

                              /// Copy pictures
                              await Directory(picturesPathOriginal).create();
                              copyDirectory(
                                  Directory(
                                      "${extractDirectory.path}/${restoreFile.path.split("/").last.replaceAll(".zip", "")}/Pictures"),
                                  Directory(picturesPathOriginal));

                              /// Copy DB
                              String dbPath = await getDatabasesPath();
                              String newPath =
                                  File("$dbPath/${global.DB_NAME}").path;
                              File sourceFile = File(
                                  "${extractDirectory.path}/${restoreFile.path.split("/").last.replaceAll(".zip", "")}/${global.DB_NAME}");
                              await copyFile(sourceFile, newPath);

                              CNotifications.showSnackBar(context,
                                  "Successfuly restored data", "success", () {},
                                  backgroundColor: Colors.green);

                              setState(() {
                                restoreFile = null;
                                _importing = false;
                              });
                            } else {
                              // Something is wrong
                              CNotifications.showSnackBar(
                                  context,
                                  "Invalid format, restore file looks like ***_kapci_backup.zip",
                                  "failed",
                                  () {},
                                  backgroundColor: Colors.red);
                            }
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

  void copyDirectory(Directory source, Directory destination) =>
      source.listSync(recursive: false).forEach((var entity) {
        if (entity is Directory) {
          var newDirectory = Directory(
              path.join(destination.absolute.path, path.basename(entity.path)));
          newDirectory.createSync();

          copyDirectory(entity.absolute, newDirectory);
        } else if (entity is File) {
          entity.copySync(
              path.join(destination.path, path.basename(entity.path)));
        }
      });

  Future<File> copyFile(File sourceFile, String newPath) async {
    final newFile = await sourceFile.copy(newPath);
    return newFile;
  }

  Widget buildRestoreDate() {
    try {
      String dateTimeText =
          restoreFile.path.split("/").last.replaceAll("_kapci_backup.zip", "");
      print("date time text : ${dateTimeText}");
      print("date time now : ${DateTime.now().toString()}");
      return Text(
        DateFormat.yMMMd().format(DateTime.parse(dateTimeText)),
        style: TextStyle(fontSize: 13, color: Colors.black87),
        textAlign: TextAlign.center,
      );
    } catch (e) {
      print("error while date parsing : ${e.toString()}");
      return Text(
        "Invalid Format",
        style: TextStyle(fontSize: 13, color: Colors.black87),
        textAlign: TextAlign.center,
      );
    }
  }
}
