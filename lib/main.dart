import 'dart:async';
import 'package:flutter/material.dart';
import 'common.dart';
import 'Screens/main_page.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Future<void> getDir() async {
    Common().dirSdCard = (await getExternalStorageDirectory()).path;
  }

  Future<void> getAccess() async {
    PermissionStatus permission = await PermissionHandler()
        .checkPermissionStatus(PermissionGroup.storage);
    if (permission != PermissionStatus.granted) {
      await PermissionHandler().requestPermissions([PermissionGroup.storage]);
    }
    await getDir();
  }

  Future.wait([initializeDateFormatting("en", null), getAccess()])
      .then((result) {
    runApp(MyApp());
  });
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter File Manager',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: FileManager(),
    );
  }
}
