import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:captain/db/shared_preference/c_shared_preference.dart';
import 'package:captain/widget/c_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';
import 'package:captain/global.dart' as global;

class ExportSettings extends StatefulWidget {
  @override
  ExportSettingsState createState() => ExportSettingsState();
}

class ExportSettingsState extends State<ExportSettings> {
  bool _exporting = false;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
            width: double.infinity,
            child: Text(
              "Export Database",
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
          absorbing: _exporting,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 15),
            child: Form(
              child: Column(
                children: [
                  OutlineButton(
                      child: _exporting
                          ? SizedBox(
                              width: 10,
                              height: 10,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                          : Text("Export"),
                      onPressed: () async {
                        setState(() {
                          _exporting = true;
                        });

                        await exportData();

                        CNotifications.showSnackBar(context,
                            "Successfully exported data", "success", () {},
                            backgroundColor: Colors.green);
                        setState(() {
                          _exporting = false;
                        });
                        
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
                    "Internal storage / Download /",
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

  static Future<void> exportData({bool deletePreviousVersion = false}) async {
    CSharedPreference cSP = GetCSPInstance.cSharedPreference;

    /// Create export directory
    Directory dir = await getExternalStorageDirectory();
    String exportDirectory =
        "${DateTime.now().toString()}_kapci_backup";
    Directory exportFile = await Directory(
            "${dir.parent.parent.parent.parent.path}/Download/$exportDirectory")
        .create();
    Directory exportPictureFile = await Directory(
            "${dir.parent.parent.parent.parent.path}/Download/$exportDirectory/Pictures")
        .create();
    
    /// Copy Images directory
    Directory imageDirectory = Directory(
        "/storage/emulated/0/Android/data/com.awramarket.captain_order_management/files/Pictures");
    if (imageDirectory.existsSync()) {
      copyDirectory(imageDirectory, exportPictureFile);
    }
    
    /// Copy Database file
    String path = await getDatabasesPath();
    File sourceFile =
        File("$path/${global.DB_NAME}"); // source file
    String newPath = "${exportFile.path}/${global.DB_NAME}";
    await copyFile(sourceFile, newPath);

    /// Deleting previously compressed file
    if(deletePreviousVersion){
      // delete previous version
      try{
        File previousExport = File(cSP.exportPath);
        if(previousExport.existsSync()){
          previousExport.deleteSync();
        }
      }catch(e){}
    }

    /// Compress File
    var encoder = ZipFileEncoder();
    String exportFileZIP = "${exportFile.path}.zip";
    encoder.create(exportFileZIP);

    /// Saving zip export path here
    if(deletePreviousVersion){
      cSP.exportPath = exportFileZIP;
    }

    /// Finalize compressing
    encoder.addDirectory(exportFile);
    encoder.close();
    
    /// Delete Original file
    exportFile.deleteSync(recursive: true);
  }

  static Future<File> copyFile(File sourceFile, String newPath) async {
    final newFile = await sourceFile.copy(newPath);
    return newFile;
  }

  static void copyDirectory(Directory source, Directory destination) =>
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
}
