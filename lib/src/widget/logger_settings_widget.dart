import 'dart:io';
import 'package:aurora_logger/src/logger/logger.dart';
import 'package:aurora_logger/src/logger/logger_storage.dart';
import 'package:aurora_logger/src/widget/log_screen/log_screen.dart';
import 'package:aurora_logger/src/widget/logger_setting_arg.dart';
import 'package:flutter/material.dart';

class LoggerSettingWidget extends StatefulWidget {
  final LoggerSettingArg arg;

  const LoggerSettingWidget(this.arg);

  @override
  _LoggerSettingWidgetState createState() => _LoggerSettingWidgetState();
}

class _LoggerSettingWidgetState extends State<LoggerSettingWidget> {
  final _storage = LoggerStorage();
  bool _debug;
  List<Widget> _logs;

  @override
  void initState() {
    super.initState();
    init();
  }

  init() {
    Future.wait([
      _storage.getDebug(),
      logger.logDir().then((value) => getLogs(value))
    ]).then((value) {
      _debug = (value[0] ?? false) as bool;
      _logs = (value[1] ?? []) as List<Widget>;
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return _debug == null
        ? SizedBox.shrink()
        : Column(
            children: <Widget>[
              ListTile(
                title: Text("Host: " + widget.arg.hostname),
              ),
              CheckboxListTile(
                value: _debug,
                title: Text(widget.arg.labelShowDebugView),
                onChanged: (bool value) {
                  _debug = value;
                  _storage.setDebug(value);
                  setState(() {});
                  logger.enable = value;
                },
              ),
              FlatButton(
                child: Text(widget.arg.labelDeleteAllLogs),
                onPressed: () async {
                  final result = await widget.arg
                      .confirmDialog(widget.arg.hintDeleteAllLogs);
                  if (result == true) {
                    deleteAll();
                  }
                },
              ),
              Expanded(
                child: ListView(
                  children: _logs,
                ),
              )
            ],
          );
  }

  Future<List<Widget>> getLogs(String path) async {
    final dir = Directory(path);
    if (!await dir.exists()) {
      return [];
    }
    var files = (await (await dir.list()).toList());
    Map<FileSystemEntity, FileStat> statMap = {};
    for (var file in files) {
      final stat = await file.stat();
      statMap[file] = stat;
    }
    files.sort((a, b) =>
        a is Directory ? 0 : statMap[a].changed.compareTo(statMap[b].changed));
    final widgets = <Widget>[];
    for (var value in files) {
      if (value is Directory) {
        final children = await getLogs(value.path);
        widgets.add(FolderLogWidget(value, children));
      } else if (value is File) {
        widgets.add(FileLogWidget(value, delete, widget.arg));
      }
    }
    return widgets;
  }

  deleteAll() async {
    final dir = Directory(await logger.logDir());
    await _delete(dir);
    init();
  }

  Future _delete(FileSystemEntity entity) async {
    if (entity is Directory) {
      final children = await entity.list().toList();
      for (var item in children) {
        await _delete(item);
      }
    } else if (entity is File) {
      await entity.delete();
    }
  }

  delete(File file) async {
    await file.delete();
    init();
  }
}

class FileLogWidget extends StatelessWidget {
  final File value;
  final LoggerSettingArg arg;
  final Function(File) onDelete;

  FileLogWidget(this.value, this.onDelete, this.arg);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(Icons.insert_drive_file),
      title: Text(value.path.split(Platform.pathSeparator).last),
      onTap: () => open(context),
    );
  }

  open(BuildContext context) async {
    final content = await value.readAsString();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) {
        return LogScreen(
          value,
          content,
          onDelete,
          arg,
        );
      }),
    );
  }
}

class FolderLogWidget extends StatefulWidget {
  final Directory value;
  final List<Widget> children;

  FolderLogWidget(this.value, this.children);

  @override
  _FolderLogWidgetState createState() => _FolderLogWidgetState();
}

class _FolderLogWidgetState extends State<FolderLogWidget> {
  bool expand = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        ListTile(
          leading: Icon(Icons.folder),
          title: Text(widget.value.path.split(Platform.pathSeparator).last),
          onTap: () => setState(() => expand = !expand),
        ),
        if (expand)
          Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: widget.children,
            ),
          )
      ],
    );
  }
}
