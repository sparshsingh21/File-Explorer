import 'dart:async';
import 'package:disk_space/disk_space.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:file_exp/common.dart';
import 'package:open_file/open_file.dart';
import 'package:path/path.dart' as d;
import 'package:intl/intl.dart';

class FileManager extends StatefulWidget {
  @override
  _FileManagerState createState() => _FileManagerState();
}

class _FileManagerState extends State<FileManager> {
  double _freeSpace;
  double _totalSpace;
  List<FileSystemEntity> files = [];
  Directory parentDir;
  ScrollController controller = ScrollController();
  List<double> position = [];

  Future<void> initPlatformState() async {
    double freeSpace;
    double totalSpace;
    try {
      freeSpace = await DiskSpace.getFreeDiskSpace;
      totalSpace = await DiskSpace.getTotalDiskSpace;
    } on PlatformException {
      freeSpace = 0;
    }
    if (!mounted) return;

    setState(() {
      _freeSpace = freeSpace / 1024;
      _totalSpace = totalSpace / 1024;
    });
  }

// git push test
  @override
  void initState() {
    super.initState();
    parentDir = Directory(Common().dirSdCard);
    initPathFiles(Common().dirSdCard);
    initPlatformState();
  }

  Future<bool> onWillPop() async {
    if (parentDir.path != Common().dirSdCard) {
      initPathFiles(parentDir.parent.path);
      jumpToPosition(false);
    } else {
      SystemNavigator.pop();
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            parentDir?.path == Common().dirSdCard
                ? 'File Explorer'
                : d.basename(parentDir.path),
            style: TextStyle(color: Colors.black),
          ),
          centerTitle: true,
          backgroundColor: Color(0xffeeeeee),
          elevation: 0.0,
          leading: parentDir?.path == Common().dirSdCard
              ? Container()
              : IconButton(
                  icon: Icon(Icons.chevron_left, color: Colors.black),
                  onPressed: onWillPop),
        ),
        body: files.length == 0
            ? Center(
                child: Center(
                child: Row(
                  children: [
                    Icon(Icons.description),
                    Text('No Directories Found'),
                  ],
                ),
              ))
            : Scrollbar(
                child: ListView.builder(
                  physics: BouncingScrollPhysics(),
                  controller: controller,
                  itemCount: files.length,
                  itemBuilder: (BuildContext context, int index) {
                    if (FileSystemEntity.isFileSync(files[index].path))
                      return _buildFile(files[index]);
                    else
                      return Column(
                        children: <Widget>[
                          if ((index == 0))
                            Text(
                                'Total Space: $_totalSpace GB \n Free Space: $_freeSpace GB'),
                          _buildFolder(files[index]),
                        ],
                      );
                  },
                ),
              ),
      ),
    );
  }

  Widget _buildFile(FileSystemEntity file) {
    String modifiedTime = DateFormat('yyyy-MM-dd HH:mm', 'en')
        .format(file.statSync().modified.toLocal());

    return InkWell(
      child: Container(
        decoration: BoxDecoration(
          border:
              Border(bottom: BorderSide(width: 0.5, color: Color(0xffe5e5e5))),
        ),
        child: ListTile(
          leading: CircleAvatar(
            child: Image.asset(
              Common().iconSelection(
                d.extension(file.path),
              ),
            ),
          ),
          title: Text(file.path.substring(file.parent.path.length + 1)),
          subtitle: Text(
              '$modifiedTime  ${Common().getFileSize(file.statSync().size)}',
              style: TextStyle(fontSize: 12.0)),
        ),
      ),
      onTap: () {
        OpenFile.open(file.path);
      },
      onLongPress: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                CupertinoButton(
                  child: Text('Rename',
                      style: TextStyle(color: Color(0xff333333))),
                  onPressed: () {
                    Navigator.pop(context);
                    renameFile(file);
                  },
                ),
                RaisedButton(
                  child: Text('Delete',
                      style: TextStyle(color: Color(0xff333333))),
                  onPressed: () {
                    Navigator.pop(context);
                    deleteFile(file);
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildFolder(FileSystemEntity file) {
    String modifiedTime = DateFormat('yyyy-MM-dd HH:mm', 'en')
        .format(file.statSync().modified.toLocal());

    return InkWell(
      child: Container(
        decoration: BoxDecoration(
          border:
              Border(bottom: BorderSide(width: 0.5, color: Color(0xffe5e5e5))),
        ),
        child: ListTile(
          leading: Image.asset('assets/images/folder.png'),
          title: Row(
            children: <Widget>[
              Expanded(
                  child:
                      Text(file.path.substring(file.parent.path.length + 1))),
              Text(
                '${_calculateFilesCountByFolder(file)}items',
                style: TextStyle(color: Colors.grey),
              )
            ],
          ),
          subtitle: Text(modifiedTime, style: TextStyle(fontSize: 12.0)),
          trailing: Icon(Icons.chevron_right),
        ),
      ),
      onTap: () {
        position.add(controller.offset);
        initPathFiles(file.path);
        jumpToPosition(true);
      },
      onLongPress: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                RaisedButton(
                  child: Text('Rename',
                      style: TextStyle(color: Color(0xff333333))),
                  onPressed: () {
                    Navigator.pop(context);
                    renameFile(file);
                  },
                ),
                RaisedButton(
                  child: Text('Delete',
                      style: TextStyle(color: Color(0xff333333))),
                  onPressed: () {
                    Navigator.pop(context);
                    deleteFile(file);
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  int _calculatePointBegin(List<FileSystemEntity> fileList) {
    int count = 0;
    for (var v in fileList) {
      if (d.basename(v.path).substring(0, 1) == '.') count++;
    }

    return count;
  }

  int _calculateFilesCountByFolder(Directory path) {
    var dir = path.listSync();
    int count = dir.length - _calculatePointBegin(dir);

    return count;
  }

  void jumpToPosition(bool isEnter) async {
    if (isEnter)
      controller.jumpTo(0.0);
    else {
      try {
        await Future.delayed(Duration(milliseconds: 1));
        controller?.jumpTo(position[position.length - 1]);
      } catch (e) {}
      position.removeLast();
    }
  }

  void initPathFiles(String path) {
    try {
      setState(() {
        parentDir = Directory(path);
        sortFiles();
      });
    } catch (e) {
      print(e);
      print("Directory does not exist！");
    }
  }

  void deleteFile(FileSystemEntity file) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete?'),
          content: Text('Cannot be recovered'),
          actions: <Widget>[
            RaisedButton(
              child: Text('Cancel', style: TextStyle(color: Colors.blue)),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            RaisedButton(
              child: Text('Delete', style: TextStyle(color: Colors.blue)),
              onPressed: () {
                if (file.statSync().type == FileSystemEntityType.directory) {
                  Directory directory = Directory(file.path);
                  directory.deleteSync(recursive: true);
                } else if (file.statSync().type == FileSystemEntityType.file) {
                  file.deleteSync();
                }
                initPathFiles(file.parent.path);
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  void renameFile(FileSystemEntity file) {
    TextEditingController _controller = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Scaffold(
          backgroundColor: Colors.transparent,
          body: Center(
            child: AlertDialog(
              title: Text('Rename File'),
              content: Padding(
                padding: EdgeInsets.only(top: 10.0),
                child: TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(2.0)),
                    hintText: 'Enter new name',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(2.0)),
                    contentPadding: EdgeInsets.all(10.0),
                  ),
                ),
              ),
              actions: <Widget>[
                RaisedButton(
                  child: Text('Cancel', style: TextStyle(color: Colors.blue)),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                RaisedButton(
                  child: Text('Rename', style: TextStyle(color: Colors.blue)),
                  onPressed: () async {
                    String newName = _controller.text;
                    if (newName.trim().length == 0) {
                      SnackBar(
                        content: Text('Name cannot be Empty'),
                      );
                      return;
                    }

                    String newPath = file.parent.path +
                        '/' +
                        newName +
                        d.extension(file.path);
                    file.renameSync(newPath);
                    initPathFiles(file.parent.path);

                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void sortFiles() {
    List<FileSystemEntity> _files = [];
    List<FileSystemEntity> _folder = [];
    for (var p in parentDir.listSync()) {
      if (d.basename(p.path).substring(0, 1) == '.') {
        continue;
      }
      if (FileSystemEntity.isFileSync(p.path))
        _files.add(p);
      else
        _folder.add(p);
    }
    _files.sort((a, b) => a.path.toLowerCase().compareTo(b.path.toLowerCase()));
    _folder
        .sort((a, b) => a.path.toLowerCase().compareTo(b.path.toLowerCase()));
    files.clear();
    files.addAll(_folder);
    files.addAll(_files);
  }
}
